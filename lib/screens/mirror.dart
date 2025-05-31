import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

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
            if (_job == null)
              TextField(
                controller: _controller,
                readOnly: _job != null,
                decoration: InputDecoration(labelText: "TikTok URL"),
              ),
            if (_job == null)
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
                    _controller.clear();
                    _error = null;
                    _job = ev.publishEvent.id;
                  });
                } catch (e) {
                  setState(() {
                    _error = e.toString();
                  });
                }
              }),
            if (_job != null) Center(child: CircularProgressIndicator()),
            if (_job != null)
              RxFilter<Nip01Event>(
                  filters: [
                    Filter(kinds: [7000], eTags: [_job!])
                  ],
                  builder: (context, state) {
                    final latest = (state ?? <Nip01Event>[])
                        .sortedBy<num>((k) => k.createdAt)
                        .lastOrNull;
                    if (latest == null) return SizedBox();
                    final status = latest.getFirstTag("status");
                    if (status == "success") {
                      setState(() {
                        _error = null;
                        _job = null;
                      });
                    }
                    return Text("Status: ${status}");
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
