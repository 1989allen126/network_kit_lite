import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/src/utils/network_connectivity.dart';
import 'package:network_kit_lite/src/i18n/error_code_intl.dart';

enum RetryPolicy {
  fixed, // 固定间隔
  linear, // 线性递增
  exponential, // 指数递增
  jitter, // 带抖动的指数递增
  random, // 随机间隔
}

/// 智能重试配置
class SmartRetryConfig {
  final int maxRetries;
  final Duration baseDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final double jitterFactor;
  final bool enableNetworkCheck;
  final Duration networkCheckTimeout;
  final Map<int, int> statusCodeRetryCount; // 特定状态码的重试次数
  final Map<DioExceptionType, int> exceptionTypeRetryCount; // 特定异常类型的重试次数

  const SmartRetryConfig({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.jitterFactor = 0.1,
    this.enableNetworkCheck = true,
    this.networkCheckTimeout = const Duration(seconds: 3),
    this.statusCodeRetryCount = const {
      408: 2, // 请求超时
      429: 3, // 频率限制
      500: 3, // 服务器错误
      502: 3, // 网关错误
      503: 3, // 服务不可用
      504: 3, // 网关超时
    },
    this.exceptionTypeRetryCount = const {
      DioExceptionType.connectionTimeout: 2,
      DioExceptionType.sendTimeout: 2,
      DioExceptionType.receiveTimeout: 2,
      DioExceptionType.connectionError: 3,
    },
  });
}

/// 重试建议
class RetrySuggestion {
  final bool shouldRetry;
  final String reason;
  final Duration delay;

  const RetrySuggestion({
    required this.shouldRetry,
    required this.reason,
    required this.delay,
  });

  @override
  String toString() {
    return 'RetrySuggestion{shouldRetry: $shouldRetry, reason: $reason, delay: ${delay.inMilliseconds}ms}';
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final SmartRetryConfig config;
  final RetryPolicy policy;
  final List<int> retryStatusCodes;
  final List<DioExceptionType> retryExceptionTypes;
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity();

  RetryInterceptor({
    required this.dio,
    SmartRetryConfig? config,
    this.policy = RetryPolicy.exponential,
    this.retryStatusCodes = const [500, 502, 503, 504],
    this.retryExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ],
  }) : config = config ?? const SmartRetryConfig();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 初始化重试计数
    if (!options.extra.containsKey('_retryCount')) {
      options.extra['_retryCount'] = 0;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = _getRetryCount(err.requestOptions);

    // 获取智能重试建议
    final suggestion = _getRetrySuggestion(err, retryCount);

    if (!suggestion.shouldRetry) {
      if (kDebugMode) {
        print('❌ 不进行重试: ${suggestion.reason}');
      }
      return handler.next(err);
    }

    // 检查网络连接状态
    if (config.enableNetworkCheck && !await _isNetworkAvailable()) {
      if (kDebugMode) {
        print('❌ 网络不可用，跳过重试: ${err.requestOptions.path}');
      }
      return handler.next(err);
    }

    if (kDebugMode) {
      print('🔄 智能重试 (${retryCount + 1}/${config.maxRetries}): ${err.requestOptions.path}');
      print('📋 重试原因: ${suggestion.reason}');
      print('⏱️ 延迟时间: ${suggestion.delay.inMilliseconds}ms');
    }

    // 等待延迟时间
    await Future.delayed(suggestion.delay);

    // 更新重试计数
    _setRetryCount(err.requestOptions, retryCount + 1);

    try {
      // 使用原始的Dio实例进行重试，避免重复拦截
      final retryDio = Dio();
      retryDio.options = dio.options;

      final response = await retryDio.fetch(err.requestOptions);

      if (kDebugMode) {
        print('✅ 智能重试成功: ${err.requestOptions.path}');
      }

      return handler.resolve(response);
    } catch (retryError) {
      if (kDebugMode) {
        print('❌ 智能重试失败 (${retryCount + 1}/${config.maxRetries}): $retryError');
      }

      // 如果是最后一次重试失败，传递原始错误
      if (retryCount + 1 >= config.maxRetries) {
        return handler.next(err);
      }

      // 继续重试循环
      return onError(retryError is DioException ? retryError : err, handler);
    }
  }

  /// 检查网络连接是否可用
  Future<bool> _isNetworkAvailable() async {
    try {
      return await _networkConnectivity.isNetworkAvailableRobust(
        timeout: config.networkCheckTimeout,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 网络检测失败: $e');
      }
      return false;
    }
  }

