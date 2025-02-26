import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

typedef VideoWidgetBuilder = Widget Function(Video);

class VideoGridWidget extends StatelessWidget {
  final int cols;
  final double spacing;
  final double aspect;
  final List<Video> events;
  final VideoWidgetBuilder? title;

  VideoGridWidget(
    this.events, {
    this.title,
    this.cols = 4,
    this.aspect = 10 / 16,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _calculateHeight(context),
      child: GridView.builder(
        itemCount: events.length,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspect,
        ),
        itemBuilder: (ctx, idx) {
          return _videoTile(
            ctx,
            events[idx],
          );
        },
      ),
    );
  }

  double _calculateHeight(BuildContext context) {
    if (events.length == 0) return 0;
    final rowCount = (events.length / cols).ceil();
    final cellWidth =
        (MediaQuery.of(context).size.width - (cols - 1) * spacing) / cols;
    final cellHeight = cellWidth / aspect;
    return rowCount * cellHeight + (rowCount - 1) * spacing;
  }

  Widget _videoTile(BuildContext context, Video v) {
    return GestureDetector(
      onTap: () {
        context.push("/e/${Nip19.encodeNoteId(v.id)}", extra: v.event);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(5),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl:
                    proxyImg(context, v.image ?? v.url ?? "", resize: 160),
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          if (title != null) title!(v),
        ],
      ),
    );
  }
}
