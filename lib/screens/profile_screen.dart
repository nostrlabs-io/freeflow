import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:ndk/ndk.dart';

final FIATJAF =
    "3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d";
final KIERAN =
    "63fe6318dc58583cfe16810f86dd09e18bfd76aabc24a0081ce2856f330504ed";

class ProfileScreen extends StatelessWidget {
  final String pubkey;
  const ProfileScreen({required this.pubkey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thisPubkey =
        pubkey == "me" ? (Random().nextBool() ? FIATJAF : KIERAN) : pubkey;
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
