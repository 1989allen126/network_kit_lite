# Endpoint 配置化使用指南

## 概述

通过配置化的方式定义 API Endpoint，无需手动编写每个 Endpoint 类，只需要配置即可自动生成。

## 使用方式

### 1. 代码配置方式

```dart
import 'package:network_kit_lite/network_kit_lite.dart';

// 初始化 Endpoint 注册表
final registry = EndpointRegistry();

// 注册 Endpoint 配置
await registry.initialize([
  const EndpointConfig(
    name: 'getUserInfo',
    path: '/api/user/info',
    method: HTTPMethod.get,
    module: 'api',
    responseType: EndpointResponseType.single,
    enableCache: true,
    cachePolicy: CachePolicy.cacheFirst,
  ),
  const EndpointConfig(
    name: 'getUserList',
    path: '/api/user/list',
    method: HTTPMethod.get,
    module: 'api',
    responseType: EndpointResponseType.list,
    enableRetry: true,
    maxRetries: 3,
  ),
  const EndpointConfig(
    name: 'updateUser',
    path: '/api/user/update',
    method: HTTPMethod.post,
    module: 'api',
    responseType: EndpointResponseType.raw,
  ),
]);

// 使用配置创建 Endpoint
final userInfoEndpoint = registry.createSingleEndpoint<UserInfoModel>(
  name: 'getUserInfo',
  parser: (item) => UserInfoModel.fromJson(item),
);

// 执行请求
final response = await dioClient.execute(userInfoEndpoint);
```

### 2. JSON 配置文件方式

创建 `assets/config/endpoints.json`:

```json
{
  "name": "api_endpoints",
  "endpoints": [
    {
      "name": "getUserInfo",
      "path": "/api/user/info",
      "method": "get",
      "module": "api",
      "responseType": "single",
      "enableCache": true,
      "cachePolicy": "cacheFirst",
      "cacheDurationMinutes": 10
    },
    {
      "name": "getUserList",
      "path": "/api/user/list",
      "method": "get",
      "module": "api",
      "responseType": "list",
      "enableRetry": true,
      "maxRetries": 3,
      "retryDelaySeconds": 1
    },
    {
      "name": "updateUser",
      "path": "/api/user/update",
      "method": "post",
      "module": "api",
      "responseType": "raw"
    }
  ]
}
```

在 `pubspec.yaml` 中添加：

```yaml
flutter:
  assets:
    - assets/config/endpoints.json
```

加载配置：

```dart
// 从 JSON 文件加载配置
await registry.loadFromJson('assets/config/endpoints.json');

// 使用配置创建 Endpoint
final userInfoEndpoint = registry.createSingleEndpoint<UserInfoModel>(
  name: 'getUserInfo',
  parser: (item) => UserInfoModel.fromJson(item),
);
```

### 3. 带参数的 Endpoint

```dart
// 创建带查询参数的 Endpoint
final userListEndpoint = registry.createListEndpoint<UserModel>(
  name: 'getUserList',
  queryParameters: {
    'page': 1,
    'limit': 20,
    'status': 'active',
  },
  parser: (element) => UserModel.fromJson(element),
);

// 创建带请求体的 Endpoint
final updateUserEndpoint = registry.createSingleEndpoint<UserModel>(
  name: 'updateUser',
  requestBody: {
    'id': userId,
    'name': newName,
    'email': newEmail,
  },
  parser: (item) => UserModel.fromJson(item),
);
```

### 4. 直接使用 EndpointFactory

```dart
// 直接使用工厂创建 Endpoint
final config = const EndpointConfig(
  name: 'getUserInfo',
  path: '/api/user/info',
  method: HTTPMethod.get,
  module: 'api',
  responseType: EndpointResponseType.single,
);

final endpoint = EndpointFactory.createSingleEndpoint<UserInfoModel>(
  config: config,
  parser: (item) => UserInfoModel.fromJson(item),
);
```

## 配置选项说明

### EndpointConfig 字段

- `name`: Endpoint 名称（唯一标识）
- `path`: 请求路径
- `method`: HTTP 方法（get, post, put, delete, patch, head）
- `module`: 模块名称（用于域名配置）
- `responseType`: 响应类型（single, list, raw）
- `responseModelType`: 响应模型类型（用于代码生成，可选）
- `enableCache`: 是否启用缓存
- `cachePolicy`: 缓存策略
- `cacheDurationMinutes`: 缓存持续时间（分钟）
- `enableRetry`: 是否启用重试
- `maxRetries`: 最大重试次数
- `retryDelaySeconds`: 重试延迟（秒）
- `connectTimeoutSeconds`: 连接超时（秒）
- `sendTimeoutSeconds`: 发送超时（秒）
- `receiveTimeoutSeconds`: 接收超时（秒）
- `enableLogging`: 是否启用日志
- `contentType`: 内容类型
- `description`: 描述

## 优势

1. **无需手动编码**：只需要配置即可，无需编写每个 Endpoint 类
2. **统一管理**：所有 Endpoint 配置集中管理，易于维护
3. **灵活配置**：支持代码配置和 JSON 配置文件两种方式
4. **类型安全**：使用 freezed 确保类型安全
5. **易于扩展**：可以轻松添加新的配置选项
