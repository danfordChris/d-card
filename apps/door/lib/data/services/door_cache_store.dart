import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;

import 'door_cache.dart';

/// Where the cache's encryption key lives (the device keystore in the app).
abstract interface class CacheKeyStore {
  Future<String?> read();
  Future<void> write(String key);
  Future<void> delete();
}

/// Keychain (iOS) / Keystore-backed storage (Android) via flutter_secure_storage.
class SecureCacheKeyStore implements CacheKeyStore {
  SecureCacheKeyStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'door.cache_key';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String key) => _storage.write(key: _key, value: key);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

/// Opens and deletes the cache database file.
abstract interface class CacheDatabaseOpener {
  Future<Database> open(String password);
  Future<void> delete();
}

/// SQLCipher database in the app's database directory (never Hive; offline-sync 9.1).
class SqlCipherOpener implements CacheDatabaseOpener {
  const SqlCipherOpener();

  static const fileName = 'door_cache.db';

  Future<String> _path() async => p.join(await sqlcipher.getDatabasesPath(), fileName);

  @override
  Future<Database> open(String password) async => sqlcipher.openDatabase(
    await _path(),
    password: password,
    version: DoorCache.schemaVersion,
    onCreate: DoorCache.createSchema,
  );

  @override
  Future<void> delete() async => sqlcipher.deleteDatabase(await _path());
}

/// The encrypted cache: a random 256-bit key in secure storage, the database opened with it.
///
/// [wipe] deletes the database file and the key, so nothing cached can be read afterwards.
class DoorCacheStore {
  DoorCacheStore({required this._keys, this._opener = const SqlCipherOpener(), Random? random})
    : _random = random ?? Random.secure();

  final CacheKeyStore _keys;
  final CacheDatabaseOpener _opener;
  final Random _random;
  Future<DoorCache>? _opening;

  /// The open cache (created with a new key on first use).
  Future<DoorCache> open() => _opening ??= _open().catchError((Object e) {
    _opening = null;
    throw e;
  });

  Future<DoorCache> _open() async {
    var key = await _keys.read();
    if (key == null) {
      // A database left without its key cannot be read: start clean.
      await _opener.delete();
      key = base64Url.encode(List<int>.generate(32, (_) => _random.nextInt(256)));
      await _keys.write(key);
    }
    try {
      return DoorCache(await _opener.open(key));
    } catch (_) {
      // Wrong key or corrupt file: the cache is only a copy, so recreate it.
      await _opener.delete();
      return DoorCache(await _opener.open(key));
    }
  }

  /// Closes and deletes the cache and its key.
  Future<void> wipe() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) {
      try {
        await (await opening).close();
      } catch (_) {}
    }
    await _opener.delete();
    await _keys.delete();
  }
}
