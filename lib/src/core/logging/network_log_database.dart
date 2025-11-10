import 'dart:async';
import 'dart:convert';

import 'package:network_kit_lite/src/core/models/network_log_entry.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 网络日志数据库
class NetworkLogDatabase {
  static final NetworkLogDatabase _instance = NetworkLogDatabase._internal();
  factory NetworkLogDatabase() => _instance;
  NetworkLogDatabase._internal();

  static const String _tableName = 'network_logs';
  static const String _dbName = 'network_logs.db';
  static const int _dbVersion = 1;
  Database? _database;

  /// 初始化数据库
  Future<void> init() async {
    if (_database != null) return;

    final dbPath = join(await getDatabasesPath(), _dbName);
    _database = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            requestId TEXT UNIQUE NOT NULL,
            method TEXT NOT NULL,
            url TEXT NOT NULL,
            requestTime INTEGER NOT NULL,
            responseTime INTEGER,
            requestHeaders TEXT,
            queryParameters TEXT,
            requestBody TEXT,
            statusCode INTEGER,
            responseHeaders TEXT,
            responseBody TEXT,
            errorType TEXT,
            errorMessage TEXT,
            serviceErrorDesc TEXT,
            duration INTEGER,
            fullRequest TEXT,
            fullResponse TEXT,
            createdAt INTEGER DEFAULT (strftime('%s', 'now'))
          )
        ''');

        // 创建索引以提高查询性能
        await db.execute('''
          CREATE INDEX idx_request_time ON $_tableName(requestTime)
        ''');
        await db.execute('''
          CREATE INDEX idx_method ON $_tableName(method)
        ''');
        await db.execute('''
          CREATE INDEX idx_status_code ON $_tableName(statusCode)
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 数据库版本升级逻辑
      },
    );
  }

  /// 关闭数据库
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  /// 插入日志
  Future<void> insertLog(NetworkLogEntry log) async {
    final db = _database;
    if (db == null) {
      await init();
      return insertLog(log);
    }

    try {
      final fullRequest = log.getFullRequestInfo();
      final fullResponse = log.getFullResponseInfo();

      await db.insert(
        _tableName,
        {
          'requestId': log.requestId,
          'method': log.method,
          'url': log.url,
          'requestTime': log.requestTime.millisecondsSinceEpoch,
          'responseTime': log.responseTime?.millisecondsSinceEpoch,
          'requestHeaders': log.requestHeaders != null ? jsonEncode(log.requestHeaders) : null,
          'queryParameters': log.queryParameters != null ? jsonEncode(log.queryParameters) : null,
          'requestBody': log.requestBody,
          'statusCode': log.statusCode,
          'responseHeaders': log.responseHeaders != null ? jsonEncode(log.responseHeaders) : null,
          'responseBody': log.responseBody,
          'errorType': log.errorType,
          'errorMessage': log.errorMessage,
          'serviceErrorDesc': log.serviceErrorDesc,
          'duration': log.duration,
          'fullRequest': fullRequest,
          'fullResponse': fullResponse,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('[NetworkLogDatabase] 插入日志失败: $e');
      rethrow;
    }
  }

  /// 查询日志
  Future<List<NetworkLogEntry>> queryLogs({
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
    int? offset,
  }) async {
    final db = _database;
    if (db == null) {
      await init();
      return queryLogs(
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
        offset: offset,
      );
    }

    try {
      final where = <String>[];
      final whereArgs = <dynamic>[];

      if (method != null && method != '全部') {
        where.add('method = ?');
        whereArgs.add(method);
      }

      if (urlContains != null && urlContains.isNotEmpty) {
        where.add('url LIKE ?');
        whereArgs.add('%$urlContains%');
      }

      if (statusCode != null) {
        where.add('statusCode = ?');
        whereArgs.add(statusCode);
      }

      if (isSuccess == true) {
        where.add('statusCode >= 200 AND statusCode < 300');
      }

      if (isFailed == true) {
        where.add('(statusCode IS NULL OR statusCode < 200 OR statusCode >= 300 OR errorType IS NOT NULL OR errorMessage IS NOT NULL)');
      }

      // 时间范围过滤
      if (startTime != null) {
        where.add('requestTime >= ?');
        whereArgs.add(startTime.millisecondsSinceEpoch);
      }

      if (endTime != null) {
        where.add('requestTime <= ?');
        whereArgs.add(endTime.millisecondsSinceEpoch);
      }

      // 按年月日时过滤
      if (year != null) {
        final yearStart = DateTime(year, 1, 1);
        final yearEnd = DateTime(year + 1, 1, 1);
        where.add('requestTime >= ? AND requestTime < ?');
        whereArgs.add(yearStart.millisecondsSinceEpoch);
        whereArgs.add(yearEnd.millisecondsSinceEpoch);
      }

      if (month != null) {
        final now = DateTime.now();
        final monthStart = DateTime(year ?? now.year, month, 1);
        final monthEnd =
            month == 12 ? DateTime((year ?? now.year) + 1, 1, 1) : DateTime(year ?? now.year, month + 1, 1);
        where.add('requestTime >= ? AND requestTime < ?');
        whereArgs.add(monthStart.millisecondsSinceEpoch);
        whereArgs.add(monthEnd.millisecondsSinceEpoch);
      }

      if (day != null) {
        final now = DateTime.now();
        final dayStart = DateTime(
          year ?? now.year,
          month ?? now.month,
          day,
        );
        final dayEnd = dayStart.add(const Duration(days: 1));
        where.add('requestTime >= ? AND requestTime < ?');
        whereArgs.add(dayStart.millisecondsSinceEpoch);
        whereArgs.add(dayEnd.millisecondsSinceEpoch);
      }

      if (hour != null) {
        final now = DateTime.now();
        final hourStart = DateTime(
          year ?? now.year,
          month ?? now.month,
          day ?? now.day,
          hour,
        );
        final hourEnd = hourStart.add(const Duration(hours: 1));
        where.add('requestTime >= ? AND requestTime < ?');
        whereArgs.add(hourStart.millisecondsSinceEpoch);
        whereArgs.add(hourEnd.millisecondsSinceEpoch);
      }

      final results = await db.query(
        _tableName,
        where: where.isNotEmpty ? where.join(' AND ') : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'requestTime DESC',
        limit: limit,
        offset: offset,
      );

      return results.map((map) => _mapToLogEntry(map)).toList();
    } catch (e) {
      print('[NetworkLogDatabase] 查询日志失败: $e');
      return [];
    }
  }

  /// 从数据库Map转换为NetworkLogEntry
  NetworkLogEntry _mapToLogEntry(Map<String, dynamic> map) {
    return NetworkLogEntry(
      requestId: map['requestId'] as String,
      requestTime: DateTime.fromMillisecondsSinceEpoch(map['requestTime'] as int),
      responseTime:
          map['responseTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['responseTime'] as int) : null,
      method: map['method'] as String,
      url: map['url'] as String,
      requestHeaders: map['requestHeaders'] != null ? jsonDecode(map['requestHeaders'] as String) : null,
      queryParameters: map['queryParameters'] != null ? jsonDecode(map['queryParameters'] as String) : null,
      requestBody: map['requestBody'] as String?,
      statusCode: map['statusCode'] as int?,
      responseHeaders: map['responseHeaders'] != null ? jsonDecode(map['responseHeaders'] as String) : null,
      responseBody: map['responseBody'] as String?,
      errorType: map['errorType'] as String?,
      errorMessage: map['errorMessage'] as String?,
      serviceErrorDesc: map['serviceErrorDesc'] as String?,
      duration: map['duration'] as int?,
    );
  }

  /// 删除日志
  Future<void> deleteLog(String requestId) async {
    final db = _database;
    if (db == null) {
      await init();
      return deleteLog(requestId);
    }

    await db.delete(
      _tableName,
      where: 'requestId = ?',
      whereArgs: [requestId],
    );
  }

  /// 清空所有日志
  Future<void> clearAllLogs() async {
    final db = _database;
    if (db == null) {
      await init();
      return clearAllLogs();
    }

    await db.delete(_tableName);
  }

  /// 删除旧日志（保留最近N条）
  Future<void> deleteOldLogs(int keepCount) async {
    final db = _database;
    if (db == null) {
      await init();
      return deleteOldLogs(keepCount);
    }

    await db.execute('''
      DELETE FROM $_tableName
      WHERE id NOT IN (
        SELECT id FROM $_tableName
        ORDER BY requestTime DESC
        LIMIT ?
      )
    ''', [keepCount]);
  }

  /// 获取日志总数
  Future<int> getLogCount({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = _database;
    if (db == null) {
      await init();
      return getLogCount(startTime: startTime, endTime: endTime);
    }

    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (startTime != null) {
      where.add('requestTime >= ?');
      whereArgs.add(startTime.millisecondsSinceEpoch);
    }

    if (endTime != null) {
      where.add('requestTime <= ?');
      whereArgs.add(endTime.millisecondsSinceEpoch);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName ${where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : ''}',
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
