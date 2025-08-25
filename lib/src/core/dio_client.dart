import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/base/base_response.dart';
import 'package:network_kit_lite/src/core/cache/cache_storage.dart';
import 'package:network_kit_lite/src/core/interceptors/auth_interceptor.dart';
import 'package:network_kit_lite/src/utils/params_creator.dart';
import 'package:network_kit_lite/src/utils/type_safety_utils.dart';

import 'app_exception.dart';
import 'cache/file_cache.dart';
import 'cache/lru_cache.dart';
import 'cache/memory_cache.dart';
import 'cache/sqlite_cache.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/timeout_interceptor.dart';

import 'models/options_extra_data.dart';
import 'package:dio/io.dart';
import 'package:network_kit_lite/src/core/interceptors/monitoring_interceptor.dart';
import 'package:network_kit_lite/src/core/monitoring/network_monitor.dart';
import 'package:network_kit_lite/src/utils/network_connectivity.dart';

// 方便外部调用
DioClient get dioClient => DioClient();

// HTTP请求方法
enum HttpRequestMethod {
  get('GET', "从服务器获取资源"),
  post('POST', "向服务器提交数据，常用于创建资源"),
  put('PUT', "更新服务器上的资源，通常需要提供完整的资源数据"),
  patch('PATCH', "部分更新服务器上的资源，只需提供需要修改的字段"),
  delete('DELETE', "删除服务器上的资源"),
  head('HEAD', "获取资源的元信息（如响应头），不返回响应体");

  final String method;
  final String desc;
  const HttpRequestMethod(this.method, this.desc);

