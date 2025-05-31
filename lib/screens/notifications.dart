import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/widgets/avatar.dart';
import 'package:freeflow/widgets/profile_name.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "All activity",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  Icon(Icons.send)
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: RxFilter<Nip01Event>(
                  filters: [
                    Filter(
                      pTags: [ndk.accounts.getPublicKey() ?? ""],
                      tags: {
                        "#k": SHORT_KIND.map((v) => v.toString()).toList()
                      },
                      kinds: [1111, 9735, 7],
                      limit: 20,
                    )
                  ],
                  builder: (ctx, data) {
                    if (data == null) {
                      return _placeholder();
                    } else {
                      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      return Column(
                        children: data
                            .map((e) => _notification(ctx, e))
                            .nonNulls
                            .toList(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _notification(BuildContext context, Nip01Event ev) {
    final zap = ev.kind == 9735 ? ZapReceipt.fromEvent(ev) : null;
    final sender = ev.kind != 9735 ? ev.pubKey : zap!.sender!;
    final targetIsMe =
        ev.kind != 9735 ? true : zap!.recipient == ndk.accounts.getPublicKey();

    if (!targetIsMe) return null;

    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        spacing: 2,
        children: [
          AvatarWidget.pubkey(sender),
          Column(
            children: [
              Row(
                spacing: 2,
                children: [
                  ProfileNameWidget.pubkey(sender),
                  _notificationAction(ev),
                  _notificationTarget(ev),
                ],
              ),
              // extra context
            ],
          ),
          Expanded(child: _notificationEndWidget(ev) ?? SizedBox.shrink())
        ],
      ),
    );
  }

  Widget _notificationAction(Nip01Event ev) {
    switch (ev.kind) {
      case 9735:
        {
          final zap = ZapReceipt.fromEvent(ev);
          return Text("zapped ${formatSats(zap.amountSats ?? 0)} sats on");
        }
      case 1111:
        return Text("commented");
      case 7:
        return Text("liked");
    }
    return Text("reacted");
  }

  Widget _notificationTarget(Nip01Event ev) {
    final eTag = ev.getEId();
    switch (ev.kind) {
      case 9735:
        {
          final zap = ZapReceipt.fromEvent(ev);
          return zap.eventId != null ? _eventName(zap.eventId!) : Text("you");
        }
    }
    return eTag != null ? _eventName(eTag) : Text("something");
  }

  Widget _eventName(String eventId) {
    return RxFilter<Nip01Event>(
      filters: [
        Filter(ids: [eventId])
      ],
      builder: (ctx, data) {
        if (data?.isEmpty ?? true) return SizedBox.shrink();

        final style = TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        );
        final ev = data!.first;
        final child = () {
          switch (ev.kind) {
            case 22:
              {
                return Text(
                  "your short",
                  style: style,
                );
              }
            case 1:
              {
                return Text(
                  "your note",
                  style: style,
                );
              }
            default:
              {
                return Text("Unknown kind: ${ev.kind}");
              }
          }
        }();
        return GestureDetector(
            onTap: () {
              context.push("/e/${Nip19.encodeNoteId(eventId)}", extra: ev);
            },
            child: child);
      },
    );
  }

  Widget? _notificationEndWidget(Nip01Event ev) {
    final eTag = ev.getEId();
    if (eTag == null) return null;

    return RxFilter<Nip01Event>(
      filters: [
        Filter(ids: [eTag])
      ],
      builder: (ctx, data) {
        if (data?.isEmpty ?? true) return SizedBox.shrink();

        final ev = data!.first;
        switch (ev.kind) {
          case 22:
            {
              final vid = Video.fromEvent(ev);
              return Container(
                height: 50,
                alignment: AlignmentDirectional.centerEnd,
                child: CachedNetworkImage(
                  imageUrl: proxyImg(
                    context,
                    vid.image ?? vid.url ?? "",
                    resize: 50,
                  ),
                ),
              );
            }
          default:
            {
              return SizedBox.shrink();
            }
        }
      },
    );
  }

  Widget _placeholder() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SvgPicture.asset("assets/svg/inbox.svg")],
          ),
          SizedBox(height: 5),
          Text(
            "All activity",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 3),
          Text(
            "Notifications about your account will appear here",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
