// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'options_extra_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OptionsExtraData {
  /// 缓存策略
  CachePolicy get cachePolicy => throw _privateConstructorUsedError;

  /// 打印日志
  bool get enableLogging => throw _privateConstructorUsedError;

  /// 缓存时间
  Duration get cacheDuration => throw _privateConstructorUsedError;

  /// 重试配置
  bool get shouldRetry => throw _privateConstructorUsedError;

  /// 重试次数
  int get maxRetries => throw _privateConstructorUsedError;

  /// 是否跳过 Auth 鉴权校验导致的退出登录
  /// 当设置为 true 时，即使鉴权失败（如 401），也不会清除 token 和触发登录回调
  /// 适用于部分接口报错不影响 App 正常使用的场景
  bool get skipAuthLogout => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OptionsExtraDataCopyWith<OptionsExtraData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionsExtraDataCopyWith<$Res> {
  factory $OptionsExtraDataCopyWith(
          OptionsExtraData value, $Res Function(OptionsExtraData) then) =
      _$OptionsExtraDataCopyWithImpl<$Res, OptionsExtraData>;
  @useResult
  $Res call(
      {CachePolicy cachePolicy,
      bool enableLogging,
      Duration cacheDuration,
      bool shouldRetry,
      int maxRetries,
      bool skipAuthLogout});
}

/// @nodoc
class _$OptionsExtraDataCopyWithImpl<$Res, $Val extends OptionsExtraData>
    implements $OptionsExtraDataCopyWith<$Res> {
  _$OptionsExtraDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cachePolicy = null,
    Object? enableLogging = null,
    Object? cacheDuration = null,
    Object? shouldRetry = null,
    Object? maxRetries = null,
    Object? skipAuthLogout = null,
  }) {
    return _then(_value.copyWith(
      cachePolicy: null == cachePolicy
          ? _value.cachePolicy
          : cachePolicy // ignore: cast_nullable_to_non_nullable
              as CachePolicy,
      enableLogging: null == enableLogging
          ? _value.enableLogging
          : enableLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      cacheDuration: null == cacheDuration
          ? _value.cacheDuration
          : cacheDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      shouldRetry: null == shouldRetry
          ? _value.shouldRetry
          : shouldRetry // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      skipAuthLogout: null == skipAuthLogout
          ? _value.skipAuthLogout
          : skipAuthLogout // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OptionsExtraDataImplCopyWith<$Res>
    implements $OptionsExtraDataCopyWith<$Res> {
  factory _$$OptionsExtraDataImplCopyWith(_$OptionsExtraDataImpl value,
          $Res Function(_$OptionsExtraDataImpl) then) =
      __$$OptionsExtraDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CachePolicy cachePolicy,
      bool enableLogging,
      Duration cacheDuration,
      bool shouldRetry,
      int maxRetries,
      bool skipAuthLogout});
}

/// @nodoc
class __$$OptionsExtraDataImplCopyWithImpl<$Res>
    extends _$OptionsExtraDataCopyWithImpl<$Res, _$OptionsExtraDataImpl>
    implements _$$OptionsExtraDataImplCopyWith<$Res> {
  __$$OptionsExtraDataImplCopyWithImpl(_$OptionsExtraDataImpl _value,
      $Res Function(_$OptionsExtraDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cachePolicy = null,
    Object? enableLogging = null,
    Object? cacheDuration = null,
    Object? shouldRetry = null,
    Object? maxRetries = null,
    Object? skipAuthLogout = null,
  }) {
    return _then(_$OptionsExtraDataImpl(
      cachePolicy: null == cachePolicy
          ? _value.cachePolicy
          : cachePolicy // ignore: cast_nullable_to_non_nullable
              as CachePolicy,
      enableLogging: null == enableLogging
          ? _value.enableLogging
          : enableLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      cacheDuration: null == cacheDuration
          ? _value.cacheDuration
          : cacheDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      shouldRetry: null == shouldRetry
          ? _value.shouldRetry
          : shouldRetry // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      skipAuthLogout: null == skipAuthLogout
          ? _value.skipAuthLogout
          : skipAuthLogout // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$OptionsExtraDataImpl implements _OptionsExtraData {
  const _$OptionsExtraDataImpl(
      {this.cachePolicy = CachePolicy.networkOnly,
      this.enableLogging = true,
      this.cacheDuration = const Duration(minutes: 5),
      this.shouldRetry = false,
      this.maxRetries = 3,
      this.skipAuthLogout = false});

  /// 缓存策略
  @override
  @JsonKey()
  final CachePolicy cachePolicy;

  /// 打印日志
  @override
  @JsonKey()
  final bool enableLogging;

  /// 缓存时间
  @override
  @JsonKey()
  final Duration cacheDuration;

  /// 重试配置
  @override
  @JsonKey()
  final bool shouldRetry;

  /// 重试次数
  @override
  @JsonKey()
  final int maxRetries;

  /// 是否跳过 Auth 鉴权校验导致的退出登录
  /// 当设置为 true 时，即使鉴权失败（如 401），也不会清除 token 和触发登录回调
  /// 适用于部分接口报错不影响 App 正常使用的场景
  @override
  @JsonKey()
  final bool skipAuthLogout;

  @override
  String toString() {
    return 'OptionsExtraData(cachePolicy: $cachePolicy, enableLogging: $enableLogging, cacheDuration: $cacheDuration, shouldRetry: $shouldRetry, maxRetries: $maxRetries, skipAuthLogout: $skipAuthLogout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptionsExtraDataImpl &&
            (identical(other.cachePolicy, cachePolicy) ||
                other.cachePolicy == cachePolicy) &&
            (identical(other.enableLogging, enableLogging) ||
                other.enableLogging == enableLogging) &&
            (identical(other.cacheDuration, cacheDuration) ||
                other.cacheDuration == cacheDuration) &&
            (identical(other.shouldRetry, shouldRetry) ||
                other.shouldRetry == shouldRetry) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.skipAuthLogout, skipAuthLogout) ||
                other.skipAuthLogout == skipAuthLogout));
  }

  @override
  int get hashCode => Object.hash(runtimeType, cachePolicy, enableLogging,
      cacheDuration, shouldRetry, maxRetries, skipAuthLogout);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OptionsExtraDataImplCopyWith<_$OptionsExtraDataImpl> get copyWith =>
      __$$OptionsExtraDataImplCopyWithImpl<_$OptionsExtraDataImpl>(
          this, _$identity);
}

abstract class _OptionsExtraData implements OptionsExtraData {
  const factory _OptionsExtraData(
      {final CachePolicy cachePolicy,
      final bool enableLogging,
      final Duration cacheDuration,
      final bool shouldRetry,
      final int maxRetries,
      final bool skipAuthLogout}) = _$OptionsExtraDataImpl;

  @override

  /// 缓存策略
  CachePolicy get cachePolicy;
  @override

  /// 打印日志
  bool get enableLogging;
  @override

  /// 缓存时间
  Duration get cacheDuration;
  @override

  /// 重试配置
  bool get shouldRetry;
  @override

  /// 重试次数
  int get maxRetries;
  @override

  /// 是否跳过 Auth 鉴权校验导致的退出登录
  /// 当设置为 true 时，即使鉴权失败（如 401），也不会清除 token 和触发登录回调
  /// 适用于部分接口报错不影响 App 正常使用的场景
  bool get skipAuthLogout;
  @override
  @JsonKey(ignore: true)
  _$$OptionsExtraDataImplCopyWith<_$OptionsExtraDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
