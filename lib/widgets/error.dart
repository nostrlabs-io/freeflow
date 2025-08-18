import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String error;
  final double? size;

  const ErrorText(this.error, {super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      error,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.red, fontWeight: FontWeight.bold, fontSize: size ?? 18),
    );
  }
}
