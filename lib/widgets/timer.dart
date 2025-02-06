import 'dart:async';

import 'package:flutter/widgets.dart';

class TimerWidget extends StatefulWidget {
  final Duration interval;
  final WidgetBuilder builder;

  TimerWidget(this.interval, this.builder);

  @override
  State<StatefulWidget> createState() => _TimerWidget(interval, builder);
}

class _TimerWidget extends State<TimerWidget> {
  final Duration interval;
  final WidgetBuilder builder;
  late Timer timer;

  _TimerWidget(this.interval, this.builder);

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(interval, (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return this.builder(context);
  }
}
