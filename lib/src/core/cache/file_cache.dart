import 'dart:convert';
import 'dart:io';
import 'package:network_kit_lite/src/core/cache/cache_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

/// 文件缓存实现
class FileCache implements CacheStorage {
  final String _cacheDir;
  final Duration _defaultDuration;

  FileCache(this._cacheDir, {Duration? defaultDuration})
      : _defaultDuration = defaultDuration ?? const Duration(days: 7);

  @override
  Future<void> init() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  @override
  Future<void> save(String key, dynamic value, {Duration? duration}) async {
    final file = File('$_cacheDir/$key');
    final content = json.encode({
      'data': value,
      'expiration': (duration ?? _defaultDuration).inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await file.writeAsString(content);
  }

  @override
  Future<dynamic> get(String key) async {
    final file = File('$_cacheDir/$key');
    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      final jsonData = json.decode(content);

      // 检查是否过期
      final timestamp = jsonData['timestamp'] as int;
      final expiration = jsonData['expiration'] as int;
      if (DateTime.now().millisecondsSinceEpoch - timestamp > expiration) {
        await file.delete();
        return null;
      }

      return jsonData['data'];
    } catch (e) {
      if (kDebugMode) {
        print('读取文件缓存错误: $e');
      }
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    final file = File('$_cacheDir/$key');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) {
      return [];
    }

    final entities = await dir.list().toList();
    return entities
        .whereType<File>()
        .map((file) => basename(file.path).replaceAll('.cache', ''))
        .toList();
  }

  @override
  Future<void> removeExpiredEntries(List<String> keys) async {
    final futures = keys.map((key) => remove(key));
    await Future.wait(futures);
  }

  @override
  Future<void> clear() async {
    final dir = Directory(_cacheDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
  }

  @override
  Future<int> getSize() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) return 0;

    int size = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }

  @override
  Future<void> close() async {
  }
}
