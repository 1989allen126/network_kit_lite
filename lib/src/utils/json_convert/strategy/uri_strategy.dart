import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';

/// Uri 转换策略
class UriStrategy implements JsonConversionStrategy {
  @override
  bool canHandle(dynamic value) {
    return value is Uri;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      return (value as Uri).toString();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ UriStrategy: 转换失败: $e');
      }
      return null;
    }
  }
}
