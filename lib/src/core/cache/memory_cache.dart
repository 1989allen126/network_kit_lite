import 'package:network_kit_lite/src/core/cache/cache_storage.dart';

/// 内存缓存实现
class MemoryCache implements CacheStorage {
  final Map<String, CacheEntry> _cache = {};

  @override
  Future<void> init() async {
    // 内存缓存不需要初始化
  }

  @override
  Future<void> save(String key, dynamic value, {Duration? duration}) async {
    _cache[key] = CacheEntry(
      key: key,
      data: value,
      expiresAt: duration != null ? DateTime.now().add(duration) : null,
    );
  }

  @override
  Future<dynamic> get(String key) async {
    final entry = _cache[key];
    if (entry == null) return null;

    // 检查是否过期
    if (entry.expiresAt != null && entry.expiresAt!.isBefore(DateTime.now())) {
      _cache.remove(key);
      return null;
    }

    return entry.data;
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
  }

  @override
  Future<List<String>> getAllKeys() async {
    return _cache.keys.toList();
  }

  @override
  Future<void> removeExpiredEntries(List<String> keys) async {
    for (final key in keys) {
      _cache.remove(key);
    }
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<int> getSize() async {
    return _cache.length;
  }

  @override
  Future<void> close() async {

  }
}
