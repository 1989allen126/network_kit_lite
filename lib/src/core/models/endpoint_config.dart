import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

part 'endpoint_config.freezed.dart';
part 'endpoint_config.g.dart';

/// Endpoint 配置类型
enum EndpointResponseType {
  /// 单个对象响应
  single,

  /// 列表响应
  list,

  /// 原始响应
  raw,
}

/// Endpoint 配置
@freezed
class EndpointConfig with _$EndpointConfig {
  const factory EndpointConfig({
    /// 端点名称（唯一标识）
    required String name,

    /// 请求路径
    required String path,

    /// HTTP 方法
    @Default(HTTPMethod.get) HTTPMethod method,

    /// 模块名称
    @Default('api') String module,

    /// 响应类型
    @Default(EndpointResponseType.single) EndpointResponseType responseType,

    /// 响应模型类型（用于代码生成）
    String? responseModelType,

    /// 是否启用缓存
    @Default(false) bool enableCache,

    /// 缓存策略
    @Default(CachePolicy.networkOnly) CachePolicy cachePolicy,

    /// 缓存持续时间（分钟）
    @Default(5) int cacheDurationMinutes,

    /// 是否启用重试
    @Default(false) bool enableRetry,

    /// 最大重试次数
    @Default(3) int maxRetries,

    /// 重试延迟（秒）
    @Default(1) int retryDelaySeconds,

    /// 连接超时（秒）
    int? connectTimeoutSeconds,

    /// 发送超时（秒）
    int? sendTimeoutSeconds,

    /// 接收超时（秒）
    int? receiveTimeoutSeconds,

    /// 是否启用日志
    bool? enableLogging,

    /// 内容类型
    String? contentType,

    /// 描述
    String? description,
  }) = _EndpointConfig;

  factory EndpointConfig.fromJson(Map<String, dynamic> json) => _$EndpointConfigFromJson(json);
}

/// Endpoint 配置集合
@freezed
class EndpointConfigCollection with _$EndpointConfigCollection {
  const factory EndpointConfigCollection({
    /// 配置集合名称
    required String name,

    /// Endpoint 配置列表
    required List<EndpointConfig> endpoints,

    /// 默认模块名称
    @Default('api') String defaultModule,

    /// 默认缓存策略
    @Default(CachePolicy.networkOnly) CachePolicy defaultCachePolicy,

    /// 默认重试配置
    @Default(false) bool defaultEnableRetry,
    @Default(3) int defaultMaxRetries,
    @Default(1) int defaultRetryDelaySeconds,
  }) = _EndpointConfigCollection;

  factory EndpointConfigCollection.fromJson(Map<String, dynamic> json) => _$EndpointConfigCollectionFromJson(json);
}
