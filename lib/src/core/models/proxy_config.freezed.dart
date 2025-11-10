// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proxy_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProxyConfig _$ProxyConfigFromJson(Map<String, dynamic> json) {
  return _ProxyConfig.fromJson(json);
}

/// @nodoc
mixin _$ProxyConfig {
  /// 代理主机地址
  String get host => throw _privateConstructorUsedError;

  /// 代理端口
  int get port => throw _privateConstructorUsedError;

  /// 代理类型
  ProxyType get type => throw _privateConstructorUsedError;

  /// 代理用户名（可选）
  String? get username => throw _privateConstructorUsedError;

  /// 代理密码（可选）
  String? get password => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProxyConfigCopyWith<ProxyConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyConfigCopyWith<$Res> {
  factory $ProxyConfigCopyWith(
          ProxyConfig value, $Res Function(ProxyConfig) then) =
      _$ProxyConfigCopyWithImpl<$Res, ProxyConfig>;
  @useResult
  $Res call(
      {String host,
      int port,
      ProxyType type,
      String? username,
      String? password});
}

/// @nodoc
class _$ProxyConfigCopyWithImpl<$Res, $Val extends ProxyConfig>
    implements $ProxyConfigCopyWith<$Res> {
  _$ProxyConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? port = null,
    Object? type = null,
    Object? username = freezed,
    Object? password = freezed,
  }) {
    return _then(_value.copyWith(
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxyType,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyConfigImplCopyWith<$Res>
    implements $ProxyConfigCopyWith<$Res> {
  factory _$$ProxyConfigImplCopyWith(
          _$ProxyConfigImpl value, $Res Function(_$ProxyConfigImpl) then) =
      __$$ProxyConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String host,
      int port,
      ProxyType type,
      String? username,
      String? password});
}

/// @nodoc
class __$$ProxyConfigImplCopyWithImpl<$Res>
    extends _$ProxyConfigCopyWithImpl<$Res, _$ProxyConfigImpl>
    implements _$$ProxyConfigImplCopyWith<$Res> {
  __$$ProxyConfigImplCopyWithImpl(
      _$ProxyConfigImpl _value, $Res Function(_$ProxyConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? port = null,
    Object? type = null,
    Object? username = freezed,
    Object? password = freezed,
  }) {
    return _then(_$ProxyConfigImpl(
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxyType,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyConfigImpl implements _ProxyConfig {
  const _$ProxyConfigImpl(
      {required this.host,
      required this.port,
      this.type = ProxyType.http,
      this.username,
      this.password});

  factory _$ProxyConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyConfigImplFromJson(json);

  /// 代理主机地址
  @override
  final String host;

  /// 代理端口
  @override
  final int port;

  /// 代理类型
  @override
  @JsonKey()
  final ProxyType type;

  /// 代理用户名（可选）
  @override
  final String? username;

  /// 代理密码（可选）
  @override
  final String? password;

  @override
  String toString() {
    return 'ProxyConfig(host: $host, port: $port, type: $type, username: $username, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyConfigImpl &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, host, port, type, username, password);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyConfigImplCopyWith<_$ProxyConfigImpl> get copyWith =>
      __$$ProxyConfigImplCopyWithImpl<_$ProxyConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyConfigImplToJson(
      this,
    );
  }
}

abstract class _ProxyConfig implements ProxyConfig {
  const factory _ProxyConfig(
      {required final String host,
      required final int port,
      final ProxyType type,
      final String? username,
      final String? password}) = _$ProxyConfigImpl;

  factory _ProxyConfig.fromJson(Map<String, dynamic> json) =
      _$ProxyConfigImpl.fromJson;

  @override

  /// 代理主机地址
  String get host;
  @override

  /// 代理端口
  int get port;
  @override

  /// 代理类型
  ProxyType get type;
  @override

  /// 代理用户名（可选）
  String? get username;
  @override

  /// 代理密码（可选）
  String? get password;
  @override
  @JsonKey(ignore: true)
  _$$ProxyConfigImplCopyWith<_$ProxyConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
