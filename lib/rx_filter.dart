import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/ndk.dart';
import 'package:rxdart/rxdart.dart';

/**
 * Reactive filter which builds the widget with a snapshot of the data
 */
class RxFilter<T> extends StatefulWidget {
  final Filter filter;
  final bool leaveOpen;
  final Widget Function(BuildContext, List<T>?) builder;
  final T Function(Nip01Event)? mapper;

  RxFilter(
      {Key? key,
      required this.filter,
      required this.builder,
      this.mapper,
      this.leaveOpen = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RxFilter<T>();
}

class _RxFilter<T> extends State<RxFilter<T>> {
  late NdkResponse _response;
  HashMap<String, (int, T)>? _events;

  @override
  void initState() {
    super.initState();
    print("RX:SEDNING ${widget.filter}");
    _response = ndk.requests.subscription(
        filters: [widget.filter], cacheRead: true, cacheWrite: true);
    if (!widget.leaveOpen) {
      _response.future.then((_) {
        ndk.requests.closeSubscription(_response.requestId);
      });
    }
    _response.stream
        .bufferTime(const Duration(milliseconds: 500))
        .where((events) => events.isNotEmpty)
        .listen((events) {
      setState(() {
        _events ??= HashMap();
        events.forEach(_replaceInto);
      });
    });
  }

  void _replaceInto(Nip01Event ev) {
    final evKey = _eventKey(ev);
    final existing = _events?[evKey];
    if (existing == null || existing.$1 < ev.createdAt) {
      _events?[evKey] =
          (ev.createdAt, widget.mapper != null ? widget.mapper!(ev) : ev as T);
    }
  }

  String _eventKey(Nip01Event ev) {
    if ([0, 3].contains(ev.kind) || (ev.kind >= 10000 && ev.kind < 20000)) {
      return "${ev.kind}:${ev.pubKey}";
    } else if (ev.kind >= 30000 && ev.kind < 40000) {
      return "${ev.kind}:${ev.pubKey}:${ev.getDtag()}";
    } else {
      return ev.id;
    }
  }

  @override
  void dispose() {
    super.dispose();

    print("RX:CLOSING ${widget.filter}");
    ndk.requests.closeSubscription(_response.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context,
        _events == null ? null : _events!.values.map((v) => v.$2).toList());
  }
}

/** 
 * An async filter loader into [RxFilter]
 */
class RxFutureFilter<T> extends StatelessWidget {
  final Future<Filter> Function() filterBuilder;
  final bool leaveOpen;
  final Widget Function(BuildContext, List<T>?) builder;
  final Widget? loadingWidget;
  final T Function(Nip01Event)? mapper;

  RxFutureFilter({
    Key? key,
    required this.filterBuilder,
    required this.builder,
    this.mapper,
    this.leaveOpen = true,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Filter>(
      future: filterBuilder(),
      builder: (ctx, data) {
        if (data.hasData) {
          return RxFilter<T>(
              filter: data.data!, mapper: mapper, builder: builder);
        } else {
          return loadingWidget ?? SizedBox.shrink();
        }
      },
    );
  }
}
