import 'dart:convert';

import 'package:bech32/bech32.dart';
import 'package:bip340/bip340.dart';
import 'package:convert/convert.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AccountType { Keys }

class Account {
  final AccountType type;
  final String pubkey;
  final String? privateKey;

  Account._(
      {required this.type, required this.pubkey, required this.privateKey});

  static Account nip19(String key) {
    final data = Bech32Decoder().convert(key);
    final hexData = hex.encode(data.data);
    final pubkey = data.hrp == "nsec" ? getPublicKey(hexData) : hexData;
    final privateKey = data.hrp != "nsec" ? null : hexData;
    return Account._(
        type: AccountType.Keys, pubkey: pubkey, privateKey: privateKey);
  }

  static Account nsec(String key) {
    return Account._(
        type: AccountType.Keys,
        privateKey: key,
        pubkey: getPublicKey(key));
  }

  static Map<String, dynamic> toJson(Account? acc) => {
        "type": acc?.type.name,
        "pubKey": acc?.pubkey,
        "privateKey": acc?.privateKey
      };

  static Account? fromJson(Map<String, dynamic> json) {
    if (json.length > 2 && json.containsKey("pubKey")) {
      return Account._(
          type: AccountType.Keys,
          pubkey: json["pubKey"],
          privateKey: json["privateKey"]);
    }
    return null;
  }
}

class LoginData extends ValueNotifier<Account?> {
  final _storage = FlutterSecureStorage();
  static const String _StorageKey = "accounts";

  LoginData() : super(null) {
    super.addListener(() async {
      final data = json.encode(Account.toJson(this.value));
      await _storage.write(key: _StorageKey, value: data);
    });
  }

  Future<void> load() async {
    final acc = await _storage.read(key: _StorageKey);
    if (acc != null) {
      super.value = Account.fromJson(json.decode(acc));
    }
  }
}
