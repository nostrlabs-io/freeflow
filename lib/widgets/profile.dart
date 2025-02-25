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
  static const TABS = [Icons.menu, Icons.favorite_border];
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
                Expanded(
                  child: PageView.builder(
                    itemCount: TABS.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, idx) {
                      return Column(
                        children: [
                          _tabHeader(idx),
                          Expanded(child: _tabBody(idx)),
                        ],
                      );
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

  Widget _tabBody(int tab) {
    switch (tab) {
      case 0:
        {
          return RxFilter<Video>(
            filter:
                Filter(kinds: SHORT_KIND, authors: [profile.pubKey], limit: 50),
            mapper: (e) => Video.fromEvent(e),
            builder: (ctx, data) {
              data?.sort(
                  (a, b) => b.event.createdAt.compareTo(a.event.createdAt));
              return VideoGridWidget(data ?? []);
            },
          );
        }
      case 1:
        {
          return RxFilter<Nip01Event>(
            filter: Filter(
              kinds: [7],
              tags: {
                "#k": SHORT_KIND.map((e) => e.toString()).toList()
              },
              authors: [profile.pubKey],
              limit: 50,
            ),
            builder: (ctx, data) {
              if ((data?.length ?? 0) == 0) {
                return SizedBox();
              }
              return RxFilter<Video>(
                  filter: Filter(
                    ids: data!.map((e) => e.getEId()).nonNulls.toList(),
                  ),
                  mapper: (e) => Video.fromEvent(e),
                  builder: (ctx, data) {
                    data?.sort((a, b) =>
                        b.event.createdAt.compareTo(a.event.createdAt));
                    return VideoGridWidget(data ?? []);
                  });
            },
          );
        }
    }
    return SizedBox();
  }

  Widget _tabHeader(int tab) {
    return Container(
      height: 45,
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: TABS
            .asMap()
            .entries
            .map(
              (t) => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    t.value,
                    color: t.key == tab ? Colors.black : Colors.black26,
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Container(
                    color: t.key == tab ? Colors.black : Colors.transparent,
                    height: 2,
                    width: 55,
                  )
                ],
              ),
            )
            .toList(),
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
