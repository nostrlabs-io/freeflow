import 'package:flutter/material.dart';
import 'package:freeflow/screens/feed_screen.dart';
import 'package:freeflow/service_locator.dart';
import 'package:ndk/ndk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FeedScreen(),
  ));
}

final ndk = Ndk(
  // Configure the Ndk instance using NdkConfig
  NdkConfig(
    eventVerifier: Bip340EventVerifier(),
    cache: MemCacheManager(),
  ),
);

final SHORT_KIND = 34236;