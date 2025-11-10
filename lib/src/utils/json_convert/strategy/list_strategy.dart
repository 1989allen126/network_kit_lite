import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';
import 'strategy_manager.dart';

/// List 转换策略
class ListStrategy implements JsonConversionStrategy {
  final StrategyManager _strategyManager;

  ListStrategy(this._strategyManager);

  @override
  bool canHandle(dynamic value) {
    return value is List;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      final list = value as List;
      return list.map((e) => _strategyManager.convert(e, visited: visited)).toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠️ ListStrategy: 转换失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      return <dynamic>[];
    }
  }
}
