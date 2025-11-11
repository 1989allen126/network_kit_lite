import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/src/core/logging/network_log_manager.dart';

class LoggingInterceptor extends Interceptor {
  final NetworkLogManager _logManager = NetworkLogManager();
  final Map<RequestOptions, String> _requestIds = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final enableLogging = options.extra['enableLogging'] as bool? ?? true;
      String? requestId;

      if (kDebugMode && enableLogging) {
        final now = DateTime.now();
        final timestamp = _formatDate(now);
        _networkReceiveLogPrint('┌──────────────────────────────────────────────────────────────────────────');
        _networkReceiveLogPrint('│ 当前时间:$timestamp');
        _networkReceiveLogPrint('│ 请求: ${options.method} ${options.uri} $timestamp');
        _networkReceiveLogPrint('│ 头信息:');
        options.headers.forEach((key, value) {
          final sanitizedValue = _sanitizeHeaderValue(key, value);
          _networkReceiveLogPrint('│   $key: $sanitizedValue');
        });
        if (options.queryParameters.isNotEmpty) {
          _networkReceiveLogPrint('│ 查询参数:');
          options.queryParameters.forEach((key, value) => _networkReceiveLogPrint('│   $key: $value'));
        }
        if (options.data != null) {
          _networkReceiveLogPrint('└──────────────────────────────────────────────────────────────────────────');
          _networkReceiveLogPrint('┌──────────────────────────────────────────────────────────────────────────');
          _networkReceiveLogPrint('│ 请求体:');
          beautyPrint('${_formatJson(options.data)}');
        }
        _networkReceiveLogPrint('└──────────────────────────────────────────────────────────────────────────');
      }

