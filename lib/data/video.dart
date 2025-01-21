import 'package:freeflow/data/imeta.dart';
import 'package:video_player/video_player.dart';

class Video {
  String id;
  String user;
  String userPic;
  String videoTitle;
  String songName;
  String likes;
  String comments;
  List<IMeta> metadata;

  String get url {
    final m1 = metadata.firstWhere((v) => v.url != null);
    return m1.url!;
  }

  VideoPlayerController? controller;

  Video(
      {required this.id,
      required this.user,
      required this.userPic,
      required this.videoTitle,
      required this.songName,
      required this.likes,
      required this.comments,
      required this.metadata});

  Future<Null> loadController() async {
    controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller?.initialize();
    controller?.setLooping(true);
  }
}
