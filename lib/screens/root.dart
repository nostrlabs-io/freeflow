import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/screens/feed_screen.dart';
import 'package:ndk/ndk.dart';

enum RootTab { Following, Latest }

class RootScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootScreen();
}

class _RootScreen extends State<RootScreen> {
  RootTab _tab = RootTab.Latest;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FeedScreen(
          () async {
            final acc = ndk.accounts.getPublicKey();
            final authors = acc != null && _tab == RootTab.Following
                ? (await ndk.follows.getContactList(acc))?.contacts
                : null;
            return Filter(kinds: SHORT_KIND, authors: authors, limit: 50);
          },
          key: Key(
            "root-tab:${_tab}",
          ),
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children:
                  [RootTab.Following, RootTab.Latest].map(_tabWidget).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabWidget(RootTab tab) {
    return GestureDetector(
      onTap: () => setState(() {
        _tab = tab;
      }),
      child: Text(
        tab.toString().split(".").last,
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: _tab == tab ? FontWeight.bold : FontWeight.normal,
          color: _tab == tab ? Colors.white : Colors.white70,
        ),
      ),
    );
  }
}
