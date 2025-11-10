// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NetworkLogEntry _$NetworkLogEntryFromJson(Map<String, dynamic> json) {
  return _NetworkLogEntry.fromJson(json);
}

/// @nodoc
mixin _$NetworkLogEntry {
  /// 请求ID（唯一标识）
  @JsonKey(name: 'RequestId')
  String get requestId => throw _privateConstructorUsedError;

  /// 请求时间
  @JsonKey(name: 'RequestTime')
  DateTime get requestTime => throw _privateConstructorUsedError;

  /// 响应时间（如果请求还未完成则为null）
  @JsonKey(name: 'ResponseTime')
  DateTime? get responseTime => throw _privateConstructorUsedError;

  /// 请求方法（GET、POST等）
  @JsonKey(name: 'Method')
  String get method => throw _privateConstructorUsedError;

  /// 请求URL
  @JsonKey(name: 'Url')
  String get url => throw _privateConstructorUsedError;

  /// 请求头
  @JsonKey(name: 'RequestHeaders')
  Map<String, dynamic>? get requestHeaders =>
      throw _privateConstructorUsedError;

  /// 查询参数
  @JsonKey(name: 'QueryParameters')
  Map<String, dynamic>? get queryParameters =>
      throw _privateConstructorUsedError;

  /// 请求体（格式化后的JSON字符串）
  @JsonKey(name: 'RequestBody')
  String? get requestBody => throw _privateConstructorUsedError;

  /// 响应状态码
  @JsonKey(name: 'StatusCode')
  int? get statusCode => throw _privateConstructorUsedError;

  /// 响应头
  @JsonKey(name: 'ResponseHeaders')
  Map<String, dynamic>? get responseHeaders =>
      throw _privateConstructorUsedError;

  /// 响应体（格式化后的JSON字符串）
  @JsonKey(name: 'ResponseBody')
  String? get responseBody => throw _privateConstructorUsedError;

  /// 错误类型（DioExceptionType）
  @JsonKey(name: 'ErrorType')
  String? get errorType => throw _privateConstructorUsedError;

  /// 错误消息
  @JsonKey(name: 'ErrorMessage')
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 服务错误描述（从响应体中提取的业务错误信息）
  @JsonKey(name: 'ServiceErrorDesc')
  String? get serviceErrorDesc => throw _privateConstructorUsedError;

  /// 请求持续时间（毫秒）
  @JsonKey(name: 'Duration')
  int? get duration => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NetworkLogEntryCopyWith<NetworkLogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkLogEntryCopyWith<$Res> {
  factory $NetworkLogEntryCopyWith(
          NetworkLogEntry value, $Res Function(NetworkLogEntry) then) =
      _$NetworkLogEntryCopyWithImpl<$Res, NetworkLogEntry>;
  @useResult
  $Res call(
      {@JsonKey(name: 'RequestId') String requestId,
      @JsonKey(name: 'RequestTime') DateTime requestTime,
      @JsonKey(name: 'ResponseTime') DateTime? responseTime,
      @JsonKey(name: 'Method') String method,
      @JsonKey(name: 'Url') String url,
      @JsonKey(name: 'RequestHeaders') Map<String, dynamic>? requestHeaders,
      @JsonKey(name: 'QueryParameters') Map<String, dynamic>? queryParameters,
      @JsonKey(name: 'RequestBody') String? requestBody,
      @JsonKey(name: 'StatusCode') int? statusCode,
      @JsonKey(name: 'ResponseHeaders') Map<String, dynamic>? responseHeaders,
      @JsonKey(name: 'ResponseBody') String? responseBody,
      @JsonKey(name: 'ErrorType') String? errorType,
      @JsonKey(name: 'ErrorMessage') String? errorMessage,
      @JsonKey(name: 'ServiceErrorDesc') String? serviceErrorDesc,
      @JsonKey(name: 'Duration') int? duration});
}

/// @nodoc
class _$NetworkLogEntryCopyWithImpl<$Res, $Val extends NetworkLogEntry>
    implements $NetworkLogEntryCopyWith<$Res> {
  _$NetworkLogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? requestTime = null,
    Object? responseTime = freezed,
    Object? method = null,
    Object? url = null,
    Object? requestHeaders = freezed,
    Object? queryParameters = freezed,
    Object? requestBody = freezed,
    Object? statusCode = freezed,
    Object? responseHeaders = freezed,
    Object? responseBody = freezed,
    Object? errorType = freezed,
    Object? errorMessage = freezed,
    Object? serviceErrorDesc = freezed,
    Object? duration = freezed,
  }) {
    return _then(_value.copyWith(
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      requestTime: null == requestTime
          ? _value.requestTime
          : requestTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      responseTime: freezed == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      requestHeaders: freezed == requestHeaders
          ? _value.requestHeaders
          : requestHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      queryParameters: freezed == queryParameters
          ? _value.queryParameters
          : queryParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      requestBody: freezed == requestBody
          ? _value.requestBody
          : requestBody // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      responseHeaders: freezed == responseHeaders
          ? _value.responseHeaders
          : responseHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      responseBody: freezed == responseBody
          ? _value.responseBody
          : responseBody // ignore: cast_nullable_to_non_nullable
              as String?,
      errorType: freezed == errorType
          ? _value.errorType
          : errorType // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceErrorDesc: freezed == serviceErrorDesc
          ? _value.serviceErrorDesc
          : serviceErrorDesc // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkLogEntryImplCopyWith<$Res>
    implements $NetworkLogEntryCopyWith<$Res> {
  factory _$$NetworkLogEntryImplCopyWith(_$NetworkLogEntryImpl value,
          $Res Function(_$NetworkLogEntryImpl) then) =
      __$$NetworkLogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'RequestId') String requestId,
      @JsonKey(name: 'RequestTime') DateTime requestTime,
      @JsonKey(name: 'ResponseTime') DateTime? responseTime,
      @JsonKey(name: 'Method') String method,
      @JsonKey(name: 'Url') String url,
      @JsonKey(name: 'RequestHeaders') Map<String, dynamic>? requestHeaders,
      @JsonKey(name: 'QueryParameters') Map<String, dynamic>? queryParameters,
      @JsonKey(name: 'RequestBody') String? requestBody,
      @JsonKey(name: 'StatusCode') int? statusCode,
      @JsonKey(name: 'ResponseHeaders') Map<String, dynamic>? responseHeaders,
      @JsonKey(name: 'ResponseBody') String? responseBody,
      @JsonKey(name: 'ErrorType') String? errorType,
      @JsonKey(name: 'ErrorMessage') String? errorMessage,
      @JsonKey(name: 'ServiceErrorDesc') String? serviceErrorDesc,
      @JsonKey(name: 'Duration') int? duration});
}

