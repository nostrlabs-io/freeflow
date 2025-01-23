import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';

class ProfileScreen extends StatelessWidget {
  final String pubkey;
  const ProfileScreen({required this.pubkey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final login = GetIt.I.get<LoginData>();
    if (login.value == null) {
      return SizedBox();
    }
    final thisPubkey = pubkey == "me" ? login.value!.pubkey : pubkey;
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
