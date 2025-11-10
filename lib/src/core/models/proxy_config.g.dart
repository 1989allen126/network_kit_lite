// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProxyConfigImpl _$$ProxyConfigImplFromJson(Map<String, dynamic> json) =>
    _$ProxyConfigImpl(
      host: json['host'] as String,
      port: (json['port'] as num).toInt(),
      type: $enumDecodeNullable(_$ProxyTypeEnumMap, json['type']) ??
          ProxyType.http,
      username: json['username'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$$ProxyConfigImplToJson(_$ProxyConfigImpl instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'type': _$ProxyTypeEnumMap[instance.type]!,
      'username': instance.username,
      'password': instance.password,
    };

const _$ProxyTypeEnumMap = {
  ProxyType.http: 'http',
  ProxyType.https: 'https',
  ProxyType.socks5: 'socks5',
};
