import 'package:flutter/widgets.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/widgets/actions_toolbar.dart';
import 'package:freeflow/widgets/short_video_placeholder.dart';
import 'package:freeflow/widgets/video_description.dart';
import 'package:ndk/ndk.dart';
import 'package:video_player/video_player.dart';

class ShortVideoPlayer extends StatefulWidget {
  final VideoPlayerController? controller;
  final Video video;

  ShortVideoPlayer(this.video, {this.controller});

  @override
  State<StatefulWidget> createState() => _ShortVideoPlayer();
}

class _ShortVideoPlayer extends State<ShortVideoPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null && widget.video.url != null) {
      if (_controller != null) {
        _controller!.dispose();
      }
      _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.url!),
          httpHeaders: Map.from({"user-agent": USER_AGENT}));
      () async {
        await _controller!.initialize();
        await _controller!.setLooping(true);
        await _controller!.play();
        setState(() {
          // nothing
        });
      }();
    } else if (widget.controller != null &&
        !widget.controller!.value.isPlaying) {
      widget.controller!.play();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final con = widget.controller ?? _controller;
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (con != null) {
              if (con.value.isPlaying) {
                con.pause();
              } else {
                con.play();
              }
            }
          },
          child: con != null
              ? SizedBox.expand(
                  child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: con.value.size.width,
                    height: con.value.size.height,
                    child: VideoPlayer(con),
                  ),
                ))
              : ShortVideoPlaceholder(widget.video),
        ),
        FutureBuilder(
          future: ndk.metadata.loadMetadata(widget.video.user),
          builder: (state, data) => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VideoDescription(
                      data.data ?? Metadata(pubKey: widget.video.user),
                      widget.video.videoTitle),
                  ActionsToolbar(widget.video,
                      data.data ?? Metadata(pubKey: widget.video.user)),
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        )
      ],
    );
  }
}
