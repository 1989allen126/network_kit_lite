import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/cache/cache_opertation_result.dart';

class CacheInterceptor extends Interceptor {
  final CacheManager _cacheManager;
  final Duration _defaultDuration;

  // 内存缓存层
  final Map<String, CachedResponse> _memoryCache = {};

  // 批量操作队列
  final List<CacheOperation> _operationQueue = [];
  bool _isProcessingQueue = false;

  CacheInterceptor(
    this._cacheManager, {
    Duration? defaultDuration,
  }) : _defaultDuration = defaultDuration ?? const Duration(minutes: 5);

  void _enqueueOperation(CacheOperation operation) {
    _operationQueue.add(operation);

    if (!_isProcessingQueue) {
      _processOperationQueue();
    }
  }

  void _processOperationQueue() {
    if (_operationQueue.isEmpty || _isProcessingQueue) return;

    _isProcessingQueue = true;

    // 同步处理队列中的操作
    while (_operationQueue.isNotEmpty) {
      final operation = _operationQueue.removeAt(0);
      _handleOperation(operation);
    }

    _isProcessingQueue = false;
  }

  void _handleOperation(CacheOperation operation) async {
    try {
      dynamic result;

      switch (operation.type) {
        case CacheOperationType.get:
          result = await _cacheManager.get(operation.key!);
          break;
        case CacheOperationType.save:
          await _cacheManager.save(operation.key!, operation.data!, duration: operation.duration);
          break;
        case CacheOperationType.clear:
          await _cacheManager.clear();
          break;
      }

      // 处理操作结果
      _handleCacheOperationResult(CacheOperationResult(
        operationId: operation.id,
        type: operation.type,
        result: result,
        success: true,
      ));
    } catch (e) {
      _handleCacheOperationResult(CacheOperationResult(
        operationId: operation.id,
        type: operation.type,
        error: e.toString(),
        success: false,
      ));
    }
  }

  void _handleCacheOperationResult(CacheOperationResult result) {
    // 只处理保存和清除操作的结果
    if (result.type == CacheOperationType.save) {
      if (kDebugMode) {
        if (result.success) {
          print('✅ 磁盘缓存保存成功: ${result.operationId}');
        } else {
          print('❌ 磁盘缓存保存失败: ${result.operationId}, Error: ${result.error}');
        }
      }
    } else if (result.type == CacheOperationType.clear) {
      if (kDebugMode) {
        print('🧹 磁盘缓存清除操作完成: ${result.success ? '成功' : '失败'}');
      }
    }
  }

  // 检查内存缓存
  CachedResponse? _checkMemoryCache(String cacheKey, Duration maxAge) {
    final cached = _memoryCache[cacheKey];
    if (cached != null) {
      final age = DateTime.now().difference(cached.timestamp);
      if (age < maxAge) {
        return cached;
      } else {
        // 缓存过期，从内存中移除
        _memoryCache.remove(cacheKey);
      }
    }
    return null;
  }

