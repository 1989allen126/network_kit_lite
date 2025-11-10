import 'package:flutter/foundation.dart';

import 'date_time_strategy.dart';
import 'enum_strategy.dart';
import 'json_conversion_strategy.dart';
import 'list_strategy.dart';
import 'map_strategy.dart';
import 'number_strategy.dart';
import 'object_strategy.dart';
import 'primitive_strategy.dart';
import 'set_strategy.dart';
import 'uri_strategy.dart';

/// 策略管理器
/// 负责选择合适的转换策略并执行转换
class StrategyManager {
  final List<JsonConversionStrategy> _strategies = [];

  StrategyManager() {
    // 按优先级顺序添加策略（越靠前的优先级越高）
    _strategies.addAll([
      NumberStrategy(), // 数字策略优先，支持从 String 安全转换
      PrimitiveStrategy(),
      DateTimeStrategy(),
      UriStrategy(),
      EnumStrategy(),
      ListStrategy(this),
      SetStrategy(this),
      MapStrategy(this),
      ObjectStrategy(this),
    ]);
  }

  /// 执行转换
  /// [value] 要转换的值
  /// [visited] 已访问的对象集合（用于检测循环引用）
  /// 返回转换后的值，如果转换失败则返回 null
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    if (value == null) return null;

    try {
      // 查找第一个支持该类型的策略
      for (final strategy in _strategies) {
        if (strategy.canHandle(value)) {
          return strategy.convert(value, visited: visited);
        }
      }

      // 如果没有找到合适的策略，返回 null
      if (kDebugMode) {
        print('⚠️ StrategyManager: 无法转换的类型: ${value.runtimeType}');
      }
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ StrategyManager: 转换异常: $e');
        print('堆栈跟踪: $stackTrace');
        print('值类型: ${value.runtimeType}');
      }
      return null;
    }
  }
}
