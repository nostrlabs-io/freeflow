import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/view_model/feed_viewmodel.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/actions_toolbar.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:freeflow/widgets/video_description.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

enum FeedTab { Following, Latest }

class _FeedScreenState extends State<FeedScreen> {
  FeedTab _tab = FeedTab.Latest;

  @override
  Widget build(BuildContext context) {
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
                  final acc = GetIt.I.get<LoginData>().value;
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
                              return videoCard(context, vid, data.data);
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

  Widget videoCard(
      BuildContext context, Video video, VideoPlayerController? controller) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (controller != null) {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            }
          },
          child: controller != null
              ? SizedBox.expand(
                  child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ))
              : SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: CachedNetworkImage(
                      imageUrl:
                          proxyImg(context, video.image ?? video.url ?? ""),
                    ),
                  ),
                ),
        ),
        FutureBuilder(
          future: ndk.metadata.loadMetadata(video.user),
          builder: (state, data) => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  VideoDescription(data.data ?? Metadata(pubKey: video.user),
                      video.videoTitle),
                  ActionsToolbar(video.likes, video.comments,
                      data.data ?? Metadata(pubKey: video.user)),
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    final feedViewModel = GetIt.instance<FeedViewModel>();
    feedViewModel.reset();
    super.dispose();
  }
}
