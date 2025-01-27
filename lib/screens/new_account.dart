import 'package:flutter/material.dart';

class NewAccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewAccountScreen();
}

class _NewAccountScreen extends State<NewAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Text("Coming soon...")
          ],
        ),
      ),
    );
  }
}
