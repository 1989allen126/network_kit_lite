import 'package:freezed_annotation/freezed_annotation.dart';

part 'cache_opertation_result.freezed.dart';

/// 缓存响应类
@freezed
class CachedResponse with _$CachedResponse {
  const factory CachedResponse({
    required dynamic data,
    required DateTime timestamp,
  }) = _CachedResponse;
}

/// 缓存操作类型
enum CacheOperationType {
  get,
  save,
  clear,
}

/// 缓存操作类
@freezed
class CacheOperation with _$CacheOperation {
  const factory CacheOperation({
    required String id,
    required CacheOperationType type,
    String? key,
    dynamic data,
    Duration? duration,
  }) = _CacheOperation;
}

/// 缓存操作结果类
@freezed
class CacheOperationResult with _$CacheOperationResult {
  const factory CacheOperationResult({
    required String operationId,
    required CacheOperationType type,
    required bool success,
    dynamic result,
    String? error,
  }) = _CacheOperationResult;
}