  @override
  String toString() => "method:$method,描述:$desc";
}

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;
  bool _isInit = false;
  final Map<String, CancelToken> _cancelTokens = {};
  late final MonitoringInterceptor _monitoringInterceptor;
  /// 网络连接检测器
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity();

  /// 网络状态变化监听器
  StreamSubscription<NetworkConnectivityStatus>? _networkStatusSubscription;

  /// 初始化网络状态监听
  void _initializeNetworkMonitoring() {
    _networkStatusSubscription = _networkConnectivity.onConnectivityChanged.listen(
      (status) {
        if (kDebugMode) {
          print('🌐 DioClient 检测到网络状态变化: ${_networkConnectivity.getNetworkTypeDescription(status)}');
        }

        // 可以根据网络状态变化执行相应操作
        // 例如：重新连接、清理缓存等
        _onNetworkStatusChanged(status);
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ 网络状态监听错误: $error');
        }
      },
    );
  }

  /// 网络状态变化处理
  void _onNetworkStatusChanged(NetworkConnectivityStatus status) {
    switch (status) {
      case NetworkConnectivityStatus.none:
        if (kDebugMode) {
          print('⚠️ 网络断开，暂停网络请求');
        }
        // 可以在这里实现网络断开时的处理逻辑
        break;
      case NetworkConnectivityStatus.wifi:
      case NetworkConnectivityStatus.mobile:
      case NetworkConnectivityStatus.ethernet:
      case NetworkConnectivityStatus.vpn:
        if (kDebugMode) {
          print('✅ 网络恢复，可以继续网络请求');
        }
        // 可以在这里实现网络恢复时的处理逻辑
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
  Future<void> init(
      {String baseUrl = '',
      Map<String, dynamic>? headers,
      int connectTimeoutSeconds = 10, // 单位：秒
      int receiveTimeoutSeconds = 10, // 单位：秒
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
      int maxConcurrentConnections = 6}) async {
    if (_isInit) return;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: connectTimeoutSeconds),
      sendTimeout: Duration(seconds: receiveTimeoutSeconds),
      receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
      headers: headers ?? {},
    ));

    // 设置HttpClientAdapter
    _dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();
        client.maxConnectionsPerHost = maxConcurrentConnections; // 设置最大并发连接数
        client.connectionTimeout = Duration(seconds: connectTimeoutSeconds); // 设置连接超时
        client.idleTimeout = const Duration(seconds: 15); // 设置空闲超时时间
        return client;
      };

    // _dio.httpClientAdapter = IOHttpClientAdapter()
    // ..onHttpClientCreate = (HttpClient client) {
    //   client.findProxy = (uri) {
    //     // 设置代理地址（如 Charles 默认 8888 端口）
    //     return 'PROXY 192.168.1.100:8888'; // 替换为你的代理 IP 和端口
    //   };
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true; // 忽略 HTTPS 证书验证
    //   return client;
    // };

    // 初始化监控拦截器
    _monitoringInterceptor = MonitoringInterceptor(
      enableDetailedLogging: kDebugMode,
      monitorRequestSize: true,
      monitorResponseSize: true,
    );

    // 添加拦截器（按优先级顺序）
    try {
      _dio.interceptors.addAll([
        // 0. 监控拦截器（最高优先级）
        _monitoringInterceptor,

        // 1. 智能重试拦截器
        RetryInterceptor(
          dio: _dio,
          config: SmartRetryConfig(
            maxRetries: maxRetries,
            baseDelay: retryDelay,
            backoffMultiplier: 2.0,
            jitterFactor: 0.3,
            enableNetworkCheck: true,
            networkCheckTimeout: const Duration(seconds: 3),
          ),
        ),

        // 2. 授权拦截器
        if(enableAuth) AuthInterceptor(),

        // 3. 缓存拦截器
        if (enableCache)
          await _createCacheInterceptor(cacheType, lruCapacity, cacheDuration),

        // 4. 日志拦截器（调试模式）
        if (kDebugMode && enableLogging)
          logInterceptor ?? LoggingInterceptor(),

        // 5. 超时拦截器
        TimeoutInterceptor(),

        // 6. 自定义拦截器（最低优先级）
        ...interceptors,
      ]);

      if (kDebugMode) {
        print('✅ DioClient 拦截器初始化成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ DioClient 拦截器初始化失败: $e');
      }
      rethrow;
    }

    // 添加响应转换器
    _dio.transformer = BackgroundTransformer();
    _isInit = true;

    // 初始化网络状态监听
    _initializeNetworkMonitoring();

    if (kDebugMode) {
      print('✅ DioClient 初始化成功: $baseUrl');
    }
  }

  Future<CacheInterceptor> _createCacheInterceptor(
      CacheType cacheType, int lruCapacity, Duration cacheDuration) async {
    final cacheStorage = await _createCacheStorage(cacheType, lruCapacity);
    final cacheManager = CacheManager(cacheStorage);
    await cacheManager.init();
    return CacheInterceptor(cacheManager, defaultDuration: cacheDuration);
  }

  Future<CacheStorage> _createCacheStorage(
      CacheType cacheType, int lruCapacity) async {
    switch (cacheType) {
      case CacheType.file:
        return FileCache('${Directory.systemTemp.path}/api_cache');
      case CacheType.sqlite:
        return SQLiteCache();
      case CacheType.lru:
        return LRUCache(lruCapacity);
      case CacheType.memory:
      default:
        return MemoryCache();
    }
  }

  /// 执行API请求
  /// [endPoint] API端点配置
  /// [cancelTokenKey] 取消令牌键
  /// [customTimeOutEnabled] 是否启用自定义超时
  /// [checkNetworkBeforeRequest] 是否在请求前检查网络状态
  Future<BaseResponse<T>> execute<T>(
    APIEndpoint endPoint, {
    String? cancelTokenKey,
    bool customTimeOutEnabled = false,
    T Function(dynamic)? responseTransformer,
    bool checkNetworkBeforeRequest = true,
  }) async {
    // 参数验证
    if (!_isInit) {
      throw AppException(
        code: -1,
        message: 'DioClient 未初始化，请先调用 init() 方法',
      );
    }

    // 验证端点URL
    if (!TypeSafetyUtils.isValidString(endPoint.url())) {
      throw AppException(
        code: -1,
        message: 'Invalid endpoint URL',
      );
    }

    // 请求前检查网络状态
    if (checkNetworkBeforeRequest) {
      final isNetworkAvailable = await _networkConnectivity.isNetworkAvailable();
      if (!isNetworkAvailable) {
        if (kDebugMode) {
          print('❌ 网络不可用，跳过请求: ${endPoint.url()}');
        }
        return ResponseHandler.handleError(
          AppException.networkError(message: '网络连接不可用，请检查网络设置'),
        );
      }
    }

    final requestId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (kDebugMode) {
        print('🚀 开始API请求 [$requestId]: ${endPoint.httpMethod} ${endPoint.url()}');
      }

      // 安全地处理查询参数和头部
      final safeQueryParams = TypeSafetyUtils.safeMap(endPoint.queryParameters);
      final safeHeaders = TypeSafetyUtils.safeMap(endPoint.headers);

      final options = Options(
        method: endPoint.httpMethod.toString().split('.').last.toUpperCase(),
        headers: safeHeaders.isNotEmpty ? safeHeaders : null,
        contentType: endPoint.contentType,
        extra: OptionsExtraData.copyWith(
                endPoint: endPoint, customTimeOut: customTimeOutEnabled)
            .toMap(),
      );

      // 管理取消令牌
      final cancelToken = _manageCancelToken(cancelTokenKey);
      final response = await _dio.request(
        endPoint.url(),
        options: options,
        queryParameters: safeQueryParams.isNotEmpty ? safeQueryParams : null,
        data: endPoint.requestBody,
        cancelToken: cancelToken,
      );

      if (kDebugMode) {
        print('✅ API请求成功 [$requestId]: ${response.statusCode}');
      }

      // 验证响应数据
      if (response.data is Map<String, dynamic>) {
        final isValid = ResponseHandler.validateResponseData(response.data as Map<String, dynamic>);
        if (!isValid && kDebugMode) {
          print('Warning: Response data validation failed for endpoint: ${endPoint.url()}');
        }
      }

      final baseResponse = ResponseHandler.handleResponse<T>(response);

      // 安全的响应转换
      if (responseTransformer != null && baseResponse.data != null) {
        try {
          baseResponse.data = responseTransformer(baseResponse.data);
        } catch (transformError) {
          if (kDebugMode) {
            print('⚠️ 响应转换失败 [$requestId]: $transformError');
          }
          // 转换失败时保持原始数据
        }
      }

      return baseResponse;
    } catch (error) {
      _removeCancelToken(cancelTokenKey);

      if (error is DioException) {
        if (CancelToken.isCancel(error)) {
          if (kDebugMode) {
            print('🚫 API请求被取消 [$requestId]: $cancelTokenKey');
          }
          return ResponseHandler.handleCancelError(error, -1);
        }

        if (kDebugMode) {
          print('❌ 网络异常 [$requestId]: ${error.type} - ${error.message}');
        }
        return ResponseHandler.handleDioException(error);
      } else if (error is AppException) {
        if (kDebugMode) {
          print('❌ 应用异常 [$requestId]: ${error.code} - ${error.message}');
        }
        return ResponseHandler.handleError(error);
      }

      if (kDebugMode) {
        print('❌ 未知异常 [$requestId]: $error');
      }

      return ResponseHandler.handleError(
        AppException.unknownError(error.toString()),
      );
    } finally {
      _removeCancelToken(cancelTokenKey);
    }
  }

  // 传统请求方式
  // 兼容legend方式的API调用
  Future<T> request<T>(String url, HttpRequestMethod method,
      {String? cancelTokenKey,
      Map<String, dynamic>? headers,
      Object? data,
      Map<String, dynamic>? queryParameters,
      CachePolicy cachePolicy = CachePolicy.networkFirst,
      ParamsCreator? creator,
      T Function(dynamic)? responseTransformer,
      }) async {
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
          method: method.method.toUpperCase(),
          headers: safeHeaders.isNotEmpty ? safeHeaders : null,
          extra: OptionsExtraData(cachePolicy: cachePolicy).toMap());

      // 转换options（仅当启用了转换时）
      if (creator != null && creator.enableOptionsConversion) {
        options = creator.convertOptions(options);
      }

      final cancelToken = _manageCancelToken(cancelTokenKey);
      final response = await _dio.request(
        url,
        options: options,
        queryParameters: (processedQueryParameters?.isNotEmpty == true) ? processedQueryParameters : null,
        data: data,
        cancelToken: cancelToken,
      );

      // 验证响应数据
      if (response.data is Map<String, dynamic>) {
        final isValid = ResponseHandler.validateResponseData(response.data as Map<String, dynamic>);
        if (!isValid && kDebugMode) {
          print('Warning: Response data validation failed for URL: $url');
        }
      }

      // 处理响应
      if (responseTransformer != null) {
        return _processResponse(response.data, responseTransformer);
      }

      // 如果没有转换器，返回原始响应数据
      return response.data as T;
    } catch (error) {
      _removeCancelToken(cancelTokenKey);
      if (error is DioException) {
        if (CancelToken.isCancel(error)) {
          if (kDebugMode) {
            print('API请求被取消: $cancelTokenKey');
          }
          throw AppException(
            message: '请求被取消',
            code: -1,
          );
        }

        throw AppException(
          message: error.message ?? '网络请求失败',
          code: error.response?.statusCode ?? -1,
        );
      } else if (error is AppException) {
        rethrow;
      }

      if (kDebugMode) {
        print('API请求错误: $error');
      }

      throw AppException(
        message: '未知错误: $error',
        code: -1,
      );
    } finally {
      _removeCancelToken(cancelTokenKey);
    }
  }

  // 处理查询参数签名的辅助方法
  Map<String, dynamic>? _signQueryParameters(Map<String, dynamic> parameters) {
    // 尝试调用sign方法，如果不存在则返回原参数
    try {
      // 检查参数是否包含sign方法
      if (parameters.containsKey('sign') && parameters['sign'] is Function) {
        final signFunction = parameters['sign'] as Function;
        final result = signFunction();
        return result as Map<String, dynamic>? ?? parameters;
      }
      return parameters;
    } catch (e) {
      if (kDebugMode) {
        print('签名方法调用失败: $e');
      }
      return parameters;
    }
  }

  // 处理响应的辅助方法
  T _processResponse<T>(dynamic responseData, T Function(dynamic) responseTransformer) {
    try {
      final result = responseTransformer(responseData);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('响应处理方法调用失败: $e');
      }
      // 处理失败时抛出异常
      throw AppException(
        message: '响应数据转换失败: $e',
        code: -1,
      );
    }
  }

  // 管理取消令牌的公共方法
  CancelToken? _manageCancelToken(String? cancelTokenKey) {
    if (cancelTokenKey == null) return null;

    cancelRequest(cancelTokenKey);
    final cancelToken = CancelToken();
    _cancelTokens[cancelTokenKey] = cancelToken;
    return cancelToken;
  }

  // 移除取消令牌
  void _removeCancelToken(String? cancelTokenKey) {
    if (cancelTokenKey != null) {
      _cancelTokens.remove(cancelTokenKey);
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

  /// 取消特定key的请求
  void cancelRequest(String cancelTokenKey) {
    final token = _cancelTokens[cancelTokenKey];
    if (token != null && !token.isCancelled) {
      token.cancel('Request cancelled by user: $cancelTokenKey');
    }
    _cancelTokens.remove(cancelTokenKey);
  }

  /// 取消所有请求
  void cancelAllRequests() {
    _cancelTokens.forEach((key, token) {
      if (!token.isCancelled) {
        token.cancel('All requests cancelled by user');
      }
    });
    _cancelTokens.clear();
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

  /// 释放资源
  void dispose() {
    _networkStatusSubscription?.cancel();
    if (kDebugMode) {
      print('✅ DioClient 资源已释放');
    }
  }
}
