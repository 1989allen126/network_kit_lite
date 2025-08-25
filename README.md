# Network Kit Lite

一个轻量级、高性能的 Flutter 网络请求库，基于 Dio 构建，提供智能重试、网络检测、缓存、监控等功能。

## ✨ 特性

- 🚀 **高性能**: 基于 Dio 构建，支持并发请求和连接池管理
- 🔄 **智能重试**: 基于错误类型和状态码的智能重试策略
- 🌐 **网络检测**: 使用 `connectivity_plus` 进行实时网络状态监听
- 💾 **多级缓存**: 支持内存、文件、SQLite、LRU 等多种缓存策略
- 📊 **性能监控**: 详细的请求性能统计和监控
- 🛡️ **错误处理**: 完善的错误分类和处理机制
- 🌍 **国际化**: 支持多语言错误消息
- 🧪 **测试友好**: 完善的单元测试和集成测试

## 📦 安装

```yaml
dependencies:
  network_kit_lite: ^1.0.0
  connectivity_plus: ^5.0.2
```

## 🚀 快速开始

### 基本使用

```dart
import 'package:network_kit_lite/network_kit_lite.dart';

void main() async {
  // 初始化 DioClient
  await dioClient.init(
    baseUrl: 'https://api.example.com',
    maxRetries: 3,
    enableCache: true,
    enableLogging: true,
  );

  // 执行请求
  final response = await dioClient.execute(
    APIEndpoint.get('/users'),
  );

  print('Response: ${response.data}');
}
```

### 网络状态监听

```dart
// 监听网络状态变化
dioClient.onConnectivityChanged.listen((status) {
  switch (status) {
    case NetworkConnectivityStatus.none:
      print('网络断开');
      break;
    case NetworkConnectivityStatus.wifi:
      print('WiFi 连接');
      break;
    case NetworkConnectivityStatus.mobile:
      print('移动网络连接');
      break;
    default:
      print('其他网络类型');
  }
});

// 检查当前网络状态
final isAvailable = await dioClient.isNetworkAvailable();
final networkType = await dioClient.getNetworkTypeDescription();
```

## 🔧 配置选项

### 初始化配置

```dart
await dioClient.init(
  baseUrl: 'https://api.example.com',
  connectTimeoutSeconds: 30,
  receiveTimeoutSeconds: 30,
  maxRetries: 3,
  retryDelay: Duration(seconds: 1),
  enableCache: true,
  cacheType: CacheType.memory,
  enableLogging: true,
  enableMonitoring: true,
);
```

### 智能重试配置

```dart
// 自定义重试策略
final config = SmartRetryConfig(
  maxRetries: 5,
  baseDelay: Duration(seconds: 1),
  backoffMultiplier: 2.0,
  jitterFactor: 0.3,
  enableNetworkCheck: true,
  statusCodeRetryCount: {
    408: 2,  // Request Timeout
    429: 3,  // Too Many Requests
    500: 3,  // Internal Server Error
  },
  exceptionTypeRetryCount: {
    DioExceptionType.connectionTimeout: 2,
    DioExceptionType.sendTimeout: 1,
  },
);
```

## 🌐 网络检测

### 基于监听的状态管理

Network Kit Lite 使用 `connectivity_plus` 的 `onConnectivityChanged` 流来监听网络状态变化，而不是依赖 `checkConnectivity()` 的即时检查。这提供了更可靠和实时的网络状态管理。

```dart
// 推荐：使用网络状态监听
dioClient.onConnectivityChanged.listen((status) {
  // 处理网络状态变化
});

// 不推荐：频繁调用 checkConnectivity()
// final status = await Connectivity().checkConnectivity();
```

### 网络状态类型

- `NetworkConnectivityStatus.none`: 无网络连接
- `NetworkConnectivityStatus.wifi`: WiFi 网络
- `NetworkConnectivityStatus.mobile`: 移动网络
- `NetworkConnectivityStatus.ethernet`: 以太网
- `NetworkConnectivityStatus.bluetooth`: 蓝牙网络
- `NetworkConnectivityStatus.vpn`: VPN 网络
- `NetworkConnectivityStatus.other`: 其他网络
- `NetworkConnectivityStatus.unknown`: 未知网络

## 💾 缓存策略

### 支持的缓存类型

```dart
// 内存缓存（默认）
CacheType.memory

// 文件缓存
CacheType.file

// SQLite 缓存
CacheType.sqlite

// LRU 缓存
CacheType.lru
```

### 缓存使用示例

```dart
// 启用缓存
await dioClient.init(
  enableCache: true,
  cacheType: CacheType.memory,
  cacheDuration: Duration(hours: 1),
);

// 缓存会自动处理 GET 请求
final response = await dioClient.execute(
  APIEndpoint.get('/users'),
);
```

## 📊 性能监控

### 获取性能统计

```dart
// 获取网络统计信息
final stats = dioClient.getNetworkStats();
print('总请求数: ${stats.totalRequests}');
print('成功请求数: ${stats.successfulRequests}');
print('失败请求数: ${stats.failedRequests}');
print('平均响应时间: ${stats.averageResponseTime}ms');

// 获取请求历史
final history = dioClient.getRequestHistory(limit: 10);

// 获取性能报告
final report = dioClient.getPerformanceReport();
```

## 🛡️ 错误处理

### 错误分类

```dart
try {
  final response = await dioClient.execute(endpoint);
} on AppException catch (e) {
  switch (e.code) {
    case -1:
      print('网络错误: ${e.message}');
      break;
    case 401:
      print('认证失败: ${e.message}');
      break;
    case 404:
      print('资源不存在: ${e.message}');
      break;
    default:
      print('其他错误: ${e.message}');
  }
}
```

### 国际化错误消息

错误消息支持多语言，会根据当前语言环境自动选择对应的错误描述。

## 🧪 测试

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/network_connectivity_test.dart
flutter test test/smart_retry_test.dart
```

### 测试覆盖

- ✅ 网络连接检测
- ✅ 智能重试逻辑
- ✅ 缓存功能
- ✅ 错误处理
- ✅ 性能监控

## 📝 更新日志

### v1.0.0

- 🎉 初始版本发布
- ✨ 智能重试机制
- 🌐 基于 `connectivity_plus` 的网络检测
- 💾 多级缓存支持
- 📊 性能监控功能
- 🛡️ 完善的错误处理
- 🌍 国际化支持

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## �� 许可证

MIT License
