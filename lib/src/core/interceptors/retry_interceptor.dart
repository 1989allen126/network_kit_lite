import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/src/i18n/error_code_intl.dart';
import 'package:network_kit_lite/src/utils/network_connectivity.dart';

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
      429: 2,// 注意：429错误（频率限制）不重试，避免加重服务器负担
      // 其他错误（404、500、502、503、504等）不应该重试
    },
    this.exceptionTypeRetryCount = const {
      // 只有超时相关的异常类型才需要延迟重试
      DioExceptionType.connectionTimeout: 2, // 连接超时
      DioExceptionType.sendTimeout: 2, // 发送超时
      DioExceptionType.receiveTimeout: 2, // 接收超时
      // 注意：connectionError 等其他错误不应该重试
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
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity();

  RetryInterceptor({
    required this.dio,
    SmartRetryConfig? config,
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

      // 如果是最后一次重试失败，传递最新的错误信息（而不是原始错误）
      if (retryCount + 1 >= config.maxRetries) {
        // 确保传递最新的错误信息，让调用层知道真正的失败原因
        if (retryError is DioException) {
          return handler.reject(retryError);
        } else {
          // 如果不是 DioException，创建一个新的 DioException 包装错误
          final finalError = DioException(
            requestOptions: err.requestOptions,
            error: retryError,
            type: DioExceptionType.unknown,
            message: '$retryError',
          );
          return handler.reject(finalError);
        }
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
      // 根据配置判断是否需要重试，并生成相应的原因信息
      if (config.statusCodeRetryCount.containsKey(statusCode)) {
        // 根据状态码生成相应的原因信息
        switch (statusCode) {
          case 408:
            reason = _getLocalizedMessage('retry_timeout', '请求超时，建议重试');
            break;
          case 429:
            reason = _getLocalizedMessage('retry_rate_limit', '请求频率过高，建议延迟重试');
            break;
          default:
            reason = _getLocalizedMessage('retry_network_error', '网络错误，建议重试');
        }
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          reason = _getLocalizedMessage('retry_network_timeout', '网络超时，建议重试');
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
      // 根据配置判断是否需要重试
      if (config.statusCodeRetryCount.containsKey(statusCode)) {
        final maxRetriesForStatusCode = config.statusCodeRetryCount[statusCode];
        if (maxRetriesForStatusCode != null && currentRetryCount >= maxRetriesForStatusCode) {
          return false;
        }
        return true;
      }

      // 其他所有错误都不应该重试
      return false;
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
    final exponentialDelay = config.baseDelay.inMilliseconds * pow(config.backoffMultiplier, retryCount).toInt();

    // 添加抖动
    final jitterRange = exponentialDelay * config.jitterFactor;
    final jitter = (Random().nextDouble() - 0.5) * 2 * jitterRange;

    final totalDelay = exponentialDelay + jitter.toInt();

    // 确保延迟在最小1秒和最大延迟之间
    const int minDelayMs = 1000; // 最小延迟1秒
    return Duration(milliseconds: totalDelay.clamp(minDelayMs, config.maxDelay.inMilliseconds));
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
