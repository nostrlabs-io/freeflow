
import 'dart:io';

import 'package:amberflutter/amberflutter.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final _key = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipOval(
                  child: Image(
                    image: AssetImage("assets/logo_512.jpg"),
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              Text(
                "Login",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Form(
                  child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          (value == null || Nip19.isNip19(value))
                              ? null
                              : "Not a valid key",
                      controller: _key,
                      decoration: InputDecoration(
                        label: Text("Nostr Key"),
                        hintText: "nsec / npub",
                      ))),
              Row(children: [
                Expanded(
                  child: BasicButton.text(
                    "Login",
                    fontSize: 16,
                    onTap: () {
                      final keyData = Nip19.decode(_key.text);
                      if (keyData.length > 0) {
                        GetIt.I.get<LoginData>().value =
                            Account.nip19(_key.text);
                        context.go("/");
                      }
                    },
                  ),
                ),
              ]),
              SizedBox(
                height: 20,
              ),
              Row(spacing: 20, children: [
                Text(
                  "OR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1, color: Color.fromARGB(50, 0, 0, 0)))),
                ))
              ]),
              SizedBox(
                height: 20,
              ),
              Row(children: [
                Expanded(
                  child: BasicButton.text(
                    "Login with external signer",
                    fontSize: 16,
                    onTap: () async {
                      final amber = Amberflutter();
                      if (Platform.isAndroid && await amber.isAppInstalled()) {
                        final result = await amber.getPublicKey();
                        if (result['signature'] != null) {
                          final key = Nip19.decode(result['signature']);
                          GetIt.I.get<LoginData>().value =
                              Account.externalPublicKeyHex(key);
                          context.go("/");
                        }
                      } else {
                        var url = Uri.parse(
                        "https://github.com/greenart7c3/Amber");
                        launchUrl(url,
                        mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),
              ]),
              SizedBox(
                height: 20,
              ),
              Row(spacing: 20, children: [
                Text(
                  "OR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1, color: Color.fromARGB(50, 0, 0, 0)))),
                ))
              ]),
              SizedBox(
                height: 20,
              ),
              Row(children: [
                Expanded(
                    child: BasicButton.text(
                  "Create Account",
                  fontSize: 16,
                  onTap: () => context.go("./new"),
                ))
              ]),
            ],
          )),
    );
  }
}
