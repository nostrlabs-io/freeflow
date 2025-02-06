import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:freeflow/screens/create.dart';
import 'package:video_player/video_player.dart';

class CreatePreview extends StatefulWidget {
  final List<RecordingSegment> segments;

  CreatePreview(this.segments);

  @override
  State<StatefulWidget> createState() => _CreatePreview();
}

class _CreatePreview extends State<CreatePreview> {
  late VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    controller =
        VideoPlayerController.file(File(widget.segments.first.file.path));
    controller!.setLooping(true);
    controller!.initialize().then((_) => controller!.play());
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return VideoPlayer(controller!);
    }
    return SizedBox.shrink();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}
