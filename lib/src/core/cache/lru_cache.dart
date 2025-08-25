import 'package:network_kit_lite/src/core/cache/cache_storage.dart';
import 'package:network_kit_lite/src/core/cache/memory_cache.dart';

/// LRU缓存实现（基于内存缓存）
class LRUCache implements CacheStorage {
  final int _capacity;
  final MemoryCache _memoryCache = MemoryCache();
  final List<String> _lruKeys = [];

  LRUCache(this._capacity);

  @override
  Future<void> init() async {
    await _memoryCache.init();
  }

  @override
  Future<void> save(String key, dynamic value, {Duration? duration}) async {
    // 如果缓存已满，移除最久未使用的项
    if (_lruKeys.length >= _capacity) {
      final oldestKey = _lruKeys.removeAt(0);
      await _memoryCache.remove(oldestKey);
    }

    // 如果key已存在，先移除
    if (_lruKeys.contains(key)) {
      _lruKeys.remove(key);
    }

    // 添加到缓存并标记为最近使用
    await _memoryCache.save(key, value, duration: duration);
    _lruKeys.add(key);
  }

  @override
  Future<dynamic> get(String key) async {
    final value = await _memoryCache.get(key);
    if (value != null) {
      // 标记为最近使用
      _lruKeys.remove(key);
      _lruKeys.add(key);
    }
    return value;
  }

  @override
  Future<void> remove(String key) async {
    await _memoryCache.remove(key);
    _lruKeys.remove(key);
  }

  @override
  Future<void> removeExpiredEntries(List<String> keys) async {
    for (final key in keys) {
      await _memoryCache.remove(key);
      _lruKeys.remove(key);
    }
  }

  @override
  Future<void> clear() async {
    await _memoryCache.clear();
    _lruKeys.clear();
  }

  @override
  Future<int> getSize() async {
    return _lruKeys.length;
  }

  @override
  Future<void> close() async {
    // 什么都不用做
  }

  @override
  Future<List<String>> getAllKeys() async {
    return  _lruKeys.map((key) => key.toString()).toList();
  }
}
