import 'dart:convert';

class Metadata {
  String? get name {
    return _inner["name"] as String?;
  }

  String? get display_name {
    return _inner["display_name"] as String?;
  }

  String? get picture {
    return _inner["picture"] as String?;
  }

  String? get about {
    return _inner["about"] as String?;
  }

  String? get website {
    return _inner["website"] as String?;
  }

  String? get lud16 {
    return _inner["lud16"] as String?;
  }

  Map<String, dynamic> _inner;

  Metadata(this._inner);

  static Metadata empty() {
    return Metadata(new Map());
  }

  static Metadata fromString(String json) {
    return Metadata(jsonDecode(json));
  }
}
