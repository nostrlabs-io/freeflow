import 'dart:convert';

import 'package:bech32/bech32.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:ndk/domain_layer/entities/filter.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/domain_layer/usecases/zaps/zap_receipt.dart';
import 'package:ndk/shared/nips/nip19/hrps.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

String formatSats(int n) {
  if (n >= 1000000) {
    return (n / 1000000).toStringAsFixed(1) + "M";
  } else if (n >= 1000) {
    return (n / 1000).toStringAsFixed(1) + "k";
  } else {
    return "${n}";
  }
}

String zapSum(List<Nip01Event> zaps) {
  final total = zaps
      .map((e) => ZapReceipt.fromEvent(e))
      .fold(0, (acc, v) => acc + (v.amountSats ?? 0));
  return formatSats(total);
}

String bech32ToHex(String bech32) {
  final decoder = Bech32Decoder();
  final data = decoder.convert(bech32, 10_000);
  final data8bit = Nip19.convertBits(data.data, 5, 8, false);
  if (data.hrp == "nevent" || data.hrp == "naddr" || data.hrp == "nprofile") {
    final tlv = parseTLV(data8bit);
    return hex.encode(tlv.firstWhere((v) => v.type == 0).value);
  } else {
    return hex.encode(data8bit);
  }
}

class TLVTypes {
  static const int kSpecial = 0;
  static const int kRelay = 1;
  static const int kAuthor = 2;
  static const int kKind = 3;
}

class TLVEntity {
  final String hrp;
  final List<TLV> data;

  const TLVEntity(this.hrp, this.data);

  TLV? get special {
    return data.firstWhereOrNull((e) => e.type == TLVTypes.kSpecial);
  }

  /// return the special entry as hex
  String? get specialHex {
    final r = special;
    return r != null ? hex.encode(r.value) : null;
  }

  /// return the special entry as utf8 string
  String? get specialUtf8 {
    final r = special;
    return r != null ? utf8.decode(r.value) : null;
  }

  int? get kind {
    final k = data.firstWhereOrNull((e) => e.type == TLVTypes.kKind);
    return k != null
        ? k.value[0] << 24 | k.value[1] << 16 | k.value[2] << 8 | k.value[3]
        : null;
  }

  String? get author {
    final a = data.firstWhereOrNull((e) => e.type == TLVTypes.kAuthor);
    return a != null ? hex.encode(a.value) : null;
  }

  List<String>? get relays {
    final r = data.where((r) => r.type == TLVTypes.kRelay);
    if (r.isNotEmpty) {
      return r.map((e) => utf8.decode(e.value)).toList();
    }
    return null;
  }

  Filter toFilter() {
    var ret = <String, dynamic>{};
    if (hrp == Hrps.kNaddr) {
      final dTag = specialUtf8;
      final kindValue = kind;
      final authorValue = author;
      if (dTag == null || kindValue == null || authorValue == null) {
        throw "Invalid naddr entity, special, kind and author must be set";
      }
      ret["#d"] = [dTag];
      ret["authors"] = [authorValue];
      ret["kinds"] = [kindValue];
    } else if (hrp == Hrps.kNevent) {
      final idValue = specialHex;
      if (idValue == null) {
        throw "Invalid nevent, special entry is invalid or missing";
      }
      ret["ids"] = [idValue];
      final kindValue = kind;
      if (kindValue != null) {
        ret["kinds"] = [kindValue];
      }
      final authorValue = author;
      if (authorValue != null) {
        ret["authors"] = [authorValue];
      }
    } else if (hrp == Hrps.kNoteId) {
      final idValue = specialHex;
      if (idValue == null) {
        throw "Invalid nevent, special entry is invalid or missing";
      }
      ret["ids"] = [idValue];
    } else {
      throw "Cant convert $hrp to a filter";
    }
    return Filter.fromMap(ret);
  }
}

class TLV {
  final int type;
  final int length;
  final List<int> value;

  TLV(this.type, this.length, this.value);

  void validate() {
    if (type < 0 || type > 255) {
      throw ArgumentError('Type must be 0-255 (1 byte)');
    }
    if (length < 0 || length > 255) {
      throw ArgumentError('Length must be 0-255 (1 byte)');
    }
    if (length != value.length) {
      throw ArgumentError(
        'Length ($length) does not match value length (${value.length})',
      );
    }
    for (var byte in value) {
      if (byte < 0 || byte > 255) {
        throw ArgumentError('Value bytes must be 0-255');
      }
    }
  }
}

List<TLV> parseTLV(List<int> data) {
  List<TLV> result = [];
  int index = 0;

  while (index < data.length) {
    // Check if we have enough bytes for type and length
    if (index + 2 > data.length) {
      throw FormatException('Incomplete TLV data');
    }

    // Read type (1 byte)
    int type = data[index];
    index++;

    // Read length (1 byte)
    int length = data[index];
    index++;

    // Check if we have enough bytes for value
    if (index + length > data.length) {
      throw FormatException('TLV value length exceeds available data');
    }

    // Read value
    List<int> value = data.sublist(index, index + length);
    index += length;

    result.add(TLV(type, length, value));
  }

  return result;
}

List<int> serializeTLV(List<TLV> tlvs) {
  List<int> result = [];

  for (var tlv in tlvs) {
    tlv.validate();
    result.add(tlv.type);
    result.add(tlv.length);
    result.addAll(tlv.value);
  }

  return result;
}

/// Encodes TLV data into a Bech32 string
String encodeBech32TLV(String hrp, List<TLV> tlvs) {
  try {
    final data8bit = serializeTLV(tlvs);
    final data5bit = Nip19.convertBits(data8bit, 8, 5, true);
    final bech32Data = Bech32(hrp, data5bit);
    return bech32.encode(bech32Data, 10_000);
  } catch (e) {
    throw FormatException('Failed to encode Bech32 or TLV: $e');
  }
}

TLVEntity decodeBech32ToTLVEntity(String input) {
  final decoder = Bech32Decoder();
  final data = decoder.convert(input, 10_000);
  final data8bit = Nip19.convertBits(data.data, 5, 8, false);
  if (data.hrp != "npub" || data.hrp != "nsec" || data.hrp != "note") {
    return TLVEntity(data.hrp, parseTLV(data8bit));
  } else {
    // convert to basic type using special entry only
    return TLVEntity(data.hrp, [TLV(0, data8bit.length, data8bit)]);
  }
}
