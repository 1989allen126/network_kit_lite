// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NetworkLogEntryImpl _$$NetworkLogEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$NetworkLogEntryImpl(
      requestId: json['RequestId'] as String,
      requestTime: DateTime.parse(json['RequestTime'] as String),
      responseTime: json['ResponseTime'] == null
          ? null
          : DateTime.parse(json['ResponseTime'] as String),
      method: json['Method'] as String,
      url: json['Url'] as String,
      requestHeaders: json['RequestHeaders'] as Map<String, dynamic>?,
      queryParameters: json['QueryParameters'] as Map<String, dynamic>?,
      requestBody: json['RequestBody'] as String?,
      statusCode: (json['StatusCode'] as num?)?.toInt(),
      responseHeaders: json['ResponseHeaders'] as Map<String, dynamic>?,
      responseBody: json['ResponseBody'] as String?,
      errorType: json['ErrorType'] as String?,
      errorMessage: json['ErrorMessage'] as String?,
      serviceErrorDesc: json['ServiceErrorDesc'] as String?,
      duration: (json['Duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$NetworkLogEntryImplToJson(
        _$NetworkLogEntryImpl instance) =>
    <String, dynamic>{
      'RequestId': instance.requestId,
      'RequestTime': instance.requestTime.toIso8601String(),
      'ResponseTime': instance.responseTime?.toIso8601String(),
      'Method': instance.method,
      'Url': instance.url,
      'RequestHeaders': instance.requestHeaders,
      'QueryParameters': instance.queryParameters,
      'RequestBody': instance.requestBody,
      'StatusCode': instance.statusCode,
      'ResponseHeaders': instance.responseHeaders,
      'ResponseBody': instance.responseBody,
      'ErrorType': instance.errorType,
      'ErrorMessage': instance.errorMessage,
      'ServiceErrorDesc': instance.serviceErrorDesc,
      'Duration': instance.duration,
    };
