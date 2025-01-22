import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freeflow/utils/tik_tok_icons_icons.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  static const double NavigationIconSize = 20.0;
  static const double CreateButtonWidth = 38.0;

  const BottomBar({Key? key}) : super(key: key);

  Widget get customCreateIcon => Container(
      width: 45.0,
      height: 27.0,
      child: Stack(children: [
        Container(
            margin: EdgeInsets.only(left: 10.0),
            width: CreateButtonWidth,
            decoration: BoxDecoration(
                color: Color.fromARGB(169, 208, 0, 255),
                borderRadius: BorderRadius.circular(7.0))),
        Container(
            margin: EdgeInsets.only(right: 10.0),
            width: CreateButtonWidth,
            decoration: BoxDecoration(
                color: Color.fromARGB(169, 0, 102, 255),
                borderRadius: BorderRadius.circular(7.0))),
        Center(
            child: Container(
          height: double.infinity,
          width: CreateButtonWidth,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(7.0)),
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 20.0,
          ),
        )),
      ]));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: Colors.black))),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              menuButton(context, 'Home', TikTokIcons.home, "/"),
              menuButton(context, 'Search', TikTokIcons.search, "/search"),
              SizedBox(
                width: 15,
              ),
              customCreateIcon,
              SizedBox(
                width: 15,
              ),
              menuButton(
                  context, 'Messages', TikTokIcons.messages, "/messages"),
              menuButton(context, 'Profile', TikTokIcons.profile,
                  "/profile/3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d")
            ],
          ),
          SizedBox(
            height: Platform.isIOS ? 40 : 10,
          )
        ],
      ),
    );
  }

  Widget menuButton(
      BuildContext context, String text, IconData icon, String path) {
    final theme = Theme.of(context);

    return GestureDetector(
        onTap: () {
          context.go(path);
        },
        child: Container(
          height: 45,
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon,
                  color: Colors.white,
                  size: NavigationIconSize),
              SizedBox(
                height: 7,
              ),
              Text(
                text,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 11.0),
              )
            ],
          ),
        ));
  }
}
