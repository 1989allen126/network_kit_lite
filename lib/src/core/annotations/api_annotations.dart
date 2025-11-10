import 'package:network_kit_lite/network_kit_lite.dart';

/// API 注解库
/// 用于标记 API 接口方法，通过代码生成器自动生成 endpoint 类

/// HTTP GET 请求注解
class ApiGET {
  /// 请求路径
  final String path;

  /// 模块名称
  final String module;

  /// 缓存策略
  final CachePolicy? cachePolicy;

  /// 缓存持续时间（分钟）
  final int? cacheDurationMinutes;

  /// 是否启用重试
  final bool? enableRetry;

  /// 最大重试次数
  final int? maxRetries;

  /// 响应类型（single/list/raw）
  final String? responseType;

  const ApiGET(
    this.path, {
    this.module = 'api',
    this.cachePolicy,
    this.cacheDurationMinutes,
    this.enableRetry,
    this.maxRetries,
    this.responseType,
  });
}

/// HTTP POST 请求注解
class ApiPOST {
  /// 请求路径
  final String path;

  /// 模块名称
  final String module;

  /// 是否启用重试
  final bool? enableRetry;

  /// 最大重试次数
  final int? maxRetries;

  /// 响应类型（single/list/raw）
  final String? responseType;

  const ApiPOST(
    this.path, {
    this.module = 'api',
    this.enableRetry,
    this.maxRetries,
    this.responseType,
  });
}

/// HTTP PUT 请求注解
class ApiPUT {
  /// 请求路径
  final String path;

  /// 模块名称
  final String module;

  /// 响应类型（single/list/raw）
  final String? responseType;

  const ApiPUT(
    this.path, {
    this.module = 'api',
    this.responseType,
  });
}

/// HTTP DELETE 请求注解
class ApiDELETE {
  /// 请求路径
  final String path;

  /// 模块名称
  final String module;

  /// 响应类型（single/list/raw）
  final String? responseType;

  const ApiDELETE(
    this.path, {
    this.module = 'api',
    this.responseType,
  });
}

/// HTTP PATCH 请求注解
class ApiPATCH {
  /// 请求路径
  final String path;

  /// 模块名称
  final String module;

  /// 响应类型（single/list/raw）
  final String? responseType;

  const ApiPATCH(
    this.path, {
    this.module = 'api',
    this.responseType,
  });
}

/// 路径参数注解
/// 用于标记路径中的动态参数，如 /api/user/{id}
class ApiPath {
  /// 参数名称
  final String name;

  const ApiPath(this.name);
}

/// 查询参数注解
/// 用于标记查询参数
class ApiQuery {
  /// 参数名称（如果为空则使用参数名）
  final String? name;

  /// 是否必需
  final bool required;

  const ApiQuery({this.name, this.required = false});
}

/// 请求体注解
/// 用于标记请求体参数
class ApiBody {
  const ApiBody();
}

/// 请求头注解
/// 用于标记请求头参数
class ApiHeader {
  /// 请求头名称（如果为空则使用参数名）
  final String? name;

  const ApiHeader({this.name});
}

/// 模块注解
/// 用于标记 API 接口类，指定默认模块
class ApiModule {
  /// 模块名称
  final String module;

  const ApiModule(this.module);
}

/// 响应类型注解
/// 用于指定响应数据的类型
class ApiResponseType {
  /// 响应类型：single（单个对象）、list（列表）、raw（原始响应）
  final String type;

  /// 响应模型类型（用于代码生成）
  final Type? modelType;

  const ApiResponseType(this.type, {this.modelType});
}

/// 缓存策略注解
class ApiCache {
  /// 缓存策略
  final CachePolicy policy;

  /// 缓存持续时间（分钟）
  final int durationMinutes;

  const ApiCache({
    required this.policy,
    this.durationMinutes = 5,
  });
}

/// 重试配置注解
class ApiRetry {
  /// 是否启用重试
  final bool enable;

  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟（秒）
  final int delaySeconds;

  const ApiRetry({
    this.enable = false,
    this.maxRetries = 3,
    this.delaySeconds = 1,
  });
}

/// 超时配置注解
class ApiTimeout {
  /// 连接超时（秒）
  final int? connectSeconds;

  /// 发送超时（秒）
  final int? sendSeconds;

  /// 接收超时（秒）
  final int? receiveSeconds;

  const ApiTimeout({
    this.connectSeconds,
    this.sendSeconds,
    this.receiveSeconds,
  });
}
