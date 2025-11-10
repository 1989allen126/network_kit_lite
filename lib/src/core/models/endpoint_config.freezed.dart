// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'endpoint_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EndpointConfig _$EndpointConfigFromJson(Map<String, dynamic> json) {
  return _EndpointConfig.fromJson(json);
}

/// @nodoc
mixin _$EndpointConfig {
  /// 端点名称（唯一标识）
  String get name => throw _privateConstructorUsedError;

  /// 请求路径
  String get path => throw _privateConstructorUsedError;

  /// HTTP 方法
  HTTPMethod get method => throw _privateConstructorUsedError;

  /// 模块名称
  String get module => throw _privateConstructorUsedError;

  /// 响应类型
  EndpointResponseType get responseType => throw _privateConstructorUsedError;

  /// 响应模型类型（用于代码生成）
  String? get responseModelType => throw _privateConstructorUsedError;

  /// 是否启用缓存
  bool get enableCache => throw _privateConstructorUsedError;

  /// 缓存策略
  CachePolicy get cachePolicy => throw _privateConstructorUsedError;

  /// 缓存持续时间（分钟）
  int get cacheDurationMinutes => throw _privateConstructorUsedError;

  /// 是否启用重试
  bool get enableRetry => throw _privateConstructorUsedError;

  /// 最大重试次数
  int get maxRetries => throw _privateConstructorUsedError;

  /// 重试延迟（秒）
  int get retryDelaySeconds => throw _privateConstructorUsedError;

  /// 连接超时（秒）
  int? get connectTimeoutSeconds => throw _privateConstructorUsedError;

  /// 发送超时（秒）
  int? get sendTimeoutSeconds => throw _privateConstructorUsedError;

  /// 接收超时（秒）
  int? get receiveTimeoutSeconds => throw _privateConstructorUsedError;

  /// 是否启用日志
  bool? get enableLogging => throw _privateConstructorUsedError;

  /// 内容类型
  String? get contentType => throw _privateConstructorUsedError;

  /// 描述
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EndpointConfigCopyWith<EndpointConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EndpointConfigCopyWith<$Res> {
  factory $EndpointConfigCopyWith(
          EndpointConfig value, $Res Function(EndpointConfig) then) =
      _$EndpointConfigCopyWithImpl<$Res, EndpointConfig>;
  @useResult
  $Res call(
      {String name,
      String path,
      HTTPMethod method,
      String module,
      EndpointResponseType responseType,
      String? responseModelType,
      bool enableCache,
      CachePolicy cachePolicy,
      int cacheDurationMinutes,
      bool enableRetry,
      int maxRetries,
      int retryDelaySeconds,
      int? connectTimeoutSeconds,
      int? sendTimeoutSeconds,
      int? receiveTimeoutSeconds,
      bool? enableLogging,
      String? contentType,
      String? description});
}

/// @nodoc
class _$EndpointConfigCopyWithImpl<$Res, $Val extends EndpointConfig>
    implements $EndpointConfigCopyWith<$Res> {
  _$EndpointConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? method = null,
    Object? module = null,
    Object? responseType = null,
    Object? responseModelType = freezed,
    Object? enableCache = null,
    Object? cachePolicy = null,
    Object? cacheDurationMinutes = null,
    Object? enableRetry = null,
    Object? maxRetries = null,
    Object? retryDelaySeconds = null,
    Object? connectTimeoutSeconds = freezed,
    Object? sendTimeoutSeconds = freezed,
    Object? receiveTimeoutSeconds = freezed,
    Object? enableLogging = freezed,
    Object? contentType = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as HTTPMethod,
      module: null == module
          ? _value.module
          : module // ignore: cast_nullable_to_non_nullable
              as String,
      responseType: null == responseType
          ? _value.responseType
          : responseType // ignore: cast_nullable_to_non_nullable
              as EndpointResponseType,
      responseModelType: freezed == responseModelType
          ? _value.responseModelType
          : responseModelType // ignore: cast_nullable_to_non_nullable
              as String?,
      enableCache: null == enableCache
          ? _value.enableCache
          : enableCache // ignore: cast_nullable_to_non_nullable
              as bool,
      cachePolicy: null == cachePolicy
          ? _value.cachePolicy
          : cachePolicy // ignore: cast_nullable_to_non_nullable
              as CachePolicy,
      cacheDurationMinutes: null == cacheDurationMinutes
          ? _value.cacheDurationMinutes
          : cacheDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      enableRetry: null == enableRetry
          ? _value.enableRetry
          : enableRetry // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      retryDelaySeconds: null == retryDelaySeconds
          ? _value.retryDelaySeconds
          : retryDelaySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      connectTimeoutSeconds: freezed == connectTimeoutSeconds
          ? _value.connectTimeoutSeconds
          : connectTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      sendTimeoutSeconds: freezed == sendTimeoutSeconds
          ? _value.sendTimeoutSeconds
          : sendTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      receiveTimeoutSeconds: freezed == receiveTimeoutSeconds
          ? _value.receiveTimeoutSeconds
          : receiveTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      enableLogging: freezed == enableLogging
          ? _value.enableLogging
          : enableLogging // ignore: cast_nullable_to_non_nullable
              as bool?,
      contentType: freezed == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EndpointConfigImplCopyWith<$Res>
    implements $EndpointConfigCopyWith<$Res> {
  factory _$$EndpointConfigImplCopyWith(_$EndpointConfigImpl value,
          $Res Function(_$EndpointConfigImpl) then) =
      __$$EndpointConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String path,
      HTTPMethod method,
      String module,
      EndpointResponseType responseType,
      String? responseModelType,
      bool enableCache,
      CachePolicy cachePolicy,
      int cacheDurationMinutes,
      bool enableRetry,
      int maxRetries,
      int retryDelaySeconds,
      int? connectTimeoutSeconds,
      int? sendTimeoutSeconds,
      int? receiveTimeoutSeconds,
      bool? enableLogging,
      String? contentType,
      String? description});
}