      // 记录日志到NetworkLogManager
      if (_logManager.isEnabled) {
        final requestBodyStr = options.data != null ? _formatJson(options.data) : null;
        requestId = _logManager.startLog(
          method: options.method,
          url: options.uri.toString(),
          requestHeaders: options.headers.isNotEmpty ? Map<String, dynamic>.from(options.headers) : null,
          queryParameters:
              options.queryParameters.isNotEmpty ? Map<String, dynamic>.from(options.queryParameters) : null,
          requestBody: requestBodyStr,
        );

        if (requestId.isNotEmpty) {
          _requestIds[options] = requestId;
          // 将requestId保存到options.extra中，供后续使用
          options.extra['requestId'] = requestId;
        }
      }
    } catch (e) {
      print(e);
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
    try {
      final enableLogging = response.requestOptions.extra['enableLogging'] as bool? ?? true;
      if (kDebugMode && enableLogging) {
        final now = DateTime.now();
        final timestamp = _formatDate(now);
        _networkReceiveLogPrint('┌──────────────────────────────────────────────────────────────────────────');
        _networkReceiveLogPrint('│ 当前时间:$timestamp');
        _networkReceiveLogPrint('│ 响应: ${response.requestOptions.method} ${response.requestOptions.uri}');
        _networkReceiveLogPrint('│ 状态码: ${response.statusCode}');
        _networkReceiveLogPrint('└──────────────────────────────────────────────────────────────────────────');
        _networkReceiveLogPrint('┌──────────────────────────────────────────────────────────────────────────');
        _networkReceiveLogPrint('│ 响应体:');
        try {
          final formattedJson = _formatJson(response.data);
          _beautyPrint(formattedJson);
        } catch (e) {
          // 如果格式化失败，直接打印原始数据
          _networkReceiveLogPrint('│ 格式化失败: $e');
          _beautyPrint(response.data?.toString() ?? 'null');
        }
        _networkReceiveLogPrint('└──────────────────────────────────────────────────────────────────────────');
      }

      // 更新日志到NetworkLogManager
      if (_logManager.isEnabled) {
        final requestId =
            _requestIds.remove(response.requestOptions) ?? response.requestOptions.extra['requestId'] as String?;
        if (requestId != null && requestId.isNotEmpty) {
          final responseBodyStr = _formatJson(response.data);
          final responseHeaders = response.headers.map.isNotEmpty
              ? response.headers.map.map((key, value) => MapEntry(key, value.join(',')))
              : null;

          // 尝试从响应体中提取服务错误描述
          String? serviceErrorDesc;
          try {
            if (response.data is Map) {
              final data = response.data as Map;
              serviceErrorDesc = data['message'] as String? ?? data['error'] as String? ?? data['msg'] as String?;
            } else if (response.data is String) {
              final dataStr = response.data as String;
              try {
                final data = jsonDecode(dataStr);
                if (data is Map) {
                  serviceErrorDesc = data['message'] as String? ?? data['error'] as String? ?? data['msg'] as String?;
                }
              } catch (_) {
                // 忽略JSON解析错误
              }
            }
          } catch (_) {
            // 忽略错误提取错误
          }

          // 对于失败状态码（404、500等），也应该记录，但需要判断是否为失败
          final statusCode = response.statusCode;
          final isFailure = statusCode != null && (statusCode < 200 || statusCode >= 300);

          if (isFailure) {
            // 失败状态码使用updateLogError记录，以便正确标识为失败
            _logManager.updateLogError(
              requestId: requestId,
              errorType: 'badResponse',
              errorMessage: 'HTTP Error: $statusCode',
              statusCode: statusCode,
              responseHeaders: responseHeaders,
              responseBody: responseBodyStr,
              serviceErrorDesc: serviceErrorDesc,
            );
          } else {
            // 成功状态码使用updateLog记录
            _logManager.updateLog(
              requestId: requestId,
              statusCode: statusCode,
              responseHeaders: responseHeaders,
              responseBody: responseBodyStr,
              serviceErrorDesc: serviceErrorDesc,
            );
          }
        }
      }
    } catch (e) {
      print(e);
    }

    super.onResponse(response, handler);
  }

  _beautyPrint(String content, {int limitLength = 100}) {
    void printLine(String message) {
      if (message.length <= limitLength) {
        _networkReceiveLogPrint('│ ${message}');
      } else {
        // 按 limitLength 分段打印
        for (var i = 0; i < message.length; i += limitLength) {
          final end = (i + limitLength < message.length) ? i + limitLength : message.length;
          final segment = message.substring(i, end);
          _networkReceiveLogPrint('│ ${segment}');
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
    try {
      final enableLogging = err.requestOptions.extra['enableLogging'] as bool? ?? true;
      if (kDebugMode && enableLogging) {
        final now = DateTime.now();
        final timestamp = _formatDate(now);
        _networkReceiveLogPrint('┌──────────────────────────────────────────────────────────────────────────');
        _networkReceiveLogPrint('│ 当前时间:$timestamp');
        _networkReceiveLogPrint('│ 错误: ${err.requestOptions.method} ${err.requestOptions.uri}');
        _networkReceiveLogPrint('│ 错误类型: ${err.type}');
        if (err.response != null) {
          _networkReceiveLogPrint('│ 状态码: ${err.response?.statusCode}');
          _networkReceiveLogPrint('│ 错误响应:');
          _networkReceiveLogPrint('│   ${_formatJson(err.response?.data)}');
        } else {
          _networkReceiveLogPrint('│ 错误信息: ${err.message}');
        }
        _networkReceiveLogPrint('└──────────────────────────────────────────────────────────────────────────');
      }

      // 更新错误日志到NetworkLogManager
      if (_logManager.isEnabled) {
        final requestId = _requestIds.remove(err.requestOptions) ?? err.requestOptions.extra['requestId'] as String?;
        if (requestId != null && requestId.isNotEmpty) {
          String? responseBodyStr;
          Map<String, dynamic>? responseHeaders;
          String? serviceErrorDesc;

          if (err.response != null) {
            responseBodyStr = _formatJson(err.response?.data);
            responseHeaders = err.response!.headers.map.isNotEmpty
                ? err.response!.headers.map.map((key, value) => MapEntry(key, value.join(',')))
                : null;

            // 尝试从响应体中提取服务错误描述
            try {
              if (err.response!.data is Map) {
                final data = err.response!.data as Map;
                serviceErrorDesc = data['message'] as String? ?? data['error'] as String? ?? data['msg'] as String?;
              } else if (err.response!.data is String) {
                final dataStr = err.response!.data as String;
                try {
                  final data = jsonDecode(dataStr);
                  if (data is Map) {
                    serviceErrorDesc = data['message'] as String? ?? data['error'] as String? ?? data['msg'] as String?;
                  }
                } catch (_) {
                  // 忽略JSON解析错误
                }
              }
            } catch (_) {
              // 忽略错误提取错误
            }
          }

          _logManager.updateLogError(
            requestId: requestId,
            errorType: err.type.toString(),
            errorMessage: err.message,
            statusCode: err.response?.statusCode,
            responseHeaders: responseHeaders,
            responseBody: responseBodyStr,
            serviceErrorDesc: serviceErrorDesc,
          );
        }
      }
    } catch (e) {
      print(e);
    }

    super.onError(err, handler);
  }

  String _formatJson(dynamic data) {
    if (data == null) return 'null';

    // 处理 FormData 类型
    if (data is FormData) {
      final buffer = StringBuffer();
      buffer.write('FormData(');
      buffer.write('fields: ${data.fields.length}, ');
      buffer.write('files: ${data.files.length}');
      buffer.write(')');
      return buffer.toString();
    }

    if (data is String) {
      try {
        final jsonData = json.decode(data);
        return JsonEncoder.withIndent('  ').convert(jsonData);
      } catch (e) {
        return data;
      }
    }

    try {
      return JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      // 如果 JSON 转换失败，返回对象的字符串表示
      return data.toString();
    }
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

  /// 清理请求头中的敏感信息
  /// [key] 请求头键名
  /// [value] 请求头值
  String _sanitizeHeaderValue(String key, dynamic value) {
    final lowerKey = key.toLowerCase();

    // 需要隐藏的敏感请求头
    final sensitiveHeaders = [
      'authorization',
      'x-api-key',
      'api-key',
      'token',
      'access-token',
      'refresh-token',
      'cookie',
      'set-cookie',
      'account',
      'password',
      'phone',
      'email',
      'uid',
      'uuid',
      'token'
    ];

    // 如果是敏感请求头，隐藏值
    if (sensitiveHeaders.any((header) => lowerKey.contains(header))) {
      final valueStr = value.toString();
      if (valueStr.isEmpty) {
        return valueStr;
      }
      // 如果值很长（可能是token），只显示前8个字符和后4个字符
      if (valueStr.length > 20) {
        return '${valueStr.substring(0, 8)}...${valueStr.substring(valueStr.length - 4)}';
      }
      // 如果值较短，全部隐藏
      return '***';
    }

    return value.toString();
  }
}
