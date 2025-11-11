import 'package:dio/dio.dart';

import '../exceptions/app_exception.dart';

class HttpAuthTokenConfig {
  // 定义本地缓存的token名称
  final String keyForToken;
  // Authorization 在头文件中的名称
  final String authParamName;
  final List<int> tokenExpiredCodes;
  // 操作本地token的方法
  final String Function()? getToken;
  final void Function()? clearToken;
  final void Function()? onTokenExpired;
  final void Function(String token)? updateToken;
  final void Function(AppException exception, dynamic data)? triggerLogin;

  final Map<String, String>? Function()? getAppCommonHeaders;

  /// 判断是否需要X-API-Key
  final bool Function(String url)? needXApiKey;

  /// 获取X-API-Key值
  final String Function()? getXApiKey;

  const HttpAuthTokenConfig({
    required this.keyForToken,
    required this.authParamName,
    required this.tokenExpiredCodes,
    this.getToken,
    this.clearToken,
    this.onTokenExpired,
    this.getAppCommonHeaders,
    this.updateToken,
    this.triggerLogin,
    this.needXApiKey,
    this.getXApiKey,
  });
}

/// 网络配置（修改部分属性，extent HttpConfig重写方法，可以修改默认配置）
class HttpConfig {
  static const int defaultConnectTimeout = 15; // 15秒
  static const int defaultReceiveTimeout = 15; // 15秒
  static const int defaultSendTimeout = 15; // 15秒

  static const String contentTypeJson = Headers.jsonContentType;
  static const String contentTypeForm = Headers.formUrlEncodedContentType;

  /// 最大并发请求数
  static const int defaultMaxConcurrentRequests = 6;

  /// 请求间隔时间
  static const Duration defaultRequestInterval = Duration(milliseconds: 200);

  /// 是否启用请求队列
  static const bool defaultEnableRequestQueue = true;

  /// 错误码最大长度
  static const int defaultErrorMessageMaxLength = 60;

  // 缓存配置
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const int defaultLRUCapacity = 100;

  // 重试配置
  static const int defaultMaxRetries = 3;
  static const Duration defaultRetryDelay = Duration(seconds: 1);

  // 是否打印日志
  static bool _enableLogging = true;

  // 设置是否打印日志
  static void setEnableLogging(bool enable) {
    _enableLogging = enable;
  }

  // 获取是否打印日志
  static bool get enableLogging => _enableLogging;

  // 设置判断http成功的成功码
  static List<int> _internalSuccessCodeList = [0, 200];

  static List<int> get successCodes => _internalSuccessCodeList;

  // authToken配置信息
  static HttpAuthTokenConfig? get authTokenConfig => _authTokenConfig;
  static HttpAuthTokenConfig? _authTokenConfig;

  // 配置判断http成功的code
  static void setupConfig({List<int>? successCodes, HttpAuthTokenConfig? authTokenConfig}) {
    // 成功的码映射表
    if (successCodes != null && successCodes.isNotEmpty) {
      _internalSuccessCodeList = successCodes;
    }

    // 设置token的一些信息
    _authTokenConfig = authTokenConfig;
  }

  /// 获取app公共头信息
  static Map<String, String>? getAppCommonHeaders() {
    if (_authTokenConfig == null) {
      return {};
    }

    return _authTokenConfig?.getAppCommonHeaders?.call() ?? {};
  }
}
