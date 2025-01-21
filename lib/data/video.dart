import 'package:freeflow/data/imeta.dart';
import 'package:ndk/ndk.dart';
import 'package:video_player/video_player.dart';

class Video {
  Nip01Event event;
  List<IMeta> metadata;

  String? get url {
    if (metadata.length == 0) {
      return null;
    }
    final m1 = metadata.firstWhere((v) => v.url != null);
    return m1.url;
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

  VideoPlayerController? controller;

  Future<Null> loadController() async {
    if (url != null) {
      controller = VideoPlayerController.networkUrl(Uri.parse(url!));
      await controller?.initialize();
      controller?.setLooping(true);
    }
  }
}
