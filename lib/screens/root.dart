import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/screens/feed_screen.dart';
import 'package:ndk/ndk.dart';

enum RootTab { Following, Latest, ForYou }

class RootScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootScreen();
}

class _RootScreen extends State<RootScreen> {
  RootTab _tab = RootTab.Latest;

  @override
  Widget build(BuildContext context) {
    final acc = ndk.accounts.getPublicKey();
    return Stack(
      children: [
        FeedScreen(
          () async {
            switch (_tab) {
              case RootTab.Following:
                {
                  final authors =
                      (await ndk.follows.getContactList(acc!))?.contacts;
                  return [
                    Filter(kinds: SHORT_KIND, authors: authors, limit: 50)
                  ];
                }
              case RootTab.Latest:
                {
                  return [Filter(kinds: SHORT_KIND, limit: 50)];
                }
              case RootTab.ForYou:
                {
                  // TODO: DVM call
                  return [Filter(kinds: SHORT_KIND, limit: 50)];
                }
            }
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
              children: (acc != null
                      ? [RootTab.Following, RootTab.Latest]
                      : [RootTab.Latest])
                  .map(_tabWidget)
                  .toList(),
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
