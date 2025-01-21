import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';

class VideoDescription extends StatelessWidget {
  final Metadata profile;
  final videtoTitle;

  VideoDescription(this.profile, this.videtoTitle);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '@' +
                        (profile.displayName ?? profile.name ?? profile.pubKey),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    videtoTitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  /*Row(children: [
                    Icon(
                      Icons.music_note,
                      size: 15.0,
                      color: Colors.white,
                    ),
                    Text(songInfo,
                        style: TextStyle(color: Colors.white, fontSize: 14.0))
                  ]),*/
                  SizedBox(
                    height: 10,
                  ),
                ])));
  }
}
