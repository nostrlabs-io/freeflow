import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';

class MirrorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MirrorPage();
}

class _MirrorPage extends State<MirrorPage> {
  late final TextEditingController _controller;
  String? _error;
  String? _job;

  @override
  void initState() {
    _controller = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mirror TikTok short",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Text("The short video will be posted by a DVM"),
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "TikTok URL"),
            ),
            BasicButton.text("Post", onTap: () async {
              try {
                final u = Uri.parse(_controller.text);
                if (!u.host.endsWith("tiktok.com")) {
                  throw "Not a TikTok URL";
                }
                final uClean =
                    Uri(scheme: u.scheme, host: u.host, path: u.path);
                final tmpKey = Bip340.generatePrivateKey();
                final ev = await ndk.broadcast.broadcast(
                  nostrEvent: Nip01Event(
                    pubKey: tmpKey.publicKey,
                    kind: 5205,
                    tags: [
                      ["i", uClean.toString(), "url"]
                    ],
                    content: "",
                  ),
                  specificRelays: DEFAULT_RELAYS,
                  customSigner: Bip340EventSigner(
                    privateKey: tmpKey.privateKey,
                    publicKey: tmpKey.publicKey,
                  ),
                );
                setState(() {
                  _error = null;
                  _job = ev.publishEvent.id;
                });
              } catch (e) {
                setState(() {
                  _error = e.toString();
                });
              }
            }),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
              )
          ],
        ),
      ),
    );
  }
}
