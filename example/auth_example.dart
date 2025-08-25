import 'package:network_kit_lite/network_kit_lite.dart';

/// 认证配置和使用示例
class AuthExample {
  static void setupAuthConfig() {
    // 配置认证token
    final authConfig = HttpAuthTokenConfig(
      keyForToken: 'auth_token',
      authParamName: 'Authorization',
      tokenExpiredCodes: [401, 403], // token过期的状态码
      getToken: () {
        // 从本地存储获取token
        return _getStoredToken() ?? '';
      },
      clearToken: () {
        // 清除本地存储的token
        _clearStoredToken();
      },
      onTokenExpired: () {
        // token过期时的处理逻辑
        _handleTokenExpired();
      },
      updateToken: (String newToken) {
        // 更新本地存储的token
        _updateStoredToken(newToken);
      },
      triggerLogin: (String? path) {
        // 触发重新登录
        _triggerReLogin();
      },
      getAppCommonHeaders: () {
        // 获取应用公共请求头
        return {
          'User-Agent': 'NetworkKitLite/1.0',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };
      },
    );

    // 设置配置
    HttpConfig.setupConfig(
      successCodes: [0, 200, 201],
      authTokenConfig: authConfig,
    );
  }

  static Future<void> initializeNetworkClient() async {
    // 初始化网络客户端
    await dioClient.init(
      baseUrl: 'https://api.example.com',
      enableCache: true,
      enableLogging: true,
      enableAuth: true,
    );
  }

  static Future<void> loginExample() async {
    try {
      // 登录请求 - 创建自定义API端点
      final loginEndpoint = _LoginEndpoint();
      final response = await dioClient.execute(loginEndpoint);

      if (response.isSuccess) {
        // 保存token
        final token = response.data['token'];
        _updateStoredToken(token);
        print('✅ 登录成功，token已保存');
      }
    } catch (e) {
      print('❌ 登录失败: $e');
    }
  }

  static Future<void> authenticatedRequestExample() async {
    try {
      // 需要认证的请求 - 创建自定义API端点
      final profileEndpoint = _UserProfileEndpoint();
      final response = await dioClient.execute(profileEndpoint);

      if (response.isSuccess) {
        print('✅ 获取用户信息成功: ${response.data}');
      }
    } catch (e) {
      print('❌ 获取用户信息失败: $e');
    }
  }

  static Future<void> concurrentRequestsExample() async {
    // 并发请求示例，测试token刷新机制
    final futures = [
      dioClient.execute(_UserProfileEndpoint()),
      dioClient.execute(_UserSettingsEndpoint()),
      dioClient.execute(_UserNotificationsEndpoint()),
    ];

    try {
      final results = await Future.wait(futures);
      print('✅ 所有并发请求完成');
    } catch (e) {
      print('❌ 并发请求失败: $e');
    }
  }

  // 私有方法 - 模拟本地存储操作
  static String? _getStoredToken() {
    // 实际应用中应该从 SharedPreferences 或其他存储中获取
    return 'stored_token_here';
  }

  static void _clearStoredToken() {
    // 实际应用中应该清除 SharedPreferences 中的token
    print('🗑️ Token已清除');
  }

  static void _updateStoredToken(String newToken) {
    // 实际应用中应该更新 SharedPreferences 中的token
    print('💾 Token已更新: $newToken');
  }

  static void _handleTokenExpired() {
    print('🔄 Token过期，开始刷新...');
    // 实际应用中应该调用刷新token的API
    // 这里模拟刷新过程
    Future.delayed(const Duration(seconds: 1), () {
      _updateStoredToken('new_refreshed_token');
      print('✅ Token刷新完成');
    });
  }

  static void _triggerReLogin() {
    print('🔐 触发重新登录');
    // 实际应用中应该跳转到登录页面
    // 或者显示登录对话框
  }
}

// 自定义API端点类
class _LoginEndpoint extends APIEndpoint {
  @override
  String get path => '/login';

  @override
  HTTPMethod get httpMethod => HTTPMethod.post;

  @override
  String get module => '';

  @override
  dynamic get requestBody => {
        'username': 'test@example.com',
        'password': 'password123',
      };

  @override
  dynamic parseResponse(dynamic response) => response;

  @override
  Map<String, dynamic>? get queryParameters => {};
}

class _UserProfileEndpoint extends APIEndpoint {
  @override
  String get path => '/user/profile';

  @override
  HTTPMethod get httpMethod => HTTPMethod.get;

  @override
  String get module => '';

  @override
  dynamic parseResponse(dynamic response) => response;

  @override
  Map<String, dynamic>? get queryParameters => {};

  @override
  get requestBody => {};
}

class _UserSettingsEndpoint extends APIEndpoint {
  @override
  String get path => '/user/settings';

  @override
  HTTPMethod get httpMethod => HTTPMethod.get;

  @override
  String get module => '';

  @override
  dynamic parseResponse(dynamic response) => response;

  @override
  Map<String, dynamic>? get queryParameters => {};

  @override
  get requestBody => {};
}

class _UserNotificationsEndpoint extends APIEndpoint {
  @override
  String get path => '/user/notifications';

  @override
  HTTPMethod get httpMethod => HTTPMethod.get;

  @override
  String get module => '';

  @override
  dynamic parseResponse(dynamic response) => response;

  @override
  Map<String, dynamic>? get queryParameters => {};

  @override
  get requestBody => {};
}

/// 使用示例
void main() async {
  // 1. 设置认证配置
  AuthExample.setupAuthConfig();

  // 2. 初始化网络客户端
  await AuthExample.initializeNetworkClient();

  // 3. 登录
  await AuthExample.loginExample();

  // 4. 发起需要认证的请求
  await AuthExample.authenticatedRequestExample();

  // 5. 测试并发请求（会触发token刷新机制）
  await AuthExample.concurrentRequestsExample();
}
