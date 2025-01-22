import 'package:flutter/material.dart';
import 'package:freeflow/utils/tik_tok_icons_icons.dart';
import 'package:freeflow/widgets/bottom_bar.dart';
import 'package:go_router/go_router.dart';

class LayoutScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  static const double NavigationIconSize = 20.0;
  static const double CreateButtonWidth = 38.0;
  static const double ButtonWidth = 60.0;

  LayoutScreen(this.navigationShell) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomBar(),
    );
  }
}
