import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/screens/create.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class CreatePreview extends StatefulWidget {
  final List<RecordingSegment> segments;

  CreatePreview(this.segments);

  @override
  State<StatefulWidget> createState() => _CreatePreview();
}

class _CreatePreview extends State<CreatePreview> {
  VideoPlayerController? controller;
  MediaInfo? _finalFile;
  double _progress = 0;
  String? _error;
  TextEditingController _description = TextEditingController();
  static String _videoServer = "https://nostr.download";

  @override
  void initState() {
    super.initState();

    // concat segments and load player
    _concatSegments();
  }

  Future<void> _concatSegments() async {
    final sub = VideoCompress.compressProgress$.subscribe((d) {
      setState(() {
        _progress = d;
      });
    });
    final res = await VideoCompress.compressVideo(
        widget.segments.map((s) => s.file.path).toList());
    if (res == null) {
      print("Transcoding failed");
      sub.unsubscribe();
      return;
    }
    setState(() {
      _finalFile = res;
    });
    sub.unsubscribe();
    controller = VideoPlayerController.file(File(res.path!));
    controller!.setLooping(true);
    await controller!.initialize();
    await controller!.setVolume(0);
    await controller!.play();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
          spacing: 10,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: TextField(
                    controller: _description,
                    minLines: 5,
                    maxLines: 8,
                    decoration: InputDecoration(labelText: "Description"),
                  ),
                ),
                SizedBox.fromSize(child: _player(), size: Size(120, 150))
              ],
            ),
            Expanded(
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...(_error != null
                      ? [
                          Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ]
                      : []),
                  BasicButton.text("Post", onTap: () {
                    if (_description.text.length > 4 && _finalFile != null) {
                      _postShort(_description.text, _finalFile!, _videoServer)
                          .then((e) {
                        context.push("/e/${Nip19.encodeNoteId(e.id)}", extra: e);
                      }).catchError((e) {
                        setState(() {
                          _error = e.toString();
                        });
                      });
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Nip01Event> _postShort(
      String description, MediaInfo videoFile, String server) async {
    final acc = GetIt.I.get<LoginData>().value;
    if (acc == null) {
      throw "Not logged in";
    }
    setState(() {
      _error = null;
    });

    final upload = await ndk.blossom.uploadBlob(
        data: await videoFile.file!.readAsBytes(),
        serverUrls: [server],
        contentType: "video/mp4");
    final mainUpload = upload.first;
    if (mainUpload.descriptor == null) {
      throw mainUpload.error!;
    }
    final ev =
        Nip01Event(pubKey: acc.pubkey, kind: 22, content: description, tags: [
      [
        "imeta",
        "url ${mainUpload.descriptor!.url}",
        "dim ${videoFile.width}x${videoFile.height}",
        "duration ${(videoFile.duration ?? 0) / 1000}",
        "x ${mainUpload.descriptor!.sha256}",
        "m ${mainUpload.descriptor!.type}",
        "size ${mainUpload.descriptor!.size}"
      ]
    ]);

    print(ev);
    await ndk.broadcast
        .broadcast(nostrEvent: ev, specificRelays: DEFAULT_RELAYS);
    return ev;
  }

  Widget _player() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color.fromARGB(200, 0, 0, 0),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: controller != null
          ? VideoPlayer(controller!)
          : Center(child: CircularProgressIndicator(value: _progress / 100)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}
