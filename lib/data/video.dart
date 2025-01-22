import 'package:freeflow/data/imeta.dart';
import 'package:ndk/ndk.dart';

class Video {
  Nip01Event event;
  List<IMeta> metadata;

  String? get url {
    for (final m in metadata) {
      if (m.url != null) {
        return m.url;
      }
    }
    return null;
  }

  String? get image {
    for (final m in metadata) {
      if (m.images != null) {
        return m.images!.first;
      }
    }
    return null;
  }

  String get id {
    return event.id;
  }

  String get user {
    return event.pubKey;
  }

  String get videoTitle {
    return event.content;
  }

  int get likes {
    return 666;
  }

  int get comments {
    return 69;
  }

  Video({required this.event, required this.metadata}) {}

  static Video fromEvent(Nip01Event event) {
    return Video(event: event, metadata: IMeta.fromEvent(event));
  }
}
