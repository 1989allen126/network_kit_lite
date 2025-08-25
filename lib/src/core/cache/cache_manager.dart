import 'dart:async';
import 'package:network_kit_lite/src/core/cache/cache_storage.dart';
import 'package:flutter/foundation.dart';

class CacheManager {
  final CacheStorage _storage;
  final Duration _cleanupInterval;
  final int _maxCacheSize;
  final Duration _defaultCacheDuration;
  DateTime? _lastCleanup;
  bool _isInitialized = false;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  CacheManager(
    this._storage, {
    Duration cleanupInterval = const Duration(days: 1),
    int maxCacheSize = 1000,
    Duration defaultCacheDuration = const Duration(hours: 24),
  }) : _cleanupInterval = cleanupInterval,
       _maxCacheSize = maxCacheSize,
       _defaultCacheDuration = defaultCacheDuration;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _storage.init();
      
      // 启动时检查是否需要清理
      if (_shouldPerformCleanup()) {
        await _performCleanup();
      }
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ CacheManager 初始化成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheManager 初始化失败: $e');
      }
      rethrow;
    }
  }

  Future<void> save(
    String key,
    dynamic data, {
    Duration? duration,
  }) async {
    if (!_isInitialized) {
      throw StateError('CacheManager 未初始化，请先调用 init() 方法');
    }
    
    if (key.isEmpty) {
      throw ArgumentError('缓存键不能为空');
    }

    try {
      // 检查缓存大小限制
      await _checkCacheSize();
      
      // 定期清理过期缓存
      if (_shouldPerformCleanup()) {
        _performCleanup();
      }

      final effectiveDuration = duration ?? _defaultCacheDuration;
      final cacheEntry = CacheEntry(
        key: key,
        data: data,
        expiresAt: DateTime.now().add(effectiveDuration),
        createdAt: DateTime.now(),
        accessCount: 0,
        lastAccessed: DateTime.now(),
      );
      
      await _storage.save(key, cacheEntry.toJson());
      
      if (kDebugMode) {
        print('💾 缓存保存: $key, 过期时间: ${cacheEntry.expiresAt}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 缓存保存失败: $key, 错误: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> get(String key) async {
    if (!_isInitialized) {
      throw StateError('CacheManager 未初始化，请先调用 init() 方法');
    }
    
    if (key.isEmpty) {
      _cacheMisses++;
      return null;
    }

    try {
      final json = await _storage.get(key);
      if (json == null) {
        _cacheMisses++;
        return null;
      }

      final entry = CacheEntry.fromJson(json);
      if (entry.isExpired) {
        _cacheMisses++;
        _storage.remove(key);
        
        if (kDebugMode) {
          print('🗑️ 移除过期缓存: $key');
        }
        return null;
      }

      // 更新访问统计
      _cacheHits++;
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
      
      // 异步更新访问信息
      _storage.save(key, entry.toJson());
      
      if (kDebugMode) {
        print('🎯 缓存命中: $key');
      }
      
      return entry.data;
    } catch (e) {
      _cacheMisses++;
      if (kDebugMode) {
        print('❌ 缓存读取失败: $key, 错误: $e');
      }
      return null;
    }
  }

  Future<void> remove(String key) async {
    if (!_isInitialized) return;
    
    try {
      await _storage.remove(key);
      if (kDebugMode) {
        print('🗑️ 手动移除缓存: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 缓存移除失败: $key, 错误: $e');
      }
    }
  }

  Future<void> clear() async {
    if (!_isInitialized) return;
    
    try {
      await _storage.clear();
      _cacheHits = 0;
      _cacheMisses = 0;
      _lastCleanup = DateTime.now();
      
      if (kDebugMode) {
        print('🧹 清空所有缓存');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 清空缓存失败: $e');
      }
    }
  }

  Future<void> close() async {
    if (!_isInitialized) return;
    
    try {
      await _storage.close();
      _isInitialized = false;
      
      if (kDebugMode) {
        print('🔒 CacheManager 已关闭');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CacheManager 关闭失败: $e');
      }
    }
  }

  Future<void> forceCleanup() => _performCleanup();

  /// 获取缓存统计信息
  CacheStats get stats {
    final total = _cacheHits + _cacheMisses;
    final hitRate = total > 0 ? _cacheHits / total : 0.0;
    
    return CacheStats(
      hits: _cacheHits,
      misses: _cacheMisses,
      hitRate: hitRate,
      lastCleanup: _lastCleanup,
    );
  }

  /// 检查缓存大小并清理最少使用的缓存
  Future<void> _checkCacheSize() async {
    try {
      final allKeys = await _storage.getAllKeys();
      if (allKeys.length <= _maxCacheSize) return;
      
      // 获取所有缓存条目并按访问频率排序
      final entries = <String, CacheEntry>{};
      for (final key in allKeys) {
        final json = await _storage.get(key);
        if (json != null) {
          try {
            entries[key] = CacheEntry.fromJson(json);
          } catch (e) {
            // 忽略损坏的缓存条目
            _storage.remove(key);
          }
        }
      }
      
      // 按最少使用排序
      final sortedEntries = entries.entries.toList()
        ..sort((a, b) {
          // 先按访问次数排序，再按最后访问时间排序
          final accessCompare = a.value.accessCount.compareTo(b.value.accessCount);
          if (accessCompare != 0) return accessCompare;
          return a.value.lastAccessed.compareTo(b.value.lastAccessed);
        });
      
      // 删除最少使用的缓存
      final toRemove = sortedEntries.length - _maxCacheSize;
      for (int i = 0; i < toRemove; i++) {
        await _storage.remove(sortedEntries[i].key);
      }
      
      if (kDebugMode && toRemove > 0) {
        print('🧹 LRU清理: 移除 $toRemove 个最少使用的缓存');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 缓存大小检查失败: $e');
      }
    }
  }

  bool _shouldPerformCleanup() {
    if (_lastCleanup == null) return true;
    return DateTime.now().difference(_lastCleanup!) > _cleanupInterval;
  }

  Future<void> _performCleanup() async {
    try {
      if (kDebugMode) {
        print('🧹 开始清理过期缓存...');
      }

      final allKeys = await _storage.getAllKeys();
      final expiredKeys = <String>[];
      final corruptedKeys = <String>[];

      for (final key in allKeys) {
        try {
          final json = await _storage.get(key);
          if (json != null) {
            final entry = CacheEntry.fromJson(json);
            if (entry.isExpired) {
              expiredKeys.add(key);
            }
          }
        } catch (e) {
          // 记录损坏的缓存条目
          corruptedKeys.add(key);
        }
      }

      // 清理过期和损坏的缓存
      final allKeysToRemove = [...expiredKeys, ...corruptedKeys];
      if (allKeysToRemove.isNotEmpty) {
        try {
          await _storage.removeExpiredEntries(allKeysToRemove);
        } catch (e) {
          // 如果存储不支持批量删除，逐个删除
          for (final key in allKeysToRemove) {
            try {
              await _storage.remove(key);
            } catch (e) {
              if (kDebugMode) {
                print('⚠️ 删除缓存失败: $key, 错误: $e');
              }
            }
          }
        }
      }

      _lastCleanup = DateTime.now();

      if (kDebugMode) {
        print('🧹 清理完成: 过期缓存 ${expiredKeys.length} 个, 损坏缓存 ${corruptedKeys.length} 个');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❗️ 缓存清理失败: $e');
      }
    }
  }
}
