import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:freeflow/widgets/short_video.dart';
import 'package:freeflow/widgets/short_video_placeholder.dart';
import 'package:ndk/ndk.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

enum FeedTab { Following, Latest }

class _FeedScreenState extends State<FeedScreen> {
  Map<String, VideoPlayerController> _contollers = Map();
  PageController _videoPage = PageController();
  FeedTab _tab = FeedTab.Latest;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  Video? _getVideo(List<Video>? videos, int index) {
    final i = index % (videos?.length ?? 1);
    return videos?[i];
  }

  Future<void> _changePlayer(List<Video>? videos, int index) async {
    final toRemove = List.empty(growable: true);
    for (final e in _contollers.entries) {
      final eIndex = videos?.indexWhere((v) => v.url == e.key) ?? -1;
      // pause if index off screen
      if ((eIndex - index).abs() > 1) {
        toRemove.add(e.key);
      }
      if (eIndex != index) {
        await e.value.pause();
      }
    }
    for (final rem in toRemove) {
      print("PLAYER: removing ${rem}");
      final c = _contollers.remove(rem);
      c?.dispose();
    }
  }

  Future<VideoPlayerController?> _loadVideo(Video vid) async {
    if (vid.url != null) {
      final existing = _contollers[vid.url!];
      if (existing != null) {
        return existing;
      } else {
        print("PLAYER: loading ${vid.url}");
        final c = VideoPlayerController.networkUrl(Uri.parse(vid.url!));
        _contollers[vid.url!] = c;
        await c.initialize();
        await c.setLooping(true);
        await c.play();
        return c;
      }
    }
    return null;
  }

  /**
   * Main player scroller
   */
  Widget _tabPlayer() {
    final acc = ndk.accounts.getPublicKey();
    return RxFutureFilter<Video>(
      key: Key("feed-view:${_tab.name}"),
      leaveOpen: false,
      mapper: (e) => Video.fromEvent(e),
      filterBuilder: () async {
        final authors = acc != null && _tab == FeedTab.Following
            ? (await ndk.follows.getContactList(acc))?.contacts
            : null;
        return Filter(kinds: SHORT_KIND, authors: authors, limit: 50);
      },
      builder: (ctx, data) {
        final videos = data;
        if (videos != null) {
          videos.sort((a, b) => b.event.createdAt.compareTo(a.event.createdAt));
        }
        return PageView.builder(
          controller: _videoPage,
          itemCount: videos?.length ?? 0,
          scrollDirection: Axis.vertical,
          onPageChanged: (idx) {
            _changePlayer(videos, idx);
          },
          itemBuilder: (context, index) {
            if (videos == null) return SizedBox();
            final vid = _getVideo(videos, index);
            if (vid == null) return SizedBox();

            return FutureBuilder(
              future: _loadVideo(vid),
              builder: (ctx, data) {
                if (data.data == null) {
                  return ShortVideoPlaceholder(vid);
                } else {
                  final controller = data.data!;
                  return PageView.builder(
                    itemCount: 2,
                    onPageChanged: (idx) {
                      if (idx != 0) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ShortVideoPlayer(
                          vid,
                          controller: controller,
                        );
                      } else {
                        return FutureBuilder(
                          key: Key("profile-card:${vid.user}"),
                          future: ndk.metadata.loadMetadata(vid.user),
                          builder: (ctx, data) {
                            return SafeArea(
                              child: ProfileWidget(
                                profile:
                                    data.data ?? Metadata(pubKey: vid.user),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final acc = ndk.accounts.getPublicKey();
    return Stack(
      children: [
        _tabPlayer(),
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
  void deactivate() {
    super.deactivate();
    _contollers.values.forEach((c) => c.pause());
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    _contollers.values.forEach((c) => c.dispose());
  }
}
