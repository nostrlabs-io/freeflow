import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';

class VideosAPINostr {
  List<Video> listVideos = <Video>[];

  VideosAPI() {
    print("hello");
    load();
  }

  Future<void> load() async {
    if (this.listVideos.length != 0) {
      return;
    }
    final response = ndk.requests.query(filters: [
      Filter(kinds: [SHORT_KIND], limit: 20)
    ]);
    this.listVideos =
        await response.stream.asyncMap((e) => Video.fromEvent(e)).toList();
  }
}
