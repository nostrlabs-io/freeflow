import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:nostr_sdk/nostr_sdk.dart';
import 'package:video_player/video_player.dart';

class FeedViewModel {
  List<Video> videos = List.empty(growable: true);
  Map<int, VideoPlayerController> controllers = Map();
  int prevVideoIndex = 0;
  int currentVideoIndex = 0;

  Video? get currentVideo {
    return videos[currentVideoIndex];
  }

  Future<VideoPlayerController?> getController(int index) async {
    if (controllers.containsKey(index)) {
      return controllers[index]!;
    }
    final url = videos[index].url;
    if (url != null) {
      print("Loading video: #${index} = ${url}");
      final c = VideoPlayerController.networkUrl(Uri.parse(url),
          httpHeaders: Map.from({"user-agent": USER_AGENT}));
      controllers[index] = c;
      await c.initialize();
      c.setLooping(true);
      return c;
    } else {
      return null;
    }
  }

  changeVideo(int next) async {
    // stop all players
    for (final v in controllers.values) {
      v.pause();
    }

    await loadVideo(next);

    prevVideoIndex = currentVideoIndex;
    currentVideoIndex = next;

    // cleanup controllers
    for (final k in [...controllers.keys]) {
      if (k < currentVideoIndex - 1 || k > currentVideoIndex + 1) {
        final v = controllers.remove(k);
        v?.pause();
        v?.dispose();
        print("Unloading video: ${k}");
      }
    }
  }

  /**
   * Load a view controller by index
   */
  Future<VideoPlayerController?> loadVideo(int index) async {
    if (videos.length > index) {
      final c = await getController(index);
      await c?.play();
      return c;
    } else {
      return null;
    }
  }

  Future<List<Video>> loadVideoData(List<String>? authors) async {
    if (videos.length == 0) {
      var filter =
          Filter().kinds(kinds: SHORT_KIND).limit(limit: BigInt.from(20));
      if (authors != null) {
        filter.authors(
            authors:
                authors.map((a) => PublicKey.parse(publicKey: a)).toList());
      }
      final response = await NOSTR.fetchEvents(
          filter: filter, timeout: Duration(seconds: 30));
      videos = response.toVec().map((e) => Video.fromEvent(e)).toList();
    }
    return videos;
  }

  void reset() {
    videos.clear();
    for (final p in controllers.values) {
      p.pause();
      p.dispose();
    }
    controllers.clear();
    prevVideoIndex = 0;
    currentVideoIndex = 0;
  }
}
