import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';
import 'strategy_manager.dart';

/// Map 转换策略
class MapStrategy implements JsonConversionStrategy {
  final StrategyManager _strategyManager;

  MapStrategy(this._strategyManager);

  @override
  bool canHandle(dynamic value) {
    return value is Map;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      final map = value as Map;
      final result = <String, dynamic>{};
      map.forEach((key, val) {
        try {
          final keyString = _convertKey(key);
          if (keyString != null) {
            result[keyString] = _strategyManager.convert(val, visited: visited);
          } else if (kDebugMode) {
            print('⚠️ MapStrategy: 跳过无效的 Map 键类型: ${key.runtimeType}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ MapStrategy: 处理键值对失败: $e');
            print('键类型: ${key.runtimeType}, 值类型: ${val.runtimeType}');
          }
        }
      });
      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠️ MapStrategy: 转换失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      return <String, dynamic>{};
    }
  }

  /// 转换 Map 键为字符串
  String? _convertKey(dynamic key) {
    if (key == null) return null;
    try {
      if (key is String) return key;
      if (key is num) return key.toString();
      if (key is bool) return key.toString();
      if (key is Enum) return key.name;
      return key.toString();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ MapStrategy: 无法转换 Map 键: ${key.runtimeType}');
      }
      return null;
    }
  }
}
