import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/utils/params_creator.dart';

import '../../utils/request_queue_manager.dart';
import '../interceptors/cache_interceptor.dart';
import '../models/options_extra_data.dart';
import 'cancel_token_manager.dart';
import 'dio_client_initializer.dart';
import 'request_executor.dart';

// 方便外部调用
DioClient get dioClient => DioClient();

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;

  /// 是否初始化
  bool _isInit = false;

  /// 监控拦截器
  late final MonitoringInterceptor _monitoringInterceptor;

  /// 请求队列管理器
  RequestQueueManager? _requestQueueManager;

  /// 错误消息最大长度
  int _maxErrorMessageLength = HttpConfig.defaultErrorMessageMaxLength;

  /// 取消令牌管理器
  final CancelTokenManager _cancelTokenManager = CancelTokenManager();

  /// 请求执行器
  RequestExecutor? _requestExecutor;

  /// 网络连接检测器
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity();

  /// 网络状态变化监听器
  StreamSubscription<NetworkConnectivityStatus>? _networkStatusSubscription;

  /// 获取错误消息最大长度
  int get maxErrorMessageLength => _maxErrorMessageLength;

  /// 初始化网络状态监听
  void _initializeNetworkMonitoring() {
    _networkStatusSubscription = _networkConnectivity.onConnectivityChanged.listen(
      (status) {
        _onNetworkStatusChanged(status);
      },
      onError: (error) {
        if (kDebugMode) {
          print('⚠️ 网络状态监听错误: $error');
        }
      },
    );
  }

  /// 网络状态变化处理
  void _onNetworkStatusChanged(NetworkConnectivityStatus status) {
    switch (status) {
      case NetworkConnectivityStatus.none:
        // 可以在这里实现网络断开时的处理逻辑
        if (kDebugMode) {
          print('🌐 网络已断开');
        }
        break;
      case NetworkConnectivityStatus.wifi:
      case NetworkConnectivityStatus.mobile:
      case NetworkConnectivityStatus.ethernet:
      case NetworkConnectivityStatus.vpn:
        // 可以在这里实现网络恢复时的处理逻辑
        if (kDebugMode) {
          print('🌐 网络已恢复: $status');
        }
        break;
      default:
        // 其他状态的处理
        break;
    }
  }

  /// 初始化Dio客户端
  /// [baseUrl] 基础URL
  /// [headers] 默认请求头
  /// [connectTimeoutSeconds] 连接超时时间（秒）
  /// [receiveTimeoutSeconds] 接收超时时间（秒）
  /// [enableCache] 是否启用缓存
  /// [cacheType] 缓存类型
  /// [lruCapacity] LRU缓存容量
  /// [cacheDuration] 缓存持续时间
  /// [maxRetries] 最大重试次数
  /// [retryDelay] 重试延迟
  /// [enableLogging] 是否启用日志
  /// [enableAuth] 是否启用认证
  /// [interceptors] 自定义拦截器
  /// [logInterceptor] 自定义日志拦截器
  /// [maxConcurrentConnections] 最大并发连接数
  /// [maxConcurrentRequests] 最大并发请求数（队列控制），默认使用 HttpConfig.defaultMaxConcurrentRequests
  /// [requestInterval] 请求间隔，默认使用 HttpConfig.defaultRequestInterval
  /// [enableRequestQueue] 是否启用请求队列管理，默认使用 HttpConfig.defaultEnableRequestQueue
  /// [proxyConfig] 代理配置（优先级高于其他代理参数）
  /// [proxy] 代理地址（格式：http://host:port 或 socks5://host:port），如果提供了 proxyConfig 则忽略此参数
  /// [proxyUsername] 代理用户名（可选），如果提供了 proxyConfig 则忽略此参数
  /// [proxyPassword] 代理密码（可选），如果提供了 proxyConfig 则忽略此参数
  /// [findProxy] 自定义代理查找函数（优先级最高）
  Future<void> init(
      {String baseUrl = '',
      Map<String, dynamic>? headers,
      int connectTimeoutSeconds = 10,
      int receiveTimeoutSeconds = 10,
      bool enableCache = false,
      CacheType cacheType = CacheType.memory,
      int lruCapacity = 100,
      Duration cacheDuration = const Duration(hours: 1),
      int maxRetries = 3,
      Duration retryDelay = const Duration(milliseconds: 500),
      bool enableLogging = true,
      bool enableAuth = true,
      List<Interceptor> interceptors = const [],
      Interceptor? logInterceptor,
      int maxErrorMessageLength = 80,
      int maxConcurrentConnections = 6,
      int? maxConcurrentRequests,
      Duration? requestInterval,
      bool? enableRequestQueue,
      ProxyConfig? proxyConfig,
      String? proxy,
      String? proxyUsername,
      String? proxyPassword,
      String Function(Uri)? findProxy}) async {
    if (_isInit) return;

    // 使用初始化器初始化Dio
    final initializer = DioClientInitializer();
    final result = await initializer.init(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeoutSeconds: connectTimeoutSeconds,
      receiveTimeoutSeconds: receiveTimeoutSeconds,
      enableCache: enableCache,
      cacheType: cacheType,
      lruCapacity: lruCapacity,
      cacheDuration: cacheDuration,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      enableLogging: enableLogging,
      enableAuth: enableAuth,
      interceptors: interceptors,
      logInterceptor: logInterceptor,
      maxConcurrentConnections: maxConcurrentConnections,
      maxConcurrentRequests: maxConcurrentRequests,
      requestInterval: requestInterval,
      enableRequestQueue: enableRequestQueue,
      maxErrorMessageLength: maxErrorMessageLength,
      proxyConfig: proxyConfig,
      proxy: proxy,
      proxyUsername: proxyUsername,
      proxyPassword: proxyPassword,
      findProxy: findProxy,
    );

    _dio = result.dio;
    _monitoringInterceptor = result.monitoringInterceptor;
    _requestQueueManager = result.requestQueueManager;
    _maxErrorMessageLength = result.maxErrorMessageLength;
    _isInit = true;

    // 初始化请求执行器
    _requestExecutor = RequestExecutor(
      dio: _dio,
      requestQueueManager: _requestQueueManager,
      cancelTokenManager: _cancelTokenManager,
      networkConnectivity: _networkConnectivity,
    );

    // 初始化网络状态监听
    _initializeNetworkMonitoring();
  }

  /// 执行API请求
  /// [endPoint] API端点配置
  /// [cancelToken] 取消令牌
  /// [customTimeOutEnabled] 是否启用自定义超时
  /// [checkNetworkBeforeRequest] 是否在请求前检查网络状态
  Future<BaseResponse<T>> execute<T>(
    APIEndpoint endPoint, {
    NetworkCancelToken? cancelToken,
    bool customTimeOutEnabled = false,
    T Function(dynamic)? responseTransformer,
    bool checkNetworkBeforeRequest = true,
  }) async {
    // 参数验证
    if (!_isInit || _requestExecutor == null) {
      throw AppException(
        code: -1,
        message: 'DioClient 未初始化，请先调用 init() 方法',
      );
    }

    // 验证端点URL
    if (!TypeSafetyUtils.isValidString(endPoint.url)) {
      throw AppException(
        code: -1,
        message: 'Invalid endpoint URL',
      );
    }

    try {
      // 安全地处理查询参数和头部
      final safeQueryParams = TypeSafetyUtils.safeMap(endPoint.queryParameters);
      final safeHeaders = TypeSafetyUtils.safeMap(endPoint.headers);

      final options = Options(
        method: endPoint.httpMethod.toUpperCase(),
        headers: safeHeaders.isNotEmpty ? safeHeaders : null,
        contentType: endPoint.contentType,
        extra: OptionsExtraData.fromEndpoint(endPoint: endPoint, enableLogging: endPoint.enableLogging).toMap(),
      );

      // 使用请求执行器执行请求
      final response = await _requestExecutor!.executeRequest(
        url: endPoint.url,
        options: options,
        queryParameters: safeQueryParams.isNotEmpty ? safeQueryParams : null,
        data: endPoint.requestBody,
        cancelToken: cancelToken,
        checkNetworkBeforeRequest: checkNetworkBeforeRequest,
      );

      // 处理响应
      return _requestExecutor!.handleResponse<T>(
        response,
        responseTransformer: responseTransformer,
      );
    } catch (error) {
      return _requestExecutor!.handleError<T>(error);
    }
  }

  /// 使用NetworkCallbacks执行API请求
  /// [endPoint] API端点配置
  /// [callbacks] 网络回调处理器
  /// [cancelToken] 取消令牌
  /// [customTimeOutEnabled] 是否启用自定义超时
  /// [checkNetworkBeforeRequest] 是否在请求前检查网络状态
  /// [responseTransformer] 响应数据转换器
  Future<void> executeWithCallbacks<T>(
    APIEndpoint endPoint,
    NetworkCallbacks<T> callbacks, {
    NetworkCancelToken? cancelToken,
    bool customTimeOutEnabled = false,
    T Function(dynamic)? responseTransformer,
    bool checkNetworkBeforeRequest = true,
  }) async {
    try {
      // 参数验证
      if (!_isInit || _requestExecutor == null) {
        final errorResponse = ResponseHandler.handleError<T>(
          AppException(
            code: -1,
            message: 'DioClient 未初始化，请先调用 init() 方法',
          ),
        );
        callbacks.callOnError(errorResponse);
        callbacks.callOnComplete();
        return;
      }

      // 验证端点URL
      if (!TypeSafetyUtils.isValidString(endPoint.url)) {
        final errorResponse = ResponseHandler.handleError<T>(
          AppException(
            code: -1,
            message: 'Invalid endpoint URL',
          ),
        );
        callbacks.callOnError(errorResponse);
        callbacks.callOnComplete();
        return;
      }

      // 安全地处理查询参数和头部
      final safeQueryParams = TypeSafetyUtils.safeMap(endPoint.queryParameters);
      final safeHeaders = TypeSafetyUtils.safeMap(endPoint.headers);

      final options = Options(
        method: endPoint.httpMethod.toUpperCase(),
        headers: safeHeaders.isNotEmpty ? safeHeaders : null,
        contentType: endPoint.contentType,
        extra: OptionsExtraData.fromEndpoint(endPoint: endPoint, enableLogging: endPoint.enableLogging).toMap(),
      );

      // 使用请求执行器执行请求
      final response = await _requestExecutor!.executeRequest(
        url: endPoint.url,
        options: options,
        queryParameters: safeQueryParams.isNotEmpty ? safeQueryParams : null,
        data: endPoint.requestBody,
        cancelToken: cancelToken,
        checkNetworkBeforeRequest: checkNetworkBeforeRequest,
      );

      // 处理响应
      final baseResponse = _requestExecutor!.handleResponse<T>(
        response,
        responseTransformer: responseTransformer,
      );

      // 调用成功回调
      callbacks.callOnData(baseResponse);
    } catch (error) {
      // 处理错误
      final errorResponse = _requestExecutor?.handleError<T>(error) ??
          ResponseHandler.handleError<T>(
            AppException.unknownError(error.toString()),
          );
      callbacks.callOnError(errorResponse);
    } finally {
      // 调用完成回调
      callbacks.callOnComplete();
    }
  }

  // 传统请求方式
  // 兼容legend方式的API调用
  Future<T> request<T>(
    String url,
    HTTPMethod method, {
    NetworkCancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CachePolicy cachePolicy = CachePolicy.networkFirst,
    ParamsCreator? creator,
    bool enableLogging = true,
    bool skipAuthLogout = false,
    T Function(dynamic)? responseTransformer,
  }) async {
    // 参数验证
    if (!_isInit || _requestExecutor == null) {
      throw AppException(
        code: -1,
        message: 'DioClient 未初始化，请先调用 init() 方法',
      );
    }

    try {
      // 验证URL参数
      if (!TypeSafetyUtils.isValidString(url)) {
        throw AppException(
          message: 'Invalid request URL',
          code: -1,
        );
      }

      // 安全地处理查询参数和头部
      Map<String, dynamic>? processedQueryParameters = TypeSafetyUtils.safeMap(queryParameters);
      final safeHeaders = TypeSafetyUtils.safeMap(headers);

      if (creator != null && creator.enableSign && queryParameters != null) {
        processedQueryParameters = _signQueryParameters(queryParameters);
      }

      // 创建并处理options
      Options options = Options(
          method: method.toUpperCase(),
          headers: safeHeaders.isNotEmpty ? safeHeaders : null,
          extra: OptionsExtraData(
            cachePolicy: cachePolicy,
            enableLogging: enableLogging,
            skipAuthLogout: skipAuthLogout,
          ).toMap());

      // 转换options（仅当启用了转换时）
      if (creator != null && creator.enableOptionsConversion) {
        options = creator.convertOptions(options);
      }

      // 使用请求执行器执行请求
      final response = await _requestExecutor!.executeRequest(
        url: url,
        options: options,
        queryParameters: (processedQueryParameters?.isNotEmpty == true) ? processedQueryParameters : null,
        data: data,
        cancelToken: cancelToken,
        checkNetworkBeforeRequest: false,
      );

      // 处理响应
      if (responseTransformer != null) {
        return _processResponse(response.data, responseTransformer);
      }

      // 如果没有转换器，返回原始响应数据
      return response.data as T;
    } catch (error) {
      if (error is DioException) {
        if (CancelToken.isCancel(error)) {
          throw AppException(
            message: '请求被取消',
            code: -1,
          );
        }
        // 保留原始错误消息，不要覆盖
        final originalMessage = error.message;
        if (originalMessage != null && originalMessage.isNotEmpty) {
          throw AppException(
            message: originalMessage,
            code: error.response?.statusCode ?? -1,
          );
        } else {
          throw AppException(
            message: '网络请求失败',
            code: error.response?.statusCode ?? -1,
          );
        }
      } else if (error is AppException) {
        rethrow;
      }
      throw AppException(
        message: '未知错误: $error',
        code: -1,
      );
    }
  }

  /// 使用NetworkCallbacks执行网络请求（直接参数方式）
  /// [url] 请求URL
  /// [method] HTTP请求方法
  /// [callbacks] 网络回调处理器
  /// [cancelToken] 取消令牌
  /// [headers] 请求头
  /// [data] 请求体数据
  /// [queryParameters] 查询参数
  /// [cachePolicy] 缓存策略
  /// [creator] 参数创建器
  /// [enableLogging] 是否启用日志
  /// [skipAuthLogout] 是否跳过 Auth 鉴权校验导致的退出登录
  /// [responseTransformer] 响应数据转换器
  /// [checkNetworkBeforeRequest] 是否在请求前检查网络状态
  Future<void> requestWithCallbacks<T>(
    String url,
    HTTPMethod method,
    NetworkCallbacks<T> callbacks, {
    NetworkCancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CachePolicy cachePolicy = CachePolicy.networkFirst,
    ParamsCreator? creator,
    bool enableLogging = true,
    bool skipAuthLogout = false,
    T Function(dynamic)? responseTransformer,
    bool checkNetworkBeforeRequest = true,
  }) async {
    try {
      // 参数验证
      if (!_isInit || _requestExecutor == null) {
        final errorResponse = ResponseHandler.handleError<T>(
          AppException(
            code: -1,
            message: 'DioClient 未初始化，请先调用 init() 方法',
          ),
        );
        callbacks.callOnError(errorResponse);
        callbacks.callOnComplete();
        return;
      }

      // 验证URL参数
      if (!TypeSafetyUtils.isValidString(url)) {
        final errorResponse = ResponseHandler.handleError<T>(
          AppException(
            message: 'Invalid request URL',
            code: -1,
          ),
        );
        callbacks.callOnError(errorResponse);
        callbacks.callOnComplete();
        return;
      }

      // 安全地处理查询参数和头部
      Map<String, dynamic>? processedQueryParameters = TypeSafetyUtils.safeMap(queryParameters);
      final safeHeaders = TypeSafetyUtils.safeMap(headers);

      if (creator != null && creator.enableSign && queryParameters != null) {
        processedQueryParameters = _signQueryParameters(queryParameters);
      }

      // 创建并处理options
      Options options = Options(
          method: method.toUpperCase(),
          headers: safeHeaders.isNotEmpty ? safeHeaders : null,
          extra: OptionsExtraData(
            cachePolicy: cachePolicy,
            enableLogging: enableLogging,
            skipAuthLogout: skipAuthLogout,
          ).toMap());

      // 转换options（仅当启用了转换时）
      if (creator != null && creator.enableOptionsConversion) {
        options = creator.convertOptions(options);
      }

      // 使用请求执行器执行请求
      final response = await _requestExecutor!.executeRequest(
        url: url,
        options: options,
        queryParameters: (processedQueryParameters?.isNotEmpty == true) ? processedQueryParameters : null,
        data: data,
        cancelToken: cancelToken,
        checkNetworkBeforeRequest: checkNetworkBeforeRequest,
      );

      // 处理响应
      final baseResponse = _requestExecutor!.handleResponse<T>(
        response,
        responseTransformer: responseTransformer,
      );

      // 调用成功回调
      callbacks.callOnData(baseResponse);
    } catch (error) {
      // 处理错误
      final errorResponse = _requestExecutor?.handleError<T>(error) ??
          ResponseHandler.handleError<T>(
            AppException.unknownError(error.toString()),
          );
      callbacks.callOnError(errorResponse);
    } finally {
      // 调用完成回调
      callbacks.callOnComplete();
    }
  }

  // 处理查询参数签名的辅助方法
  Map<String, dynamic>? _signQueryParameters(Map<String, dynamic> parameters) {
    try {
      if (parameters.containsKey('sign') && parameters['sign'] is Function) {
        final signFunction = parameters['sign'] as Function;
        final result = signFunction();
        return result as Map<String, dynamic>? ?? parameters;
      }
      return parameters;
    } catch (e) {
      return parameters;
    }
  }

  // 处理响应的辅助方法
  T _processResponse<T>(dynamic responseData, T Function(dynamic) responseTransformer) {
    try {
      final result = responseTransformer(responseData);
      return result;
    } catch (e) {
      throw AppException(
        message: '响应数据转换失败: $e',
        code: -1,
      );
    }
  }

  // 清除所有缓存
  Future<void> clearCache() async {
    for (final interceptor in _dio.interceptors) {
      if (interceptor is CacheInterceptor) {
        await interceptor.clearCache();
        break;
      }
    }
  }

  /// 取消特定请求
  /// [cancelToken] 取消令牌，可以是 NetworkCancelToken 或 String（向后兼容）
  void cancelRequest(dynamic cancelToken) {
    _cancelTokenManager.cancelRequest(cancelToken);
  }

  /// 取消所有请求
  void cancelAllRequests() {
    _cancelTokenManager.cancelAllRequests();
  }

  /// 获取监控拦截器
  MonitoringInterceptor get monitoringInterceptor => _monitoringInterceptor;

  /// 获取网络统计信息
  NetworkStats getNetworkStats() {
    return _monitoringInterceptor.getStats();
  }

  /// 获取请求历史
  List<RequestPerformance> getRequestHistory({int? limit}) {
    return _monitoringInterceptor.getRequestHistory(limit: limit);
  }

  /// 获取性能报告
  Map<String, dynamic> getPerformanceReport() {
    return _monitoringInterceptor.getPerformanceReport();
  }

  /// 清除监控历史
  void clearMonitoringHistory() {
    _monitoringInterceptor.clearHistory();
  }

  /// 启用/禁用网络监控
  void setMonitoringEnabled(bool enabled) {
    _monitoringInterceptor.setEnabled(enabled);
  }

  /// 检查网络连接是否可用
  Future<bool> isNetworkAvailable() async {
    return await _networkConnectivity.isNetworkAvailable();
  }

  /// 检查网络连接是否可用（使用多个测试地址）
  Future<bool> isNetworkAvailableRobust() async {
    return await _networkConnectivity.isNetworkAvailableRobust();
  }

  /// 获取当前网络状态
  Future<NetworkConnectivityStatus> getNetworkStatus() async {
    return await _networkConnectivity.getNetworkStatus();
  }

  /// 检查是否为无网络状态
  Future<bool> isNoNetwork() async {
    return await _networkConnectivity.isNoNetwork();
  }

  /// 检查是否有网络连接
  Future<bool> hasNetworkConnection() async {
    return await _networkConnectivity.hasNetworkConnection();
  }

  /// 检查是否为移动网络
  Future<bool> isMobileNetwork() async {
    return await _networkConnectivity.isMobileNetwork();
  }

  /// 检查是否为WiFi网络
  Future<bool> isWifiNetwork() async {
    return await _networkConnectivity.isWifiNetwork();
  }

  /// 检查是否为VPN网络
  Future<bool> isVpnNetwork() async {
    return await _networkConnectivity.isVpnNetwork();
  }

  /// 获取网络连接类型描述
  Future<String> getNetworkTypeDescription() async {
    final status = await _networkConnectivity.getNetworkStatus();
    return _networkConnectivity.getNetworkTypeDescription(status);
  }

  /// 监听网络状态变化
  Stream<NetworkConnectivityStatus> get onConnectivityChanged {
    return _networkConnectivity.onConnectivityChanged;
  }

  /// 测试特定域名的连接性
  Future<bool> testHostConnectivity(String host, {Duration timeout = const Duration(seconds: 5)}) async {
    return await _networkConnectivity.testHostConnectivity(host, timeout: timeout);
  }

  /// 获取请求队列状态
  /// 返回活跃请求数和队列长度
  Map<String, int> getRequestQueueStatus() {
    if (_requestQueueManager == null) {
      return {'activeRequests': 0, 'queueLength': 0};
    }
    return {
      'activeRequests': _requestQueueManager!.activeRequests,
      'queueLength': _requestQueueManager!.queueLength,
    };
  }

  /// 清空请求队列
  void clearRequestQueue() {
    _requestQueueManager?.clearQueue();
  }

  /// 释放资源
  void dispose() {
    _networkStatusSubscription?.cancel();
    _requestQueueManager?.clearQueue();
    _cancelTokenManager.clear();
  }
}
