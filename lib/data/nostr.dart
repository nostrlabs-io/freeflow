import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';

class VideosAPINostr {
  static Future<List<Video>> load() async {
    final response = ndk.requests.query(filters: [
      Filter(kinds: [SHORT_KIND], limit: 20)
    ]);
    return await response.stream.asyncMap((e) => Video.fromEvent(e)).toList();
  }
}
