import 'package:stacked/stacked.dart';

class RouterThing extends BaseViewModel {
  int _currentRoute = 0;

  void setRoute(int n) {
    _currentRoute = n;
    notifyListeners();
  }

  int get route {
    return _currentRoute;
  }
}
