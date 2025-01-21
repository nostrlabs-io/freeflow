import 'package:flutter/material.dart';
import 'package:freeflow/screens/feed_screen.dart';
import 'package:freeflow/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FeedScreen(),
  ));
}