  // 后台更新缓存的方法
  Future<void> _updateCacheInBackground(RequestOptions options, String cacheKey, Duration cacheDuration) async {
    try {
      // 创建一个新的请求，避免干扰主请求流程
      final newOptions = options.copyWith(
        extra: {...options.extra, 'cachePolicy': CachePolicy.networkOnly},
      );

      // 使用共享的Dio实例
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      // 配置并发限制
      if (dio.httpClientAdapter is IOHttpClientAdapter) {
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.maxConnectionsPerHost = 5;
          client.idleTimeout = const Duration(seconds: 30);
          return client;
        };
      }

      // 异步发起网络请求
      final response = await dio.request(
        newOptions.path,
        data: newOptions.data,
        queryParameters: newOptions.queryParameters,
        options: Options(
            method: newOptions.method,
            headers: newOptions.headers,
            contentType: newOptions.contentType,
            extra: newOptions.extra),
      );

      // 更新缓存
      if (response.statusCode == 200) {
        // 先更新内存缓存
        _memoryCache[cacheKey] = CachedResponse(
          data: response.data,
          timestamp: DateTime.now(),
        );

        // 再更新磁盘缓存
        _enqueueOperation(CacheOperation(
          id: 'save_${DateTime.now().millisecondsSinceEpoch}',
          type: CacheOperationType.save,
          key: cacheKey,
          data: response.data,
          duration: cacheDuration,
        ));

        if (kDebugMode) {
          print('🔄 缓存已更新: $cacheKey');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ 网络请求返回非成功状态码: ${response.statusCode}, $cacheKey');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ 缓存更新失败: $cacheKey, Error: $e');
        print(stackTrace);
      }
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final cachePolicy = options.extra['cachePolicy'] as CachePolicy? ?? CachePolicy.networkOnly;

    if (cachePolicy == CachePolicy.cacheFirst || cachePolicy == CachePolicy.cacheOnly) {
      final cacheKey = _generateCacheKey(options);
      final cacheDuration = options.extra['cacheDuration'] as Duration? ?? _defaultDuration;

      // 检查内存缓存
      final memoryCached = _checkMemoryCache(cacheKey, cacheDuration);
      if (memoryCached != null) {
        if (kDebugMode) {
          print('📥 内存缓存命中: $cacheKey');
        }

        if (cachePolicy == CachePolicy.cacheOnly) {
          return handler.resolve(
            Response(
              requestOptions: options,
              data: memoryCached.data,
              statusCode: 200,
              statusMessage: 'OK (Memory Cache)',
            ),
          );
        }

        handler.resolve(
          Response(
            requestOptions: options,
            data: memoryCached.data,
            statusCode: 200,
            statusMessage: 'OK (Memory Cache, updating...)',
          ),
        );

        _updateCacheInBackground(options, cacheKey, cacheDuration);
        return;
      }

      // 内存缓存未命中，直接继续请求流程
      // 磁盘缓存将在响应拦截器中处理
      if (kDebugMode) {
        print('❌ 缓存未命中: $cacheKey，继续网络请求');
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final cachePolicy = response.requestOptions.extra['cachePolicy'] as CachePolicy? ?? CachePolicy.networkOnly;
    final cacheDuration = response.requestOptions.extra['cacheDuration'] as Duration? ?? _defaultDuration;

    if (cachePolicy == CachePolicy.cacheFirst ||
        cachePolicy == CachePolicy.networkFirst ||
        cachePolicy == CachePolicy.cacheAndNetwork) {
      final cacheKey = _generateCacheKey(response.requestOptions);

      // 更新内存缓存
      _memoryCache[cacheKey] = CachedResponse(
        data: response.data,
        timestamp: DateTime.now(),
      );

      // 更新磁盘缓存
      _enqueueOperation(CacheOperation(
        id: 'save_${DateTime.now().millisecondsSinceEpoch}',
        type: CacheOperationType.save,
        key: cacheKey,
        data: response.data,
        duration: cacheDuration,
      ));

      if (kDebugMode) {
        print('💾 缓存保存: $cacheKey');
      }
    }

    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final cachePolicy = err.requestOptions.extra['cachePolicy'] as CachePolicy? ?? CachePolicy.networkOnly;

    // 对于CacheFirst策略，如果网络请求失败，尝试返回缓存
    if (cachePolicy == CachePolicy.cacheFirst) {
      final cacheKey = _generateCacheKey(err.requestOptions);

      // 优先检查内存缓存
      final memoryCached = _checkMemoryCache(cacheKey, _defaultDuration);
      if (memoryCached != null) {
        if (kDebugMode) {
          print('📥 网络请求失败，返回内存缓存: $cacheKey');
        }

        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            data: memoryCached.data,
            statusCode: 200,
            statusMessage: 'OK (Memory Cache)',
          ),
        );
      }

      // 检查磁盘缓存
      final completer = Completer<dynamic>();
      final operationId = 'get_${DateTime.now().millisecondsSinceEpoch}';

      _enqueueOperation(CacheOperation(
        id: operationId,
        type: CacheOperationType.get,
        key: cacheKey,
      ));

      completer.future.then((cachedResponse) {
        if (cachedResponse != null) {
          // 更新内存缓存
          _memoryCache[cacheKey] = CachedResponse(
            data: cachedResponse,
            timestamp: DateTime.now(),
          );

          if (kDebugMode) {
            print('📥 网络请求失败，返回磁盘缓存: $cacheKey');
          }

          return handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              data: cachedResponse,
              statusCode: 200,
              statusMessage: 'OK (Disk Cache)',
            ),
          );
        }

        // 没有缓存，继续错误处理
        handler.next(err);
      }).catchError((error) {
        // 获取缓存失败，继续错误处理
        handler.next(err);
      });

      if (err.response != null) {
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            data: err.response?.data,
            statusCode: err.response?.statusCode,
            statusMessage: err.message,
          ),
        );
      }

      return handler.next(err);
    }

    return handler.next(err);
  }

  // 生成缓存键（保持原有的实现不变）
  String _generateCacheKey(RequestOptions options) {
    final method = options.method;
    final path = options.path;
    // 排除不影响响应的参数
    final queryParams = Map<String, dynamic>.from(options.queryParameters)
      ..removeWhere((key, value) => key.toLowerCase() == 'timestamp');

    final data = options.data;
    // 添加版本号
    final version = 'v1';
    final keyParts = [version, method, Uri.encodeComponent(path)];

    // 处理查询参数
    if (queryParams.isNotEmpty) {
      final sortedParams = Map.fromEntries(
        queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      keyParts.add(json.encode(sortedParams));
    }

    // 处理请求体
    if (data != null) {
      String dataString;
      if (data is Map || data is List) {
        try {
          dataString = json.encode(data);
        } catch (e) {
          if (kDebugMode) {
            print('缓存键生成失败，无法序列化请求体: $e');
          }
          dataString = data.toString();
        }
      } else {
        dataString = data.toString();
      }

      // 对长数据计算哈希
      if (dataString.length > 100) {
        dataString = sha256.convert(utf8.encode(dataString)).toString();
      }
      keyParts.add(dataString);
    }

    // 使用Base64编码确保键的安全性
    final cacheKey = base64Url.encode(utf8.encode(keyParts.join('|')));
    if (kDebugMode) {
      print('生成缓存键: $cacheKey');
    }

    return cacheKey;
  }

  // 清除所有缓存
  Future<void> clearCache() async {
    // 先清除内存缓存
    _memoryCache.clear();

    // 再清除磁盘缓存
    final operationId = 'clear_${DateTime.now().millisecondsSinceEpoch}';
    _enqueueOperation(CacheOperation(
      id: operationId,
      type: CacheOperationType.clear,
    ));

    if (kDebugMode) {
      print('🧹 缓存清除请求已发送');
    }
  }
}