/// @nodoc
class __$$NetworkLogEntryImplCopyWithImpl<$Res>
    extends _$NetworkLogEntryCopyWithImpl<$Res, _$NetworkLogEntryImpl>
    implements _$$NetworkLogEntryImplCopyWith<$Res> {
  __$$NetworkLogEntryImplCopyWithImpl(
      _$NetworkLogEntryImpl _value, $Res Function(_$NetworkLogEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? requestTime = null,
    Object? responseTime = freezed,
    Object? method = null,
    Object? url = null,
    Object? requestHeaders = freezed,
    Object? queryParameters = freezed,
    Object? requestBody = freezed,
    Object? statusCode = freezed,
    Object? responseHeaders = freezed,
    Object? responseBody = freezed,
    Object? errorType = freezed,
    Object? errorMessage = freezed,
    Object? serviceErrorDesc = freezed,
    Object? duration = freezed,
  }) {
    return _then(_$NetworkLogEntryImpl(
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      requestTime: null == requestTime
          ? _value.requestTime
          : requestTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      responseTime: freezed == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      requestHeaders: freezed == requestHeaders
          ? _value._requestHeaders
          : requestHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      queryParameters: freezed == queryParameters
          ? _value._queryParameters
          : queryParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      requestBody: freezed == requestBody
          ? _value.requestBody
          : requestBody // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      responseHeaders: freezed == responseHeaders
          ? _value._responseHeaders
          : responseHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      responseBody: freezed == responseBody
          ? _value.responseBody
          : responseBody // ignore: cast_nullable_to_non_nullable
              as String?,
      errorType: freezed == errorType
          ? _value.errorType
          : errorType // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceErrorDesc: freezed == serviceErrorDesc
          ? _value.serviceErrorDesc
          : serviceErrorDesc // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NetworkLogEntryImpl implements _NetworkLogEntry {
  const _$NetworkLogEntryImpl(
      {@JsonKey(name: 'RequestId') required this.requestId,
      @JsonKey(name: 'RequestTime') required this.requestTime,
      @JsonKey(name: 'ResponseTime') this.responseTime,
      @JsonKey(name: 'Method') required this.method,
      @JsonKey(name: 'Url') required this.url,
      @JsonKey(name: 'RequestHeaders')
      final Map<String, dynamic>? requestHeaders,
      @JsonKey(name: 'QueryParameters')
      final Map<String, dynamic>? queryParameters,
      @JsonKey(name: 'RequestBody') this.requestBody,
      @JsonKey(name: 'StatusCode') this.statusCode,
      @JsonKey(name: 'ResponseHeaders')
      final Map<String, dynamic>? responseHeaders,
      @JsonKey(name: 'ResponseBody') this.responseBody,
      @JsonKey(name: 'ErrorType') this.errorType,
      @JsonKey(name: 'ErrorMessage') this.errorMessage,
      @JsonKey(name: 'ServiceErrorDesc') this.serviceErrorDesc,
      @JsonKey(name: 'Duration') this.duration})
      : _requestHeaders = requestHeaders,
        _queryParameters = queryParameters,
        _responseHeaders = responseHeaders;

  factory _$NetworkLogEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$NetworkLogEntryImplFromJson(json);

  /// 请求ID（唯一标识）
  @override
  @JsonKey(name: 'RequestId')
  final String requestId;

  /// 请求时间
  @override
  @JsonKey(name: 'RequestTime')
  final DateTime requestTime;

  /// 响应时间（如果请求还未完成则为null）
  @override
  @JsonKey(name: 'ResponseTime')
  final DateTime? responseTime;

  /// 请求方法（GET、POST等）
  @override
  @JsonKey(name: 'Method')
  final String method;

  /// 请求URL
  @override
  @JsonKey(name: 'Url')
  final String url;

  /// 请求头
  final Map<String, dynamic>? _requestHeaders;

  /// 请求头
  @override
  @JsonKey(name: 'RequestHeaders')
  Map<String, dynamic>? get requestHeaders {
    final value = _requestHeaders;
    if (value == null) return null;
    if (_requestHeaders is EqualUnmodifiableMapView) return _requestHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// 查询参数
  final Map<String, dynamic>? _queryParameters;

  /// 查询参数
  @override
  @JsonKey(name: 'QueryParameters')
  Map<String, dynamic>? get queryParameters {
    final value = _queryParameters;
    if (value == null) return null;
    if (_queryParameters is EqualUnmodifiableMapView) return _queryParameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// 请求体（格式化后的JSON字符串）
  @override
  @JsonKey(name: 'RequestBody')
  final String? requestBody;

  /// 响应状态码
  @override
  @JsonKey(name: 'StatusCode')
  final int? statusCode;

  /// 响应头
  final Map<String, dynamic>? _responseHeaders;

  /// 响应头
  @override
  @JsonKey(name: 'ResponseHeaders')
  Map<String, dynamic>? get responseHeaders {
    final value = _responseHeaders;
    if (value == null) return null;
    if (_responseHeaders is EqualUnmodifiableMapView) return _responseHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// 响应体（格式化后的JSON字符串）
  @override
  @JsonKey(name: 'ResponseBody')
  final String? responseBody;

  /// 错误类型（DioExceptionType）
  @override
  @JsonKey(name: 'ErrorType')
  final String? errorType;

  /// 错误消息
  @override
  @JsonKey(name: 'ErrorMessage')
  final String? errorMessage;

  /// 服务错误描述（从响应体中提取的业务错误信息）
  @override
  @JsonKey(name: 'ServiceErrorDesc')
  final String? serviceErrorDesc;

  /// 请求持续时间（毫秒）
  @override
  @JsonKey(name: 'Duration')
  final int? duration;

  @override
  String toString() {
    return 'NetworkLogEntry(requestId: $requestId, requestTime: $requestTime, responseTime: $responseTime, method: $method, url: $url, requestHeaders: $requestHeaders, queryParameters: $queryParameters, requestBody: $requestBody, statusCode: $statusCode, responseHeaders: $responseHeaders, responseBody: $responseBody, errorType: $errorType, errorMessage: $errorMessage, serviceErrorDesc: $serviceErrorDesc, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkLogEntryImpl &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.requestTime, requestTime) ||
                other.requestTime == requestTime) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality()
                .equals(other._requestHeaders, _requestHeaders) &&
            const DeepCollectionEquality()
                .equals(other._queryParameters, _queryParameters) &&
            (identical(other.requestBody, requestBody) ||
                other.requestBody == requestBody) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            const DeepCollectionEquality()
                .equals(other._responseHeaders, _responseHeaders) &&
            (identical(other.responseBody, responseBody) ||
                other.responseBody == responseBody) &&
            (identical(other.errorType, errorType) ||
                other.errorType == errorType) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.serviceErrorDesc, serviceErrorDesc) ||
                other.serviceErrorDesc == serviceErrorDesc) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      requestId,
      requestTime,
      responseTime,
      method,
      url,
      const DeepCollectionEquality().hash(_requestHeaders),
      const DeepCollectionEquality().hash(_queryParameters),
      requestBody,
      statusCode,
      const DeepCollectionEquality().hash(_responseHeaders),
      responseBody,
      errorType,
      errorMessage,
      serviceErrorDesc,
      duration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkLogEntryImplCopyWith<_$NetworkLogEntryImpl> get copyWith =>
      __$$NetworkLogEntryImplCopyWithImpl<_$NetworkLogEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NetworkLogEntryImplToJson(
      this,
    );
  }
}

abstract class _NetworkLogEntry implements NetworkLogEntry {
  const factory _NetworkLogEntry(
      {@JsonKey(name: 'RequestId') required final String requestId,
      @JsonKey(name: 'RequestTime') required final DateTime requestTime,
      @JsonKey(name: 'ResponseTime') final DateTime? responseTime,
      @JsonKey(name: 'Method') required final String method,
      @JsonKey(name: 'Url') required final String url,
      @JsonKey(name: 'RequestHeaders')
      final Map<String, dynamic>? requestHeaders,
      @JsonKey(name: 'QueryParameters')
      final Map<String, dynamic>? queryParameters,
      @JsonKey(name: 'RequestBody') final String? requestBody,
      @JsonKey(name: 'StatusCode') final int? statusCode,
      @JsonKey(name: 'ResponseHeaders')
      final Map<String, dynamic>? responseHeaders,
      @JsonKey(name: 'ResponseBody') final String? responseBody,
      @JsonKey(name: 'ErrorType') final String? errorType,
      @JsonKey(name: 'ErrorMessage') final String? errorMessage,
      @JsonKey(name: 'ServiceErrorDesc') final String? serviceErrorDesc,
      @JsonKey(name: 'Duration') final int? duration}) = _$NetworkLogEntryImpl;

  factory _NetworkLogEntry.fromJson(Map<String, dynamic> json) =
      _$NetworkLogEntryImpl.fromJson;

  @override

  /// 请求ID（唯一标识）
  @JsonKey(name: 'RequestId')
  String get requestId;
  @override

  /// 请求时间
  @JsonKey(name: 'RequestTime')
  DateTime get requestTime;
  @override

  /// 响应时间（如果请求还未完成则为null）
  @JsonKey(name: 'ResponseTime')
  DateTime? get responseTime;
  @override

  /// 请求方法（GET、POST等）
  @JsonKey(name: 'Method')
  String get method;
  @override

  /// 请求URL
  @JsonKey(name: 'Url')
  String get url;
  @override

  /// 请求头
  @JsonKey(name: 'RequestHeaders')
  Map<String, dynamic>? get requestHeaders;
  @override

  /// 查询参数
  @JsonKey(name: 'QueryParameters')
  Map<String, dynamic>? get queryParameters;
  @override

  /// 请求体（格式化后的JSON字符串）
  @JsonKey(name: 'RequestBody')
  String? get requestBody;
  @override

  /// 响应状态码
  @JsonKey(name: 'StatusCode')
  int? get statusCode;
  @override

  /// 响应头
  @JsonKey(name: 'ResponseHeaders')
  Map<String, dynamic>? get responseHeaders;
  @override

  /// 响应体（格式化后的JSON字符串）
  @JsonKey(name: 'ResponseBody')
  String? get responseBody;
  @override

  /// 错误类型（DioExceptionType）
  @JsonKey(name: 'ErrorType')
  String? get errorType;
  @override

  /// 错误消息
  @JsonKey(name: 'ErrorMessage')
  String? get errorMessage;
  @override

  /// 服务错误描述（从响应体中提取的业务错误信息）
  @JsonKey(name: 'ServiceErrorDesc')
  String? get serviceErrorDesc;
  @override

  /// 请求持续时间（毫秒）
  @JsonKey(name: 'Duration')
  int? get duration;
  @override
  @JsonKey(ignore: true)
  _$$NetworkLogEntryImplCopyWith<_$NetworkLogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
