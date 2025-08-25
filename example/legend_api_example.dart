import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:dio/dio.dart';
import '../lib/src/utils/params_creator.dart';

/// Legend方式API调用示例
class LegendApiExample {
  late final DioClient _dioClient;

  /// 初始化
  Future<void> initialize() async {
    _dioClient = DioClient();
    await _dioClient.init(
      baseUrl: 'https://api.example.com',
      enableCache: true,
      cacheType: CacheType.memory,
      enableLogging: true,
      enableAuth: true,
      maxRetries: 3,
      retryDelay: const Duration(seconds: 1),
    );
  }

  /// 示例1: 基础GET请求
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    return await _dioClient.request<Map<String, dynamic>>(
      '/api/users/$userId',
      HttpRequestMethod.get,
      headers: {
        'Authorization': 'Bearer your-token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// 示例2: POST请求带数据
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    return await _dioClient.request<Map<String, dynamic>>(
      '/api/users',
      HttpRequestMethod.post,
      data: userData,
      headers: {
        'Authorization': 'Bearer your-token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// 示例3: 带查询参数的请求
  Future<Map<String, dynamic>> searchUsers({
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }

    return await _dioClient.request<Map<String, dynamic>>(
      '/api/users/search',
      HttpRequestMethod.get,
      queryParameters: queryParams,
      headers: {
        'Authorization': 'Bearer your-token',
      },
    );
  }

  /// 示例4: 使用缓存策略
  Future<Map<String, dynamic>> getCachedData() async {
    return await _dioClient.request<Map<String, dynamic>>(
      '/api/cached-data',
      HttpRequestMethod.get,
      cachePolicy: CachePolicy.cacheFirst,
      headers: {
        'Authorization': 'Bearer your-token',
      },
    );
  }

  /// 示例5: 带响应转换器的请求
  Future<User> getUserWithTransformer(String userId) async {
    return await _dioClient.request<User>(
      '/api/users/$userId',
      HttpRequestMethod.get,
      headers: {
        'Authorization': 'Bearer your-token',
      },
      responseTransformer: (data) => User.fromJson(data),
    );
  }

  /// 示例6: 带参数签名的请求
  Future<Map<String, dynamic>> getSignedData(Map<String, dynamic> params) async {
    return await _dioClient.request<Map<String, dynamic>>(
      '/api/signed-data',
      HttpRequestMethod.post,
      data: params,
      creator: SignedParamsCreator(),
      headers: {
        'Authorization': 'Bearer your-token',
      },
    );
  }

  /// 示例7: 可取消的请求
  Future<Map<String, dynamic>> getCancellableData(String cancelTokenKey) async {
    return await _dioClient.request<Map<String, dynamic>>(
      '/api/long-running-operation',
      HttpRequestMethod.get,
      cancelTokenKey: cancelTokenKey,
      headers: {
        'Authorization': 'Bearer your-token',
      },
    );
  }

  /// 示例8: 复杂数据请求
  Future<Map<String, dynamic>> createComplexData({
    required String title,
    required List<String> tags,
    required Map<String, dynamic> metadata,
  }) async {
    final complexData = {
      'title': title,
      'tags': tags,
      'metadata': metadata,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'active',
    };

    return await _dioClient.request<Map<String, dynamic>>(
      '/api/complex-data',
      HttpRequestMethod.post,
      data: complexData,
      headers: {
        'Authorization': 'Bearer your-token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// 示例9: 批量操作
  Future<List<Map<String, dynamic>>> batchGetUsers(List<String> userIds) async {
    final results = <Map<String, dynamic>>[];

    for (final userId in userIds) {
      try {
        final user = await _dioClient.request<Map<String, dynamic>>(
          '/api/users/$userId',
          HttpRequestMethod.get,
          headers: {
            'Authorization': 'Bearer your-token',
          },
        );
        results.add(user);
      } catch (e) {
        print('获取用户 $userId 失败: $e');
        results.add({'id': userId, 'error': e.toString()});
      }
    }

    return results;
  }

  /// 示例10: 错误处理
  Future<void> handleErrors() async {
    try {
      await _dioClient.request<Map<String, dynamic>>(
        '/api/non-existent-endpoint',
        HttpRequestMethod.get,
      );
    } on AppException catch (e) {
      print('应用异常: ${e.message}, 代码: ${e.code}');
    } catch (e) {
      print('其他异常: $e');
    }
  }

  /// 清理资源
  void dispose() {
    _dioClient.cancelAllRequests();
  }
}

/// 用户数据模型
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

/// 带签名的参数创建器
class SignedParamsCreator extends ParamsCreator {
  @override
  bool get enableSign => true;

  @override
  bool get enableOptionsConversion => true;

  @override
  Map<String, dynamic> createParams(Map<String, dynamic> params) {
    // 模拟签名过程
    final signedParams = Map<String, dynamic>.from(params);
    signedParams['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    signedParams['sign'] = _generateSignature(signedParams);
    return signedParams;
  }

  @override
  Options convertOptions(Options options) {
    // 添加自定义头部
    final convertedOptions = options.copyWith();
    convertedOptions.headers?['X-Signed-Request'] = 'true';
    convertedOptions.headers?['X-Request-Time'] = DateTime.now().toIso8601String();
    return convertedOptions;
  }

  /// 生成签名
  String _generateSignature(Map<String, dynamic> params) {
    // 这里应该实现真实的签名算法
    // 示例中使用简单的哈希
    final sortedKeys = params.keys.toList()..sort();
    final signString = sortedKeys.map((key) => '$key=${params[key]}').join('&');
    return 'sign_${signString.hashCode}';
  }
}

/// 使用示例
void main() async {
  final example = LegendApiExample();

  try {
    // 初始化
    await example.initialize();

    // 示例1: 获取用户信息
    print('=== 示例1: 获取用户信息 ===');
    try {
      final userInfo = await example.getUserInfo('123');
      print('用户信息: $userInfo');
    } catch (e) {
      print('获取用户信息失败: $e');
    }

    // 示例2: 创建用户
    print('\n=== 示例2: 创建用户 ===');
    try {
      final newUser = await example.createUser({
        'name': '张三',
        'email': 'zhangsan@example.com',
        'age': 25,
      });
      print('创建用户结果: $newUser');
    } catch (e) {
      print('创建用户失败: $e');
    }

    // 示例3: 搜索用户
    print('\n=== 示例3: 搜索用户 ===');
    try {
      final searchResult = await example.searchUsers(
        keyword: '张',
        page: 1,
        pageSize: 10,
      );
      print('搜索结果: $searchResult');
    } catch (e) {
      print('搜索用户失败: $e');
    }

    // 示例4: 带响应转换器的请求
    print('\n=== 示例4: 带响应转换器的请求 ===');
    try {
      final user = await example.getUserWithTransformer('123');
      print('转换后的用户对象: $user');
    } catch (e) {
      print('获取用户对象失败: $e');
    }

    // 示例5: 复杂数据请求
    print('\n=== 示例5: 复杂数据请求 ===');
    try {
      final complexResult = await example.createComplexData(
        title: '测试标题',
        tags: ['标签1', '标签2', '标签3'],
        metadata: {
          'category': '测试',
          'priority': 'high',
          'tags': ['重要', '紧急'],
        },
      );
      print('复杂数据创建结果: $complexResult');
    } catch (e) {
      print('创建复杂数据失败: $e');
    }

    // 示例6: 错误处理
    print('\n=== 示例6: 错误处理 ===');
    await example.handleErrors();

  } catch (e) {
    print('初始化失败: $e');
  } finally {
    // 清理资源
    example.dispose();
  }
}
