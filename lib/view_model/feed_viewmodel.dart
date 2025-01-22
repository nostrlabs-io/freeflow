import 'package:freeflow/data/nostr.dart';
import 'package:freeflow/data/video.dart';
import 'package:video_player/video_player.dart';

class FeedViewModel {
  List<Video> videos = List.empty();
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
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      c.setLooping(true);
      controllers[index] = c;
      return c;
    } else {
      return null;
    }
  }

  changeVideo(int next) async {
    final cNext = await getController(next);
    cNext?.play();

    final cPrev = await getController(currentVideoIndex);
    cPrev?.pause();

    prevVideoIndex = currentVideoIndex;
    currentVideoIndex = next;

    for (final k in controllers.keys) {
      if (k < currentVideoIndex - 1 && k > currentVideoIndex) {
        controllers.remove(k);
      }
    }
  }

  /**
   * Load a view controller by index
   */
  Future<VideoPlayerController?> loadVideo(int index) async {
    if (videos.length == 0) {
      videos = await VideosAPINostr.load();
    }
    if (videos.length > index) {
      final c = await getController(index);
      await c?.play();
      return c;
    } else {
      return null;
    }
  }

  void dispose() {
    controllers.clear();
  }
}
