import 'dart:async';
import 'dart:collection';

import 'semaphore.dart';

/// 请求队列管理器
/// 用于控制并发数和请求间隔
class RequestQueueManager {
  /// 最大并发请求数
  final int maxConcurrentRequests;

  /// 请求最小间隔时间
  final Duration requestInterval;

  /// 请求队列
  final Queue<_QueuedRequest> _requestQueue = Queue<_QueuedRequest>();

  /// 队列处理锁
  bool _isProcessing = false;

  /// 信号量（用于控制并发数和请求间隔）
  final Semaphore _semaphore;

  /// 是否启用请求队列
  final bool enableRequestQueue;

  RequestQueueManager({
    this.maxConcurrentRequests = 6,
    this.requestInterval = const Duration(milliseconds: 100),
    this.enableRequestQueue = true,
  }) : _semaphore = Semaphore(maxConcurrentRequests, concurrentInterval: requestInterval);

  /// 执行请求
  /// [request] 请求函数
  /// [requestId] 请求标识，用于区分不同的接口（如 URL path）
  /// 相同 requestId 的请求会进行间隔控制，不同 requestId 可以并发执行
  Future<T> execute<T>(Future<T> Function() request, {String? requestId}) async {
    /// 如果未启用请求队列，直接执行请求，不进行队列管理
    if (!enableRequestQueue) {
      return request();
    }

    final completer = Completer<T>();
    _requestQueue.add(_QueuedRequest<T>(
      request: request,
      completer: completer,
      requestId: requestId ?? 'default',
    ));
    _processQueue();
    return completer.future;
  }

  /// 处理队列
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      while (_requestQueue.isNotEmpty) {
        final queuedRequest = _requestQueue.removeFirst();
        _executeRequest(queuedRequest);
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// 执行请求
  Future<void> _executeRequest<T>(_QueuedRequest<T> queuedRequest) async {
    // 使用信号量控制并发数和请求间隔
    // 只对相同 requestId 的请求进行间隔控制
    await _semaphore.acquire(queuedRequest.requestId);
    try {
      // 执行请求
      final result = await queuedRequest.request();
      queuedRequest.completer.complete(result);
    } catch (error) {
      if (!queuedRequest.completer.isCompleted) {
        queuedRequest.completer.completeError(error);
      }
    } finally {
      // 释放信号量
      _semaphore.release(queuedRequest.requestId);
      // 继续处理队列
      _processQueue();
    }
  }

  /// 获取当前活跃请求数
  int get activeRequests => _semaphore.currentCount;

  /// 获取队列长度
  int get queueLength => _requestQueue.length;

  /// 清空队列
  void clearQueue() {
    while (_requestQueue.isNotEmpty) {
      final queuedRequest = _requestQueue.removeFirst();
      if (!queuedRequest.completer.isCompleted) {
        queuedRequest.completer.completeError(
          Exception('Request queue cleared'),
        );
      }
    }
  }
}

/// 队列中的请求
class _QueuedRequest<T> {
  final Future<T> Function() request;
  final Completer<T> completer;
  final String requestId;

  _QueuedRequest({
    required this.request,
    required this.completer,
    required this.requestId,
  });
}
