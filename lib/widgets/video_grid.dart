import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

class VideoGridWidget extends StatelessWidget {
  final List<Video> events;

  VideoGridWidget(this.events);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        itemCount: events.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 10 / 16,
        ),
        itemBuilder: (ctx, idx) {
          if (events.length >= idx) {
            return _videoTile(
              ctx,
              events[idx],
            );
          } else {
            return null;
          }
        });
  }

  Widget _videoTile(BuildContext context, Video v) {
    return GestureDetector(
      onTap: () {
        context.push("/e/${Nip19.encodeNoteId(v.id)}", extra: v.event);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black26,
            border: Border.all(color: Colors.white70, width: .5)),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: proxyImg(context, v.image ?? v.url ?? "", resize: 160),
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}
