import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'json_convert/strategy/strategy_manager.dart';

/// JSON 转换工具类
/// 提供健壮的 JSON 序列化和反序列化功能
/// 使用策略模式处理不同类型的数据转换
class JsonConverter {
  static final StrategyManager _strategyManager = StrategyManager();

  /// 将对象转换为 JSON 字符串
  /// [object] 要转换的对象
  /// [prettyPrint] 是否格式化输出（默认 false）
  /// 返回 JSON 字符串，如果转换失败则返回 'null'
  ///
  /// 注意：此方法包含完善的异常处理，确保网络请求异常不会导致页面布局异常
  static String toJsonString(
    dynamic object, {
    bool prettyPrint = false,
  }) {
    try {
      if (object == null) return 'null';

      final jsonData = convertToJson(object);
      if (jsonData == null) return 'null';

      if (prettyPrint) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(jsonData);
      }
      return json.encode(jsonData);
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ JsonConverter.toJsonString 转换异常: $e');
        print('堆栈跟踪: $stackTrace');
        print('原始对象类型: ${object.runtimeType}');
      }
      // 返回 'null' 而不是抛出异常，确保页面不会崩溃
      return 'null';
    }
  }

  /// 辅助方法：将对象转换为可 JSON 序列化的格式
  /// [value] 要转换的值
  /// [visited] 已访问的对象集合（用于检测循环引用）
  /// 返回可 JSON 序列化的对象，如果转换失败则返回 null
  ///
  /// 注意：此方法包含完善的异常处理，确保网络请求异常不会导致页面布局异常
  static dynamic convertToJson(
    dynamic value, {
    Set<Object?>? visited,
  }) {
    try {
      return _strategyManager.convert(value, visited: visited);
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ JsonConverter.convertToJson 转换异常: $e');
        print('堆栈跟踪: $stackTrace');
        print('值类型: ${value.runtimeType}');
      }
      // 返回 null 而不是抛出异常，确保页面不会崩溃
      return null;
    }
  }

  /// 安全的 JSON 解析
  /// [jsonString] JSON 字符串
  /// 返回解析后的对象，如果解析失败则返回 null
  ///
  /// 注意：此方法包含完善的异常处理，确保网络请求异常不会导致页面布局异常
  static dynamic safeJsonDecode(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      return json.decode(jsonString);
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ JsonConverter.safeJsonDecode 解析异常: $e');
        print('堆栈跟踪: $stackTrace');
        print('JSON 字符串长度: ${jsonString.length}');
        if (jsonString.length < 200) {
          print('JSON 字符串内容: $jsonString');
        }
      }
      // 返回 null 而不是抛出异常，确保页面不会崩溃
      return null;
    }
  }

  /// 安全的 JSON 编码
  /// [value] 要编码的值
  /// 返回 JSON 字符串，如果编码失败则返回 null
  ///
  /// 注意：此方法包含完善的异常处理，确保网络请求异常不会导致页面布局异常
  static String? safeJsonEncode(dynamic value) {
    if (value == null) return null;

    try {
      final jsonData = convertToJson(value);
      if (jsonData == null) return null;
      return json.encode(jsonData);
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ JsonConverter.safeJsonEncode 编码异常: $e');
        print('堆栈跟踪: $stackTrace');
        print('值类型: ${value.runtimeType}');
      }
      // 返回 null 而不是抛出异常，确保页面不会崩溃
      return null;
    }
  }
}
