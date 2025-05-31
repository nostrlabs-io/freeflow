import 'package:flutter/material.dart';
import 'package:freeflow/data/video.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/rx_filter.dart';
import 'package:freeflow/widgets/avatar.dart';
import 'package:freeflow/widgets/profile_loader.dart';
import 'package:freeflow/widgets/profile_name.dart';
import 'package:freeflow/widgets/video_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _search = TextEditingController();
  Filter? _searchFilter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                alignment: AlignmentDirectional.center,
                child: TextField(
                  onSubmitted: (v) {
                    setState(() {
                      _searchFilter = Filter(
                          search: v, kinds: [...SHORT_KIND, 0], limit: 50);
                    });
                  },
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                ),
              ),
            ),
            if (_searchFilter != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(5),
                  child: RxFilter<Nip01Event>(
                    key: Key("search-${_searchFilter.hashCode}"),
                    relays: SEARCH_RELAYS,
                    filters: [_searchFilter!],
                    builder: (ctx, data) {
                      final shorts =
                          data?.where((e) => SHORT_KIND.contains(e.kind));
                      final profiles = data?.where((e) => e.kind == 0);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 5,
                        children: [
                          if ((shorts?.length ?? 0) > 0) ...[
                            Text("${shorts?.length ?? 0} shorts"),
                            VideoGridWidget(
                              shorts?.map((e) => Video.fromEvent(e)).toList() ??
                                  [],
                              cols: 2,
                              title: (v) => Text(
                                v.videoTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (profiles?.isNotEmpty ?? false) ...[
                            Text("${profiles?.length} profiles"),
                            ...profiles?.map(_searchRow).nonNulls ?? [],
                          ]
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _searchRow(Nip01Event ev) {
    switch (ev.kind) {
      case 0:
        {
          return ProfileLoaderWidget(
            ev.pubKey,
            (ctx, data) {
              final profile = data.data ?? Metadata(pubKey: ev.pubKey);
              return GestureDetector(
                onTap: () {
                  ctx.push("/p/${profile.pubKey}", extra: profile);
                },
                child: Row(
                  spacing: 5,
                  children: [
                    AvatarWidget(profile: profile),
                    ProfileNameWidget(profile: profile)
                  ],
                ),
              );
            },
          );
        }
    }
    return null;
  }
}
