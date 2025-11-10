import 'dart:async';
import 'package:network_kit_lite/src/core/logging/network_log_database.dart';
import 'package:network_kit_lite/src/core/models/network_log_entry.dart';

/// 网络日志管理器
/// 负责存储、查询、过滤网络请求日志
class NetworkLogManager {
  static final NetworkLogManager _instance = NetworkLogManager._internal();
  factory NetworkLogManager() => _instance;
  NetworkLogManager._internal();

  /// SQLite 数据库
  final NetworkLogDatabase _database = NetworkLogDatabase();

  /// 日志存储队列（最近的在末尾，用于内存缓存）
  final List<NetworkLogEntry> _logQueue = [];

  /// 活跃请求映射（requestId -> NetworkLogEntry）
  final Map<String, NetworkLogEntry> _activeLogs = {};

  /// 日志流控制器
  final StreamController<NetworkLogEntry> _logStreamController = StreamController<NetworkLogEntry>.broadcast();

  /// 是否启用日志记录
  bool _isEnabled = true;

  /// 是否启用本地持久化（SQLite）
  bool _isPersistenceEnabled = true;

  /// 最大保存的日志数量（内存缓存）
  int _maxLogSize = 500;

  /// 是否已初始化数据库
  bool _isDatabaseInitialized = false;

  /// 日志流
  Stream<NetworkLogEntry> get logStream => _logStreamController.stream;

  /// 是否启用日志记录
  bool get isEnabled => _isEnabled;

  /// 设置是否启用日志记录
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// 是否启用本地持久化
  bool get isPersistenceEnabled => _isPersistenceEnabled;

  /// 设置是否启用本地持久化
  Future<void> setPersistenceEnabled(bool enabled) async {
    _isPersistenceEnabled = enabled;
    if (enabled && !_isDatabaseInitialized) {
      await _database.init();
      _isDatabaseInitialized = true;
    }
  }

  /// 初始化数据库（如果需要）
  Future<void> ensureDatabaseInitialized() async {
    if (!_isDatabaseInitialized && _isPersistenceEnabled) {
      await _database.init();
      _isDatabaseInitialized = true;
    }
  }

  /// 获取最大日志数量
  int get maxLogSize => _maxLogSize;

  /// 设置最大日志数量
  void setMaxLogSize(int size) {
    _maxLogSize = size;
    // 如果当前日志数量超过新的大小限制，删除最旧的日志（仅内存缓存）
    while (_logQueue.length > _maxLogSize) {
      _logQueue.removeAt(0);
    }
  }

  /// 开始记录请求
  /// 返回requestId，用于后续更新日志
  String startLog({
    required String method,
    required String url,
    Map<String, dynamic>? requestHeaders,
    Map<String, dynamic>? queryParameters,
    String? requestBody,
  }) {
    if (!_isEnabled) return '';

    final requestId = '${DateTime.now().millisecondsSinceEpoch}_${url.hashCode}';
    final requestTime = DateTime.now();

    final logEntry = NetworkLogEntry(
      requestId: requestId,
      requestTime: requestTime,
      method: method,
      url: url,
      requestHeaders: requestHeaders,
      queryParameters: queryParameters,
      requestBody: requestBody,
    );

    _activeLogs[requestId] = logEntry;
    return requestId;
  }

  /// 更新响应日志
  void updateLog({
    required String requestId,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    String? responseBody,
    String? serviceErrorDesc,
  }) {
    if (!_isEnabled || requestId.isEmpty) return;

    final activeLog = _activeLogs.remove(requestId);
    if (activeLog == null) return;

    final responseTime = DateTime.now();
    final duration = responseTime.difference(activeLog.requestTime).inMilliseconds;

    final completedLog = NetworkLogEntry(
      requestId: activeLog.requestId,
      requestTime: activeLog.requestTime,
      responseTime: responseTime,
      method: activeLog.method,
      url: activeLog.url,
      requestHeaders: activeLog.requestHeaders,
      queryParameters: activeLog.queryParameters,
      requestBody: activeLog.requestBody,
      statusCode: statusCode,
      responseHeaders: responseHeaders,
      responseBody: responseBody,
      serviceErrorDesc: serviceErrorDesc,
      duration: duration,
    );

    // 添加到队列
    _addToQueue(completedLog);

    // 发送事件
    _logStreamController.add(completedLog);

    // 如果启用持久化，保存到SQLite
    if (_isPersistenceEnabled) {
      ensureDatabaseInitialized().then((_) {
        _database.insertLog(completedLog).catchError((e) {
        });
      });
    }
  }

  /// 更新错误日志
  void updateLogError({
    required String requestId,
    String? errorType,
    String? errorMessage,
    int? statusCode,
    Map<String, dynamic>? responseHeaders,
    String? responseBody,
    String? serviceErrorDesc,
  }) {
    if (!_isEnabled || requestId.isEmpty) return;

    final activeLog = _activeLogs.remove(requestId);
    if (activeLog == null) return;

    final responseTime = DateTime.now();
    final duration = responseTime.difference(activeLog.requestTime).inMilliseconds;

    final completedLog = NetworkLogEntry(
      requestId: activeLog.requestId,
      requestTime: activeLog.requestTime,
      responseTime: responseTime,
      method: activeLog.method,
      url: activeLog.url,
      requestHeaders: activeLog.requestHeaders,
      queryParameters: activeLog.queryParameters,
      requestBody: activeLog.requestBody,
      statusCode: statusCode,
      responseHeaders: responseHeaders,
      responseBody: responseBody,
      errorType: errorType,
      errorMessage: errorMessage,
      serviceErrorDesc: serviceErrorDesc,
      duration: duration,
    );

    // 添加到队列
    _addToQueue(completedLog);

    // 发送事件
    _logStreamController.add(completedLog);

    // 如果启用持久化，保存到SQLite
    if (_isPersistenceEnabled) {
      ensureDatabaseInitialized().then((_) {
        _database.insertLog(completedLog).catchError((e) {
        });
      });
    }
  }

