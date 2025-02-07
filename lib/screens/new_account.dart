import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk/shared/nips/nip01/key_pair.dart';

class NewAccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewAccountScreen();
}

class _NewAccountScreen extends State<NewAccountScreen> {
  TextEditingController _name = TextEditingController();
  String? _avatar;
  String? _error;
  KeyPair _privateKey = Bip340.generatePrivateKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
        child: Column(
          spacing: 40,
          children: [
            GestureDetector(
              onTap: () {
                _uploadAvatar().catchError((e) {
                  setState(() {
                    if (e is String) {
                      _error = e;
                    }
                  });
                });
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(200)),
                  color: Color.fromARGB(100, 50, 50, 50),
                ),
                child: Center(child: Text("Upload Avatar")),
              ),
            ),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: "Username",
              ),
            ),
            BasicButton.text("Login", onTap: () {
              _login().then((_) {
                GetIt.I.get<LoginData>().value =
                    Account.privateKeyHex(_privateKey.privateKey!);
                context.go("/");
              }).catchError((e) {
                setState(() {
                  if (e is String) {
                    _error = e;
                  }
                });
              });
            }),
            if (_error != null) Text(_error!),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAvatar() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final upload =
          await ndk.blossom.uploadBlob(data: await file.readAsBytes());
      setState(() {
        _avatar = upload.first.descriptor!.url;
      });
    }
  }

  Future<void> _login() async {
    final meta = Metadata(
      pubKey: _privateKey.publicKey,
      name: _name.text,
      picture: _avatar,
    );

    final profile = meta.toEvent();
    profile.sign(_privateKey.privateKey!);

    final relays = Nip65.fromMap(
      _privateKey.publicKey,
      Map.fromEntries(
        DEFAULT_RELAYS.map(
          (r) => MapEntry(r, ReadWriteMarker.readWrite),
        ),
      ),
    );
    final relayEvent = relays.toEvent();
    relayEvent.sign(_privateKey.privateKey!);

    await ndk.userRelayLists
        .setInitialUserRelayList(UserRelayList.fromNip65(relays));
    await ndk.broadcast.broadcast(
      nostrEvent: profile,
      specificRelays: DEFAULT_RELAYS,
    );
  }
}
