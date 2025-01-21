import 'package:freeflow/view_model/feed_viewmodel.dart';
import 'package:freeflow/view_model/router.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerSingleton<FeedViewModel>(FeedViewModel());
  locator.registerSingleton<RouterThing>(RouterThing());
}