  /// 添加到内存队列
  void _addToQueue(NetworkLogEntry logEntry) {
    _logQueue.add(logEntry);

    // 保持队列大小限制
    while (_logQueue.length > _maxLogSize) {
      _logQueue.removeAt(0);
    }
  }

  /// 获取所有日志（按时间倒序，最新的在前）
  Future<List<NetworkLogEntry>> getAllLogs({int? limit}) async {
    if (_isPersistenceEnabled) {
      await ensureDatabaseInitialized();
      return await _database.queryLogs(limit: limit);
    }
    final logs = _logQueue.reversed.toList();
    if (limit != null && limit < logs.length) {
      return logs.sublist(0, limit);
    }
    return logs;
  }

  /// 根据条件过滤日志
  Future<List<NetworkLogEntry>> filterLogs({
    String? method,
    String? urlContains,
    int? statusCode,
    bool? isSuccess,
    bool? isFailed,
    DateTime? startTime,
    DateTime? endTime,
    int? year,
    int? month,
    int? day,
    int? hour,
    int? limit,
  }) async {
    // 如果启用持久化，从数据库查询
    if (_isPersistenceEnabled) {
      await ensureDatabaseInitialized();
      return await _database.queryLogs(
        method: method,
        urlContains: urlContains,
        statusCode: statusCode,
        isSuccess: isSuccess,
        isFailed: isFailed,
        startTime: startTime,
        endTime: endTime,
        year: year,
        month: month,
        day: day,
        hour: hour,
        limit: limit,
      );
    }

    // 否则从内存队列查询
    var logs = _logQueue.reversed.toList();

    if (method != null && method != '全部') {
      logs = logs.where((log) => log.method == method).toList();
    }

    if (urlContains != null && urlContains.isNotEmpty) {
      logs = logs.where((log) => log.url.toLowerCase().contains(urlContains.toLowerCase())).toList();
    }

    if (statusCode != null) {
      logs = logs.where((log) => log.statusCode == statusCode).toList();
    }

    if (isSuccess == true) {
      logs = logs.where((log) => log.isSuccess).toList();
    }

    if (isFailed == true) {
      logs = logs.where((log) => log.isFailed).toList();
    }

    if (startTime != null) {
      logs = logs
          .where((log) => log.requestTime.isAfter(startTime) || log.requestTime.isAtSameMomentAs(startTime))
          .toList();
    }

    if (endTime != null) {
      logs =
          logs.where((log) => log.requestTime.isBefore(endTime) || log.requestTime.isAtSameMomentAs(endTime)).toList();
    }

    // 按年月日时过滤（内存查询）
    if (year != null) {
      logs = logs.where((log) => log.requestTime.year == year).toList();
    }

    if (month != null) {
      logs = logs.where((log) => log.requestTime.month == month).toList();
    }

    if (day != null) {
      logs = logs.where((log) => log.requestTime.day == day).toList();
    }

    if (hour != null) {
      logs = logs.where((log) => log.requestTime.hour == hour).toList();
    }

    if (limit != null && limit < logs.length) {
      logs = logs.sublist(0, limit);
    }

    return logs;
  }

  /// 根据URL路径分组
  /// 返回Map<路径, 日志列表>
  Future<Map<String, List<NetworkLogEntry>>> groupLogsByPath() async {
    final grouped = <String, List<NetworkLogEntry>>{};
    final logs = _isPersistenceEnabled ? await getAllLogs() : _logQueue.reversed.toList();

    for (final log in logs) {
      try {
        final uri = Uri.parse(log.url);
        final path = uri.path;
        if (!grouped.containsKey(path)) {
          grouped[path] = <NetworkLogEntry>[];
        }
        grouped[path]!.add(log);
      } catch (e) {
        // 如果URL解析失败，使用完整URL作为key
        if (!grouped.containsKey(log.url)) {
          grouped[log.url] = <NetworkLogEntry>[];
        }
        grouped[log.url]!.add(log);
      }
    }

    return grouped;
  }

  /// 清除所有日志
  Future<void> clearAllLogs() async {
    _logQueue.clear();
    _activeLogs.clear();

    if (_isPersistenceEnabled) {
      await ensureDatabaseInitialized();
      await _database.clearAllLogs();
    }
  }

  /// 根据ID获取日志
  NetworkLogEntry? getLogById(String requestId) {
    // 先在历史记录中查找
    final historyLog = _logQueue.where((log) => log.requestId == requestId).toList();
    if (historyLog.isNotEmpty) {
      return historyLog.last;
    }

    // 再在活跃请求中查找
    return _activeLogs[requestId];
  }

  /// 销毁管理器
  void dispose() {
    _logStreamController.close();
    _logQueue.clear();
    _activeLogs.clear();
  }
}
