import 'package:dio/dio.dart';

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

  final Map<String, String>? Function()? getAppCommonHeaders;
  // final Future<void> Function(String token)? saveToken;

  const HttpAuthTokenConfig({
    required this.keyForToken,
    required this.authParamName,
    required this.tokenExpiredCodes,
    this.getToken,
    this.clearToken,
    this.onTokenExpired,
    this.getAppCommonHeaders
  });
}

class HttpConfig {
  static const int defaultConnectTimeout = 15; // 15秒
  static const int defaultReceiveTimeout = 15; // 15秒
  static const int defaultSendTimeout = 15; // 15秒

  static const String contentTypeJson = Headers.jsonContentType;
  static const String contentTypeForm = Headers.formUrlEncodedContentType;

  // 缓存配置
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const int defaultLRUCapacity = 100;

  // 重试配置
  static const int defaultMaxRetries = 3;
  static const Duration defaultRetryDelay = Duration(seconds: 1);

  // 设置判断http成功的成功码
  static List<int> _internalSuccessCodeList = [0, 200];

  static List<int> get successCodes => _internalSuccessCodeList;

  // authToken配置信息
  static HttpAuthTokenConfig? get authTokenConfig => _authTokenConfig;
  static HttpAuthTokenConfig? _authTokenConfig;

  // 配置判断http成功的code
  static void setupConfig(
      {List<int>? successCodes, HttpAuthTokenConfig? authTokenConfig}) {
    // 成功的码映射表
    if (successCodes != null && successCodes.isNotEmpty) {
        _internalSuccessCodeList = successCodes;
    }

    // 设置token的一些信息
    _authTokenConfig = authTokenConfig;
  }

  /// 获取app公共头信息
  static Map<String, String>? getAppCommonHeaders() {
    if(_authTokenConfig == null) {
      return {};
    }

    return _authTokenConfig?.getAppCommonHeaders?.call() ?? {};
  }
}
