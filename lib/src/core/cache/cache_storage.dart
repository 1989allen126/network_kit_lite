import 'dart:async';

/// 缓存存储接口
abstract class CacheStorage {
  /// 初始化缓存
  Future<void> init();

  /// 保存缓存数据
  Future<void> save(String key, dynamic data, {Duration? duration});

  /// 获取缓存数据
  Future<dynamic> get(String key);

  /// 移除指定缓存
  Future<void> remove(String key);

  /// 删除失效的keys
  Future<void> removeExpiredEntries(List<String> keys);

  /// 清除所有缓存
  Future<void> clear();

  /// 获取数据大小
  Future<int> getSize();

  /// 关闭缓存
  Future<void> close();

  /// 获取所有key
  Future<List<String>> getAllKeys();
}

// 缓存方式
enum CacheType {
  file,
  sqlite,
  lru,
  memory
}

/// 缓存条目
class CacheEntry {
  final String key;
  final dynamic data;
  final DateTime? expiresAt;
  final DateTime createdAt;
  int accessCount;
  DateTime lastAccessed;

  CacheEntry({
    required this.key,
    required this.data,
    this.expiresAt,
    DateTime? createdAt,
    this.accessCount = 0,
    DateTime? lastAccessed,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastAccessed = lastAccessed ?? DateTime.now();

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'key': key,
        'data': data,
        'expiresAt': expiresAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'accessCount': accessCount,
        'lastAccessed': lastAccessed.toIso8601String(),
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        key: json['key'],
        data: json['data'],
        expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        accessCount: json['accessCount'] ?? 0,
        lastAccessed: json['lastAccessed'] != null ? DateTime.parse(json['lastAccessed']) : DateTime.now(),
      );
}

/// 缓存统计信息
class CacheStats {
  final int hits;
  final int misses;
  final double hitRate;
  final DateTime? lastCleanup;

  CacheStats({
    required this.hits,
    required this.misses,
    required this.hitRate,
    this.lastCleanup,
  });

  @override
  String toString() {
    return 'CacheStats(hits: $hits, misses: $misses, hitRate: ${(hitRate * 100).toStringAsFixed(2)}%, lastCleanup: $lastCleanup)';
  }
}
