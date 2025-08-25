# Legend API 兼容性使用指南

## 概述

`DioClient` 提供了兼容 Legend 方式的 API 调用方法，支持传统的 HTTP 请求方式，同时集成了现代化的功能特性。

## 主要特性

- ✅ 支持所有 HTTP 方法 (GET, POST, PUT, DELETE, PATCH, HEAD)
- ✅ 内置缓存策略支持
- ✅ 参数签名和转换
- ✅ 响应数据转换
- ✅ 请求取消功能
- ✅ 错误处理
- ✅ 重试机制
- ✅ 日志记录

## 基础用法

### 1. 初始化

```dart
final dioClient = DioClient();
await dioClient.init(
  baseUrl: 'https://api.example.com',
  enableCache: true,
  cacheType: CacheType.memory,
  enableLogging: true,
  enableAuth: true,
  maxRetries: 3,
  retryDelay: const Duration(seconds: 1),
);
```

### 2. 基础请求

```dart
// GET 请求
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/users/123',
  HttpRequestMethod.get,
);

// POST 请求
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/users',
  HttpRequestMethod.post,
  data: {'name': '张三', 'email': 'zhangsan@example.com'},
);
```

## 高级功能

### 1. 缓存策略

```dart
// 网络优先
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/data',
  HttpRequestMethod.get,
  cachePolicy: CachePolicy.networkFirst,
);

// 缓存优先
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/data',
  HttpRequestMethod.get,
  cachePolicy: CachePolicy.cacheFirst,
);

// 仅缓存
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/data',
  HttpRequestMethod.get,
  cachePolicy: CachePolicy.cacheOnly,
);
```

### 2. 参数签名

```dart
class MyParamsCreator extends ParamsCreator {
  @override
  bool get enableSign => true;

  @override
  Map<String, dynamic> createParams(Map<String, dynamic> params) {
    final signedParams = Map<String, dynamic>.from(params);
    signedParams['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    signedParams['sign'] = _generateSignature(signedParams);
    return signedParams;
  }

  String _generateSignature(Map<String, dynamic> params) {
    // 实现签名算法
    return 'signature';
  }
}

final response = await dioClient.request<Map<String, dynamic>>(
  '/api/signed-endpoint',
  HttpRequestMethod.post,
  data: {'key': 'value'},
  creator: MyParamsCreator(),
);
```

### 3. 响应转换

```dart
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

final user = await dioClient.request<User>(
  '/api/users/123',
  HttpRequestMethod.get,
  responseTransformer: (data) => User.fromJson(data),
);
```

### 4. 请求取消

```dart
final cancelTokenKey = 'user_request_123';

// 启动请求
final future = dioClient.request<Map<String, dynamic>>(
  '/api/users/123',
  HttpRequestMethod.get,
  cancelTokenKey: cancelTokenKey,
);

// 取消请求
dioClient.cancelRequest(cancelTokenKey);

// 或者取消所有请求
dioClient.cancelAllRequests();
```

### 5. 自定义 Headers

```dart
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/protected-endpoint',
  HttpRequestMethod.get,
  headers: {
    'Authorization': 'Bearer your-token',
    'X-Custom-Header': 'custom-value',
    'Content-Type': 'application/json',
  },
);
```

### 6. 查询参数

```dart
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/users/search',
  HttpRequestMethod.get,
  queryParameters: {
    'keyword': '张',
    'page': 1,
    'pageSize': 20,
    'sortBy': 'name',
    'order': 'asc',
  },
);
```

## 错误处理

```dart
try {
  final response = await dioClient.request<Map<String, dynamic>>(
    '/api/endpoint',
    HttpRequestMethod.get,
  );
} on AppException catch (e) {
  print('应用异常: ${e.message}, 代码: ${e.code}');
  // 处理应用异常
} catch (e) {
  print('其他异常: $e');
  // 处理其他异常
}
```

## 缓存管理

```dart
// 清除所有缓存
await dioClient.clearCache();

// 缓存策略说明
// - networkOnly: 仅从网络获取，不使用缓存
// - networkFirst: 先请求网络，成功后更新缓存
// - cacheFirst: 优先使用缓存，缓存不存在则请求网络
// - cacheOnly: 仅使用缓存，不请求网络
// - cacheAndNetwork: 先使用缓存，同时在后台更新缓存
```

## 最佳实践

### 1. 类型安全

```dart
// ✅ 推荐：明确指定返回类型
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/data',
  HttpRequestMethod.get,
);

// ✅ 推荐：使用响应转换器
final user = await dioClient.request<User>(
  '/api/users/123',
  HttpRequestMethod.get,
  responseTransformer: (data) => User.fromJson(data),
);
```

### 2. 错误处理

```dart
// ✅ 推荐：使用 try-catch 处理异常
try {
  final response = await dioClient.request<Map<String, dynamic>>(
    '/api/endpoint',
    HttpRequestMethod.get,
  );
  // 处理成功响应
} on AppException catch (e) {
  // 处理应用异常
  _handleAppException(e);
} catch (e) {
  // 处理其他异常
  _handleGenericException(e);
}
```

### 3. 请求取消

```dart
// ✅ 推荐：为长时间运行的请求提供取消功能
class UserService {
  Future<User> getUser(String userId) async {
    return await dioClient.request<User>(
      '/api/users/$userId',
      HttpRequestMethod.get,
      cancelTokenKey: 'user_$userId',
      responseTransformer: (data) => User.fromJson(data),
    );
  }

  void cancelGetUser(String userId) {
    dioClient.cancelRequest('user_$userId');
  }
}
```

### 4. 缓存策略选择

```dart
// 频繁变化的数据：使用 networkOnly
final liveData = await dioClient.request<Map<String, dynamic>>(
  '/api/live-data',
  HttpRequestMethod.get,
  cachePolicy: CachePolicy.networkOnly,
);

// 相对稳定的数据：使用 cacheFirst
final staticData = await dioClient.request<Map<String, dynamic>>(
  '/api/static-data',
  HttpRequestMethod.get,
  cachePolicy: CachePolicy.cacheFirst,
);

// 离线优先的数据：使用 cacheOnly
final offlineData = await dioClient.request<Map<String, dynamic>>(
  '/api/offline-data',
  HttpRequestMethod.get,
  cachePolicy: CachePolicy.cacheOnly,
);
```

## 测试

运行测试：

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/dio_client_legend_simple_test.dart

# 运行示例
dart run example/legend_api_example.dart
```

## 注意事项

1. **初始化**：使用前必须先调用 `init()` 方法
2. **类型安全**：建议明确指定泛型类型
3. **错误处理**：始终使用 try-catch 处理异常
4. **资源清理**：在适当的时候调用 `cancelAllRequests()` 和 `clearCache()`
5. **缓存策略**：根据数据特性选择合适的缓存策略
6. **请求取消**：为长时间运行的请求提供取消机制

## 迁移指南

从传统 Dio 迁移到 Legend API：

```dart
// 传统方式
final response = await dio.get('/api/users/123');

// Legend 方式
final response = await dioClient.request<Map<String, dynamic>>(
  '/api/users/123',
  HttpRequestMethod.get,
);
```

## 常见问题

### Q: 如何处理网络超时？
A: 在 `init()` 方法中设置超时时间，或使用重试机制。

### Q: 如何实现自定义认证？
A: 在请求 headers 中添加认证信息，或使用拦截器。

### Q: 如何调试网络请求？
A: 启用日志记录 `enableLogging: true`。

### Q: 如何优化缓存性能？
A: 选择合适的缓存类型和策略，定期清理过期缓存。 