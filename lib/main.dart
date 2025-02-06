import 'package:flutter/material.dart';
import 'package:freeflow/metadata.dart';
import 'package:freeflow/screens/create.dart';
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
import 'package:nostr_sdk/nostr_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NostrSdk.init();
  NOSTR.addRelay(url: "wss://nos.lol");
  NOSTR.addRelay(url: "wss://relay.damus.io");
  NOSTR.addRelay(url: "wss://relay.snort.social");
  NOSTR.connect();

  final l = LoginData();

  // reload / cache login data
  l.addListener(() {
    // ndk.metadata.loadMetadata(l.value!.pubkey);
    // ndk.follows.getContactList(l.value!.pubkey);
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

final SHORT_KIND = [22, 34236];
final USER_AGENT = "freeflow/1.0";

final NOSTR = Client.builder().build();

class N {
  static Future<Set<String>> contactList(String pubkey) async {
    final evs = await NOSTR.fetchEvents(
        filter: Filter()
            .kind(kind: 3)
            .author(author: PublicKey.parse(publicKey: pubkey)),
        timeout: Duration(seconds: 30));

    return evs
            .first()
            ?.tags()
            .where((t) => t.kind() == "p")
            .map((t) => t.content())
            .where((t) => t != null)
            .map((t) => t!)
            .toSet() ??
        new Set();
  }

  static Future<Metadata?> profile(String pubkey) async {
    final evs = await NOSTR.fetchEvents(
        filter: Filter()
            .kind(kind: 0)
            .author(author: PublicKey.parse(publicKey: pubkey)),
        timeout: Duration(seconds: 30));
    final json = evs.first()?.content();
    if (json != null) {
      return Metadata.fromString(json);
    } else {
      return null;
    }
  }

  static Future<List<ParsedZap>> zapReceipts(String pubkey) async {
    final evs = await NOSTR.fetchEvents(
        filter: Filter()
            .kind(kind: 9735)
            .pubkey(pubkey: PublicKey.parse(publicKey: pubkey)),
        timeout: Duration(seconds: 30));
    return evs.toVec().map((e) => ParsedZap.fromEvent(e)).toList();
  }
}

class ParsedZap {
  int? amount;

  ParsedZap(this.amount);

  static ParsedZap fromEvent(Event e) {
    return ParsedZap(null);
  }
}

String formatSats(int n) {
  if (n > 1000000) {
    return (n / 1000000).toStringAsFixed(0) + "M";
  } else if (n > 1000) {
    return (n / 1000).toStringAsFixed(0) + "k";
  } else {
    return "${n}";
  }
}
