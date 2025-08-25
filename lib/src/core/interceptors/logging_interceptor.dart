import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final now = DateTime.now();
      final timestamp = _formatDate(now);
      _networkReceiveLogPrint(
          '┌──────────────────────────────────────────────────────────────────────────');
      _networkReceiveLogPrint('│ 当前时间:$timestamp');
      _networkReceiveLogPrint('│ 请求: ${options.method}${options.baseUrl} ${options.uri} $timestamp');
      _networkReceiveLogPrint('│ 头信息:');
      options.headers.forEach((key, value) => _networkReceiveLogPrint('│   $key: $value'));
      if (options.queryParameters.isNotEmpty) {
        _networkReceiveLogPrint('│ 查询参数:');
        options.queryParameters
            .forEach((key, value) => _networkReceiveLogPrint('│   $key: $value'));
      }
      if (options.data != null) {
        _networkReceiveLogPrint(
            '└──────────────────────────────────────────────────────────────────────────');
        _networkReceiveLogPrint(
            '┌──────────────────────────────────────────────────────────────────────────');
        _networkReceiveLogPrint('│ 请求体:');
        beautyPrint('${_formatJson(options.data)}');
      }
      _networkReceiveLogPrint(
          '└──────────────────────────────────────────────────────────────────────────');
    }
    super.onRequest(options, handler);
  }

  // 打印请求体
  void beautyPrint(String message, {int limitLength = 180}) {
    if (message.length < limitLength) {
      _networkReceiveLogPrint('│   $message');
    } else {
      final buffer = StringBuffer();
      for (var i = 0; i < message.length; i++) {
        buffer.write(message[i]);
        // 每达到限制长度时换行输出
        if ((i + 1) % limitLength == 0) {
          _networkReceiveLogPrint('│   $buffer');
          buffer.clear();
        }
      }
      // 处理剩余内容
      if (buffer.isNotEmpty) {
        _networkReceiveLogPrint('│   $buffer');
      }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final now = DateTime.now();
      final timestamp = _formatDate(now);
      _networkReceiveLogPrint(
          '┌──────────────────────────────────────────────────────────────────────────');
      _networkReceiveLogPrint('│ 当前时间:$timestamp');
      _networkReceiveLogPrint(
          '│ 响应: ${response.requestOptions.method} ${response.requestOptions.uri}');
      _networkReceiveLogPrint('│ 状态码: ${response.statusCode}');
      _networkReceiveLogPrint(
          '└──────────────────────────────────────────────────────────────────────────');
      _networkReceiveLogPrint(
          '┌──────────────────────────────────────────────────────────────────────────');
      _networkReceiveLogPrint('│ 响应体:');
      _beautyPrint(_formatJson(response.data));
      _networkReceiveLogPrint(
          '└──────────────────────────────────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  _beautyPrint(String content, {int limitLength = 100}) {
    void printLine(String message) {
      if (message.length < limitLength) {
        _networkReceiveLogPrint('│ ${message}');
      } else {
        var outStr = StringBuffer();
        for (var index = 0; index < message.length; index++) {
          outStr.write(message[index]);
          if (index % limitLength == 0 && index != 0) {
            final content = outStr.toString();
            _networkReceiveLogPrint('│ ${content}');
            outStr.clear();
            var lastIndex = index + 1;
            if (message.length - lastIndex < limitLength) {
              final content = message.substring(lastIndex, message.length);
              _networkReceiveLogPrint('│ ${content}');
              break;
            }
          }
        }
      }
    }

    // 如果包含换行符，则按行打印
    final lines = content.split('\n');
    if (lines.length > 1) {
      for (var line in lines) {
        printLine(line);
      }
      return;
    }

    // 如果长度小于限制长度，直接打印
    printLine(content);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final now = DateTime.now();
      final timestamp = _formatDate(now);
      _networkReceiveLogPrint(
          '┌──────────────────────────────────────────────────────────────────────────');
      _networkReceiveLogPrint('│ 当前时间:$timestamp');
      _networkReceiveLogPrint('│ 错误: ${err.requestOptions.method} ${err.requestOptions.uri}');
      _networkReceiveLogPrint('│ 错误类型: ${err.type}');
      if (err.response != null) {
        _networkReceiveLogPrint('│ 状态码: ${err.response?.statusCode}');
        _networkReceiveLogPrint('│ 错误响应:');
        _networkReceiveLogPrint('│   ${_formatJson(err.response?.data)}');
      } else {
        _networkReceiveLogPrint('│ 错误信息: ${err.message}'  );
      }
      _networkReceiveLogPrint(
          '└──────────────────────────────────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }

  String _formatJson(dynamic data) {
    if (data == null) return 'null';
    if (data is String) {
      try {
        final jsonData = json.decode(data);
        return JsonEncoder.withIndent('  ').convert(jsonData);
      } catch (e) {
        return data;
      }
    }
    return JsonEncoder.withIndent('  ').convert(data);
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}.'
        '${date.millisecond.toString().padLeft(3, '0')}';
  }

  void _networkReceiveLogPrint(String content) {
    print(content);
  }
}
