import 'package:network_kit_lite/network_kit_lite.dart';

/// Endpoint 工厂
/// 根据配置生成 Endpoint 实例
class EndpointFactory {
  EndpointFactory._();

  /// 根据配置创建单个对象响应的 Endpoint
  static GenericAPIEndpoint<T> createSingleEndpoint<T>({
    required EndpointConfig config,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    return _ConfigurableSingleEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser ?? ((dynamic item) => item as T),
    );
  }

  /// 根据配置创建列表响应的 Endpoint
  static ListAPIEndpoint<T> createListEndpoint<T>({
    required EndpointConfig config,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    return _ConfigurableListEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser ?? ((dynamic element) => element as T),
    );
  }

  /// 根据配置创建原始响应的 Endpoint
  static APIEndpoint createRawEndpoint({
    required EndpointConfig config,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
  }) {
    return _ConfigurableRawEndpoint(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
    );
  }

  /// 根据配置自动创建 Endpoint
  static APIEndpoint createEndpoint({
    required EndpointConfig config,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    dynamic Function(dynamic)? parser,
  }) {
    switch (config.responseType) {
      case EndpointResponseType.single:
        return createSingleEndpoint<dynamic>(
          config: config,
          queryParameters: queryParameters,
          requestBody: requestBody,
          headers: headers,
          parser: parser,
        );
      case EndpointResponseType.list:
        return createListEndpoint<dynamic>(
          config: config,
          queryParameters: queryParameters,
          requestBody: requestBody,
          headers: headers,
          parser: parser,
        );
      case EndpointResponseType.raw:
        return createRawEndpoint(
          config: config,
          queryParameters: queryParameters,
          requestBody: requestBody,
          headers: headers,
        );
    }
  }
}

/// 可配置的单个对象响应 Endpoint
class _ConfigurableSingleEndpoint<T> extends GenericAPIEndpoint<T> {
  final EndpointConfig _config; // 接口配置
  final Map<String, dynamic>? _queryParameters; // 接口查询参数
  final dynamic _requestBody; // 接口请求体
  final Map<String, String>? _headers; // 接口请求头
  final T Function(dynamic) _parser; // 接口解析器

  _ConfigurableSingleEndpoint({
    required EndpointConfig config,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    required T Function(dynamic) parser,
  })  : _config = config,
        _queryParameters = queryParameters,
        _requestBody = requestBody,
        _headers = headers,
        _parser = parser;

  @override
  String get path => _config.path; // 接口路径

  @override
  HTTPMethod get httpMethod => _config.method; // 接口方法

  @override
  String get module => _config.module; // 接口模块

  @override
  Map<String, dynamic>? get queryParameters => _queryParameters; // 接口查询参数

  @override
  dynamic get requestBody => _requestBody; // 接口请求体

  @override
  Map<String, String>? get headers => _headers ?? super.headers; // 接口请求头

  @override
  String? get contentType => _config.contentType ?? super.contentType; // 接口内容类型

  @override
  int get connectTimeoutSeconds => _config.connectTimeoutSeconds ?? super.connectTimeoutSeconds; // 接口连接超时时间

  @override
  int get sendTimeoutSeconds => _config.sendTimeoutSeconds ?? super.sendTimeoutSeconds; // 接口发送超时时间

  @override
  int get receiveTimeoutSeconds => _config.receiveTimeoutSeconds ?? super.receiveTimeoutSeconds; // 接口接收超时时间

  @override
  CachePolicy get cachePolicy => _config.cachePolicy; // 接口缓存策略

  @override
  Duration get cacheDuration => Duration(minutes: _config.cacheDurationMinutes); // 接口缓存时长

  @override
  bool get shouldRetry => _config.enableRetry; // 接口是否启用重试

  @override
  int get maxRetries => _config.maxRetries; // 接口最大重试次数

  @override
  Duration get retryDelay => Duration(seconds: _config.retryDelaySeconds); // 接口重试延迟时间

  @override
  bool get enableLogging => _config.enableLogging ?? super.enableLogging; // 接口是否启用日志

  @override
  T parseItem(dynamic item) => _parser(item); // 接口解析单个对象
}

/// 可配置的列表响应 Endpoint
class _ConfigurableListEndpoint<T> extends ListAPIEndpoint<T> {
  final EndpointConfig _config; // 接口配置
  final Map<String, dynamic>? _queryParameters; // 接口查询参数
  final dynamic _requestBody; // 接口请求体
  final Map<String, String>? _headers; // 接口请求头
  final T Function(dynamic) _parser; // 接口解析器

