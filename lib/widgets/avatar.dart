import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/ndk.dart';

class AvatarWidget extends StatelessWidget {
  final double? size;
  final Metadata profile;

  AvatarWidget({required this.profile, this.size});

  static Widget pubkey(String pubkey, {double? size}) {
    return FutureBuilder(
      future: ndk.metadata.loadMetadata(pubkey),
      builder: (ctx, data) {
        return AvatarWidget(
          profile: data.data ?? Metadata(pubKey: pubkey),
          size: size,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final thisSize = size ?? 40;
    return ClipOval(
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: proxyImg(
            context,
            profile.picture ??
                "https://nostr.api.v0l.io/api/v1/avatar/cyberpunks/${profile.pubKey}",
            resize: thisSize.ceil()),
        height: thisSize,
        width: thisSize,
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
