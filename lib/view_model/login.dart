import 'dart:convert';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/utils.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

enum WalletType { nwc }

class WalletConfig {
  final WalletType type;
  final String data;
  final String? privateKey;

  WalletConfig({required this.type, required this.data, this.privateKey});

  Map<String, dynamic> toJson() {
    return {"type": type.name, "data": data, "privateKey": privateKey};
  }

  static WalletConfig fromJson(Map<String, dynamic> json) {
    final type = WalletType.values.firstWhereOrNull(
      (v) => v.name == json["type"],
    );
    if (type == null) {
      throw "Invalid wallet type: ${json["type"]}";
    }
    return WalletConfig(
      type: type,
      data: json["data"],
      privateKey: json["privateKey"],
    );
  }
}

class WalletInfo {
  final String name;
  final int balance;

  const WalletInfo({required this.name, required this.balance});
}

abstract class SimpleWallet {
  Future<String> payInvoice(String pr);
  Future<WalletInfo> getInfo();
}

class NWCWrapper extends SimpleWallet {
  final NwcConnection _conn;

  NWCWrapper({required NwcConnection conn}) : _conn = conn;

  @override
  Future<String> payInvoice(String pr) async {
    final rsp = await ndk.nwc.payInvoice(
      _conn,
      invoice: pr,
      timeout: Duration(seconds: 60),
    );
    if (rsp.preimage == null) {
      throw "Payment failed, preimage missing";
    } else {
      return rsp.preimage!;
    }
  }

  @override
  Future<WalletInfo> getInfo() async {
    final info = await ndk.nwc.getInfo(_conn);
    final balance = await ndk.nwc.getBalance(_conn);
    return WalletInfo(name: info.alias, balance: balance.balanceSats);
  }
}

class LoginAccount {
  final AccountType type;
  final String pubkey;
  final String? privateKey;
  final List<String>? signerRelays;
  final WalletConfig? wallet;

  SimpleWallet? _cachedWallet;

  LoginAccount({
    required this.type,
    required this.pubkey,
    this.privateKey,
    this.signerRelays,
    this.wallet,
  });

  static LoginAccount nip19(String key) {
    final keyData = bech32ToHex(key);
    final pubkey =
        Nip19.isKey("nsec", key) ? Bip340.getPublicKey(keyData) : keyData;
    final privateKey = Nip19.isKey("npub", key) ? null : keyData;
    return LoginAccount(
      type: Nip19.isKey("npub", key)
          ? AccountType.publicKey
          : AccountType.privateKey,
      pubkey: pubkey,
      privateKey: privateKey,
    );
  }

  static LoginAccount privateKeyHex(String key) {
    return LoginAccount(
      type: AccountType.privateKey,
      privateKey: key,
      pubkey: Bip340.getPublicKey(key),
    );
  }

  static LoginAccount externalPublicKeyHex(String key) {
    return LoginAccount(type: AccountType.externalSigner, pubkey: key);
  }

  static LoginAccount bunker(
    String privateKey,
    String pubkey,
    List<String> relays,
  ) {
    return LoginAccount(
      type: AccountType.externalSigner,
      pubkey: pubkey,
      privateKey: privateKey,
      signerRelays: relays,
    );
  }

  static Map<String, dynamic> toJson(LoginAccount? acc) => {
        "type": acc?.type.name,
        "pubKey": acc?.pubkey,
        "privateKey": acc?.privateKey,
        "wallet": acc?.wallet?.toJson(),
      };

  static LoginAccount? fromJson(Map<String, dynamic> json) {
    if (json.length > 2 && json.containsKey("pubKey")) {
      if ((json["pubKey"] as String).length != 64) {
        throw "Invalid pubkey, length != 64";
      }
      if (json.containsKey("privateKey")) {
        final privKey = json["privateKey"] as String?;
        if (privKey != null && privKey.length != 64) {
          throw "Invalid privateKey, length != 64";
        }
      }
      return LoginAccount(
        type: AccountType.values.firstWhere(
          (v) => v.toString().endsWith(json["type"] as String),
        ),
        pubkey: json["pubKey"],
        privateKey: json["privateKey"],
        wallet: json.containsKey("wallet") && json["wallet"] != null
            ? WalletConfig.fromJson(json["wallet"])
            : null,
      );
    }
    return null;
  }

  Future<SimpleWallet?> getWallet() async {
    if (_cachedWallet == null && wallet != null) {
      switch (wallet!.type) {
        case WalletType.nwc:
          {
            try {
              final conn = await ndk.nwc.connect(wallet!.data);
              _cachedWallet = NWCWrapper(conn: conn);
            } catch (e) {
              developer.log("Failed to setup wallet: $e");
            }
            break;
          }
      }
    }
    return _cachedWallet;
  }
}

class LoginData extends ValueNotifier<LoginAccount?> {
  final _storage = FlutterSecureStorage();
  static const String _storageKey = "accounts";

  LoginData() : super(null) {
    super.addListener(() async {
      if (value != null) {
        final data = json.encode(LoginAccount.toJson(value));
        await _storage.write(key: _storageKey, value: data);
      } else {
        await _storage.delete(key: _storageKey);
      }
    });
  }

  void logout() {
    super.value = null;
  }

  Future<void> load() async {
    final acc = await _storage.read(key: _storageKey);
    if (acc?.isNotEmpty ?? false) {
      try {
        super.value = LoginAccount.fromJson(json.decode(acc!));
      } catch (e) {
        developer.log(e.toString());
      }
    }
  }

  void configure({
    List<String>? signerRelays,
    WalletConfig? wallet,
    String? streamEndpoint,
  }) {
    if (value != null) {
      value = LoginAccount(
        type: value!.type,
        pubkey: value!.pubkey,
        privateKey: value!.privateKey,
        signerRelays: signerRelays ?? value!.signerRelays,
        wallet: wallet,
      );
    }
  }
}
