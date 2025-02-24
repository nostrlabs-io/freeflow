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
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                alignment: AlignmentDirectional.center,
                height: 40,
                child: TextField(
                  onSubmitted: (v) {
                    setState(() {
                      _searchFilter = Filter(
                          search: v, kinds: [...SHORT_KIND, 0], limit: 50);
                    });
                  },
                  controller: _search,
                  decoration: InputDecoration.collapsed(hintText: "Search"),
                ),
              ),
            ),
            if (_searchFilter != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: SingleChildScrollView(
                    child: RxFilter<Nip01Event>(
                      key: Key("search-${_searchFilter.hashCode}"),
                      relays: SEARCH_RELAYS,
                      filter: _searchFilter!,
                      builder: (ctx, data) {
                        final shorts =
                            data?.where((e) => SHORT_KIND.contains(e.kind));
                        final profiles = data?.where((e) => e.kind == 0);
                        return Column(
                          spacing: 5,
                          children: [
                            Text("${data?.length ?? 0} results"),
                            if ((shorts?.length ?? 0) > 0)
                              VideoGridWidget(data
                                      ?.map((e) => Video.fromEvent(e))
                                      .toList() ??
                                  []),
                            ...(profiles?.map(_searchRow).nonNulls ?? [])
                          ],
                        );
                      },
                    ),
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
