import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:freeflow/widgets/error.dart';

class ShortVideoPlaceholder extends StatelessWidget {
  final Video? video;

  ShortVideoPlaceholder(this.video);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: CachedNetworkImage(
          imageUrl: proxyImg(context, video?.image ?? video?.url ?? ""),
          errorWidget: (ctx, msg, obj) {
            return ErrorText(msg);
          },
        ),
      ),
    );
  }
}
