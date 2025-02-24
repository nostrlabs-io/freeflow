import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:freeflow/widgets/record_button.dart';
import 'package:freeflow/widgets/timer.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
  int camera = -1;
  CameraDescription? current_camera;
  List<CameraDescription> cameras = List.empty();
  int recording_start = 0;
  List<RecordingSegment> clips = List.empty();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    availableCameras().then((c) {
      setState(() {
        cameras = c;
      });
      _cycleCamera();
    });
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }

  void _cycleCamera() {
    if (cameras.length > 0)
      setState(() {
        camera = camera + 1;
        current_camera = cameras[camera % cameras.length];
        if (controller != null) {
          controller!.dispose();
          controller = null;
        }
        controller = CameraController(current_camera!, ResolutionPreset.high);
        controller!.initialize().then((_) {
          setState(() {});
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color.fromARGB(255, 0, 0, 0),
        child: (controller?.value.isInitialized ?? false)
            ? SizedBox.expand(
                child: ValueListenableBuilder(
                  valueListenable: controller!,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            IconButton.filled(
                              color: Color.fromARGB(255, 255, 255, 255),
                              onPressed: () => _cycleCamera(),
                              icon: Icon(Icons.cameraswitch),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                BasicButton.text(
                                  "Next",
                                  onTap: () =>
                                      context.push("/create/preview", extra: clips),
                                  fontSize: 16,
                                  margin: EdgeInsets.only(right: 5),
                                ),
                              ],
                            ),
                            Center(child: _recordButton(context)),
                          ],
                        )
                      ],
                    ),
                  ),
                  builder: (ctx, data, child) {
                    return Stack(
                      children: [
                        RotatedBox(
                          quarterTurns:
                              ((current_camera?.sensorOrientation ?? 0) / 90)
                                  .floor(),
                          child: controller!.buildPreview(),
                        ),
                        child!
                      ],
                    );
                  },
                ),
              )
            : null,
      ),
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
