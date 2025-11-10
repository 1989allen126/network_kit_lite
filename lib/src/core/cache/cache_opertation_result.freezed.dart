// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cache_opertation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CachedResponse {
  dynamic get data => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CachedResponseCopyWith<CachedResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CachedResponseCopyWith<$Res> {
  factory $CachedResponseCopyWith(
          CachedResponse value, $Res Function(CachedResponse) then) =
      _$CachedResponseCopyWithImpl<$Res, CachedResponse>;
  @useResult
  $Res call({dynamic data, DateTime timestamp});
}

/// @nodoc
class _$CachedResponseCopyWithImpl<$Res, $Val extends CachedResponse>
    implements $CachedResponseCopyWith<$Res> {
  _$CachedResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CachedResponseImplCopyWith<$Res>
    implements $CachedResponseCopyWith<$Res> {
  factory _$$CachedResponseImplCopyWith(_$CachedResponseImpl value,
          $Res Function(_$CachedResponseImpl) then) =
      __$$CachedResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic data, DateTime timestamp});
}

/// @nodoc
class __$$CachedResponseImplCopyWithImpl<$Res>
    extends _$CachedResponseCopyWithImpl<$Res, _$CachedResponseImpl>
    implements _$$CachedResponseImplCopyWith<$Res> {
  __$$CachedResponseImplCopyWithImpl(
      _$CachedResponseImpl _value, $Res Function(_$CachedResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? timestamp = null,
  }) {
    return _then(_$CachedResponseImpl(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$CachedResponseImpl implements _CachedResponse {
  const _$CachedResponseImpl({required this.data, required this.timestamp});

  @override
  final dynamic data;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'CachedResponse(data: $data, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CachedResponseImpl &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CachedResponseImplCopyWith<_$CachedResponseImpl> get copyWith =>
      __$$CachedResponseImplCopyWithImpl<_$CachedResponseImpl>(
          this, _$identity);
}

abstract class _CachedResponse implements CachedResponse {
  const factory _CachedResponse(
      {required final dynamic data,
      required final DateTime timestamp}) = _$CachedResponseImpl;

  @override
  dynamic get data;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$CachedResponseImplCopyWith<_$CachedResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CacheOperation {
  String get id => throw _privateConstructorUsedError;
  CacheOperationType get type => throw _privateConstructorUsedError;
  String? get key => throw _privateConstructorUsedError;
  dynamic get data => throw _privateConstructorUsedError;
  Duration? get duration => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CacheOperationCopyWith<CacheOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CacheOperationCopyWith<$Res> {
  factory $CacheOperationCopyWith(
          CacheOperation value, $Res Function(CacheOperation) then) =
      _$CacheOperationCopyWithImpl<$Res, CacheOperation>;
  @useResult
  $Res call(
      {String id,
      CacheOperationType type,
      String? key,
      dynamic data,
      Duration? duration});
}

/// @nodoc
class _$CacheOperationCopyWithImpl<$Res, $Val extends CacheOperation>
    implements $CacheOperationCopyWith<$Res> {
  _$CacheOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? key = freezed,
    Object? data = freezed,
    Object? duration = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CacheOperationType,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CacheOperationImplCopyWith<$Res>
    implements $CacheOperationCopyWith<$Res> {
  factory _$$CacheOperationImplCopyWith(_$CacheOperationImpl value,
          $Res Function(_$CacheOperationImpl) then) =
      __$$CacheOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      CacheOperationType type,
      String? key,
      dynamic data,
      Duration? duration});
}

/// @nodoc
class __$$CacheOperationImplCopyWithImpl<$Res>
    extends _$CacheOperationCopyWithImpl<$Res, _$CacheOperationImpl>
    implements _$$CacheOperationImplCopyWith<$Res> {
  __$$CacheOperationImplCopyWithImpl(
      _$CacheOperationImpl _value, $Res Function(_$CacheOperationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? key = freezed,
    Object? data = freezed,
    Object? duration = freezed,
  }) {
    return _then(_$CacheOperationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CacheOperationType,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc

class _$CacheOperationImpl implements _CacheOperation {
  const _$CacheOperationImpl(
      {required this.id,
      required this.type,
      this.key,
      this.data,
      this.duration});

  @override
  final String id;
  @override
  final CacheOperationType type;
  @override
  final String? key;
  @override
  final dynamic data;
  @override
  final Duration? duration;

  @override
  String toString() {
    return 'CacheOperation(id: $id, type: $type, key: $key, data: $data, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheOperationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.key, key) || other.key == key) &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, type, key,
      const DeepCollectionEquality().hash(data), duration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheOperationImplCopyWith<_$CacheOperationImpl> get copyWith =>
      __$$CacheOperationImplCopyWithImpl<_$CacheOperationImpl>(
          this, _$identity);
}

abstract class _CacheOperation implements CacheOperation {
  const factory _CacheOperation(
      {required final String id,
      required final CacheOperationType type,
      final String? key,
      final dynamic data,
      final Duration? duration}) = _$CacheOperationImpl;

  @override
  String get id;
  @override
  CacheOperationType get type;
  @override
  String? get key;
  @override
  dynamic get data;
  @override
  Duration? get duration;
  @override
  @JsonKey(ignore: true)
  _$$CacheOperationImplCopyWith<_$CacheOperationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CacheOperationResult {
  String get operationId => throw _privateConstructorUsedError;
  CacheOperationType get type => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  dynamic get result => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CacheOperationResultCopyWith<CacheOperationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CacheOperationResultCopyWith<$Res> {
  factory $CacheOperationResultCopyWith(CacheOperationResult value,
          $Res Function(CacheOperationResult) then) =
      _$CacheOperationResultCopyWithImpl<$Res, CacheOperationResult>;
  @useResult
  $Res call(
      {String operationId,
      CacheOperationType type,
      bool success,
      dynamic result,
      String? error});
}

/// @nodoc
class _$CacheOperationResultCopyWithImpl<$Res,
        $Val extends CacheOperationResult>
    implements $CacheOperationResultCopyWith<$Res> {
  _$CacheOperationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operationId = null,
    Object? type = null,
    Object? success = null,
    Object? result = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      operationId: null == operationId
          ? _value.operationId
          : operationId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CacheOperationType,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as dynamic,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CacheOperationResultImplCopyWith<$Res>
    implements $CacheOperationResultCopyWith<$Res> {
  factory _$$CacheOperationResultImplCopyWith(_$CacheOperationResultImpl value,
          $Res Function(_$CacheOperationResultImpl) then) =
      __$$CacheOperationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String operationId,
      CacheOperationType type,
      bool success,
      dynamic result,
      String? error});
}

/// @nodoc
class __$$CacheOperationResultImplCopyWithImpl<$Res>
    extends _$CacheOperationResultCopyWithImpl<$Res, _$CacheOperationResultImpl>
    implements _$$CacheOperationResultImplCopyWith<$Res> {
  __$$CacheOperationResultImplCopyWithImpl(_$CacheOperationResultImpl _value,
      $Res Function(_$CacheOperationResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operationId = null,
    Object? type = null,
    Object? success = null,
    Object? result = freezed,
    Object? error = freezed,
  }) {
    return _then(_$CacheOperationResultImpl(
      operationId: null == operationId
          ? _value.operationId
          : operationId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CacheOperationType,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as dynamic,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CacheOperationResultImpl implements _CacheOperationResult {
  const _$CacheOperationResultImpl(
      {required this.operationId,
      required this.type,
      required this.success,
      this.result,
      this.error});

  @override
  final String operationId;
  @override
  final CacheOperationType type;
  @override
  final bool success;
  @override
  final dynamic result;
  @override
  final String? error;

  @override
  String toString() {
    return 'CacheOperationResult(operationId: $operationId, type: $type, success: $success, result: $result, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheOperationResultImpl &&
            (identical(other.operationId, operationId) ||
                other.operationId == operationId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other.result, result) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, operationId, type, success,
      const DeepCollectionEquality().hash(result), error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheOperationResultImplCopyWith<_$CacheOperationResultImpl>
      get copyWith =>
          __$$CacheOperationResultImplCopyWithImpl<_$CacheOperationResultImpl>(
              this, _$identity);
}

abstract class _CacheOperationResult implements CacheOperationResult {
  const factory _CacheOperationResult(
      {required final String operationId,
      required final CacheOperationType type,
      required final bool success,
      final dynamic result,
      final String? error}) = _$CacheOperationResultImpl;

  @override
  String get operationId;
  @override
  CacheOperationType get type;
  @override
  bool get success;
  @override
  dynamic get result;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$CacheOperationResultImplCopyWith<_$CacheOperationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
