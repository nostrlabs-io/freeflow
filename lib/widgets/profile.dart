import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/widgets/avatar.dart';
import 'package:freeflow/widgets/follow_button.dart';
import 'package:freeflow/widgets/profile_name.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

class ProfileWidget extends StatelessWidget {
  final Metadata profile;

  ProfileWidget({required this.profile}) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FollowButtonWidget(profile.pubKey),
                ProfileNameWidget(
                  profile: profile,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.more_horiz)
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Center(
                    child: AvatarWidget(
                  profile: profile,
                  size: 100,
                )),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        FutureBuilder(
                            future: ndk.follows.getContactList(profile.pubKey),
                            builder: (context, data) {
                              if (!data.hasData) {
                                return SizedBox(
                                  width: 29,
                                  height: 29,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Text(
                                (data.data?.contacts.length ?? 0).toString(),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              );
                            }),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Following",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Container(
                      color: Colors.black54,
                      width: 1,
                      height: 15,
                      margin: EdgeInsets.symmetric(horizontal: 15),
                    ),
                    Column(
                      children: [
                        RxFilter<ZapReceipt>(
                            filter:
                                Filter(pTags: [profile.pubKey], kinds: [9735]),
                            mapper: (e) => ZapReceipt.fromEvent(e),
                            builder: (context, data) {
                              if (data == null) {
                                return SizedBox(
                                  width: 29,
                                  height: 29,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Text(
                                formatSats(data.fold(
                                    0, (acc, v) => acc + (v.amountSats ?? 0))),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              );
                            }),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Zaps",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 45,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.menu),
                          SizedBox(
                            height: 7,
                          ),
                          Container(
                            color: Colors.black,
                            height: 2,
                            width: 55,
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: Colors.black26,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Container(
                            color: Colors.transparent,
                            height: 2,
                            width: 55,
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.black26,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Container(
                            color: Colors.transparent,
                            height: 2,
                            width: 55,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RxFilter<Video>(
                    filter: Filter(
                        kinds: SHORT_KIND,
                        authors: [profile.pubKey],
                        limit: 10),
                    mapper: (e) => Video.fromEvent(e),
                    builder: (ctx, data) {
                      data?.sort((a, b) =>
                          b.event.createdAt.compareTo(a.event.createdAt));
                      return GridView.builder(
                          shrinkWrap: true,
                          itemCount: data?.length ?? 0,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 9 / 16,
                          ),
                          itemBuilder: (ctx, idx) {
                            if ((data?.length ?? 0) >= idx) {
                              return _profileTile(
                                ctx,
                                data![idx],
                              );
                            } else {
                              return null;
                            }
                          });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _followers() {
    return [
      Container(
        color: Colors.black54,
        width: 1,
        height: 15,
        margin: EdgeInsets.symmetric(horizontal: 15),
      ),
      Column(
        children: [
          RxFilter<Nip01Event>(
              filter: Filter(pTags: [profile.pubKey], kinds: [3]),
              builder: (context, data) {
                if (data == null) {
                  return SizedBox(
                    width: 29,
                    height: 29,
                    child: CircularProgressIndicator(),
                  );
                }
                return Text(
                  formatSats(data.length),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              }),
          SizedBox(
            height: 5,
          ),
          Text(
            "Followers",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ];
  }

  Widget _profileTile(BuildContext context, Video v) {
    return GestureDetector(
      onTap: () {
        context.push("/e/${Nip19.encodeNoteId(v.id)}", extra: v.event);
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
            color: Colors.black26,
            border: Border.all(color: Colors.white70, width: .5)),
        child: CachedNetworkImage(
          fit: BoxFit.contain,
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
