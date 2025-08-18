import 'dart:convert';
import 'dart:developer' as developer;

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:freeflow/main.dart';
import 'package:ndk/ndk.dart';
import 'package:http/http.dart' as http;

class Notepush {
  final String base;
  final EventSigner signer;

  Notepush(this.base, {required this.signer});

  Future<String> register(String token) async {
    final pubkey = signer.getPublicKey();
    final url =
        "$base/user-info/$pubkey/${Uri.encodeComponent(token)}?backend=fcm";
    final rsp = await _sendPutRequest(url);
    return rsp.body;
  }

  Future<List<String>> getWatchedKeys() async {
    final pubkey = signer.getPublicKey();
    final url = "$base/user-info/$pubkey/notify";
    final rsp = await _sendGetRequest(url);
    final List<dynamic> obj = JsonCodec().decode(rsp.body);
    return List<String>.from(obj);
  }

  Future<void> watchPubkey(String target, List<int> kinds) async {
    final pubkey = signer.getPublicKey();
    final url = "$base/user-info/$pubkey/notify/$target";
    await _sendPutRequest(url, body: {"kinds": kinds});
  }

  Future<void> removeWatchPubkey(String target) async {
    final pubkey = signer.getPublicKey();
    final url = "$base/user-info/$pubkey/notify/$target";
    await _sendDeleteRequest(url);
  }

  Future<void> setNotificationSettings(String token, List<int> kinds) async {
    final pubkey = signer.getPublicKey();
    final url =
        "$base/user-info/$pubkey/${Uri.encodeComponent(token)}/preference";
    await _sendPutRequest(url, body: {"kinds": kinds});
  }

  Future<http.Response> _sendPutRequest(String url, {Object? body}) async {
    final jsonBody = body != null ? JsonCodec().encode(body) : null;
    final auth = await _makeAuth("PUT", url, body: jsonBody);
    final rsp = await http.put(
      Uri.parse(url),
      body: jsonBody,
      headers: {
        "authorization": "Nostr $auth",
        "accept": "application/json",
        "content-type": "application/json",
      },
    ).timeout(Duration(seconds: 10));
    developer.log(rsp.body);
    return rsp;
  }

  Future<http.Response> _sendGetRequest(String url, {Object? body}) async {
    final jsonBody = body != null ? JsonCodec().encode(body) : null;
    final auth = await _makeAuth("GET", url, body: jsonBody);
    final rsp = await http.get(
      Uri.parse(url),
      headers: {
        "authorization": "Nostr $auth",
        "accept": "application/json",
        "content-type": "application/json",
      },
    ).timeout(Duration(seconds: 10));
    developer.log(rsp.body);
    return rsp;
  }

  Future<http.Response> _sendDeleteRequest(String url, {Object? body}) async {
    final jsonBody = body != null ? JsonCodec().encode(body) : null;
    final auth = await _makeAuth("DELETE", url, body: jsonBody);
    final rsp = await http.delete(
      Uri.parse(url),
      headers: {
        "authorization": "Nostr $auth",
        "accept": "application/json",
        "content-type": "application/json",
      },
    ).timeout(Duration(seconds: 10));
    developer.log(rsp.body);
    return rsp;
  }

  Future<String> _makeAuth(String method, String url, {String? body}) async {
    final pubkey = signer.getPublicKey();
    var tags = [
      ["u", url],
      ["method", method],
    ];
    if (body != null) {
      final hash = hex.encode(sha256.convert(utf8.encode(body)).bytes);
      tags.add(["payload", hash]);
    }
    final authEvent = Nip01Event(
      pubKey: pubkey,
      kind: 27235,
      tags: tags,
      content: "",
    );
    await signer.sign(authEvent);
    return authEvent.toBase64();
  }
}

Notepush? getNotificationService() {
  final signer = ndk.accounts.getLoggedAccount()?.signer;
  return signer != null
      ? Notepush("https://notepush.nostrlabs.io", signer: signer)
      : null;
}
