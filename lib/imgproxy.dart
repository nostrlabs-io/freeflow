import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';

class ImgProxySettings {
  final String url;
  final String key;
  final String salt;

  ImgProxySettings({required this.url, required this.key, required this.salt});

  static ImgProxySettings static() {
    return ImgProxySettings(
        url: "https://imgproxy.v0l.io",
        key:
            "a82fcf26aa0ccb55dfc6b4bd6a1c90744d3be0f38429f21a8828b43449ce7cebe6bdc2b09a827311bef37b18ce35cb1e6b1c60387a254541afa9e5b4264ae942",
        salt:
            "a897770d9abf163de055e9617891214e75a9016d748f8ef865e6ffbcb9ed932295659549773a22a019a5f06d0b440c320be411e3fddfe784e199e4f03d74bd9b");
  }
}

String urlSafe(String s) {
  return s.replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
}

String signUrl(String u, ImgProxySettings settings) {
  final keyBytes = hex.decode(settings.key);
  final saltBytes = hex.decode(settings.salt);
  final uBytes = utf8.encode(u);

  final hmac = Hmac(sha256, keyBytes);
  final result = hmac.convert(saltBytes + uBytes);

  return urlSafe(base64.encode(result.bytes));
}

String proxyImg(BuildContext context, String url,
    {ImgProxySettings? settings, int? resize, String? sha256, double? dpr}) {
  final s = settings == null ? ImgProxySettings.static() : settings;

  if (url.startsWith("data:") || url.startsWith("blob:") || url.isEmpty) {
    return url;
  }

  final opts = <String>[];

  if (sha256 != null) {
    opts.add('hs:sha256:$sha256');
  }

  if (resize != null) {
    opts.add('rs:fit:$resize:$resize');
  }

  final q = MediaQuery.of(context);
  opts.add('dpr:${q.devicePixelRatio}');

  final urlBytes = utf8.encode(url);
  final urlEncoded = urlSafe(base64.encode(urlBytes));

  final path = '/${opts.join("/")}/$urlEncoded';
  final sig = signUrl(path, s);

  return '${s.url}/$sig$path';
}
