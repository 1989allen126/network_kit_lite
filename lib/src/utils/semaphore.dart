import 'dart:async';

extension _InternalDurationExtension on Duration {
  /// 判断 Duration 是否在 min 和 max 之间
  /// [min] 最小 Duration
  /// [max] 最大 Duration
  bool isInRange({required Duration min, required Duration max}) {
    return this >= min && this <= max;
  }
}

/// 信号量，用于控制并发数
/// 只针对相同接口（相同 requestId）限制连续请求，不同接口可以并发执行
class Semaphore {
  Semaphore(this.maxCount, {this.concurrentInterval});

  final int maxCount;
  int _currentCount = 0;
  final Duration? concurrentInterval;

  /// 针对不同的请求ID，记录上次请求开始时间
  /// 只对相同 requestId 的请求进行间隔控制
  final Map<String, DateTime> _lastRequestStartTimeMap = <String, DateTime>{};

  final List<Completer<void>> _waitQueue = [];

  /// 获取信号量
  /// [requestId] 请求标识，用于区分不同的接口（如 URL path）
  /// 相同 requestId 的请求会进行间隔控制，不同 requestId 可以并发执行
  Future<void> acquire(String requestId) async {
    // 等待间隔时间（只针对相同 requestId）
    await _waitForIntervalIfNeeded(requestId);

    // 尝试获取信号量
    if (_currentCount < maxCount) {
      _currentCount++;
      return;
    }

    // 如果无法获取，加入等待队列
    final completer = Completer<void>();
    _waitQueue.add(completer);
    // 等待被唤醒
    await completer.future;
    // 被唤醒后，获取信号量
    _currentCount++;
  }

  /// 等待间隔时间（只针对相同 requestId）
  /// [requestId] 请求标识
  Future<void> _waitForIntervalIfNeeded(String requestId) async {
    if (concurrentInterval == null) {
      // 记录当前请求时间
      _lastRequestStartTimeMap[requestId] = DateTime.now();
      return;
    }

    // concurrentInterval必须在内部限制，超长时间不起作用
    final isValidConcurrentInterval = concurrentInterval!.isInRange(
      min: const Duration(milliseconds: 200),
      max: const Duration(seconds: 50),
    );
    if (!isValidConcurrentInterval) {
      _lastRequestStartTimeMap[requestId] = DateTime.now();
      return;
    }

    final now = DateTime.now();
    final lastRequestTime = _lastRequestStartTimeMap[requestId];

    if (lastRequestTime == null) {
      // 该 requestId 的第一个请求，不需要等待
      _lastRequestStartTimeMap[requestId] = now;
      return;
    }

    // 计算距离上次相同接口请求的时间间隔
    final elapsed = now.difference(lastRequestTime);
    if (elapsed < concurrentInterval!) {
      // 需要等待，确保相同接口的最小间隔
      final waitTime = concurrentInterval! - elapsed;
      await Future.delayed(waitTime);
    }

    // 更新该 requestId 的上次请求时间
    _lastRequestStartTimeMap[requestId] = DateTime.now();
  }

  /// 释放信号量
  /// [requestId] 请求标识（当前未使用，保留用于未来扩展）
  void release(String requestId) {
    // 确保计数器不会小于0
    if (_currentCount <= 0) {
      return;
    }

    _currentCount--;
    if (_waitQueue.isNotEmpty) {
      // 唤醒队列中的第一个等待者
      // 等待者被唤醒后，会在 acquire() 中增加 _currentCount
      final completer = _waitQueue.removeAt(0);
      completer.complete();
    }
  }

  /// 获取当前活跃请求数
  int get currentCount => _currentCount;

  /// 获取等待队列长度
  int get waitQueueLength => _waitQueue.length;
}
