import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:freeflow/widgets/record_button.dart';
import 'package:freeflow/widgets/timer.dart';
import 'package:go_router/go_router.dart';

class CreateShortScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateShortScreen();
}

class RecordingSegment {
  final XFile file;
  final double duration;

  RecordingSegment(this.file, this.duration);
}

class _CreateShortScreen extends State<CreateShortScreen> {
  CameraController? controller;
  int camera = 1;
  int recording_start = 0;
  List<RecordingSegment> clips = List.empty();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          key: Key("camera-${camera}"),
          future: () async {
            final cams = await availableCameras();
            if (controller == null) {
              controller = CameraController(cams[camera], ResolutionPreset.high,
                  fps: 30);
              await controller!.initialize();
            }
          }(),
          builder: (ctx, data) {
            return Container(
              color: Color.fromARGB(255, 0, 0, 0),
              child: controller != null
                  ? SizedBox.expand(
                      child: CameraPreview(
                        controller!,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      BasicButton.text(
                                        "Next",
                                        onTap: () => ctx.go("/create/preview",
                                            extra: clips),
                                        fontSize: 16,
                                        margin: EdgeInsets.only(right: 5),
                                      )
                                    ],
                                  ),
                                  Center(child: _recordButton(context)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
            );
          }),
    );
  }

  Widget _recordButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) {
        if (!controller!.value.isRecordingVideo) {
          controller!.startVideoRecording().then((_) {
            setState(() {
              recording_start = DateTime.now().millisecondsSinceEpoch;
            });
            print("Recording started");
          }).catchError((e) {
            print("recording error ${e}");
          });
        }
      },
      onTapUp: (d) {
        controller!.stopVideoRecording().then((f) {
          setState(() {
            final duration = recording_start != 0
                ? (DateTime.now().millisecondsSinceEpoch - recording_start) /
                    1000.0
                : 0.0;
            recording_start = 0;
            clips = List.from([...clips, RecordingSegment(f, duration)]);
          });
        });
      },
      child: TimerWidget(
        Duration(milliseconds: 250),
        (ctx) {
          final duration = recording_start != 0
              ? (DateTime.now().millisecondsSinceEpoch - recording_start) /
                  1000.0
              : 0.0;
          final totalDuration =
              duration + clips.fold(0.0, (acc, v) => acc + v.duration);
          return RecordButton(
            progress: totalDuration / 60,
          );
        },
      ),
    );
  }
}
