import 'package:flutter/widgets.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/ndk.dart';

class ProfileLoaderWidget extends StatelessWidget {
  final String pubkey;
  final AsyncWidgetBuilder<Metadata?> builder;

  ProfileLoaderWidget(this.pubkey, this.builder);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ndk.metadata.loadMetadata(pubkey), builder: builder);
  }
}
