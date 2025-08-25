import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 网络请求统计信息
class NetworkStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double averageResponseTime;
  final double successRate;
  final Map<String, int> statusCodeCounts;
  final Map<String, int> methodCounts;
  final DateTime lastUpdated;

  NetworkStats({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageResponseTime,
    required this.successRate,
    required this.statusCodeCounts,
    required this.methodCounts,
    required this.lastUpdated,
  });

  @override
  String toString() {
    return 'NetworkStats{'
        'total: $totalRequests, '
        'success: $successfulRequests, '
        'failed: $failedRequests, '
        'avgTime: ${averageResponseTime.toStringAsFixed(2)}ms, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%'
        '}';
  }
}

/// 单个请求的性能信息
class RequestPerformance {
  final String url;
  final String method;
  final DateTime startTime;
  final DateTime? endTime;
  final int? statusCode;
  final String? error;
  final int? responseSize;
  final Map<String, dynamic>? headers;

  RequestPerformance({
    required this.url,
    required this.method,
    required this.startTime,
    this.endTime,
    this.statusCode,
    this.error,
    this.responseSize,
    this.headers,
  });

  /// 请求持续时间（毫秒）
  int get duration {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMilliseconds;
  }

  /// 是否成功
  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// 是否失败
  bool get isFailed => error != null || (statusCode != null && (statusCode! < 200 || statusCode! >= 300));

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'method': method,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'statusCode': statusCode,
      'error': error,
      'responseSize': responseSize,
      'isSuccess': isSuccess,
      'headers': headers,
    };
  }
}

/// 网络监控管理器
class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal();

  final Queue<RequestPerformance> _requestHistory = Queue<RequestPerformance>();
  final Map<String, RequestPerformance> _activeRequests = {};
  final StreamController<RequestPerformance> _requestStreamController = StreamController.broadcast();
  final StreamController<NetworkStats> _statsStreamController = StreamController.broadcast();

  /// 最大保存的请求历史数量
  int maxHistorySize = 1000;

  /// 是否启用监控
  bool isEnabled = true;

  /// 请求流
  Stream<RequestPerformance> get requestStream => _requestStreamController.stream;

  /// 统计信息流
  Stream<NetworkStats> get statsStream => _statsStreamController.stream;

  /// 开始监控请求
  String startRequest({
    required String url,
    required String method,
    Map<String, dynamic>? headers,
  }) {
    if (!isEnabled) return '';

    final requestId = '${DateTime.now().millisecondsSinceEpoch}_${url.hashCode}';
    final performance = RequestPerformance(
      url: url,
      method: method,
      startTime: DateTime.now(),
      headers: headers,
    );

    _activeRequests[requestId] = performance;

    if (kDebugMode) {
      print('🚀 [NetworkMonitor] Request started: $method $url');
    }

    return requestId;
  }

  /// 结束监控请求
  void endRequest({
    required String requestId,
    int? statusCode,
    String? error,
    int? responseSize,
  }) {
    if (!isEnabled || requestId.isEmpty) return;

    final activeRequest = _activeRequests.remove(requestId);
    if (activeRequest == null) return;

    final completedRequest = RequestPerformance(
      url: activeRequest.url,
      method: activeRequest.method,
      startTime: activeRequest.startTime,
      endTime: DateTime.now(),
      statusCode: statusCode,
      error: error,
      responseSize: responseSize,
      headers: activeRequest.headers,
    );

    // 添加到历史记录
    _addToHistory(completedRequest);

    // 发送事件
    _requestStreamController.add(completedRequest);
    _updateStats();

    if (kDebugMode) {
      final status = completedRequest.isSuccess ? '✅' : '❌';
      print('$status [NetworkMonitor] Request completed: '
          '${completedRequest.method} ${completedRequest.url} '
          '(${completedRequest.duration}ms, ${completedRequest.statusCode})');
    }
  }

  /// 添加到历史记录
  void _addToHistory(RequestPerformance request) {
    _requestHistory.add(request);

    // 保持历史记录大小限制
    while (_requestHistory.length > maxHistorySize) {
      _requestHistory.removeFirst();
    }
  }

  /// 更新统计信息
  void _updateStats() {
    final stats = getStats();
    _statsStreamController.add(stats);
  }

  /// 获取统计信息
  NetworkStats getStats() {
    if (_requestHistory.isEmpty) {
      return NetworkStats(
        totalRequests: 0,
        successfulRequests: 0,
        failedRequests: 0,
        averageResponseTime: 0.0,
        successRate: 0.0,
        statusCodeCounts: {},
        methodCounts: {},
        lastUpdated: DateTime.now(),
      );
    }

    final total = _requestHistory.length;
    final successful = _requestHistory.where((r) => r.isSuccess).length;
    final failed = total - successful;
    final totalTime = _requestHistory.fold<int>(0, (sum, r) => sum + r.duration);
    final avgTime = total > 0 ? totalTime / total : 0.0;
    final successRate = total > 0 ? successful / total : 0.0;

    // 统计状态码
    final statusCodes = <String, int>{};
    for (final request in _requestHistory) {
      if (request.statusCode != null) {
        final code = request.statusCode.toString();
        statusCodes[code] = (statusCodes[code] ?? 0) + 1;
      }
    }

    // 统计请求方法
    final methods = <String, int>{};
    for (final request in _requestHistory) {
      methods[request.method] = (methods[request.method] ?? 0) + 1;
    }

    return NetworkStats(
      totalRequests: total,
      successfulRequests: successful,
      failedRequests: failed,
      averageResponseTime: avgTime,
      successRate: successRate,
      statusCodeCounts: statusCodes,
      methodCounts: methods,
      lastUpdated: DateTime.now(),
    );
  }

  /// 获取请求历史
  List<RequestPerformance> getRequestHistory({int? limit}) {
    final history = _requestHistory.toList();
    if (limit != null && limit < history.length) {
      return history.sublist(history.length - limit);
    }
    return history;
  }

  /// 获取活跃请求
  List<RequestPerformance> getActiveRequests() {
    return _activeRequests.values.toList();
  }

  /// 清除历史记录
  void clearHistory() {
    _requestHistory.clear();
    _updateStats();

    if (kDebugMode) {
      print('🧹 [NetworkMonitor] History cleared');
    }
  }

  /// 获取性能报告
  Map<String, dynamic> getPerformanceReport() {
    final stats = getStats();
    final slowRequests = _requestHistory
        .where((r) => r.duration > 3000) // 超过3秒的请求
        .map((r) => r.toMap())
        .toList();

    final errorRequests = _requestHistory
        .where((r) => r.isFailed)
        .map((r) => r.toMap())
        .toList();

    return {
      'stats': {
        'totalRequests': stats.totalRequests,
        'successfulRequests': stats.successfulRequests,
        'failedRequests': stats.failedRequests,
        'averageResponseTime': stats.averageResponseTime,
        'successRate': stats.successRate,
        'statusCodeCounts': stats.statusCodeCounts,
        'methodCounts': stats.methodCounts,
      },
      'slowRequests': slowRequests,
      'errorRequests': errorRequests,
      'activeRequestsCount': _activeRequests.length,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 销毁监控器
  void dispose() {
    _requestStreamController.close();
    _statsStreamController.close();
    _requestHistory.clear();
    _activeRequests.clear();

    if (kDebugMode) {
      print('🔄 [NetworkMonitor] Disposed');
    }
  }
}
