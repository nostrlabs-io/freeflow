import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:ndk/ndk.dart';

class FollowButtonWidget extends StatefulWidget {
  final String pubkey;
  final Widget Function(bool)? child;
  final Widget? loaderWidget;

  FollowButtonWidget(this.pubkey, {this.child, this.loaderWidget});

  @override
  State<StatefulWidget> createState() => _FollowButtonWidget();
}

class _FollowButtonWidget extends State<FollowButtonWidget> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final myPubkey = ndk.accounts.getPublicKey();
    if (myPubkey != null && myPubkey != widget.pubkey) {
      return RxFilter<List<String>>(
        filter: Filter(authors: [myPubkey], kinds: [3]),
        mapper: (e) => e.tags
            .where((t) => t[0] == "p" && t[1].length == 64)
            .map((t) => t[1])
            .toList(),
        builder: (ctx, data) {
          if (data == null || _loading) {
            return widget.loaderWidget ??
                Container(
                  height: theme.size,
                  width: theme.size,
                  child: CircularProgressIndicator(),
                );
          }
          final follows = HashSet.from(data.expand((i) => i).toList());
          final doesFollow = follows.contains(widget.pubkey);
          return GestureDetector(
            onTap: () async {
              setState(() {
                _loading = true;
              });
              if (doesFollow) {
                await ndk.follows.broadcastRemoveContact(widget.pubkey);
              } else {
                await ndk.follows.broadcastAddContact(widget.pubkey);
              }
              setState(() {
                _loading = false;
              });
            },
            child: widget.child != null
                ? widget.child!(doesFollow)
                : (Icon(!doesFollow
                    ? Icons.person_add_alt_1_outlined
                    : Icons.person_remove_alt_1_outlined)),
          );
        },
      );
    } else {
      return SizedBox(
        height: theme.size,
        width: theme.size,
      );
    }
  }
}
