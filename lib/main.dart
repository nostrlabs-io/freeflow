import 'package:flutter/material.dart';
import 'package:freeflow/screens/feed_screen.dart';
import 'package:freeflow/screens/profile_screen.dart';
import 'package:freeflow/view_model/feed_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.I.registerSingleton<FeedViewModel>(FeedViewModel());

  runApp(MaterialApp.router(
    routerConfig: GoRouter(routes: [
      GoRoute(
          path: "/",
          builder: (context, state) {
            return Theme(
              data: ThemeData.light(),
              child: FeedScreen(),
            );
          }),
      GoRoute(
        path: "/profile/:pubkey",
        builder: (context, state) {
          return Theme(
              data: ThemeData.light(),
              child: ProfileScreen(pubkey: state.pathParameters["pubkey"]!));
        },
      )
    ]),
  ));
}

final ndk = Ndk(
  NdkConfig(
    eventVerifier: Bip340EventVerifier(),
    cache: MemCacheManager(),
  ),
);

final SHORT_KIND = 34236;
