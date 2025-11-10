// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'endpoint_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EndpointConfigImpl _$$EndpointConfigImplFromJson(Map<String, dynamic> json) =>
    _$EndpointConfigImpl(
      name: json['name'] as String,
      path: json['path'] as String,
      method: $enumDecodeNullable(_$HTTPMethodEnumMap, json['method']) ??
          HTTPMethod.get,
      module: json['module'] as String? ?? 'api',
      responseType: $enumDecodeNullable(
              _$EndpointResponseTypeEnumMap, json['responseType']) ??
          EndpointResponseType.single,
      responseModelType: json['responseModelType'] as String?,
      enableCache: json['enableCache'] as bool? ?? false,
      cachePolicy:
          $enumDecodeNullable(_$CachePolicyEnumMap, json['cachePolicy']) ??
              CachePolicy.networkOnly,
      cacheDurationMinutes:
          (json['cacheDurationMinutes'] as num?)?.toInt() ?? 5,
      enableRetry: json['enableRetry'] as bool? ?? false,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      retryDelaySeconds: (json['retryDelaySeconds'] as num?)?.toInt() ?? 1,
      connectTimeoutSeconds: (json['connectTimeoutSeconds'] as num?)?.toInt(),
      sendTimeoutSeconds: (json['sendTimeoutSeconds'] as num?)?.toInt(),
      receiveTimeoutSeconds: (json['receiveTimeoutSeconds'] as num?)?.toInt(),
      enableLogging: json['enableLogging'] as bool?,
      contentType: json['contentType'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$EndpointConfigImplToJson(
        _$EndpointConfigImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'method': _$HTTPMethodEnumMap[instance.method]!,
      'module': instance.module,
      'responseType': _$EndpointResponseTypeEnumMap[instance.responseType]!,
      'responseModelType': instance.responseModelType,
      'enableCache': instance.enableCache,
      'cachePolicy': _$CachePolicyEnumMap[instance.cachePolicy]!,
      'cacheDurationMinutes': instance.cacheDurationMinutes,
      'enableRetry': instance.enableRetry,
      'maxRetries': instance.maxRetries,
      'retryDelaySeconds': instance.retryDelaySeconds,
      'connectTimeoutSeconds': instance.connectTimeoutSeconds,
      'sendTimeoutSeconds': instance.sendTimeoutSeconds,
      'receiveTimeoutSeconds': instance.receiveTimeoutSeconds,
      'enableLogging': instance.enableLogging,
      'contentType': instance.contentType,
      'description': instance.description,
    };

const _$HTTPMethodEnumMap = {
  HTTPMethod.get: 'get',
  HTTPMethod.post: 'post',
  HTTPMethod.put: 'put',
  HTTPMethod.patch: 'patch',
  HTTPMethod.delete: 'delete',
  HTTPMethod.head: 'head',
};

const _$EndpointResponseTypeEnumMap = {
  EndpointResponseType.single: 'single',
  EndpointResponseType.list: 'list',
  EndpointResponseType.raw: 'raw',
};

const _$CachePolicyEnumMap = {
  CachePolicy.networkOnly: 'networkOnly',
  CachePolicy.cacheAndNetwork: 'cacheAndNetwork',
  CachePolicy.cacheFirst: 'cacheFirst',
  CachePolicy.cacheOnly: 'cacheOnly',
  CachePolicy.networkFirst: 'networkFirst',
};

_$EndpointConfigCollectionImpl _$$EndpointConfigCollectionImplFromJson(
        Map<String, dynamic> json) =>
    _$EndpointConfigCollectionImpl(
      name: json['name'] as String,
      endpoints: (json['endpoints'] as List<dynamic>)
          .map((e) => EndpointConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultModule: json['defaultModule'] as String? ?? 'api',
      defaultCachePolicy: $enumDecodeNullable(
              _$CachePolicyEnumMap, json['defaultCachePolicy']) ??
          CachePolicy.networkOnly,
      defaultEnableRetry: json['defaultEnableRetry'] as bool? ?? false,
      defaultMaxRetries: (json['defaultMaxRetries'] as num?)?.toInt() ?? 3,
      defaultRetryDelaySeconds:
          (json['defaultRetryDelaySeconds'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$EndpointConfigCollectionImplToJson(
        _$EndpointConfigCollectionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'endpoints': instance.endpoints,
      'defaultModule': instance.defaultModule,
      'defaultCachePolicy': _$CachePolicyEnumMap[instance.defaultCachePolicy]!,
      'defaultEnableRetry': instance.defaultEnableRetry,
      'defaultMaxRetries': instance.defaultMaxRetries,
      'defaultRetryDelaySeconds': instance.defaultRetryDelaySeconds,
    };