  /// 获取智能重试建议
  RetrySuggestion _getRetrySuggestion(DioException error, int currentRetryCount) {
    if (!shouldRetry(error, currentRetryCount)) {
      return RetrySuggestion(
        shouldRetry: false,
        reason: _getLocalizedMessage('retry_max_reached', '已达到最大重试次数或错误类型不支持重试'),
        delay: Duration.zero,
      );
    }

    final delay = _calculateDelay(currentRetryCount);
    String reason = '';

    if (error.response?.statusCode != null) {
      final statusCode = error.response!.statusCode!;
      if (statusCode >= 500) {
        reason = _getLocalizedMessage('retry_server_error', '服务器错误，建议重试');
      } else if (statusCode == 408) {
        reason = _getLocalizedMessage('retry_timeout', '请求超时，建议重试');
      } else if (statusCode == 429) {
        reason = _getLocalizedMessage('retry_rate_limit', '请求频率过高，建议延迟重试');
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          reason = _getLocalizedMessage('retry_network_timeout', '网络超时，建议重试');
          break;
        case DioExceptionType.connectionError:
          reason = _getLocalizedMessage('retry_connection_error', '网络连接错误，建议重试');
          break;
        case DioExceptionType.unknown:
          reason = _getLocalizedMessage('retry_unknown_error', '未知网络错误，建议重试');
          break;
        default:
          reason = _getLocalizedMessage('retry_network_error', '网络错误，建议重试');
      }
    }

    return RetrySuggestion(
      shouldRetry: true,
      reason: reason,
      delay: delay,
    );
  }

  /// 判断是否应该重试（公共方法，用于测试）
  bool shouldRetry(DioException error, int currentRetryCount) {
    // 检查是否达到最大重试次数
    if (currentRetryCount >= config.maxRetries) {
      return false;
    }

    // 不重试取消的请求
    if (error.type == DioExceptionType.cancel) {
      return false;
    }

    // 根据状态码判断重试次数
    if (error.response?.statusCode != null) {
      final statusCode = error.response!.statusCode!;
      final maxRetriesForStatusCode = config.statusCodeRetryCount[statusCode];
      if (maxRetriesForStatusCode != null && currentRetryCount >= maxRetriesForStatusCode) {
        return false;
      }

      // 客户端错误通常不应该重试，除非是特定的错误
      if (statusCode >= 400 && statusCode < 500) {
        return statusCode == 408 || statusCode == 429;
      }

      // 服务器错误（5xx）应该重试
      if (statusCode >= 500 && statusCode < 600) {
        return true;
      }
    }

    // 根据异常类型判断重试次数
    final maxRetriesForException = config.exceptionTypeRetryCount[error.type];
    if (maxRetriesForException != null && currentRetryCount >= maxRetriesForException) {
      return false;
    }

    // 检查是否是可重试的异常类型
    if (config.exceptionTypeRetryCount.containsKey(error.type)) {
      return true;
    }

    // 对于未知错误，根据错误消息判断
    if (error.type == DioExceptionType.unknown) {
      return _shouldRetryUnknownError(error);
    }

    return false;
  }

  /// 判断未知错误是否应该重试
  bool _shouldRetryUnknownError(DioException error) {
    final message = error.message?.toLowerCase() ?? '';

    // 不重试明显的客户端错误
    if (message.contains('certificate') ||
        message.contains('ssl') ||
        message.contains('handshake') ||
        message.contains('bad request') ||
        message.contains('unauthorized') ||
        message.contains('forbidden') ||
        message.contains('not found')) {
      return false;
    }

    // 重试网络相关的未知错误
    return message.contains('timeout') ||
           message.contains('connection') ||
           message.contains('network') ||
           message.contains('dns') ||
           message.contains('no route to host');
  }

  /// 计算重试延迟时间
  Duration _calculateDelay(int retryCount) {
    // 指数退避算法
    final exponentialDelay = config.baseDelay.inMilliseconds *
        pow(config.backoffMultiplier, retryCount).toInt();

    // 添加抖动
    final jitterRange = exponentialDelay * config.jitterFactor;
    final jitter = (Random().nextDouble() - 0.5) * 2 * jitterRange;

    final totalDelay = exponentialDelay + jitter.toInt();

    // 确保不超过最大延迟
    return Duration(milliseconds: totalDelay.clamp(0, config.maxDelay.inMilliseconds));
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra['_retryCount'] as int? ?? 0;
  }

  void _setRetryCount(RequestOptions options, int count) {
    options.extra['_retryCount'] = count;
  }

  /// 获取本地化消息
  String _getLocalizedMessage(String key, String fallback) {
    try {
      return ErrorCodeIntl.getMessage(key);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 国际化消息获取失败: $key, 使用默认消息: $fallback');
      }
      return fallback;
    }
  }

  /// 计算延迟时间（公共方法，用于测试）
  Duration calculateDelay(int retryCount) {
    return _calculateDelay(retryCount);
  }

  /// 获取重试建议（公共方法，用于测试）
  RetrySuggestion getRetrySuggestion(DioException error, int currentRetryCount) {
    return _getRetrySuggestion(error, currentRetryCount);
  }
}
