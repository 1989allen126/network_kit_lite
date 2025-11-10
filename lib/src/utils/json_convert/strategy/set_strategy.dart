import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';
import 'strategy_manager.dart';

/// Set 转换策略（转换为 List）
class SetStrategy implements JsonConversionStrategy {
  final StrategyManager _strategyManager;

  SetStrategy(this._strategyManager);

  @override
  bool canHandle(dynamic value) {
    return value is Set;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      final set = value as Set;
      return set.map((e) => _strategyManager.convert(e, visited: visited)).toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠️ SetStrategy: 转换失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      return <dynamic>[];
    }
  }
}
