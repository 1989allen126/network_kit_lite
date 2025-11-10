import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'network_log_entry.freezed.dart';
part 'network_log_entry.g.dart';

/// 网络请求日志条目
@freezed
class NetworkLogEntry with _$NetworkLogEntry {
  const factory NetworkLogEntry({
    /// 请求ID（唯一标识）
    @JsonKey(name: 'RequestId') required String requestId,

    /// 请求时间
    @JsonKey(name: 'RequestTime') required DateTime requestTime,

    /// 响应时间（如果请求还未完成则为null）
    @JsonKey(name: 'ResponseTime') DateTime? responseTime,

    /// 请求方法（GET、POST等）
    @JsonKey(name: 'Method') required String method,

    /// 请求URL
    @JsonKey(name: 'Url') required String url,

    /// 请求头
    @JsonKey(name: 'RequestHeaders') Map<String, dynamic>? requestHeaders,

    /// 查询参数
    @JsonKey(name: 'QueryParameters') Map<String, dynamic>? queryParameters,

    /// 请求体（格式化后的JSON字符串）
    @JsonKey(name: 'RequestBody') String? requestBody,

    /// 响应状态码
    @JsonKey(name: 'StatusCode') int? statusCode,

    /// 响应头
    @JsonKey(name: 'ResponseHeaders') Map<String, dynamic>? responseHeaders,

    /// 响应体（格式化后的JSON字符串）
    @JsonKey(name: 'ResponseBody') String? responseBody,

    /// 错误类型（DioExceptionType）
    @JsonKey(name: 'ErrorType') String? errorType,

    /// 错误消息
    @JsonKey(name: 'ErrorMessage') String? errorMessage,

    /// 服务错误描述（从响应体中提取的业务错误信息）
    @JsonKey(name: 'ServiceErrorDesc') String? serviceErrorDesc,

    /// 请求持续时间（毫秒）
    @JsonKey(name: 'Duration') int? duration,
  }) = _NetworkLogEntry;

  /// 从 JSON 创建
  factory NetworkLogEntry.fromJson(Map<String, dynamic> json) => _$NetworkLogEntryFromJson(json);

  /// 创建新的日志条目（自动生成 requestId 和 requestTime）
  factory NetworkLogEntry.create({
    required String method,
    required String url,
    Map<String, dynamic>? requestHeaders,
    Map<String, dynamic>? queryParameters,
    String? requestBody,
  }) {
    return NetworkLogEntry(
      requestId: const Uuid().v4(),
      requestTime: DateTime.now(),
      method: method,
      url: url,
      requestHeaders: requestHeaders,
      queryParameters: queryParameters,
      requestBody: requestBody,
    );
  }

  /// 从Map创建（用于从持久化数据恢复，兼容旧版本）
  factory NetworkLogEntry.fromMap(Map<String, dynamic> map) {
    return NetworkLogEntry(
      requestId: (map['requestId'] as String?) ?? (map['request_id'] as String?) ?? const Uuid().v4(),
      requestTime: map['requestTime'] != null
          ? DateTime.parse(map['requestTime'] as String)
          : (map['request_time'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['request_time'] as int)
              : DateTime.now()),
      responseTime: map['responseTime'] != null
          ? DateTime.parse(map['responseTime'] as String)
          : (map['response_time'] != null ? DateTime.fromMillisecondsSinceEpoch(map['response_time'] as int) : null),
      method: map['method'] as String,
      url: map['url'] as String,
      requestHeaders: map['requestHeaders'] != null
          ? jsonDecode(map['requestHeaders'] as String)
          : (map['request_headers'] != null ? jsonDecode(map['request_headers'] as String) : null),
      queryParameters: map['queryParameters'] != null
          ? jsonDecode(map['queryParameters'] as String)
          : (map['query_parameters'] != null ? jsonDecode(map['query_parameters'] as String) : null),
      requestBody: map['requestBody'] as String? ?? map['request_body'] as String?,
      statusCode: map['statusCode'] as int? ?? map['status_code'] as int?,
      responseHeaders: map['responseHeaders'] != null
          ? jsonDecode(map['responseHeaders'] as String)
          : (map['response_headers'] != null ? jsonDecode(map['response_headers'] as String) : null),
      responseBody: map['responseBody'] as String? ?? map['response_body'] as String?,
      errorType: map['errorType'] as String? ?? map['error_type'] as String?,
      errorMessage: map['errorMessage'] as String? ?? map['error_message'] as String?,
      serviceErrorDesc: map['serviceErrorDesc'] as String? ?? map['service_error_desc'] as String?,
      duration: map['duration'] as int?,
    );
  }
}

