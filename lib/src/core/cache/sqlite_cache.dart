import 'dart:convert';
import 'package:network_kit_lite/src/core/cache/cache_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite缓存实现
class SQLiteCache implements CacheStorage {
  static const String _tableName = 'cache';
  Database? _database;
  final Duration _defaultDuration;

  SQLiteCache({Duration? defaultDuration})
      : _defaultDuration = defaultDuration ?? const Duration(days: 7);

  @override
  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'app_cache.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName(key TEXT PRIMARY KEY, value TEXT, expiration INTEGER, timestamp INTEGER)',
        );
      },
      version: 1,
    );
  }

  @override
  Future<void> save(String key, dynamic value, {Duration? duration}) async {
    final db = _database;
    if (db == null) throw Exception('数据库未初始化');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final expiration = (duration ?? _defaultDuration).inMilliseconds;

    await db.insert(
      _tableName,
      {
        'key': key,
        'value': json.encode(value),
        'expiration': expiration,
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<dynamic> get(String key) async {
    final db = _database;
    if (db == null) throw Exception('数据库未初始化');

    final maps = await db.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final timestamp = map['timestamp'] as int;
    final expiration = map['expiration'] as int;

    // 检查是否过期
    if (DateTime.now().millisecondsSinceEpoch - timestamp > expiration) {
      await remove(key);
      return null;
    }

    return json.decode(map['value'] as String);
  }

  @override
  Future<void> remove(String key) async {
    final db = _database;
    if (db == null) throw Exception('数据库未初始化');

    await db.delete(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<void> clear() async {
    final db = _database;
    if (db == null) throw Exception('数据库未初始化');

    await db.delete(_tableName);
  }

  @override
  Future<int> getSize() async {
    final db = _database;
    if (db == null) throw Exception('数据库未初始化');

    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> close() async {
  }

  @override
  Future<List<String>> getAllKeys() async {
    final db = _database;
    if (db == null) throw Exception('数据库未初始化');
    final result = await db.query(
      _tableName,
      columns: ['key'],
    );
    return result.map((row) => row['key'] as String).toList();
  }

  Future<void> removeExpiredEntries(List<String> keys) async {
    if (keys.isEmpty) return;
    final db = _database;
    if (db == null) throw Exception('数据库未初始化');
    final placeholders = List.filled(keys.length, '?').join(',');
    await db.execute(
      'DELETE FROM $_tableName WHERE key IN ($placeholders)',
      keys,
    );
  }
}
