import 'dart:async';
import 'package:dio/dio.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:flutter/foundation.dart';

/// 网络监控使用示例
class MonitoringExample {
  late final DioClient _client;
  late final NetworkMonitor _monitor;

  MonitoringExample() {
    _client = DioClient();
    _monitor = NetworkMonitor();
    _setupMonitoring();
  }

  /// 设置监控
  void _setupMonitoring() {
    // 监听请求完成事件
    _monitor.requestStream.listen((request) {
      if (kDebugMode) {
        print('📊 Request completed: ${request.method} ${request.url}');
        print('   Duration: ${request.duration}ms');
        print('   Status: ${request.statusCode}');
        print('   Success: ${request.isSuccess}');
      }
    });

    // 监听统计信息更新
    _monitor.statsStream.listen((stats) {
      if (kDebugMode) {
        print('📈 Network Stats Updated:');
        print('   Total Requests: ${stats.totalRequests}');
        print('   Success Rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
        print('   Average Response Time: ${stats.averageResponseTime.toStringAsFixed(2)}ms');
      }
    });
  }

  /// 示例：发送多个请求并监控性能
  Future<void> performanceTest() async {
    print('🚀 Starting performance test...');

    // 清除之前的历史记录
    _client.clearMonitoringHistory();

    final urls = [
      'https://jsonplaceholder.typicode.com/posts/1',
      'https://jsonplaceholder.typicode.com/posts/2',
      'https://jsonplaceholder.typicode.com/posts/3',
      'https://jsonplaceholder.typicode.com/users/1',
      'https://jsonplaceholder.typicode.com/users/2',
    ];

    // 并发发送请求
    final futures = urls.map((url) => _makeRequest(url)).toList();
    await Future.wait(futures);

    // 等待一下让监控数据更新
    await Future.delayed(Duration(milliseconds: 100));

    // 打印性能报告
    _printPerformanceReport();
  }

  /// 发送单个请求
  Future<void> _makeRequest(String url) async {
    try {
      final response = await _client.request<Map<String, dynamic>>(
        url,
        HttpRequestMethod.get,
      );
      // 处理响应数据
      if (response != null && response is Map<String, dynamic>) {
        print('✅ Success: $url');
        print('Response: $response');
      } else {
        print('❌ Failed: $url - Invalid response');
      }
    } catch (e) {
      print('❌ Error: $url - $e');
    }
  }

  /// 打印性能报告
  void _printPerformanceReport() {
    final report = _client.getPerformanceReport();
    final stats = report['stats'] as Map<String, dynamic>;
    final slowRequests = report['slowRequests'] as List;
    final errorRequests = report['errorRequests'] as List;

    print('\n📊 Performance Report:');
    print('=' * 50);
    print('Total Requests: ${stats['totalRequests']}');
    print('Successful: ${stats['successfulRequests']}');
    print('Failed: ${stats['failedRequests']}');
    print('Success Rate: ${(stats['successRate'] * 100).toStringAsFixed(1)}%');
    print('Average Response Time: ${stats['averageResponseTime'].toStringAsFixed(2)}ms');

    if (stats['statusCodeCounts'] != null) {
      print('\nStatus Code Distribution:');
      final statusCodes = stats['statusCodeCounts'] as Map<String, dynamic>;
      statusCodes.forEach((code, count) {
        print('  $code: $count requests');
      });
    }

    if (stats['methodCounts'] != null) {
      print('\nMethod Distribution:');
      final methods = stats['methodCounts'] as Map<String, dynamic>;
      methods.forEach((method, count) {
        print('  $method: $count requests');
      });
    }

    if (slowRequests.isNotEmpty) {
      print('\n🐌 Slow Requests (>3s):');
      for (final request in slowRequests) {
        print('  ${request['method']} ${request['url']} - ${request['duration']}ms');
      }
    }

    if (errorRequests.isNotEmpty) {
      print('\n💥 Error Requests:');
      for (final request in errorRequests) {
        print('  ${request['method']} ${request['url']} - ${request['error']}');
      }
    }

    print('=' * 50);
  }

  /// 示例：实时监控网络状态
  void startRealTimeMonitoring() {
    print('🔄 Starting real-time monitoring...');

    // 每5秒打印一次统计信息
    Timer.periodic(Duration(seconds: 5), (timer) {
      final stats = _client.getNetworkStats();
      print('\n⏰ Real-time Stats (${DateTime.now().toIso8601String()}):');
      print('  Total: ${stats.totalRequests}');
      print('  Success Rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
      print('  Avg Time: ${stats.averageResponseTime.toStringAsFixed(2)}ms');

      // 获取最近的请求
      final recentRequests = _client.getRequestHistory(limit: 3);
      if (recentRequests.isNotEmpty) {
        print('  Recent Requests:');
        for (final request in recentRequests) {
          final status = request.isSuccess ? '✅' : '❌';
          print('    $status ${request.method} ${request.url} (${request.duration}ms)');
        }
      }
    });
  }

  /// 示例：监控特定API的性能
  Future<void> monitorSpecificAPI() async {
    print('🎯 Monitoring specific API performance...');

    const apiUrl = 'https://jsonplaceholder.typicode.com/posts';
    const testCount = 10;

    // 清除历史记录
    _client.clearMonitoringHistory();

    // 发送多次请求
    for (int i = 0; i < testCount; i++) {
      await _makeRequest('$apiUrl/${i + 1}');
      await Future.delayed(Duration(milliseconds: 100)); // 间隔100ms
    }

    // 分析结果
    final history = _client.getRequestHistory();
    final apiRequests = history.where((r) => r.url.contains(apiUrl)).toList();

    if (apiRequests.isNotEmpty) {
      final durations = apiRequests.map((r) => r.duration).toList();
      final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
      final minDuration = durations.reduce((a, b) => a < b ? a : b);
      final maxDuration = durations.reduce((a, b) => a > b ? a : b);
      final successCount = apiRequests.where((r) => r.isSuccess).length;

      print('\n🎯 API Performance Analysis:');
      print('API: $apiUrl');
      print('Total Requests: ${apiRequests.length}');
      print('Success Count: $successCount');
      print('Success Rate: ${(successCount / apiRequests.length * 100).toStringAsFixed(1)}%');
      print('Average Duration: ${avgDuration.toStringAsFixed(2)}ms');
      print('Min Duration: ${minDuration}ms');
      print('Max Duration: ${maxDuration}ms');
    }
  }

  /// 示例：错误监控和告警
  void setupErrorMonitoring() {
    print('🚨 Setting up error monitoring...');

    _monitor.requestStream.listen((request) {
      // 检查慢请求
      if (request.duration > 2000) {
        print('🐌 SLOW REQUEST ALERT: ${request.url} took ${request.duration}ms');
      }

      // 检查错误请求
      if (request.isFailed) {
        print('💥 ERROR REQUEST ALERT: ${request.url} failed with ${request.error}');
      }

      // 检查大响应
      if (request.responseSize != null && request.responseSize! > 1024 * 1024) {
        final sizeMB = (request.responseSize! / (1024 * 1024)).toStringAsFixed(2);
        print('📦 LARGE RESPONSE ALERT: ${request.url} returned ${sizeMB}MB');
      }
    });

    _monitor.statsStream.listen((stats) {
      // 检查成功率
      if (stats.totalRequests > 10 && stats.successRate < 0.9) {
        print('📉 LOW SUCCESS RATE ALERT: ${(stats.successRate * 100).toStringAsFixed(1)}%');
      }

      // 检查平均响应时间
      if (stats.totalRequests > 5 && stats.averageResponseTime > 3000) {
        print('⏱️ HIGH LATENCY ALERT: Average ${stats.averageResponseTime.toStringAsFixed(2)}ms');
      }
    });
  }

  /// 清理资源
  void dispose() {
    _monitor.dispose();
  }
}

/// 使用示例
void main() async {
  final example = MonitoringExample();

  try {
    // 设置错误监控
    example.setupErrorMonitoring();

    // 执行性能测试
    await example.performanceTest();

    // 监控特定API
    await example.monitorSpecificAPI();

    // 开始实时监控（注释掉避免无限运行）
    // example.startRealTimeMonitoring();

  } finally {
    example.dispose();
  }
}