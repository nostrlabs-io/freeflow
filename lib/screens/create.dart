import 'package:flutter/material.dart';

class CreateShortScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateShortScreen();
}

class _CreateShortScreen extends State<CreateShortScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Text("Coming soon...")
            ],
          )),
    );
  }
}
