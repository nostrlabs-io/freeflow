import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/metadata.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:get_it/get_it.dart';

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
    return SafeArea(
        child: FutureBuilder(
            future: N.profile(thisPubkey),
            builder: (state, data) {
              return ProfileWidget(
                  pubkey: thisPubkey, profile: data.data ?? Metadata.empty());
            }));
  }
}