/// @nodoc
class __$$EndpointConfigImplCopyWithImpl<$Res>
    extends _$EndpointConfigCopyWithImpl<$Res, _$EndpointConfigImpl>
    implements _$$EndpointConfigImplCopyWith<$Res> {
  __$$EndpointConfigImplCopyWithImpl(
      _$EndpointConfigImpl _value, $Res Function(_$EndpointConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? method = null,
    Object? module = null,
    Object? responseType = null,
    Object? responseModelType = freezed,
    Object? enableCache = null,
    Object? cachePolicy = null,
    Object? cacheDurationMinutes = null,
    Object? enableRetry = null,
    Object? maxRetries = null,
    Object? retryDelaySeconds = null,
    Object? connectTimeoutSeconds = freezed,
    Object? sendTimeoutSeconds = freezed,
    Object? receiveTimeoutSeconds = freezed,
    Object? enableLogging = freezed,
    Object? contentType = freezed,
    Object? description = freezed,
  }) {
    return _then(_$EndpointConfigImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as HTTPMethod,
      module: null == module
          ? _value.module
          : module // ignore: cast_nullable_to_non_nullable
              as String,
      responseType: null == responseType
          ? _value.responseType
          : responseType // ignore: cast_nullable_to_non_nullable
              as EndpointResponseType,
      responseModelType: freezed == responseModelType
          ? _value.responseModelType
          : responseModelType // ignore: cast_nullable_to_non_nullable
              as String?,
      enableCache: null == enableCache
          ? _value.enableCache
          : enableCache // ignore: cast_nullable_to_non_nullable
              as bool,
      cachePolicy: null == cachePolicy
          ? _value.cachePolicy
          : cachePolicy // ignore: cast_nullable_to_non_nullable
              as CachePolicy,
      cacheDurationMinutes: null == cacheDurationMinutes
          ? _value.cacheDurationMinutes
          : cacheDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      enableRetry: null == enableRetry
          ? _value.enableRetry
          : enableRetry // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      retryDelaySeconds: null == retryDelaySeconds
          ? _value.retryDelaySeconds
          : retryDelaySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      connectTimeoutSeconds: freezed == connectTimeoutSeconds
          ? _value.connectTimeoutSeconds
          : connectTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      sendTimeoutSeconds: freezed == sendTimeoutSeconds
          ? _value.sendTimeoutSeconds
          : sendTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      receiveTimeoutSeconds: freezed == receiveTimeoutSeconds
          ? _value.receiveTimeoutSeconds
          : receiveTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      enableLogging: freezed == enableLogging
          ? _value.enableLogging
          : enableLogging // ignore: cast_nullable_to_non_nullable
              as bool?,
      contentType: freezed == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EndpointConfigImpl implements _EndpointConfig {
  const _$EndpointConfigImpl(
      {required this.name,
      required this.path,
      this.method = HTTPMethod.get,
      this.module = 'api',
      this.responseType = EndpointResponseType.single,
      this.responseModelType,
      this.enableCache = false,
      this.cachePolicy = CachePolicy.networkOnly,
      this.cacheDurationMinutes = 5,
      this.enableRetry = false,
      this.maxRetries = 3,
      this.retryDelaySeconds = 1,
      this.connectTimeoutSeconds,
      this.sendTimeoutSeconds,
      this.receiveTimeoutSeconds,
      this.enableLogging,
      this.contentType,
      this.description});

  factory _$EndpointConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$EndpointConfigImplFromJson(json);

  /// 端点名称（唯一标识）
  @override
  final String name;

  /// 请求路径
  @override
  final String path;

  /// HTTP 方法
  @override
  @JsonKey()
  final HTTPMethod method;

  /// 模块名称
  @override
  @JsonKey()
  final String module;

  /// 响应类型
  @override
  @JsonKey()
  final EndpointResponseType responseType;

  /// 响应模型类型（用于代码生成）
  @override
  final String? responseModelType;

  /// 是否启用缓存
  @override
  @JsonKey()
  final bool enableCache;

  /// 缓存策略
  @override
  @JsonKey()
  final CachePolicy cachePolicy;

  /// 缓存持续时间（分钟）
  @override
  @JsonKey()
  final int cacheDurationMinutes;

  /// 是否启用重试
  @override
  @JsonKey()
  final bool enableRetry;

  /// 最大重试次数
  @override
  @JsonKey()
  final int maxRetries;

  /// 重试延迟（秒）
  @override
  @JsonKey()
  final int retryDelaySeconds;

  /// 连接超时（秒）
  @override
  final int? connectTimeoutSeconds;

  /// 发送超时（秒）
  @override
  final int? sendTimeoutSeconds;

  /// 接收超时（秒）
  @override
  final int? receiveTimeoutSeconds;

  /// 是否启用日志
  @override
  final bool? enableLogging;

  /// 内容类型
  @override
  final String? contentType;

  /// 描述
  @override
  final String? description;

  @override
  String toString() {
    return 'EndpointConfig(name: $name, path: $path, method: $method, module: $module, responseType: $responseType, responseModelType: $responseModelType, enableCache: $enableCache, cachePolicy: $cachePolicy, cacheDurationMinutes: $cacheDurationMinutes, enableRetry: $enableRetry, maxRetries: $maxRetries, retryDelaySeconds: $retryDelaySeconds, connectTimeoutSeconds: $connectTimeoutSeconds, sendTimeoutSeconds: $sendTimeoutSeconds, receiveTimeoutSeconds: $receiveTimeoutSeconds, enableLogging: $enableLogging, contentType: $contentType, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EndpointConfigImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.responseType, responseType) ||
                other.responseType == responseType) &&
            (identical(other.responseModelType, responseModelType) ||
                other.responseModelType == responseModelType) &&
            (identical(other.enableCache, enableCache) ||
                other.enableCache == enableCache) &&
            (identical(other.cachePolicy, cachePolicy) ||
                other.cachePolicy == cachePolicy) &&
            (identical(other.cacheDurationMinutes, cacheDurationMinutes) ||
                other.cacheDurationMinutes == cacheDurationMinutes) &&
            (identical(other.enableRetry, enableRetry) ||
                other.enableRetry == enableRetry) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.retryDelaySeconds, retryDelaySeconds) ||
                other.retryDelaySeconds == retryDelaySeconds) &&
            (identical(other.connectTimeoutSeconds, connectTimeoutSeconds) ||
                other.connectTimeoutSeconds == connectTimeoutSeconds) &&
            (identical(other.sendTimeoutSeconds, sendTimeoutSeconds) ||
                other.sendTimeoutSeconds == sendTimeoutSeconds) &&
            (identical(other.receiveTimeoutSeconds, receiveTimeoutSeconds) ||
                other.receiveTimeoutSeconds == receiveTimeoutSeconds) &&
            (identical(other.enableLogging, enableLogging) ||
                other.enableLogging == enableLogging) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      path,
      method,
      module,
      responseType,
      responseModelType,
      enableCache,
      cachePolicy,
      cacheDurationMinutes,
      enableRetry,
      maxRetries,
      retryDelaySeconds,
      connectTimeoutSeconds,
      sendTimeoutSeconds,
      receiveTimeoutSeconds,
      enableLogging,
      contentType,
      description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EndpointConfigImplCopyWith<_$EndpointConfigImpl> get copyWith =>
      __$$EndpointConfigImplCopyWithImpl<_$EndpointConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EndpointConfigImplToJson(
      this,
    );
  }
}

