import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

import '../../utils/request_queue_manager.dart';
import '../cache/cache_storage.dart';
import '../cache/file_cache.dart';
import '../cache/lru_cache.dart';
import '../cache/memory_cache.dart';
import '../cache/sqlite_cache.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/cache_interceptor.dart';
import '../interceptors/timeout_interceptor.dart';

/// Dio客户端初始化器
/// 负责初始化Dio实例和配置
class DioClientInitializer {
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
  /// [maxConcurrentRequests] 最大并发请求数（队列控制）
  /// [requestInterval] 请求间隔
  /// [enableRequestQueue] 是否启用请求队列管理
  /// [maxErrorMessageLength] 最大错误消息长度
  /// [proxyConfig] 代理配置（优先级高于其他代理参数）
  /// [proxy] 代理地址（格式：http://host:port 或 socks5://host:port），如果提供了 proxyConfig 则忽略此参数
  /// [proxyUsername] 代理用户名（可选），如果提供了 proxyConfig 则忽略此参数
  /// [proxyPassword] 代理密码（可选），如果提供了 proxyConfig 则忽略此参数
  /// [findProxy] 自定义代理查找函数（优先级最高）
  Future<DioClientInitResult> init({
    required String baseUrl,
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
    int maxConcurrentConnections = 6,
    int? maxConcurrentRequests,
    Duration? requestInterval,
    bool? enableRequestQueue,
    int maxErrorMessageLength = 80,
    ProxyConfig? proxyConfig,
    String? proxy,
    String? proxyUsername,
    String? proxyPassword,
    String Function(Uri)? findProxy,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: connectTimeoutSeconds),
      sendTimeout: Duration(seconds: receiveTimeoutSeconds),
      receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
      headers: headers ?? {},
    ));

    // 设置HttpClientAdapter
    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();
        client.maxConnectionsPerHost = maxConcurrentConnections;
        client.connectionTimeout = Duration(seconds: connectTimeoutSeconds);
        client.idleTimeout = const Duration(seconds: 15);

        // 设置代理
        ProxyConfig? finalProxyConfig;
        if (proxyConfig != null) {
          // 使用代理配置对象
          finalProxyConfig = proxyConfig;
        } else if (proxy != null && proxy.isNotEmpty) {
          // 从字符串创建代理配置
          try {
            finalProxyConfig = ProxyConfig.fromString(
              proxy: proxy,
              username: proxyUsername,
              password: proxyPassword,
            );
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ 创建代理配置失败: $e');
            }
          }
        }

        if (findProxy != null) {
          // 使用自定义代理查找函数（优先级最高）
          client.findProxy = findProxy;
        } else if (finalProxyConfig != null) {
          // 使用代理配置
          client.findProxy = (uri) {
            return finalProxyConfig!.toProxyString();
          };

          // 设置代理认证（如果提供了用户名和密码）
          if (finalProxyConfig.hasAuthentication) {
            final proxyUsername = finalProxyConfig.username!;
            final proxyPassword = finalProxyConfig.password!;
            client.authenticateProxy = (host, port, scheme, realm) async {
              client.addProxyCredentials(
                host,
                port,
                realm ?? '',
                HttpClientBasicCredentials(proxyUsername, proxyPassword),
              );
              return true;
            };
          }
        }

        return client;
      };

    // 初始化监控拦截器
    final monitoringInterceptor = MonitoringInterceptor(
      enableDetailedLogging: kDebugMode,
      monitorRequestSize: true,
      monitorResponseSize: true,
    );

    // 添加拦截器（按优先级顺序）
    dio.interceptors.addAll([
      // 0. 监控拦截器（最高优先级）
      monitoringInterceptor,
      // 1. 智能重试拦截器
      RetryInterceptor(
        dio: dio,
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
      if (enableAuth) AuthInterceptor(),
      // 3. 缓存拦截器
      if (enableCache) await _createCacheInterceptor(cacheType, lruCapacity, cacheDuration),
      // 4. 日志拦截器（调试模式）
      if (kDebugMode && enableLogging) logInterceptor ?? LoggingInterceptor(),
      // 5. 超时拦截器
      TimeoutInterceptor(),
      // 6. 自定义拦截器（最低优先级）
      ...interceptors,
    ]);

    // 添加响应转换器
    dio.transformer = BackgroundTransformer();

    // 初始化请求队列管理器
    RequestQueueManager? requestQueueManager;
    final shouldEnableQueue = enableRequestQueue ?? HttpConfig.defaultEnableRequestQueue;
    if (shouldEnableQueue) {
      requestQueueManager = RequestQueueManager(
        maxConcurrentRequests: maxConcurrentRequests ?? HttpConfig.defaultMaxConcurrentRequests,
        requestInterval: requestInterval ?? HttpConfig.defaultRequestInterval,
        enableRequestQueue: shouldEnableQueue,
      );
    }

    return DioClientInitResult(
      dio: dio,
      monitoringInterceptor: monitoringInterceptor,
      requestQueueManager: requestQueueManager,
      maxErrorMessageLength: maxErrorMessageLength,
    );
  }

  Future<CacheInterceptor> _createCacheInterceptor(
    CacheType cacheType,
    int lruCapacity,
    Duration cacheDuration,
  ) async {
    final cacheStorage = await _createCacheStorage(cacheType, lruCapacity);
    final cacheManager = CacheManager(cacheStorage);
    await cacheManager.init();
    return CacheInterceptor(cacheManager, defaultDuration: cacheDuration);
  }

  Future<CacheStorage> _createCacheStorage(CacheType cacheType, int lruCapacity) async {
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
}

/// Dio客户端初始化结果
class DioClientInitResult {
  final Dio dio;
  final MonitoringInterceptor monitoringInterceptor;
  final RequestQueueManager? requestQueueManager;
  final int maxErrorMessageLength;

  DioClientInitResult({
    required this.dio,
    required this.monitoringInterceptor,
    this.requestQueueManager,
    required this.maxErrorMessageLength,
  });
}
