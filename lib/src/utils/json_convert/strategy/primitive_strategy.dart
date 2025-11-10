import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';

/// 基础类型转换策略
/// 处理 String、bool 等基础类型（数字类型由 NumberStrategy 处理）
class PrimitiveStrategy implements JsonConversionStrategy {
  @override
  bool canHandle(dynamic value) {
    // 排除数字类型，由 NumberStrategy 处理
    if (value is num) return false;
    return value is String || value is bool;
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      return value;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ PrimitiveStrategy: 转换失败: $e');
      }
      return null;
    }
  }
}
