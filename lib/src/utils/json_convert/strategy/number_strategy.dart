import 'package:flutter/foundation.dart';

import 'json_conversion_strategy.dart';

/// 数字类型转换策略
/// 安全地处理数字类型转换，支持从 String 或 int 安全转换
class NumberStrategy implements JsonConversionStrategy {
  @override
  bool canHandle(dynamic value) {
    return value is num || _isNumericString(value);
  }

  @override
  dynamic convert(dynamic value, {Set<Object?>? visited}) {
    try {
      // 如果已经是数字类型，直接返回
      if (value is num) {
        return value;
      }

      // 如果是字符串，尝试转换为数字
      if (value is String) {
        return _safeParseNumber(value);
      }

      // 其他类型尝试转换为字符串再解析
      final stringValue = value.toString();
      return _safeParseNumber(stringValue);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NumberStrategy: 转换失败: $e');
        print('值类型: ${value.runtimeType}, 值: $value');
      }
      return null;
    }
  }

  /// 判断字符串是否为数字
  bool _isNumericString(dynamic value) {
    if (value is! String) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    // 支持整数、小数、科学计数法
    return RegExp(r'^-?\d+(\.\d+)?([eE][+-]?\d+)?$').hasMatch(trimmed);
  }

  /// 安全地解析数字
  /// 优先尝试解析为 int，如果失败则尝试解析为 double
  dynamic _safeParseNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    // 先尝试解析为 int
    final intValue = int.tryParse(trimmed);
    if (intValue != null) {
      return intValue;
    }

    // 如果 int 解析失败，尝试解析为 double
    final doubleValue = double.tryParse(trimmed);
    if (doubleValue != null) {
      // 如果是整数形式的小数（如 "1.0"），返回 int
      if (doubleValue == doubleValue.truncateToDouble()) {
        return doubleValue.toInt();
      }
      return doubleValue;
    }

    // 如果都失败，返回 null
    if (kDebugMode) {
      print('⚠️ NumberStrategy: 无法解析为数字: $value');
    }
    return null;
  }
}
