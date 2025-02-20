import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/widgets/comments.dart';
import 'package:ndk/ndk.dart';

class ActionsToolbar extends StatelessWidget {
  // Full dimensions of an action
  static const double ActionWidgetSize = 60.0;

// The size of the icon showen for Social Actions
  static const double ActionIconSize = 35.0;

// The size of the share social icon
  static const double ShareActionIconSize = 25.0;

// The size of the profile image in the follow Action
  static const double ProfileImageSize = 50.0;

// The size of the plus icon under the profile image in follow action
  static const double PlusIconSize = 20.0;

  final Video video;
  final Metadata user;

  ActionsToolbar(this.video, this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ActionWidgetSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 15,
        children: [
          _getFollowAction(user),
          _getSocialAction(
              icon: "heart",
              kind: 7,
              onPressed: () {
                ndk.broadcast.broadcastReaction(eventId: video.id);
              }),
          _getSocialAction(
              icon: "comment",
              kind: 1111,
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    constraints: BoxConstraints.expand(),
                    builder: (context) => CommentsWidget(video: video));
              }),
          _getSocialAction(icon: "zap", kind: 9735, title: 'Zap')
        ],
      ),
    );
  }

  Widget _getSocialAction(
      {required String icon,
      required int kind,
      String? title,
      void Function()? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: ActionWidgetSize,
        child: Column(
          children: [
            SvgPicture.asset("assets/svg/${icon}.svg"),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: FutureBuilder(
                  future: ndk.requests.query(filters: [
                    Filter(kinds: [kind], eTags: [video.id])
                  ]).future,
                  builder: (ctx, data) {
                    return Text(
                      title ?? data.data?.length.toString() ?? "0",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget _getFollowAction(Metadata profile) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        width: ActionWidgetSize,
        height: ActionWidgetSize,
        child: Stack(children: [_getProfilePicture(profile), _getPlusIcon()]));
  }

  Widget _getPlusIcon() {
    return Positioned(
      bottom: 0,
      left: ((ActionWidgetSize / 2) - (PlusIconSize / 2)),
      child: Container(
          width: PlusIconSize, // PlusIconSize = 20.0;
          height: PlusIconSize, // PlusIconSize = 20.0;
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 43, 84),
              borderRadius: BorderRadius.circular(15.0)),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 20.0,
          )),
    );
  }

  Widget _getProfilePicture(Metadata profile) {
    return Positioned(
        left: (ActionWidgetSize / 2) - (ProfileImageSize / 2),
        child: Container(
            padding:
                EdgeInsets.all(1.0), // Add 1.0 point padding to create border
            height: ProfileImageSize, // ProfileImageSize = 50.0;
            width: ProfileImageSize, // ProfileImageSize = 50.0;
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ProfileImageSize / 2)),
            // import 'package:cached_network_image/cached_network_image.dart'; at the top to use CachedNetworkImage
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10000.0),
                child: CachedNetworkImage(
                  imageUrl: profile.picture ??
                      "https://nostr.api.v0l.io/api/v1/avatar/cyberpunks/${profile.pubKey}",
                  placeholder: (context, url) =>
                      new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ))));
  }
}
