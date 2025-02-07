import 'package:flutter/widgets.dart';
import 'package:freeflow/theme.dart';

class BasicButton extends StatelessWidget {
  final Widget? child;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final void Function()? onTap;

  const BasicButton(this.child,
      {this.decoration, this.padding, this.margin, this.onTap});

  static text(String text,
      {BoxDecoration? decoration,
      EdgeInsetsGeometry? padding,
      EdgeInsetsGeometry? margin,
      void Function()? onTap,
      double? fontSize}) {
    return BasicButton(
      Text(
        text,
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      decoration: decoration,
      padding: padding,
      margin: margin,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 50,
        padding: padding,
        margin: margin,
        decoration: decoration ??
            BoxDecoration(
              color: NEUTRAL_800,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
