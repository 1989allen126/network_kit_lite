import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络连接状态枚举
enum NetworkConnectivityStatus {
  none, // 无网络
  wifi, // WiFi连接
  mobile, // 移动网络
  ethernet, // 以太网
  bluetooth, // 蓝牙
  vpn, // VPN
  other, // 其他
  unknown, // 未知
}

/// 网络连接检测工具类
/// 使用 connectivity_plus 进行网络状态检测和监听
class NetworkConnectivity {
  static final NetworkConnectivity _instance = NetworkConnectivity._internal();
  factory NetworkConnectivity() => _instance;
  NetworkConnectivity._internal();

  /// 当前网络状态
  NetworkConnectivityStatus _currentStatus = NetworkConnectivityStatus.unknown;

  /// 网络状态变化流控制器
  final StreamController<NetworkConnectivityStatus> _statusController =
      StreamController<NetworkConnectivityStatus>.broadcast();

  /// 网络状态变化流
  Stream<NetworkConnectivityStatus> get onConnectivityChanged => _statusController.stream;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化网络监听
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // 获取初始网络状态
      final initialResults = await Connectivity().checkConnectivity();
      _currentStatus = _convertConnectivityResults(initialResults);

      // 监听网络状态变化
      Connectivity().onConnectivityChanged.listen((results) {
        final newStatus = _convertConnectivityResults(results);
        if (newStatus != _currentStatus) {
          _currentStatus = newStatus;
          _statusController.add(newStatus);

          if (kDebugMode) {
            print('🌐 网络状态变化: ${_getStatusDescription(_currentStatus)}');
          }
        }
      });

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ 网络监听初始化完成，当前状态: ${_getStatusDescription(_currentStatus)}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 网络监听初始化失败: $e');
      }
      _currentStatus = NetworkConnectivityStatus.unknown;
    }
  }

  /// 检查网络是否可用（基于监听的状态 + 实际连接测试）
  Future<bool> isNetworkAvailable({Duration timeout = const Duration(seconds: 3)}) async {
    await _initialize();

    // 首先检查当前网络状态
    if (_currentStatus == NetworkConnectivityStatus.none) {
      if (kDebugMode) {
        print('⚠️ 网络连接状态: 无网络连接');
      }
      return false;
    }

    // 然后进行实际的网络连接测试
    return await _testNetworkConnectivity(timeout: timeout);
  }

  /// 鲁棒性网络可用性检查
  Future<bool> isNetworkAvailableRobust({Duration timeout = const Duration(seconds: 5)}) async {
    await _initialize();

    // 检查网络状态
    if (_currentStatus == NetworkConnectivityStatus.none) {
      return false;
    }

    // 进行多次连接测试以提高可靠性
    for (int i = 0; i < 3; i++) {
      if (await _testNetworkConnectivity(timeout: timeout)) {
        return true;
      }

      // 短暂延迟后重试
      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return false;
  }

  /// 测试网络连接性
  Future<bool> testHostConnectivity(String host, {Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final result = await InternetAddress.lookup(host).timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 主机连接测试失败 ($host): $e');
      }
      return false;
    }
  }

  /// 获取当前网络状态
  Future<NetworkConnectivityStatus> getNetworkStatus() async {
    await _initialize();
    return _currentStatus;
  }

  /// 检查是否为移动网络
  Future<bool> isMobileNetwork() async {
    await _initialize();
    return _currentStatus == NetworkConnectivityStatus.mobile;
  }

  /// 检查是否为WiFi网络
  Future<bool> isWifiNetwork() async {
    await _initialize();
    return _currentStatus == NetworkConnectivityStatus.wifi;
  }

  /// 检查是否为VPN网络
  Future<bool> isVpnNetwork() async {
    await _initialize();
    return _currentStatus == NetworkConnectivityStatus.vpn;
  }

  /// 检查是否为以太网
  Future<bool> isEthernetNetwork() async {
    await _initialize();
    return _currentStatus == NetworkConnectivityStatus.ethernet;
  }

  /// 检查是否为蓝牙网络
  Future<bool> isBluetoothNetwork() async {
    await _initialize();
    return _currentStatus == NetworkConnectivityStatus.bluetooth;
  }

  /// 检查是否无网络连接
  Future<bool> isNoNetwork() async {
    await _initialize();
    return _currentStatus == NetworkConnectivityStatus.none;
  }

  /// 检查是否有网络连接
  Future<bool> hasNetworkConnection() async {
    await _initialize();
    return _currentStatus != NetworkConnectivityStatus.none;
  }

  /// 获取网络类型描述
  String getNetworkTypeDescription(NetworkConnectivityStatus status) {
    switch (status) {
      case NetworkConnectivityStatus.none:
        return '无网络连接';
      case NetworkConnectivityStatus.wifi:
        return 'WiFi网络';
      case NetworkConnectivityStatus.mobile:
        return '移动网络';
      case NetworkConnectivityStatus.ethernet:
        return '以太网';
      case NetworkConnectivityStatus.bluetooth:
        return '蓝牙网络';
      case NetworkConnectivityStatus.vpn:
        return 'VPN网络';
      case NetworkConnectivityStatus.other:
        return '其他网络';
      case NetworkConnectivityStatus.unknown:
        return '未知网络';
    }
  }

  /// 获取当前网络类型描述
  String getCurrentNetworkTypeDescription() {
    return getNetworkTypeDescription(_currentStatus);
  }

  /// 实际网络连接测试
  Future<bool> _testNetworkConnectivity({Duration timeout = const Duration(seconds: 3)}) async {
    // 测试多个可靠的域名
    final testHosts = ['google.com', 'cloudflare.com', 'baidu.com'];

    for (final host in testHosts) {
      if (await testHostConnectivity(host, timeout: timeout)) {
        return true;
      }
    }

    return false;
  }

  /// 转换单个 ConnectivityResult 为 NetworkConnectivityStatus
  NetworkConnectivityStatus _convertConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        return NetworkConnectivityStatus.none;
      case ConnectivityResult.wifi:
        return NetworkConnectivityStatus.wifi;
      case ConnectivityResult.mobile:
        return NetworkConnectivityStatus.mobile;
      case ConnectivityResult.ethernet:
        return NetworkConnectivityStatus.ethernet;
      case ConnectivityResult.bluetooth:
        return NetworkConnectivityStatus.bluetooth;
      case ConnectivityResult.vpn:
        return NetworkConnectivityStatus.vpn;
      case ConnectivityResult.other:
        return NetworkConnectivityStatus.other;
    }
  }

  /// 处理 List<ConnectivityResult> 并返回主要网络状态
  NetworkConnectivityStatus _convertConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return NetworkConnectivityStatus.none;
    }

    // 过滤掉none，只保留有效的网络连接
    final validResults = results.where((result) => result != ConnectivityResult.none).toList();

    if (validResults.isEmpty) {
      return NetworkConnectivityStatus.none;
    }

    // 如果有多个有效连接，按优先级返回
    // 优先级：VPN > WiFi > 以太网 > 移动网络 > 蓝牙 > 其他
    if (validResults.contains(ConnectivityResult.vpn)) {
      return NetworkConnectivityStatus.vpn;
    }
    if (validResults.contains(ConnectivityResult.wifi)) {
      return NetworkConnectivityStatus.wifi;
    }
    if (validResults.contains(ConnectivityResult.ethernet)) {
      return NetworkConnectivityStatus.ethernet;
    }
    if (validResults.contains(ConnectivityResult.mobile)) {
      return NetworkConnectivityStatus.mobile;
    }
    if (validResults.contains(ConnectivityResult.bluetooth)) {
      return NetworkConnectivityStatus.bluetooth;
    }
    if (validResults.contains(ConnectivityResult.other)) {
      return NetworkConnectivityStatus.other;
    }

    // 如果都不匹配，返回第一个有效结果
    return _convertConnectivityResult(validResults.first);
  }

  /// 获取状态描述（用于调试）
  String _getStatusDescription(NetworkConnectivityStatus status) {
    return getNetworkTypeDescription(status);
  }
}
