import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';

/// 枚举类型转换策略
class EnumStrategy implements JsonConversionStrategy {
  @override
  bool canHandle(dynamic value) {
    return value is Enum;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      return (value as Enum).name;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ EnumStrategy: 转换失败: $e');
      }
      return null;
    }
  }
}
