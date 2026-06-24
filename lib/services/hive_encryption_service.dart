import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveEncryptionService {
  static const  FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked_this_device),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<List<int>> getKey({required String userId, required String boxName}) async {
    final keyName = 'hive_key_${userId}_$boxName';

    final encodedKey = await _storage.read(key: keyName);

    if (encodedKey != null) {
      return base64Url.decode(encodedKey);
    }

    final key = Hive.generateSecureKey();

    await _storage.write(
      key: keyName,
      value: base64UrlEncode(key),
    );

    return key;
  }
}