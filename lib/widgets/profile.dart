import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/ndk.dart';

class ProfileWidget extends StatelessWidget {
  final Metadata profile;

  ProfileWidget({required this.profile}) {}

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName ?? profile.name ?? profile.pubKey;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.person_add_alt_1_outlined),
                Text(
                  name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.more_horiz)
              ],
            ),
          ),
          SingleChildScrollView(
            primary: true,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: ClipOval(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: profile.picture ??
                          "https://nostr.api.v0l.io/api/v1/avatar/cyberpunks/${profile.pubKey}",
                      height: 100.0,
                      width: 100.0,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "@" + name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
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
                        Text(
                          "0",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Followers",
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
                        FutureBuilder(
                            future: ndk.zaps
                                .fetchZappedReceipts(pubKey: profile.pubKey)
                                .toList(),
                            builder: (context, data) {
                              if (!data.hasData) {
                                return SizedBox(
                                  width: 29,
                                  height: 29,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Text(
                                formatSats(data.data?.fold(
                                        0,
                                        (acc, v) =>
                                            acc! + (v.amountSats ?? 0)) ??
                                    0),
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
                StreamBuilder(
                    stream: ndk.requests
                        .query(filters: [
                          Filter(
                              kinds: [SHORT_KIND],
                              authors: [profile.pubKey],
                              limit: 10)
                        ])
                        .future
                        .asStream(),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasData) {
                        return GridView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (ctx, idx) {
                              return _profileTile(
                                  Video.fromEvent(snapshot.data![idx]));
                            });
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(Video v) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
          color: Colors.black26,
          border: Border.all(color: Colors.white70, width: .5)),
      child: FittedBox(
        child: CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl: v.image ?? "",
          placeholder: (context, url) => Padding(
            padding: const EdgeInsets.all(35.0),
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        fit: BoxFit.fill,
      ),
    );
  }
}
