import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';
import 'strategy_manager.dart';

/// 对象转换策略（处理有 toJson 方法的对象）
class ObjectStrategy implements JsonConversionStrategy {
  final StrategyManager _strategyManager;

  ObjectStrategy(this._strategyManager);

  @override
  bool canHandle(dynamic value) {
    return value is Object && value is! Function;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    // 检测循环引用
    visited ??= <Object?>{};
    if (visited.contains(value)) {
      if (kDebugMode) {
        print('⚠️ ObjectStrategy: 检测到循环引用，跳过对象: ${value.runtimeType}');
      }
      return null;
    }

    try {
      visited.add(value);
      final jsonData = (value as dynamic).toJson();
      // 递归处理 toJson 返回的数据
      final result = _strategyManager.convert(jsonData, visited: visited);
      visited.remove(value);
      return result;
    } catch (e, stackTrace) {
      visited.remove(value);
      if (kDebugMode) {
        print('⚠️ ObjectStrategy: toJson 调用失败: $e');
        print('堆栈跟踪: $stackTrace');
        print('对象类型: ${value.runtimeType}');
      }
      // 回退到调试信息（仅用于调试）
      if (kDebugMode) {
        try {
          return {
            '_toString': value.toString(),
            '_type': value.runtimeType.toString(),
          };
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }
}
