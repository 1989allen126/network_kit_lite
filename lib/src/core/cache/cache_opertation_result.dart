// 缓存响应类
class CachedResponse {
  final dynamic data;
  final DateTime timestamp;

  CachedResponse({required this.data, required this.timestamp});
}

// 缓存操作类型
enum CacheOperationType {
  get,
  save,
  clear,
}

// 缓存操作类
class CacheOperation {
  final String id;
  final CacheOperationType type;
  final String? key;
  final dynamic data;
  final Duration? duration;

  CacheOperation({
    required this.id,
    required this.type,
    this.key,
    this.data,
    this.duration,
  });
}

// 缓存操作结果类
class CacheOperationResult {
  final String operationId;
  final CacheOperationType type;
  final bool success;
  final dynamic result;
  final String? error;

  CacheOperationResult(
    this.operationId,
    this.type, {
    required this.success,
    this.result,
    this.error,
  });
}
