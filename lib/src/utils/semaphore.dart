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
class Semaphore {
  Semaphore(this.maxCount, {this.concurrentInterval});

  final int maxCount;
  int _currentCount = 0;
  final Duration? concurrentInterval;

  /// 上次请求开始时间
  DateTime? _lastRequestStartTime;

  final List<Completer<void>> _waitQueue = [];

  /// 获取信号量
  Future<void> acquire() async {
    // 等待间隔时间（如果需要）
    await _waitForIntervalIfNeeded();

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

  /// 等待间隔时间（如果需要）
  Future<void> _waitForIntervalIfNeeded() async {
    if (concurrentInterval == null) {
      _lastRequestStartTime = DateTime.now();
      return;
    }
    // concurrentInterval必须在内部限制，超长时间不起作用
    final isValidConcurrentInterval = concurrentInterval!.isInRange(
      min: const Duration(milliseconds: 200),
      max: const Duration(seconds: 50),
    );
    if (!isValidConcurrentInterval) {
      _lastRequestStartTime = DateTime.now();
      return;
    }

    final now = DateTime.now();
    if (_lastRequestStartTime == null) {
      // 第一个请求，不需要等待
      _lastRequestStartTime = now;
      return;
    }

    final elapsed = now.difference(_lastRequestStartTime!);
    if (elapsed < concurrentInterval!) {
      // 需要等待，确保最小间隔
      final waitTime = concurrentInterval! - elapsed;
      await Future.delayed(waitTime);
    }
    _lastRequestStartTime = DateTime.now();
  }

  /// 释放信号量
  void release() {
    if (_waitQueue.isNotEmpty) {
      // 唤醒队列中的第一个等待者
      final completer = _waitQueue.removeAt(0);
      // 等待者被唤醒后，它会增加 _currentCount
      completer.complete();
    } else {
      // 没有等待者，减少计数
      _currentCount--;
    }
  }

  /// 获取当前活跃请求数
  int get currentCount => _currentCount;

  /// 获取等待队列长度
  int get waitQueueLength => _waitQueue.length;
}