/// NetworkLogEntry 扩展方法
extension NetworkLogEntryExtension on NetworkLogEntry {
  /// 是否成功
  bool get isSuccess {
    final code = statusCode;
    return code != null && code >= 200 && code < 300;
  }

  /// 是否失败
  bool get isFailed {
    final code = statusCode;
    return errorType != null || errorMessage != null || code == null || (code < 200 || code >= 300);
  }

  /// 转换为Map（用于持久化，兼容旧版本）
  Map<String, dynamic> toMap() {
    return {
      'requestId': this.requestId,
      'requestTime': this.requestTime.toIso8601String(),
      'responseTime': this.responseTime?.toIso8601String(),
      'method': this.method,
      'url': this.url,
      'requestHeaders': this.requestHeaders != null ? jsonEncode(this.requestHeaders) : null,
      'queryParameters': this.queryParameters != null ? jsonEncode(this.queryParameters) : null,
      'requestBody': this.requestBody,
      'statusCode': this.statusCode,
      'responseHeaders': this.responseHeaders != null ? jsonEncode(this.responseHeaders) : null,
      'responseBody': this.responseBody,
      'errorType': this.errorType,
      'errorMessage': this.errorMessage,
      'serviceErrorDesc': this.serviceErrorDesc,
      'duration': this.duration,
    };
  }

  /// 获取完整的请求信息（用于显示）
  String getFullRequestInfo() {
    final buffer = StringBuffer();
    buffer.writeln('┌──────────────────────────────────────────────────────────────────────────');
    buffer.writeln('│ 请求ID: ${this.requestId}');
    buffer.writeln('│ 请求时间: ${_formatDateTime(this.requestTime)}');
    buffer.writeln('│ 请求: ${this.method} ${this.url}');
    final queryParams = this.queryParameters;
    if (queryParams != null && queryParams.isNotEmpty) {
      buffer.writeln('│ 查询参数:');
      queryParams.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }
    final reqHeaders = this.requestHeaders;
    if (reqHeaders != null && reqHeaders.isNotEmpty) {
      buffer.writeln('│ 请求头:');
      reqHeaders.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }
    final reqBody = this.requestBody;
    if (reqBody != null && reqBody.isNotEmpty) {
      buffer.writeln('│ 请求体:');
      buffer.writeln('│   $reqBody');
    }
    buffer.writeln('└──────────────────────────────────────────────────────────────────────────');
    return buffer.toString();
  }

  /// 获取完整的响应信息（用于显示）
  String getFullResponseInfo() {
    final buffer = StringBuffer();
    buffer.writeln('┌──────────────────────────────────────────────────────────────────────────');
    final respTime = this.responseTime;
    if (respTime != null) {
      buffer.writeln('│ 响应时间: ${_formatDateTime(respTime)}');
    }
    final dur = this.duration;
    if (dur != null) {
      buffer.writeln('│ 耗时: ${dur}ms');
    }
    final code = this.statusCode;
    if (code != null) {
      buffer.writeln('│ 状态码: $code');
    }
    final respHeaders = this.responseHeaders;
    if (respHeaders != null && respHeaders.isNotEmpty) {
      buffer.writeln('│ 响应头:');
      respHeaders.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }
    final respBody = this.responseBody;
    if (respBody != null && respBody.isNotEmpty) {
      buffer.writeln('│ 响应体:');
      buffer.writeln('│   $respBody');
    }
    final errType = this.errorType;
    final errMsg = this.errorMessage;
    if (errType != null || errMsg != null) {
      buffer.writeln('│ 错误信息:');
      if (errType != null) {
        buffer.writeln('│   错误类型: $errType');
      }
      if (errMsg != null) {
        buffer.writeln('│   错误消息: $errMsg');
      }
      final serviceErr = this.serviceErrorDesc;
      if (serviceErr != null) {
        buffer.writeln('│   服务错误描述: $serviceErr');
      }
    }
    buffer.writeln('└──────────────────────────────────────────────────────────────────────────');
    return buffer.toString();
  }

  /// 获取完整日志（请求+响应）
  String getFullLog() {
    final buffer = StringBuffer();
    buffer.write(getFullRequestInfo());
    buffer.write('\n');
    buffer.write(getFullResponseInfo());
    return buffer.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}.'
        '${dateTime.millisecond.toString().padLeft(3, '0')}';
  }
}
