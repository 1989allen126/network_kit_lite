import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

/// 授权拦截器
class AuthInterceptor extends Interceptor {
  /// 是否正在处理登录回调，防止重复触发
  static bool _isHandlingLogin = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 跳过不需要认证的请求
    if (_shouldSkipAuth(options)) {
      return super.onRequest(options, handler);
    }

    // 获取token
    final token = _getValidToken();
    if (token != null && token.isNotEmpty) {
      _addAuthHeader(options, token);
    }

    // 添加公共请求头
    _addCommonHeaders(options);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ///更新token
    String? authorization = response.headers.value("authorization");
    if (authorization != null) {
      if (authorization.isNotEmpty) {
        HttpConfig.authTokenConfig?.updateToken?.call(authorization);
      }
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    // 检查是否是token过期错误
    if (_isTokenExpiredError(response)) {
      // 检查是否跳过 Auth 鉴权校验导致的退出登录
      final skipAuthLogout = _shouldSkipAuthLogout(err.requestOptions);
      if (skipAuthLogout) {
        // 如果设置了跳过退出登录，直接拒绝请求，不触发登录回调
        if (kDebugMode) {
          print('⚠️ 跳过 Auth 鉴权校验导致的退出登录: ${err.requestOptions.path}');
        }
        handler.reject(err);
        return;
      }

      // 防止重复触发登录回调
      if (_isHandlingLogin) {
        // 如果正在处理登录，直接拒绝请求，避免重复触发
        handler.reject(err);
        return;
      }

      try {
        // 设置标志，防止重复触发
        _isHandlingLogin = true;

        // 取出错误信息
        final errorMessage = err.response?.data?['msg'] ?? err.response?.data?['message'];
        final appException = AppException.httpError(401, message: errorMessage ?? '');
        // 清除token
        HttpConfig.authTokenConfig?.clearToken?.call();
        // 触发登录（是否需要弹框，在App端自己决定）
        final path = err.requestOptions.path;
        final data = {
          'path': path,
          'method': err.requestOptions.method,
          'headers': err.requestOptions.headers,
          'data': err.requestOptions.data,
        };
        HttpConfig.authTokenConfig?.triggerLogin?.call(appException, data);
      } finally {
        // 延迟重置标志，确保回调执行完成
        Future.delayed(const Duration(milliseconds: 100), () {
          _isHandlingLogin = false;
        });
      }

      // 拒绝请求
      handler.reject(err);
      return;
    }

    super.onError(err, handler);
  }

  /// 检查是否应该跳过认证
  bool _shouldSkipAuth(RequestOptions options) {
    // 可以配置不需要认证的路径
    final skipPaths = ['/login', '/register', '/public'];
    return skipPaths.any((path) => options.path.contains(path));
  }

  /// 获取有效的token
  String? _getValidToken() {
    try {
      return HttpConfig.authTokenConfig?.getToken?.call();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 获取token失败: $e');
      }
      return null;
    }
  }

  /// 添加认证头
  void _addAuthHeader(RequestOptions options, String token) {
    final authParamName = HttpConfig.authTokenConfig?.authParamName ?? 'Authorization';
    final authValue = _formatAuthValue(token, authParamName);
    options.headers[authParamName] = authValue;
  }

  /// 格式化认证值
  String _formatAuthValue(String token, String authParamName, {bool needBearerPrefix = false}) {
    if (authParamName.toLowerCase() == 'authorization' && needBearerPrefix) {
      return token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
    return token;
  }

  /// 添加公共请求头
  void _addCommonHeaders(RequestOptions options) {
    final commonHeaders = HttpConfig.getAppCommonHeaders();
    if (commonHeaders != null) {
      options.headers.addAll(commonHeaders);
    }
    // 根据URL判断是否需要X-API-Key
    _addXApiKeyIfNeeded(options);
  }

  /// 根据URL判断是否需要添加X-API-Key
  void _addXApiKeyIfNeeded(RequestOptions options) {
    // 检查是否需要X-API-Key
    final needXApiKey = _shouldAddXApiKey(options);
    if (needXApiKey) {
      // 从HttpConfig获取X-API-Key值
      final xApiKey = _getXApiKey();
      if (xApiKey != null && xApiKey.isNotEmpty) {
        options.headers['X-API-Key'] = xApiKey;
      }
    } else {
      // 如果不需要，移除X-API-Key（如果存在）
      options.headers.remove('X-API-Key');
    }
  }

  /// 判断是否需要添加X-API-Key
  bool _shouldAddXApiKey(RequestOptions options) {
    final config = HttpConfig.authTokenConfig;
    if (config == null) {
      return false;
    }
    // 使用配置中的needXApiKey方法
    if (config.needXApiKey != null) {
      final fullUrl = options.uri.toString();
      return config.needXApiKey!(fullUrl);
    }
    return false;
  }

  /// 获取X-API-Key值
  String? _getXApiKey() {
    final config = HttpConfig.authTokenConfig;
    if (config == null) {
      return null;
    }
    // 使用配置中的getXApiKey方法
    if (config.getXApiKey != null) {
      return config.getXApiKey!();
    }
    return null;
  }

  /// 检查是否是token过期错误
  bool _isTokenExpiredError(Response? response) {
    if (response == null) return false;

    final expiredCodes = HttpConfig.authTokenConfig?.tokenExpiredCodes ?? [401];
    return expiredCodes.contains(response.statusCode);
  }

  /// 检查是否应该跳过 Auth 鉴权校验导致的退出登录
  /// 从请求的 extra 中获取 skipAuthLogout 标志（由 APIEndpoint 设置）
  bool _shouldSkipAuthLogout(RequestOptions options) {
    final extra = options.extra as Map<String, dynamic>?;
    if (extra == null) {
      return false;
    }
    final skipAuthLogout = extra['skipAuthLogout'];
    return skipAuthLogout == true;
  }
}
