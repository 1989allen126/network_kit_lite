# API 注解使用指南

## 概述

通过注解标记 API 接口方法，使用代码生成器自动生成 endpoint 类，无需手动编写每个 endpoint。

## 注解说明

### HTTP 方法注解

- `@ApiGET(path)`: GET 请求
- `@ApiPOST(path)`: POST 请求
- `@ApiPUT(path)`: PUT 请求
- `@ApiDELETE(path)`: DELETE 请求
- `@ApiPATCH(path)`: PATCH 请求

### 参数注解

- `@ApiPath(name)`: 路径参数，用于路径中的动态参数
- `@ApiQuery({name, required})`: 查询参数
- `@ApiBody()`: 请求体参数
- `@ApiHeader({name})`: 请求头参数

### 配置注解

- `@ApiModule(module)`: 标记 API 接口类，指定默认模块
- `@ApiResponseType(type, {modelType})`: 指定响应类型
- `@ApiCache({policy, durationMinutes})`: 缓存配置
- `@ApiRetry({enable, maxRetries, delaySeconds})`: 重试配置
- `@ApiTimeout({connectSeconds, sendSeconds, receiveSeconds})`: 超时配置

## 使用示例

### 1. 定义 API 接口

```dart
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/annotations/api_annotations.dart';

@ApiModule('api')
abstract class AccountApi {
  /// 测试接口
  @ApiGET('/api/account/test')
  Future<BaseResponse<Map<String, dynamic>>> test();

  /// 检查更新
  @ApiGET('/api/account/checkupdate')
  Future<BaseResponse<CheckUpdateResponseModel>> checkUpdate(
    @ApiQuery() String apkName,
  );

  /// 登录
  @ApiPOST('/api/account/login')
  Future<BaseResponse<LoginResponseModel>> login(
    @ApiBody() LoginDtoRequestModel request,
  );

  /// 获取用户信息
  @ApiGET('/api/user/info')
  @ApiCache(policy: CachePolicy.cacheFirst, durationMinutes: 10)
  Future<BaseResponse<UserInfoModel>> getUserInfo();

  /// 获取用户列表
  @ApiGET('/api/user/list')
  @ApiResponseType('list', modelType: UserModel)
  Future<BaseResponse<List<UserModel>>> getUserList(
    @ApiQuery() int page,
    @ApiQuery() int limit,
    @ApiQuery(name: 'status') String? status,
  );

  /// 更新用户信息
  @ApiPUT('/api/user/{id}')
  Future<BaseResponse<UserModel>> updateUser(
    @ApiPath('id') String userId,
    @ApiBody() UpdateUserRequestModel request,
  );

  /// 删除用户
  @ApiDELETE('/api/user/{id}')
  Future<BaseResponse<void>> deleteUser(
    @ApiPath('id') String userId,
  );
}
```

### 2. 运行代码生成

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 使用生成的 Endpoint

```dart
// 代码生成器会自动生成 AccountApiImpl 类
final api = AccountApiImpl();

// 使用生成的 endpoint
final response = await dioClient.execute(api.test());
final updateResponse = await dioClient.execute(api.checkUpdate('app.apk'));
final loginResponse = await dioClient.execute(api.login(loginRequest));
```

## 注解参数说明

### @ApiGET/@ApiPOST/@ApiPUT/@ApiDELETE/@ApiPATCH

```dart
@ApiGET(
  '/api/user/info',  // 请求路径
  module: 'api',     // 模块名称（可选，默认 'api'）
  cachePolicy: CachePolicy.cacheFirst,  // 缓存策略（可选）
  cacheDurationMinutes: 10,  // 缓存持续时间（可选）
  enableRetry: true,  // 是否启用重试（可选）
  maxRetries: 3,  // 最大重试次数（可选）
  responseType: 'single',  // 响应类型：single/list/raw（可选）
)
```

### @ApiPath

```dart
@ApiGET('/api/user/{id}')
Future<BaseResponse<UserModel>> getUser(
  @ApiPath('id') String userId,  // 路径参数，会替换路径中的 {id}
);
```

### @ApiQuery

```dart
@ApiGET('/api/user/list')
Future<BaseResponse<List<UserModel>>> getUserList(
  @ApiQuery() int page,  // 查询参数，参数名作为 key
  @ApiQuery(name: 'limit') int pageSize,  // 指定查询参数名
  @ApiQuery(required: false) String? status,  // 可选参数
);
```

### @ApiBody

```dart
@ApiPOST('/api/user/create')
Future<BaseResponse<UserModel>> createUser(
  @ApiBody() CreateUserRequestModel request,  // 请求体
);
```

### @ApiHeader

```dart
@ApiGET('/api/user/info')
Future<BaseResponse<UserModel>> getUserInfo(
  @ApiHeader(name: 'X-Custom-Header') String customHeader,  // 自定义请求头
);
```

### @ApiResponseType

```dart
@ApiGET('/api/user/list')
@ApiResponseType('list', modelType: UserModel)  // 列表响应
Future<BaseResponse<List<UserModel>>> getUserList();

@ApiGET('/api/user/info')
@ApiResponseType('single', modelType: UserModel)  // 单个对象响应
Future<BaseResponse<UserModel>> getUserInfo();

@ApiPOST('/api/user/update')
@ApiResponseType('raw')  // 原始响应
Future<BaseResponse<dynamic>> updateUser();
```

### @ApiCache

```dart
@ApiGET('/api/user/info')
@ApiCache(
  policy: CachePolicy.cacheFirst,  // 缓存策略
  durationMinutes: 10,  // 缓存持续时间（分钟）
)
Future<BaseResponse<UserModel>> getUserInfo();
```

### @ApiRetry

```dart
@ApiPOST('/api/user/create')
@ApiRetry(
  enable: true,  // 启用重试
  maxRetries: 3,  // 最大重试次数
  delaySeconds: 1,  // 重试延迟（秒）
)
Future<BaseResponse<UserModel>> createUser();
```

### @ApiTimeout

```dart
@ApiGET('/api/user/info')
@ApiTimeout(
  connectSeconds: 30,  // 连接超时（秒）
  sendSeconds: 30,  // 发送超时（秒）
  receiveSeconds: 30,  // 接收超时（秒）
)
Future<BaseResponse<UserModel>> getUserInfo();
```

## 代码生成器

代码生成器会读取注解并自动生成：

1. **Endpoint 类**：每个方法生成对应的 endpoint 类
2. **API 实现类**：实现 API 接口，提供 endpoint 创建方法
3. **参数处理**：自动处理路径参数、查询参数、请求体等

## 优势

1. **无需手动编码**：只需要注解即可，无需编写每个 endpoint 类
2. **类型安全**：编译时检查，类型安全
3. **自动生成**：代码生成器自动生成所有必要的代码
4. **易于维护**：接口定义集中，易于修改
5. **IDE 支持**：完整的 IDE 自动补全和类型检查
