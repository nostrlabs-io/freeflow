import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/view_model/feed_viewmodel.dart';
import 'package:freeflow/widgets/actions_toolbar.dart';
import 'package:freeflow/widgets/bottom_bar.dart';
import 'package:freeflow/widgets/video_description.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final feedViewModel = GetIt.instance<FeedViewModel>();

  @override
  void initState() {
    feedViewModel.loadVideo(0);
    feedViewModel.loadVideo(1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return videoScreen();
  }

  Widget videoScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: feedVideos()),
              BottomBar(),
            ],
          )
        ],
      ),
    );
  }

  Widget feedVideos() {
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(
            initialPage: 0,
            viewportFraction: 1,
          ),
          itemCount: feedViewModel.videos.length,
          onPageChanged: (index) {
            index = index % feedViewModel.videos.length;
            feedViewModel.changeVideo(index);
          },
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            index = index % feedViewModel.videos.length;
            return FutureBuilder(
                future: feedViewModel.loadVideo(index),
                builder: (ctx, data) =>
                    videoCard(feedViewModel.videos[index], data.data));
          },
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Following',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70)),
                  SizedBox(
                    width: 7,
                  ),
                  Container(
                    color: Colors.white70,
                    height: 10,
                    width: 1.0,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text('For You',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                ]),
          ),
        ),
      ],
    );
  }

  Widget videoCard(Video video, VideoPlayerController? controller) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (controller != null) {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            }
          },
          child: controller != null
              ? SizedBox.expand(
                  child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ))
              : Container(
                  width: 64,
                  child: CircularProgressIndicator(),
                ),
        ),
        FutureBuilder(
          future: ndk.metadata.loadMetadata(video.user),
          initialData: Metadata(pubKey: video.user),
          builder: (state, data) => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  VideoDescription(data.data!, video.videoTitle),
                  ActionsToolbar(video.likes, video.comments, data.data!),
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    feedViewModel.dispose();
    super.dispose();
  }
}
