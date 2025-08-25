import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class DomainConfig {
  static Map<String, dynamic>? _config;
  static bool _initialized = false;
  static bool _isProductMode = true; // 默认生产模式

  // 默认配置
  static final Map<String, dynamic> _defaultConfig = {
    "api": {
      "develop2": "http://192.168.1.183:8135",
      "develop": "https://api.musspark.com",
      "test": "http://bk1.onmovemusic.com:8135",
      "sandbox": "https://api-sandbox.musspark.com",
      "production": "https://api-t.musspark.com"
    }
  };

  // 初始化域名配置
  static Future<void> initialize([bool? isProductMode]) async {
    if (_initialized) return;

    // 设置生产模式标志
    if (isProductMode != null) {
      _isProductMode = isProductMode;
    } else {
      // 如果没有传入参数，根据当前环境自动判断
      _isProductMode = _getEnvironment() == 'production' || _getEnvironment() == 'sandbox';
    }

    try {
      // 尝试从assets加载配置文件
      final configString =
          await rootBundle.loadString('assets/config/domains.json');
      _config = json.decode(configString);
      _initialized = true;

      // 根据生产模式决定是否打印日志
      if (!_isProductMode) {
        print('✅ 域名配置加载成功');
      }
    } catch (e) {
      if (kDebugMode && !_isProductMode) {
        print('警告: 从assets加载域名配置失败: $e');
        print('⚠️ 使用默认域名配置');
      }
      // 使用默认配置
      _config = _defaultConfig;
      _initialized = true;
    }
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

  // 获取模块的默认域名
  static String _getDefaultBaseUrl(String module) {
    final env = _getEnvironment();
    print("测试请求配置：${_defaultConfig}");

    Map<String, dynamic>? moduleConfig = _defaultConfig[module] as Map<String, dynamic>?;

    if (moduleConfig == null) {
      if (kDebugMode) {
        print('错误: 默认配置中也没有模块"$module"的域名配置');
      }
      return '';
    }
    print("测试请求配置：${moduleConfig}");
    String? url = moduleConfig[env];
    return url ?? "";
  }
}
