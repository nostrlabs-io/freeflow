import 'package:flutter/widgets.dart';
import 'package:freeflow/main.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

// create simple sync cache to avoid extra re-draw
final Map<String, Metadata> syncProfileCache = {};

class ProfileLoaderWidget extends StatelessWidget {
  final String pubkey;
  final AsyncWidgetBuilder<Metadata?> builder;

  const ProfileLoaderWidget(this.pubkey, this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: super.key,
      initialData: syncProfileCache.containsKey(pubkey)
          ? syncProfileCache[pubkey]
          : null,
      future: () async {
        final profile = await ndk.metadata.loadMetadata(pubkey);
        if (profile != null) {
          syncProfileCache[pubkey] = profile;
        }
        return profile;
      }(),
      builder: builder,
    );
  }
}

class ProfileNameWidget extends StatelessWidget {
  final Metadata profile;
  final TextStyle? style;
  final bool? linkToProfile;

  const ProfileNameWidget({
    super.key,
    required this.profile,
    this.style,
    this.linkToProfile,
  });

  static Widget pubkey(
    String pubkey, {
    Key? key,
    TextStyle? style,
    bool? linkToProfile,
  }) {
    return ProfileLoaderWidget(
      pubkey,
      (ctx, data) => ProfileNameWidget(
        profile: data.data ?? Metadata(pubKey: pubkey),
        style: style,
        linkToProfile: linkToProfile,
      ),
      key: key,
    );
  }

  static String nameFromProfile(Metadata profile) {
    if ((profile.displayName?.length ?? 0) > 0) {
      return profile.displayName!;
    }
    if ((profile.name?.length ?? 0) > 0) {
      return profile.name!;
    }
    return Nip19.encodeSimplePubKey(profile.pubKey);
  }

  @override
  Widget build(BuildContext context) {
    final inner = Text(
      ProfileNameWidget.nameFromProfile(profile),
      style: style,
      overflow: TextOverflow.ellipsis,
    );
    if (linkToProfile ?? true) {
      return GestureDetector(
        onTap: () => context.push(
          "/p/${Nip19.encodePubKey(profile.pubKey)}",
          extra: profile,
        ),
        child: inner,
      );
    } else {
      return inner;
    }
  }
}
