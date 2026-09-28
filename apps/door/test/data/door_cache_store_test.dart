import 'dart:convert';

import 'package:dcard_door/data/services/door_cache_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fakes.dart';

void main() {
  test('creates a random 256-bit key in secure storage and opens the database with it', () async {
    final keys = MemoryKeyStore();
    final opener = MemoryDbOpener();
    final store = DoorCacheStore(keys: keys, opener: opener);
    final a = await store.open();
    expect(identical(a, await store.open()), isTrue, reason: 'opened once');
    expect(keys.key, isNotNull);
    expect(opener.passwords, [keys.key]);
    expect(opener.deletes, 1, reason: 'a database without a key is deleted before the key is created');

    final other = MemoryKeyStore();
    await DoorCacheStore(keys: other, opener: MemoryDbOpener()).open();
    expect(other.key, isNot(keys.key));
    expect(base64Url.decode(keys.key!), hasLength(32));
  });

  test('an existing key is reused', () async {
    final keys = MemoryKeyStore()..key = 'existing';
    final opener = MemoryDbOpener();
    await DoorCacheStore(keys: keys, opener: opener).open();
    expect(opener.passwords, ['existing']);
    expect(opener.deletes, 0);
  });

  test('wipe deletes the database and the key; the next open starts a new cache', () async {
    final keys = MemoryKeyStore();
    final opener = MemoryDbOpener();
    final store = DoorCacheStore(keys: keys, opener: opener);
    await (await store.open()).writeLockout(2, null);
    final firstKey = keys.key;

    await store.wipe();
    expect(keys.key, isNull);
    expect(keys.deletes, 1);
    expect(opener.current, isNull);

    final reopened = await store.open();
    expect(keys.key, isNot(firstKey));
    expect(await reopened.readLockout(), (0, null));
  });
}
