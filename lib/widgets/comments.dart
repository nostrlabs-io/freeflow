import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/avatar.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';

class CommentsWidget extends StatefulWidget {
  final Video video;

  CommentsWidget({required this.video});

  @override
  State<StatefulWidget> createState() => _CommentsWidget();
}

class _CommentsWidget extends State<CommentsWidget> {
  final TextEditingController _comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: FutureBuilder(
        future: ndk.requests.query(filters: [
          Filter(kinds: [1111], eTags: [widget.video.id])
        ]).future,
        builder: (context, data) {
          return Column(
            spacing: 10,
            children: [
              Text("${data.data?.length ?? 0} comments"),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 5,
                    children: data.data?.map(_commentWidget).toList() ?? [],
                  ),
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _comment,
                      decoration: InputDecoration(
                        labelText: "Comment",
                      ),
                    ),
                  ),
                  BasicButton.text("Send", onTap: () async {
                    await _postComment();
                    setState(() {
                      _comment.clear();
                    });
                  }),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _commentWidget(Nip01Event ev) {
    return Row(
      spacing: 10,
      children: [
        AvatarWidget.pubkey(ev.pubKey),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Username"),
            Text(ev.content),
          ],
        )
      ],
    );
  }

  Future<Nip01Event> _postComment() async {
    final acc = GetIt.I.get<LoginData>().value;
    if (acc == null) {
      throw "Not logged in";
    }

    final ev = Nip01Event(
        pubKey: acc.pubkey,
        kind: 1111,
        content: _comment.text,
        tags: [
          ["E", widget.video.id, "", widget.video.user],
          ["K", widget.video.event.kind.toString()],
          ["P", widget.video.user],
          ["e", widget.video.id, "", widget.video.user],
          ["k", widget.video.event.kind.toString()],
          ["p", widget.video.user],
        ]);

    print(ev);
    await ndk.broadcast
        .broadcast(nostrEvent: ev, specificRelays: DEFAULT_RELAYS);
    return ev;
  }
}
