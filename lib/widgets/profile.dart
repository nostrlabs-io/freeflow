import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/widgets/avatar.dart';
import 'package:freeflow/widgets/follow_button.dart';
import 'package:freeflow/widgets/profile_name.dart';
import 'package:freeflow/widgets/video_grid.dart';
import 'package:ndk/ndk.dart';

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
                        RxFilter<Nip01Event>(
                            filter:
                                Filter(pTags: [profile.pubKey], kinds: [9735]),
                            builder: (context, data) {
                              if (data == null) {
                                return SizedBox(
                                  width: 29,
                                  height: 29,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Text(
                                zapSum(data),
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
                      return VideoGridWidget(data ?? []);
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
}
