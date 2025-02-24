import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:ndk/ndk.dart';

class ProfileScreen extends StatelessWidget {
  final String pubkey;
  const ProfileScreen({required this.pubkey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thisPubkey = pubkey == "me" ? ndk.accounts.getPublicKey()! : pubkey;
    final init = Metadata(pubKey: thisPubkey);
    return SafeArea(
        child: FutureBuilder(
            future: ndk.metadata.loadMetadata(thisPubkey),
            initialData: init,
            builder: (state, data) {
              return ProfileWidget(profile: data.data ?? init);
            }));
  }
}
