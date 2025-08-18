import 'package:flutter/widgets.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/widgets/actions_toolbar.dart';
import 'package:freeflow/widgets/error.dart';
import 'package:freeflow/widgets/short_video_placeholder.dart';
import 'package:freeflow/widgets/video_description.dart';
import 'package:ndk/ndk.dart';
import 'package:video_player/video_player.dart';

class ShortVideoPlayer extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool willHaveController;
  final Video video;

  ShortVideoPlayer(this.video,
      {this.controller, this.willHaveController = false});

  @override
  State<StatefulWidget> createState() => _ShortVideoPlayer();
}

class _ShortVideoPlayer extends State<ShortVideoPlayer> {
  VideoPlayerController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null &&
        widget.video.url != null &&
        !widget.willHaveController) {
      if (_controller != null) {
        _controller!.dispose();
      }

      () async {
        try {
          final controller = VideoPlayerController.networkUrl(
              Uri.parse(widget.video.url!),
              httpHeaders: Map.from({"user-agent": USER_AGENT}));
          await controller.initialize();
          await controller.setLooping(true);
          await controller.play();
          setState(() {
            _controller = controller;
            _error = null;
          });
        } catch (e) {
          setState(() {
            _error = e.toString();
          });
        }
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

  Widget _inner() {
    final con = widget.controller ?? _controller;
    if (con != null) {
      return SizedBox.expand(
          child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: con.value.size.width,
          height: con.value.size.height,
          child: VideoPlayer(con),
        ),
      ));
    }
    if (_error != null) {
      return SizedBox.expand(
        child: Center(
          child: ErrorText(_error!),
        ),
      );
    }
    return ShortVideoPlaceholder(widget.video);
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
          child: _inner(),
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
