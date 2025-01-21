import 'package:flutter/material.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:ndk/ndk.dart';

import '../main.dart';

class ProfileScreen extends StatelessWidget {
  final String pubkey;
  const ProfileScreen({required this.pubkey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ndk.metadata.loadMetadata(pubkey),
        initialData: Metadata(pubKey: pubkey),
        builder: (state, data) =>
            SafeArea(child: ProfileWidget(profile: data.data!)));
  }
}
