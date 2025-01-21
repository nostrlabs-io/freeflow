import 'package:ndk/ndk.dart';

class IMeta {
  (int, int)? dimensions = null;
  String? url = null;
  String? hash = null;
  String? mime_type = null;
  List<String>? images = null;
  List<String>? fallback = null;

  static List<IMeta> fromEvent(Nip01Event event) {
    List<IMeta> tags = List.empty(growable: true);
    for (final tag in event.tags) {
      if (tag.first != "imeta") {
        continue;
      }
      var r = IMeta();
      for (final e in tag.skip(1)) {
        final es = e.split(" ");
        if (es.length < 2) {
          continue;
        }
        switch (es[0]) {
          case "dim":
            {
              final ds = es[1].split("x");
              r.dimensions = (int.parse(ds[0]), int.parse(ds[1]));
              break;
            }
          case "url":
            {
              r.url = es[1];
              break;
            }
          case "x":
            {
              r.hash = es[1];
              break;
            }
          case "m":
            {
              r.mime_type = es[1];
              break;
            }
          case "image":
            {
              r.images ??= List.empty(growable: true);
              r.images!.insert(0, es[1]);
              break;
            }
          case "fallback":
            {
              r.fallback ??= List.empty(growable: true);
              r.fallback!.insert(0, es[1]);
              break;
            }
        }
      }
      tags.insert(0, r);
    }
    return tags;
  }
}
