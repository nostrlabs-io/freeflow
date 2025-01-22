import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freeflow/utils/tik_tok_icons_icons.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  static const double NavigationIconSize = 20.0;
  static const double CreateButtonWidth = 38.0;

  const BottomBar({Key? key}) : super(key: key);

  Widget get customCreateIcon => Container(
      width: CreateButtonWidth,
      height: 27,
      child: Stack(alignment: Alignment.center, children: [
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
      margin: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(child: menuButton(context, 'Home', TikTokIcons.home, "/")),
          Expanded(
              child:
                  menuButton(context, 'Search', TikTokIcons.search, "/search")),
          Expanded(
            child: GestureDetector(
                onTap: () => context.go("/create"), child: customCreateIcon),
          ),
          Expanded(
              child: menuButton(
                  context, 'Messages', TikTokIcons.messages, "/messages")),
          Expanded(
              child: menuButton(
                  context, 'Profile', TikTokIcons.profile, "/profile/me"))
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
              Icon(icon, color: Colors.white, size: NavigationIconSize),
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
