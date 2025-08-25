import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

/// 授权拦截器
class AuthInterceptor extends Interceptor {
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
    if(authorization!=null){
      if(authorization.isNotEmpty){
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
      // 清除token
      HttpConfig.authTokenConfig?.clearToken?.call();
      // 触发登录（是否需要弹框，在App端自己决定）
      final path = err.requestOptions.path;
      HttpConfig.authTokenConfig?.triggerLogin?.call(path);
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
  String _formatAuthValue(String token, String authParamName,{bool needBearerPrefix = false}) {
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
  }

  /// 检查是否是token过期错误
  bool _isTokenExpiredError(Response? response) {
    if (response == null) return false;

    final expiredCodes = HttpConfig.authTokenConfig?.tokenExpiredCodes ?? [401];
    return expiredCodes.contains(response.statusCode);
  }
}
