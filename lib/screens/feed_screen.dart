import 'dart:developer' as developer;

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
  final Future<Filter> Function() feedBuilder;

  FeedScreen(this.feedBuilder, {Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Map<String, VideoPlayerController> _contollers = Map();
  PageController _videoPage = PageController();

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
      developer.log("PLAYER: removing ${rem}");
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
        developer.log("PLAYER: loading ${vid.url}");
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

  Widget build(BuildContext context) {
    return RxFutureFilter<Video>(
      leaveOpen: false,
      mapper: (e) => Video.fromEvent(e),
      filterBuilder: widget.feedBuilder,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (!(route?.isCurrent ?? false)) {
      _contollers.values.forEach((c) => c.pause());
    }
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    _contollers.values.forEach((c) => c.dispose());
    _contollers.clear();
  }
}