  _ConfigurableListEndpoint({
    required EndpointConfig config,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    required T Function(dynamic) parser,
  })  : _config = config,
        _queryParameters = queryParameters,
        _requestBody = requestBody,
        _headers = headers,
        _parser = parser;

  @override
  String get path => _config.path; // 接口路径

  @override
  HTTPMethod get httpMethod => _config.method; // 接口方法

  @override
  String get module => _config.module; // 接口模块

  @override
  Map<String, dynamic>? get queryParameters => _queryParameters; // 接口查询参数

  @override
  dynamic get requestBody => _requestBody; // 接口请求体

  @override
  Map<String, String>? get headers => _headers ?? super.headers; // 接口请求头

  @override
  String? get contentType => _config.contentType ?? super.contentType; // 接口内容类型

  @override
  int get connectTimeoutSeconds => _config.connectTimeoutSeconds ?? super.connectTimeoutSeconds; // 接口连接超时时间

  @override
  int get sendTimeoutSeconds => _config.sendTimeoutSeconds ?? super.sendTimeoutSeconds; // 接口发送超时时间

  @override
  int get receiveTimeoutSeconds => _config.receiveTimeoutSeconds ?? super.receiveTimeoutSeconds; // 接口接收超时时间

  @override
  CachePolicy get cachePolicy => _config.cachePolicy; // 接口缓存策略

  @override
  Duration get cacheDuration => Duration(minutes: _config.cacheDurationMinutes); // 接口缓存时长

  @override
  bool get shouldRetry => _config.enableRetry; // 接口是否启用重试

  @override
  int get maxRetries => _config.maxRetries; // 接口最大重试次数

  @override
  Duration get retryDelay => Duration(seconds: _config.retryDelaySeconds); // 接口重试延迟时间

  @override
  bool get enableLogging => _config.enableLogging ?? super.enableLogging; // 接口是否启用日志

  @override
  T parseElement(dynamic element) => _parser(element); // 接口解析列表元素
}

/// 可配置的原始响应 Endpoint
class _ConfigurableRawEndpoint extends APIEndpoint {
  final EndpointConfig _config; // 接口配置
  final Map<String, dynamic>? _queryParameters; // 接口查询参数
  final dynamic _requestBody; // 接口请求体
  final Map<String, String>? _headers; // 接口请求头

  _ConfigurableRawEndpoint({
    required EndpointConfig config,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
  })  : _config = config,
        _queryParameters = queryParameters,
        _requestBody = requestBody,
        _headers = headers;

  @override
  String get path => _config.path; // 接口路径

  @override
  HTTPMethod get httpMethod => _config.method; // 接口方法

  @override
  String get module => _config.module; // 接口模块

  @override
  Map<String, dynamic>? get queryParameters => _queryParameters; // 接口查询参数

  @override
  dynamic get requestBody => _requestBody; // 接口请求体

  @override
  Map<String, String>? get headers => _headers ?? super.headers; // 接口请求头

  @override
  String? get contentType => _config.contentType ?? super.contentType; // 接口内容类型

  @override
  int get connectTimeoutSeconds => _config.connectTimeoutSeconds ?? super.connectTimeoutSeconds; // 接口连接超时时间

  @override
  int get sendTimeoutSeconds => _config.sendTimeoutSeconds ?? super.sendTimeoutSeconds; // 接口发送超时时间

  @override
  int get receiveTimeoutSeconds => _config.receiveTimeoutSeconds ?? super.receiveTimeoutSeconds; // 接口接收超时时间

  @override
  CachePolicy get cachePolicy => _config.cachePolicy; // 接口缓存策略

  @override
  Duration get cacheDuration => Duration(minutes: _config.cacheDurationMinutes); // 接口缓存时长

  @override
  bool get shouldRetry => _config.enableRetry; // 接口是否启用重试

  @override
  int get maxRetries => _config.maxRetries; // 接口最大重试次数

  @override
  Duration get retryDelay => Duration(seconds: _config.retryDelaySeconds); // 接口重试延迟时间

  @override
  bool get enableLogging => _config.enableLogging ?? super.enableLogging; // 接口是否启用日志

  @override
  dynamic parseResponse(dynamic response) => response; // 接口解析响应数据
}
