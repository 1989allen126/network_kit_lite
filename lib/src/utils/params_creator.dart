import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class ParamsCreator {
  /// Enable or disable the signature of the parameters
  ///
  bool get enableSign => false;

  /// Enable or disable the conversion of the options to the parameters
  bool get enableOptionsConversion => false;

  /// Creates a map with the given parameters
  Map<String, dynamic> createParams(Map<String, dynamic> params);

  ///转化options
  Options convertOptions(Options options) {
    // 尝试调用toOptions方法，如果不存在则返回原options
    try {
      // 这里假设toOptions方法是一个扩展方法，可以通过这种方式调用
      // 实际使用时可能需要根据具体实现调整
      final dynamic result = (options as dynamic).toOptions();
      return result as Options;
    } catch (e) {
      if (kDebugMode) {
        print('Options转换方法调用失败: $e');
      }
      return options;
    }
  }
}