abstract class _EndpointConfig implements EndpointConfig {
  const factory _EndpointConfig(
      {required final String name,
      required final String path,
      final HTTPMethod method,
      final String module,
      final EndpointResponseType responseType,
      final String? responseModelType,
      final bool enableCache,
      final CachePolicy cachePolicy,
      final int cacheDurationMinutes,
      final bool enableRetry,
      final int maxRetries,
      final int retryDelaySeconds,
      final int? connectTimeoutSeconds,
      final int? sendTimeoutSeconds,
      final int? receiveTimeoutSeconds,
      final bool? enableLogging,
      final String? contentType,
      final String? description}) = _$EndpointConfigImpl;

  factory _EndpointConfig.fromJson(Map<String, dynamic> json) =
      _$EndpointConfigImpl.fromJson;

  @override

  /// 端点名称（唯一标识）
  String get name;
  @override

  /// 请求路径
  String get path;
  @override

  /// HTTP 方法
  HTTPMethod get method;
  @override

  /// 模块名称
  String get module;
  @override

  /// 响应类型
  EndpointResponseType get responseType;
  @override

  /// 响应模型类型（用于代码生成）
  String? get responseModelType;
  @override

  /// 是否启用缓存
  bool get enableCache;
  @override

  /// 缓存策略
  CachePolicy get cachePolicy;
  @override

