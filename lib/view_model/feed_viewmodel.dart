import 'package:freeflow/data/nostr.dart';
import 'package:freeflow/data/video.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

class FeedViewModel extends BaseViewModel {
  VideoPlayerController? controller;
  VideosAPINostr? videoSource;

  int prevVideoIndex = 0;
  int currentVideoIndex = 0;

  FeedViewModel() {
    videoSource = VideosAPINostr();
  }

  Video? get currentVideo {
    return videoSource?.listVideos[currentVideoIndex];
  }

  changeVideo(int next) async {
    if (videoSource!.listVideos[next].controller == null) {
      await videoSource!.listVideos[next].loadController();
    }
    videoSource!.listVideos[next].controller?.play();

    if (videoSource!.listVideos[prevVideoIndex].controller != null) {
      videoSource!.listVideos[prevVideoIndex].controller!.dispose();
    }

    prevVideoIndex = currentVideoIndex;
    currentVideoIndex = next;
    notifyListeners();
  }

  void loadVideo(int index) async {
    await videoSource!.load();
    if (videoSource!.listVideos.length > index) {
      await videoSource!.listVideos[index].loadController();
      videoSource!.listVideos[index].controller?.play();
      notifyListeners();
    }
  }
}
