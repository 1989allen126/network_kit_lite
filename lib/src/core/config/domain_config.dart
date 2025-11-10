import 'package:flutter/foundation.dart';

import '../../i18n/error_msg_localization_strategy.dart';

class DomainConfig {
  static Map<String, dynamic>? _config;
  static bool _initialized = false;
  static bool _isProductMode = true; // 默认生产模式

  /// 错误消息国际化策略
  static ErrorMsgLocalizationStrategy _errorMsgLocalizationStrategy = ErrorMsgLocalizationStrategy.localize;

  /// 设置错误消息国际化策略
  static set errorMsgLocalizationStrategy(ErrorMsgLocalizationStrategy value) {
    _errorMsgLocalizationStrategy = value;
  }

  /// 获取错误消息国际化策略
  static ErrorMsgLocalizationStrategy get errorMsgLocalizationStrategy => _errorMsgLocalizationStrategy;

  // 初始化域名配置
  /// [config] 域名配置，格式: {"module": {"environment": "url"}}
  /// [isProductMode] 是否为生产模式，如果为 null 则根据环境自动判断
  static Future<void> initialize({
    Map<String, dynamic>? config,
    bool? isProductMode,
  }) async {
    if (_initialized) return;

    // 设置生产模式标志
    if (isProductMode != null) {
      _isProductMode = isProductMode;
    } else {
      // 如果没有传入参数，根据当前环境自动判断
      _isProductMode = _getEnvironment() == 'production' || _getEnvironment() == 'sandbox';
    }

    // 使用传入的配置，如果没有传入则使用空配置
    _config = config ?? <String, dynamic>{};
    _initialized = true;
  }

  /// 获取当前是否为生产模式
  static bool get isProductMode => _isProductMode;

  /// 获取当前是否为开发模式
  static bool get isDevelopmentMode => !_isProductMode;

  /// 获取当前是否为国内环境
  static bool get isMainlandEnvironment => !_getGlobalEnvironment();

  // 获取指定模块的基础URL
  static String getBaseUrl(String module) {
    // 确保配置已初始化
    if (!_initialized) {
      try {
        initialize();
        // 由于initialize是异步的，这里可能无法立即获取配置
        // 实际项目中应该使用await，但此处为了保持同步API
        // 我们会在第一次调用后立即返回默认值
      } catch (e) {
        if (kDebugMode) {
          print('错误: 域名配置未初始化: $e');
        }
        return _getDefaultBaseUrl(module);
      }
    }

    if (_config == null) {
      if (kDebugMode) {
        print('错误: Domains配置未正确加载，使用默认配置');
      }
      return _getDefaultBaseUrl(module);
    }

    final env = _getEnvironment();
    final moduleConfig = _config![module] as Map<String, dynamic>?;

    if (moduleConfig == null) {
      if (kDebugMode) {
        print('警告: 未找到模块"$module"的域名配置，使用默认配置');
      }
      return _getDefaultBaseUrl(module);
    }

    return moduleConfig[env] as String? ?? _getDefaultBaseUrl(module);
  }

  // 获取当前环境
  static String _getEnvironment() {
    // 使用新的环境配置系统
    const env = String.fromEnvironment('DART_DEFINE_APP_ENV', defaultValue: 'production');
    return env;
  }

  // 获取当前是否为海外环境
  static bool _getGlobalEnvironment() {
    const env = String.fromEnvironment('DART_DEFINE_GLOBAL_ENV', defaultValue: 'YES');
    return ["YES", "yes", "Y", "y", "1", true, "true"].contains(env);
  }

  // 获取模块的默认域名（当配置未找到时返回空字符串）
  static String _getDefaultBaseUrl(String module) {
    if (kDebugMode) {
      print('警告: 模块"$module"的域名配置未找到，返回空字符串');
    }
    return '';
  }
}
