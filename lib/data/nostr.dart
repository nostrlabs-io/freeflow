import 'package:freeflow/data/imeta.dart';
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
    print("Loading videos");
    final response = ndk.requests.query(filters: [
      Filter(kinds: [34236])
    ]);
    this.listVideos = await response.stream
        .asyncMap((e) => Video.new(
            id: e.id,
            user: e.pubKey,
            userPic: "",
            videoTitle: '',
            songName: '',
            likes: '',
            comments: '',
            metadata: IMeta.fromEvent(e)))
        .toList();
    print(this.listVideos);
  }
}
