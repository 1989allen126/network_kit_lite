import 'package:flutter/widgets.dart';

/// 错误码国际化工具类
/// 现在使用 ARB 文件中的词条，通过回调函数来获取本地化消息
class ErrorCodeIntl {
  static String _currentLocale = 'zh';
  static bool _isInitialized = false;
  static String? _defaultMessage;

  // 本地化消息获取回调函数
  static String Function(String errorCode, {String? serverMessage})? _localizationCallback;
  static String Function(int statusCode)? _httpErrorCallback;

  // 初始化国际化配置
  static Future<void> initialize({
    String defaultLocale = 'zh',
    String? defaultMessage,
    String? assetsPath, // 保留参数以保持向后兼容，但不再使用
    String Function(String errorCode, {String? serverMessage})? localizationCallback,
    String Function(int statusCode)? httpErrorCallback,
  }) async {
    if (_isInitialized) return;

    _currentLocale = defaultLocale;
    _defaultMessage = defaultMessage;
    _localizationCallback = localizationCallback;
    _httpErrorCallback = httpErrorCallback;

    _isInitialized = true;
    print('✅ 错误码国际化初始化成功（使用 ARB 文件）');
  }

  // 设置当前语言环境
  static void setLocale(String locale) {
    if (locale == _currentLocale) return;

    _currentLocale = locale;
    print('🌍 错误消息语言环境已设置为: $locale');
  }

  // 根据当前Flutter应用的语言环境自动设置
  static void setLocaleFromApp(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    setLocale(locale);
  }

  // 获取错误消息
  static String getMessage(String errorCode, {String? serverMessage}) {
    if (!_isInitialized) {
      print('⚠️ 错误码国际化未初始化，使用默认消息');
      return serverMessage ?? _defaultMessage ?? '未知错误';
    }

    // 优先使用服务器返回的消息
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    // 使用本地化回调函数获取消息（来自 ARB 文件）
    if (_localizationCallback != null) {
      try {
        final localizedMessage = _localizationCallback!(errorCode, serverMessage: serverMessage);
        if (localizedMessage.isNotEmpty) {
          return localizedMessage;
        }
      } catch (e) {
        print('⚠️ 本地化回调函数执行失败: $e');
        rethrow;
      }
    }

    // 最终兜底方案：使用默认消息
    return _defaultMessage ?? '未知错误';
  }

  // 获取 HTTP 错误消息
  static String getHttpErrorMessage(int statusCode) {
    if (!_isInitialized) {
      return _getFallbackHttpErrorMessage(statusCode);
    }

    // 使用 HTTP 错误回调函数（来自 ARB 文件）
    if (_httpErrorCallback != null) {
      try {
        final localizedMessage = _httpErrorCallback!(statusCode);
        if (localizedMessage.isNotEmpty) {
          return localizedMessage;
        }
      } catch (e) {
        print('⚠️ HTTP 错误回调函数执行失败: $e');
      }
    }

    // 兜底方案：使用默认 HTTP 错误消息
    return _getFallbackHttpErrorMessage(statusCode);
  }

  // 兜底的 HTTP 错误消息（当回调函数不可用时使用）
  // 注意：这个方法现在返回硬编码的中文消息，建议通过回调函数提供 ARB 文件中的消息
  static String _getFallbackHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '错误请求，参数可能不正确';
      case 401:
        return '未授权，请登录';
      case 403:
        return '禁止访问，没有权限';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不被允许';
      case 408:
        return '请求超时，请稍后重试';
      case 409:
        return '请求冲突，资源已存在';
      case 422:
        return '请求格式正确，但语义错误';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '错误网关';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return '客户端请求错误 ($statusCode)';
        } else if (statusCode >= 500 && statusCode < 600) {
          return '服务器错误 ($statusCode)';
        }
        return '未知错误，状态码: $statusCode';
    }
  }

  /// 获取当前语言环境
  static String get currentLocale => _currentLocale;

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;
}
