import 'package:flutter/material.dart';
import 'package:freeflow/widgets/bottom_bar.dart';
import 'package:freeflow/widgets/profile.dart';
import 'package:ndk/ndk.dart';

import '../main.dart';

class ProfileScreen extends StatelessWidget {
  final String pubkey;
  const ProfileScreen({required this.pubkey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder(
            future: ndk.metadata.loadMetadata(pubkey),
            initialData: Metadata(pubKey: pubkey),
            builder: (state, data) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(child: ProfileWidget(profile: data.data!)),
                        BottomBar(),
                      ],
                    )
                  ],
                ),
              );
            }));
  }
}
