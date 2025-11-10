import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';

/// DateTime 转换策略
class DateTimeStrategy implements JsonConversionStrategy {
  @override
  bool canHandle(dynamic value) {
    return value is DateTime;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      return (value as DateTime).toIso8601String();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ DateTimeStrategy: 转换失败: $e');
      }
      return null;
    }
  }
}
