import 'package:amberflutter/amberflutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/screens/create.dart';
import 'package:freeflow/screens/create_preview.dart';
import 'package:freeflow/screens/layout.dart';
import 'package:freeflow/screens/login.dart';
import 'package:freeflow/screens/notifications.dart';
import 'package:freeflow/screens/new_account.dart';
import 'package:freeflow/screens/profile_screen.dart';
import 'package:freeflow/screens/root.dart';
import 'package:freeflow/screens/search_screen.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:freeflow/widgets/short_video.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';
import 'package:ndk_amber/data_layer/data_sources/amber_flutter.dart';
import 'package:ndk_amber/data_layer/repositories/signers/amber_event_signer.dart';
import 'package:ndk_objectbox/ndk_objectbox.dart';
import 'package:ndk_rust_verifier/data_layer/repositories/verifiers/rust_event_verifier.dart';

class NoVerify extends EventVerifier {
  @override
  Future<bool> verify(Nip01Event event) {
    return Future.value(true);
  }
}

final ndk_cache = DbObjectBox();
final eventVerifier = kDebugMode ? NoVerify() : RustEventVerifier();
var ndk = Ndk(
  NdkConfig(
    eventVerifier: eventVerifier,
    cache: ndk_cache,
  ),
);

final SHORT_KIND = [22];
final USER_AGENT = "freeflow/1.0";
const DEFAULT_RELAYS = [
  "wss://nos.lol",
  "wss://relay.damus.io",
  "wss://relay.primal.net"
];
const SEARCH_RELAYS = [
  "wss://relay.nostr.band/",
  "wss://search.nos.today/",
  "wss://relay.noswhere.com/"
];

final LOGIN = LoginData();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // reload / cache login data
  LOGIN.addListener(() {
    if (LOGIN.value != null) {
      if (!ndk.accounts.hasAccount(LOGIN.value!.pubkey)) {
        switch (LOGIN.value!.type) {
          case AccountType.privateKey:
            ndk.accounts.loginPrivateKey(
                pubkey: LOGIN.value!.pubkey, privkey: LOGIN.value!.privateKey!);
          case AccountType.externalSigner:
            ndk.accounts.loginExternalSigner(
                signer: AmberEventSigner(
                    publicKey: LOGIN.value!.pubkey,
                    amberFlutterDS: AmberFlutterDS(Amberflutter())));
          case AccountType.publicKey:
            ndk.accounts.loginPublicKey(pubkey: LOGIN.value!.pubkey);
        }
      }
      ndk.metadata.loadMetadata(LOGIN.value!.pubkey);
      ndk.follows.getContactList(LOGIN.value!.pubkey);
    }
  });

  await LOGIN.load();

  runApp(MaterialApp.router(
    routerConfig: GoRouter(routes: [
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              SafeArea(child: LayoutScreen(navigationShell), top: false),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: "/",
                builder: (context, state) => RootScreen(),
              ),
              GoRoute(
                path: "/p/:pubkey",
                builder: (context, state) =>
                    ProfileScreen(pubkey: state.pathParameters["pubkey"]!),
              ),
              GoRoute(
                  path: "/search", builder: (context, state) => SearchScreen()),
              GoRoute(
                path: "/messages",
                builder: (context, state) => NotificationsScreen(),
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
                  ]),
              GoRoute(
                path: "/e/:id",
                builder: (ctx, state) {
                  if (state.extra is Nip01Event) {
                    return ShortVideoPlayer(
                        Video.fromEvent(state.extra as Nip01Event));
                  } else {
                    return RxFilter<Nip01Event>(
                      filter: Filter(
                        ids: [Nip19.decode(state.pathParameters["id"]!)],
                      ),
                      builder: (ctx, data) {
                        final ev = (data?.length ?? 0) > 0 ? data!.first : null;
                        if (ev != null) {
                          return ShortVideoPlayer(Video.fromEvent(ev));
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    );
                  }
                },
              )
            ]),
          ]),
    ]),
  ));
}

String formatSats(int n) {
  if (n >= 1000000) {
    return (n / 1000000).toStringAsFixed(1) + "M";
  } else if (n >= 1000) {
    return (n / 1000).toStringAsFixed(1) + "k";
  } else {
    return "${n}";
  }
}

String zapSum(List<Nip01Event> zaps) {
  final total = zaps
      .map((e) => ZapReceipt.fromEvent(e))
      .fold(0, (acc, v) => acc + (v.amountSats ?? 0));
  return formatSats(total);
}
