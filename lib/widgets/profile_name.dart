import 'package:flutter/widgets.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

class ProfileNameWidget extends StatelessWidget {
  final Metadata profile;
  final TextStyle? style;

  ProfileNameWidget({required this.profile, this.style});

  static Widget pubkey(String pubkey, {TextStyle? style}) {
    return FutureBuilder(
      future: ndk.metadata.loadMetadata(pubkey),
      builder: (ctx, data) => ProfileNameWidget(
        profile: data.data ?? Metadata(pubKey: pubkey),
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = () {
      if ((profile.displayName?.length ?? 0) > 0) {
        return profile.displayName!;
      }
      if ((profile.name?.length ?? 0) > 0) {
        return profile.name!;
      }
      return Nip19.encodeSimplePubKey(profile.pubKey);
    }();

    return Text(
      name,
      style: style,
    );
  }
}
