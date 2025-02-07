import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/view_model/feed_viewmodel.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:freeflow/widgets/short_video.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

enum FeedTab { Following, Latest }

class _FeedScreenState extends State<FeedScreen> {
  FeedTab _tab = FeedTab.Latest;

  @override
  void initState() {
    WakelockPlus.enable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final acc = GetIt.I.get<LoginData>().value;
    return Stack(
      children: [
        PageView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            final feedViewModel = GetIt.instance<FeedViewModel>();
            if (index == 0) {
              return FutureBuilder<List<Video>>(
                key: Key("feed-view:${_tab.name}"),
                future: () async {
                  final authors =
                      acc?.pubkey != null && _tab == FeedTab.Following
                          ? (await ndk.follows.getContactList(acc!.pubkey))
                              ?.contacts
                          : null;
                  feedViewModel.reset();
                  print(
                      "Loading feed ${_tab.name}, authors=${authors?.length}");
                  return await feedViewModel.loadVideoData(authors);
                }(),
                builder: (ctx, data) {
                  final videos = data.data;
                  return PageView.builder(
                    controller: PageController(
                      initialPage: feedViewModel.currentVideoIndex,
                      viewportFraction: 1,
                    ),
                    itemCount: videos?.length ?? 0,
                    onPageChanged: (index) {
                      index = index % (videos?.length ?? 1);
                      feedViewModel.changeVideo(index);
                    },
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      index = index % (videos?.length ?? 1);
                      return FutureBuilder(
                          future: feedViewModel.loadVideo(index),
                          builder: (ctx, data) {
                            final vid = videos != null && videos.length > index
                                ? videos[index]
                                : null;
                            if (vid == null) {
                              return SizedBox.shrink();
                            } else {
                              return ShortVideoPlayer(
                                vid,
                                controller: data.data,
                              );
                            }
                          });
                    },
                  );
                },
              );
            } else {
              final vid = feedViewModel.currentVideo!;
              return FutureBuilder(
                  key: Key("profile-card:${vid.user}"),
                  future: ndk.metadata.loadMetadata(vid.user),
                  builder: (ctx, data) {
                    return SafeArea(
                      child: ProfileWidget(
                        profile: data.data ?? Metadata(pubKey: vid.user),
                      ),
                    );
                  });
            }
          },
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ...(acc != null
                    ? [
                        GestureDetector(
                          onTap: () => setState(() {
                            _tab = FeedTab.Following;
                          }),
                          child: Text(
                            'Following',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: _tab == FeedTab.Following
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _tab == FeedTab.Following
                                    ? Colors.white
                                    : Colors.white70),
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Container(
                          color: Colors.white70,
                          height: 10,
                          width: 1.0,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                      ]
                    : []),
                GestureDetector(
                  onTap: () => setState(() {
                    _tab = FeedTab.Latest;
                  }),
                  child: Text(
                    "Latest",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: _tab == FeedTab.Latest
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _tab == FeedTab.Latest
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    final feedViewModel = GetIt.instance<FeedViewModel>();
    feedViewModel.reset();
    super.dispose();
  }
}
