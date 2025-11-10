import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/src/core/monitoring/network_monitor.dart';

/// 网络监控拦截器
class MonitoringInterceptor extends Interceptor {
  final NetworkMonitor _monitor = NetworkMonitor();
  final Map<RequestOptions, String> _requestIds = {};

  /// 是否启用详细日志
  final bool enableDetailedLogging;

  /// 是否监控请求体大小
  final bool monitorRequestSize;

  /// 是否监控响应体大小
  final bool monitorResponseSize;

  MonitoringInterceptor({
    this.enableDetailedLogging = kDebugMode,
    this.monitorRequestSize = true,
    this.monitorResponseSize = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // 提取请求头信息
      final headers = enableDetailedLogging ? Map<String, dynamic>.from(options.headers) : null;
      
      // 开始监控请求
      final requestId = _monitor.startRequest(
        url: options.uri.toString(),
        method: options.method,
        headers: headers,
      );

      // 保存请求ID以便后续使用
      if (requestId.isNotEmpty) {
        _requestIds[options] = requestId;
      }

      // 添加请求大小信息
      if (monitorRequestSize && options.data != null) {
        final requestSize = _calculateDataSize(options.data);
        if (enableDetailedLogging && requestSize > 0) {
          print('[MonitoringInterceptor] Request size: ${_formatBytes(requestSize)}');
        }
      }

      // 添加监控标识到请求头
      options.headers['X-Request-Monitor-Id'] = requestId;
      
    } catch (e) {
      if (kDebugMode) {
        print('[MonitoringInterceptor] Error in onRequest: $e');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final requestId = _requestIds.remove(response.requestOptions);
      if (requestId != null && requestId.isNotEmpty) {
        // 计算响应大小
        int? responseSize;
        if (monitorResponseSize) {
          responseSize = _calculateDataSize(response.data);
          if (enableDetailedLogging && responseSize > 0) {
            print('[MonitoringInterceptor] Response size: ${_formatBytes(responseSize)}');
          }
        }

        // 结束监控请求
        _monitor.endRequest(
          requestId: requestId,
          statusCode: response.statusCode,
          responseSize: responseSize,
        );

        // 性能警告
        if (enableDetailedLogging) {
          _checkPerformanceWarnings(response, responseSize);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MonitoringInterceptor] Error in onResponse: $e');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final requestId = _requestIds.remove(err.requestOptions);
      if (requestId != null && requestId.isNotEmpty) {
        // 结束监控请求（错误情况）
        _monitor.endRequest(
          requestId: requestId,
          statusCode: err.response?.statusCode,
          error: _formatError(err),
        );

        if (enableDetailedLogging) {
          print('[MonitoringInterceptor] Request failed: ${err.requestOptions.method} ${err.requestOptions.uri}');
          print('  Error: ${_formatError(err)}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MonitoringInterceptor] Error in onError: $e');
      }
    }

    handler.next(err);
  }

  /// 计算数据大小（字节）
  int _calculateDataSize(dynamic data) {
    if (data == null) return 0;

    try {
      if (data is String) {
        return data.length;
      } else if (data is List<int>) {
        return data.length;
      } else if (data is Map || data is List) {
        // 对于复杂对象，估算JSON序列化后的大小
        final jsonString = data.toString();
        return jsonString.length;
      } else {
        return data.toString().length;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MonitoringInterceptor] Error calculating data size: $e');
      }
      return 0;
    }
  }

  /// 格式化字节大小
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// 格式化错误信息
  String _formatError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${err.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error: ${err.message}';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
      case DioExceptionType.unknown:
      default:
        return err.message ?? 'Unknown error';
    }
  }

  /// 检查性能警告
  void _checkPerformanceWarnings(Response response, int? responseSize) {
    final uri = response.requestOptions.uri;
    
    // 检查响应时间
    final requestTime = response.requestOptions.extra['request_time'] as DateTime?;
    if (requestTime != null) {
      final duration = DateTime.now().difference(requestTime).inMilliseconds;
      if (duration > 5000) {
        print('[MonitoringInterceptor] Slow request detected: ${uri} (${duration}ms)');
      }
    }

    // 检查响应大小
    if (responseSize != null && responseSize > 1024 * 1024) { // 1MB
      print('[MonitoringInterceptor] Large response detected: ${uri} (${_formatBytes(responseSize)})');
    }

    // 检查状态码
    final statusCode = response.statusCode;
    if (statusCode != null) {
      if (statusCode >= 400 && statusCode < 500) {
        print('[MonitoringInterceptor] Client error: ${uri} ($statusCode)');
      } else if (statusCode >= 500) {
        print('[MonitoringInterceptor] Server error: ${uri} ($statusCode)');
      }
    }
  }

  /// 获取监控统计信息
  NetworkStats getStats() {
    return _monitor.getStats();
  }

  /// 获取请求历史
  List<RequestPerformance> getRequestHistory({int? limit}) {
    return _monitor.getRequestHistory(limit: limit);
  }

  /// 获取性能报告
  Map<String, dynamic> getPerformanceReport() {
    return _monitor.getPerformanceReport();
  }

  /// 清除监控历史
  void clearHistory() {
    _monitor.clearHistory();
  }

  /// 启用/禁用监控
  void setEnabled(bool enabled) {
    _monitor.isEnabled = enabled;
  }

  /// 获取监控器实例
  NetworkMonitor get monitor => _monitor;
}