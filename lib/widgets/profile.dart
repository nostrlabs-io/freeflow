import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/imgproxy.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/metadata.dart';
import 'package:nostr_sdk/nostr_sdk.dart';

class ProfileWidget extends StatelessWidget {
  final String pubkey;
  final Metadata profile;

  ProfileWidget({required this.pubkey, required this.profile}) {}

  @override
  Widget build(BuildContext context) {
    final name = profile.display_name ?? profile.name ?? pubkey;
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
                      imageUrl: proxyImg(
                          context,
                          profile.picture ??
                              "https://nostr.api.v0l.io/api/v1/avatar/cyberpunks/${pubkey}",
                          resize: 100),
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
                            future: N.contactList(pubkey),
                            builder: (context, data) {
                              if (!data.hasData) {
                                return SizedBox(
                                  width: 29,
                                  height: 29,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Text(
                                (data.data?.length ?? 0).toString(),
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
                            future: N.zapReceipts(pubkey),
                            builder: (context, data) {
                              if (!data.hasData) {
                                return SizedBox(
                                  width: 29,
                                  height: 29,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Text(
                                formatSats(data.data?.fold(0,
                                        (acc, v) => acc! + (v.amount ?? 0)) ??
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
                FutureBuilder(
                    key: Key(pubkey),
                    future: NOSTR.fetchEvents(
                      filter: Filter()
                          .kinds(kinds: SHORT_KIND)
                          .author(author: PublicKey.parse(publicKey: pubkey))
                          .limit(limit: BigInt.from(10)),
                      timeout: Duration(seconds: 30),
                    ),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasData) {
                        return GridView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.len().toInt(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (ctx, idx) {
                              return _profileTile(ctx,
                                  Video.fromEvent(snapshot.data!.asVec()[idx]));
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

  Widget _profileTile(BuildContext context, Video v) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
          color: Colors.black26,
          border: Border.all(color: Colors.white70, width: .5)),
      child: CachedNetworkImage(
        fit: BoxFit.contain,
        imageUrl: proxyImg(context, v.image ?? v.url ?? "", resize: 160),
        placeholder: (context, url) => Padding(
          padding: const EdgeInsets.all(35.0),
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
