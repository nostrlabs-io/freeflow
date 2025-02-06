import 'package:flutter/material.dart';
import 'package:freeflow/screens/create.dart';
import 'package:freeflow/screens/create_preview.dart';
import 'package:freeflow/screens/feed_screen.dart';
import 'package:freeflow/screens/layout.dart';
import 'package:freeflow/screens/login.dart';
import 'package:freeflow/screens/messages_screen.dart';
import 'package:freeflow/screens/new_account.dart';
import 'package:freeflow/screens/profile_screen.dart';
import 'package:freeflow/screens/search_screen.dart';
import 'package:freeflow/view_model/feed_viewmodel.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_objectbox/ndk_objectbox.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final l = LoginData();

  // reload / cache login data
  l.addListener(() {
    ndk.metadata.loadMetadata(l.value!.pubkey);
    ndk.follows.getContactList(l.value!.pubkey);
  });

  await l.load();

  GetIt.I.registerSingleton<FeedViewModel>(FeedViewModel());
  GetIt.I.registerSingleton<LoginData>(l);

  runApp(MaterialApp.router(
    routerConfig: GoRouter(routes: [
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              LayoutScreen(navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: "/", builder: (context, state) => FeedScreen()),
              GoRoute(
                path: "/profile/:pubkey",
                builder: (context, state) =>
                    ProfileScreen(pubkey: state.pathParameters["pubkey"]!),
              ),
              GoRoute(
                  path: "/search", builder: (context, state) => SearchScreen()),
              GoRoute(
                path: "/messages",
                builder: (context, state) => MessagesScreen(),
              ),
              GoRoute(
                path: "/create",
                builder: (context, state) => CreateShortScreen(),
                routes: [
                  GoRoute(
                      path: "preview",
                      builder: (context, state) =>
                          CreatePreview(state.extra as List<RecordingSegment>)),
                ],
              ),
              GoRoute(
                  path: "/login",
                  builder: (context, state) => LoginScreen(),
                  routes: [
                    GoRoute(
                      path: "new",
                      builder: (context, state) => NewAccountScreen(),
                    )
                  ])
            ]),
          ]),
    ]),
  ));
}

class NoVerify extends EventVerifier {
  @override
  Future<bool> verify(Nip01Event event) {
    return Future.value(true);
  }
}

final ndk = Ndk(
  NdkConfig(
    eventVerifier: NoVerify(),
    cache: DbObjectBox(),
  ),
);

final SHORT_KIND = [22, 34236];
final USER_AGENT = "freeflow/1.0";

String formatSats(int n) {
  if (n > 1000000) {
    return (n / 1000000).toStringAsFixed(0) + "M";
  } else if (n > 1000) {
    return (n / 1000).toStringAsFixed(0) + "k";
  } else {
    return "${n}";
  }
}