  /// 缓存持续时间（分钟）
  int get cacheDurationMinutes;
  @override

  /// 是否启用重试
  bool get enableRetry;
  @override

  /// 最大重试次数
  int get maxRetries;
  @override

  /// 重试延迟（秒）
  int get retryDelaySeconds;
  @override

  /// 连接超时（秒）
  int? get connectTimeoutSeconds;
  @override

  /// 发送超时（秒）
  int? get sendTimeoutSeconds;
  @override

  /// 接收超时（秒）
  int? get receiveTimeoutSeconds;
  @override

  /// 是否启用日志
  bool? get enableLogging;
  @override

  /// 内容类型
  String? get contentType;
  @override

  /// 描述
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$EndpointConfigImplCopyWith<_$EndpointConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EndpointConfigCollection _$EndpointConfigCollectionFromJson(
    Map<String, dynamic> json) {
  return _EndpointConfigCollection.fromJson(json);
}

/// @nodoc
mixin _$EndpointConfigCollection {
  /// 配置集合名称
  String get name => throw _privateConstructorUsedError;

  /// Endpoint 配置列表
  List<EndpointConfig> get endpoints => throw _privateConstructorUsedError;

  /// 默认模块名称
  String get defaultModule => throw _privateConstructorUsedError;

  /// 默认缓存策略
  CachePolicy get defaultCachePolicy => throw _privateConstructorUsedError;

  /// 默认重试配置
  bool get defaultEnableRetry => throw _privateConstructorUsedError;
  int get defaultMaxRetries => throw _privateConstructorUsedError;
  int get defaultRetryDelaySeconds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EndpointConfigCollectionCopyWith<EndpointConfigCollection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EndpointConfigCollectionCopyWith<$Res> {
  factory $EndpointConfigCollectionCopyWith(EndpointConfigCollection value,
          $Res Function(EndpointConfigCollection) then) =
      _$EndpointConfigCollectionCopyWithImpl<$Res, EndpointConfigCollection>;
  @useResult
  $Res call(
      {String name,
      List<EndpointConfig> endpoints,
      String defaultModule,
      CachePolicy defaultCachePolicy,
      bool defaultEnableRetry,
      int defaultMaxRetries,
      int defaultRetryDelaySeconds});
}

/// @nodoc
class _$EndpointConfigCollectionCopyWithImpl<$Res,
        $Val extends EndpointConfigCollection>
    implements $EndpointConfigCollectionCopyWith<$Res> {
  _$EndpointConfigCollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? endpoints = null,
    Object? defaultModule = null,
    Object? defaultCachePolicy = null,
    Object? defaultEnableRetry = null,
    Object? defaultMaxRetries = null,
    Object? defaultRetryDelaySeconds = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      endpoints: null == endpoints
          ? _value.endpoints
          : endpoints // ignore: cast_nullable_to_non_nullable
              as List<EndpointConfig>,
      defaultModule: null == defaultModule
          ? _value.defaultModule
          : defaultModule // ignore: cast_nullable_to_non_nullable
              as String,
      defaultCachePolicy: null == defaultCachePolicy
          ? _value.defaultCachePolicy
          : defaultCachePolicy // ignore: cast_nullable_to_non_nullable
              as CachePolicy,
      defaultEnableRetry: null == defaultEnableRetry
          ? _value.defaultEnableRetry
          : defaultEnableRetry // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultMaxRetries: null == defaultMaxRetries
          ? _value.defaultMaxRetries
          : defaultMaxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      defaultRetryDelaySeconds: null == defaultRetryDelaySeconds
          ? _value.defaultRetryDelaySeconds
          : defaultRetryDelaySeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EndpointConfigCollectionImplCopyWith<$Res>
    implements $EndpointConfigCollectionCopyWith<$Res> {
  factory _$$EndpointConfigCollectionImplCopyWith(
          _$EndpointConfigCollectionImpl value,
          $Res Function(_$EndpointConfigCollectionImpl) then) =
      __$$EndpointConfigCollectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      List<EndpointConfig> endpoints,
      String defaultModule,
      CachePolicy defaultCachePolicy,
      bool defaultEnableRetry,
      int defaultMaxRetries,
      int defaultRetryDelaySeconds});
}

/// @nodoc
class __$$EndpointConfigCollectionImplCopyWithImpl<$Res>
    extends _$EndpointConfigCollectionCopyWithImpl<$Res,
        _$EndpointConfigCollectionImpl>
    implements _$$EndpointConfigCollectionImplCopyWith<$Res> {
  __$$EndpointConfigCollectionImplCopyWithImpl(
      _$EndpointConfigCollectionImpl _value,
      $Res Function(_$EndpointConfigCollectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? endpoints = null,
    Object? defaultModule = null,
    Object? defaultCachePolicy = null,
    Object? defaultEnableRetry = null,
    Object? defaultMaxRetries = null,
    Object? defaultRetryDelaySeconds = null,
  }) {
    return _then(_$EndpointConfigCollectionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      endpoints: null == endpoints
          ? _value._endpoints
          : endpoints // ignore: cast_nullable_to_non_nullable
              as List<EndpointConfig>,
      defaultModule: null == defaultModule
          ? _value.defaultModule
          : defaultModule // ignore: cast_nullable_to_non_nullable
              as String,
      defaultCachePolicy: null == defaultCachePolicy
          ? _value.defaultCachePolicy
          : defaultCachePolicy // ignore: cast_nullable_to_non_nullable
              as CachePolicy,
      defaultEnableRetry: null == defaultEnableRetry
          ? _value.defaultEnableRetry
          : defaultEnableRetry // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultMaxRetries: null == defaultMaxRetries
          ? _value.defaultMaxRetries
          : defaultMaxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      defaultRetryDelaySeconds: null == defaultRetryDelaySeconds
          ? _value.defaultRetryDelaySeconds
          : defaultRetryDelaySeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EndpointConfigCollectionImpl implements _EndpointConfigCollection {
  const _$EndpointConfigCollectionImpl(
      {required this.name,
      required final List<EndpointConfig> endpoints,
      this.defaultModule = 'api',
      this.defaultCachePolicy = CachePolicy.networkOnly,
      this.defaultEnableRetry = false,
      this.defaultMaxRetries = 3,
      this.defaultRetryDelaySeconds = 1})
      : _endpoints = endpoints;

  factory _$EndpointConfigCollectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$EndpointConfigCollectionImplFromJson(json);

  /// 配置集合名称
  @override
  final String name;

  /// Endpoint 配置列表
  final List<EndpointConfig> _endpoints;

  /// Endpoint 配置列表
  @override
  List<EndpointConfig> get endpoints {
    if (_endpoints is EqualUnmodifiableListView) return _endpoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_endpoints);
  }

  /// 默认模块名称
  @override
  @JsonKey()
  final String defaultModule;

  /// 默认缓存策略
  @override
  @JsonKey()
  final CachePolicy defaultCachePolicy;

  /// 默认重试配置
  @override
  @JsonKey()
  final bool defaultEnableRetry;
  @override
  @JsonKey()
  final int defaultMaxRetries;
  @override
  @JsonKey()
  final int defaultRetryDelaySeconds;

  @override
  String toString() {
    return 'EndpointConfigCollection(name: $name, endpoints: $endpoints, defaultModule: $defaultModule, defaultCachePolicy: $defaultCachePolicy, defaultEnableRetry: $defaultEnableRetry, defaultMaxRetries: $defaultMaxRetries, defaultRetryDelaySeconds: $defaultRetryDelaySeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EndpointConfigCollectionImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._endpoints, _endpoints) &&
            (identical(other.defaultModule, defaultModule) ||
                other.defaultModule == defaultModule) &&
            (identical(other.defaultCachePolicy, defaultCachePolicy) ||
                other.defaultCachePolicy == defaultCachePolicy) &&
            (identical(other.defaultEnableRetry, defaultEnableRetry) ||
                other.defaultEnableRetry == defaultEnableRetry) &&
            (identical(other.defaultMaxRetries, defaultMaxRetries) ||
                other.defaultMaxRetries == defaultMaxRetries) &&
            (identical(
                    other.defaultRetryDelaySeconds, defaultRetryDelaySeconds) ||
                other.defaultRetryDelaySeconds == defaultRetryDelaySeconds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      const DeepCollectionEquality().hash(_endpoints),
      defaultModule,
      defaultCachePolicy,
      defaultEnableRetry,
      defaultMaxRetries,
      defaultRetryDelaySeconds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EndpointConfigCollectionImplCopyWith<_$EndpointConfigCollectionImpl>
      get copyWith => __$$EndpointConfigCollectionImplCopyWithImpl<
          _$EndpointConfigCollectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EndpointConfigCollectionImplToJson(
      this,
    );
  }
}

abstract class _EndpointConfigCollection implements EndpointConfigCollection {
  const factory _EndpointConfigCollection(
      {required final String name,
      required final List<EndpointConfig> endpoints,
      final String defaultModule,
      final CachePolicy defaultCachePolicy,
      final bool defaultEnableRetry,
      final int defaultMaxRetries,
      final int defaultRetryDelaySeconds}) = _$EndpointConfigCollectionImpl;

  factory _EndpointConfigCollection.fromJson(Map<String, dynamic> json) =
      _$EndpointConfigCollectionImpl.fromJson;

  @override

  /// 配置集合名称
  String get name;
  @override

  /// Endpoint 配置列表
  List<EndpointConfig> get endpoints;
  @override

  /// 默认模块名称
  String get defaultModule;
  @override

  /// 默认缓存策略
  CachePolicy get defaultCachePolicy;
  @override

  /// 默认重试配置
  bool get defaultEnableRetry;
  @override
  int get defaultMaxRetries;
  @override
  int get defaultRetryDelaySeconds;
  @override
  @JsonKey(ignore: true)
  _$$EndpointConfigCollectionImplCopyWith<_$EndpointConfigCollectionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
