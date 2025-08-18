import 'package:flutter/material.dart';
import 'package:freeflow/theme.dart';

class BasicButton extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final void Function(BuildContext)? onTap;
  final bool? disabled;

  const BasicButton(
    this.child, {
    super.key,
    this.color,
    this.decoration,
    this.padding,
    this.margin,
    this.onTap,
    this.disabled,
  });

  static Widget text(
    String text, {
    Color? color,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    void Function(BuildContext)? onTap,
    double? fontSize,
    bool? disabled,
    Icon? icon,
  }) {
    return BasicButton(
      Text.rich(
        TextSpan(
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          children: [
            if (icon != null)
              WidgetSpan(child: icon, alignment: PlaceholderAlignment.middle),
            if (icon != null) TextSpan(text: " "),
            TextSpan(text: text),
          ],
        ),
      ),
      disabled: disabled,
      color: color,
      decoration: decoration,
      padding: padding ?? EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      margin: margin,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !(color != null && decoration != null),
      "Cant set both 'color' and 'decoration'",
    );
    final defaultBr = BorderRadius.circular(8);
    final inner = Container(
      padding: padding,
      margin: margin,
      decoration: decoration ??
          BoxDecoration(color: color ?? NEUTRAL_800, borderRadius: defaultBr),
      child: Center(child: child),
    );
    return GestureDetector(
      onTap: () {
        if (!(disabled ?? false) && onTap != null) {
          onTap!(context);
        }
      },
      child: (disabled ?? false) ? Opacity(opacity: 0.5, child: inner) : inner,
    );
  }
}
