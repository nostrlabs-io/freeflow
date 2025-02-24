import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/widgets/avatar.dart';
import 'package:freeflow/widgets/comments.dart';
import 'package:freeflow/widgets/follow_button.dart';
import 'package:freeflow/widgets/zap.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip25/reactions.dart';

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
    final myPubkey = ndk.accounts.getPublicKey();
    return Container(
      width: ActionWidgetSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 15,
        children: [
          _getFollowAction(user),
          _getSocialAction(
              icon: "heart",
              activeColor: Colors.red,
              kind: 7,
              onPressed: (hasReacted) {
                if (hasReacted) return;
                if (ndk.accounts.isNotLoggedIn) {
                  context.push("/login");
                  return;
                }
                final reaction = Nip01Event(
                  pubKey: myPubkey!,
                  content: "+",
                  kind: Reaction.kKind,
                  tags: [
                    ["e", video.id],
                    ["p", video.user],
                    ["k", video.event.kind.toString()],
                  ],
                );
                ndk.broadcast.broadcast(nostrEvent: reaction);
              }),
          _getSocialAction(
              icon: "comment",
              activeColor: Colors.blueAccent,
              kind: 1111,
              onPressed: (_) {
                showModalBottomSheet(
                    context: context,
                    constraints: BoxConstraints.expand(),
                    builder: (context) => CommentsWidget(video: video));
              }),
          _getSocialAction(
              icon: "zap",
              activeColor: Colors.red,
              kind: 9735,
              title: 'Zap',
              onPressed: (_) {
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints.expand(),
                  builder: (context) => ZapWidget(
                    pubkey: video.user,
                    target: video.event,
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget _getSocialAction(
      {required String icon,
      required int kind,
      required Color activeColor,
      String? title,
      void Function(bool)? onPressed}) {
    return RxFilter<Nip01Event>(
      filter: Filter(kinds: [kind], eTags: [video.id]),
      builder: (ctx, data) {
        final hasMyReaction = data?.any((e) {
              if (e.kind != 9735) {
                return e.pubKey == ndk.accounts.getPublicKey();
              } else {
                return ZapReceipt.fromEvent(e).sender ==
                    ndk.accounts.getPublicKey();
              }
            }) ??
            false;
        return GestureDetector(
          onTap: () {
            if (onPressed != null) {
              onPressed(hasMyReaction);
            }
          },
          child: Container(
              width: ActionWidgetSize,
              child: Column(
                children: [
                  SvgPicture.asset(
                    "assets/svg/${icon}.svg",
                    colorFilter: hasMyReaction
                        ? ColorFilter.mode(activeColor, BlendMode.srcATop)
                        : null,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        title ?? data?.length.toString() ?? "0",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0),
                      )),
                ],
              )),
        );
      },
    );
  }

  Widget _getFollowAction(Metadata profile) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      width: ActionWidgetSize,
      height: ActionWidgetSize,
      child: Stack(
        children: [
          _getProfilePicture(profile),
          _getPlusIcon(profile),
        ],
      ),
    );
  }

  Widget _getPlusIcon(Metadata profile) {
    return Positioned(
      bottom: 0,
      left: ((ActionWidgetSize / 2) - (PlusIconSize / 2)),
      child: FollowButtonWidget(
        profile.pubKey,
        child: (f) {
          if (f) {
            return SizedBox.shrink();
          } else {
            return Container(
              width: PlusIconSize, // PlusIconSize = 20.0;
              height: PlusIconSize, // PlusIconSize = 20.0;
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 43, 84),
                  borderRadius: BorderRadius.circular(15.0)),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20.0,
              ),
            );
          }
        },
        loaderWidget: SizedBox.shrink(),
      ),
    );
  }

  Widget _getProfilePicture(Metadata profile) {
    return Positioned(
      left: (ActionWidgetSize / 2) - (ProfileImageSize / 2),
      child: Container(
        padding: EdgeInsets.all(1.0), // Add 1.0 point padding to create border
        height: ProfileImageSize, // ProfileImageSize = 50.0;
        width: ProfileImageSize, // ProfileImageSize = 50.0;
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ProfileImageSize / 2),
        ),
        child: AvatarWidget(profile: profile),
      ),
    );
  }
}
