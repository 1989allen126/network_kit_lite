import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import '../models/endpoint_config.dart';
import 'endpoint_factory.dart';

/// Endpoint 注册表
/// 管理所有配置化的 Endpoint
class EndpointRegistry {
  static final EndpointRegistry _instance = EndpointRegistry._internal();
  factory EndpointRegistry() => _instance;
  EndpointRegistry._internal();

  /// Endpoint 配置映射
  final Map<String, EndpointConfig> _configs = {};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化注册表
  /// [configs] Endpoint 配置列表
  Future<void> initialize(List<EndpointConfig> configs) async {
    if (_isInitialized) return;

    for (final config in configs) {
      _configs[config.name] = config;
    }

    _isInitialized = true;
  }

  /// 从 JSON 文件加载配置
  /// [assetPath] JSON 文件路径（相对于 assets）
  Future<void> loadFromJson(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> json = jsonDecode(jsonString);

      if (json.containsKey('endpoints')) {
        final List<dynamic> endpointsJson = json['endpoints'] as List<dynamic>;
        final List<EndpointConfig> configs = endpointsJson
            .map((e) => EndpointConfig.fromJson(e as Map<String, dynamic>))
            .toList();
        await initialize(configs);
      } else if (json.containsKey('name') && json.containsKey('endpoints')) {
        // 如果是 EndpointConfigCollection
        final collection = EndpointConfigCollection.fromJson(json);
        await initialize(collection.endpoints);
      }
    } catch (e) {
      throw Exception('Failed to load endpoint configs from $assetPath: $e');
    }
  }

  /// 注册 Endpoint 配置
  void register(EndpointConfig config) {
    _configs[config.name] = config;
  }

  /// 批量注册 Endpoint 配置
  void registerAll(List<EndpointConfig> configs) {
    for (final config in configs) {
      _configs[config.name] = config;
    }
  }

  /// 获取 Endpoint 配置
  EndpointConfig? getConfig(String name) {
    return _configs[name];
  }

  /// 创建 Endpoint 实例
  /// [name] Endpoint 配置名称
  /// [queryParameters] 查询参数
  /// [requestBody] 请求体
  /// [headers] 请求头
  /// [parser] 响应解析器
  APIEndpoint createEndpoint({
    required String name,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    dynamic Function(dynamic)? parser,
  }) {
    final config = _configs[name];
    if (config == null) {
      throw Exception('Endpoint config not found: $name');
    }

    return EndpointFactory.createEndpoint(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser,
    );
  }

  /// 创建单个对象响应的 Endpoint
  GenericAPIEndpoint<T> createSingleEndpoint<T>({
    required String name,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    final config = _configs[name];
    if (config == null) {
      throw Exception('Endpoint config not found: $name');
    }

    return EndpointFactory.createSingleEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser,
    );
  }

  /// 创建列表响应的 Endpoint
  ListAPIEndpoint<T> createListEndpoint<T>({
    required String name,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    final config = _configs[name];
    if (config == null) {
      throw Exception('Endpoint config not found: $name');
    }

    return EndpointFactory.createListEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser,
    );
  }

  /// 获取所有配置名称
  List<String> getAllConfigNames() {
    return _configs.keys.toList();
  }

  /// 清除所有配置
  void clear() {
    _configs.clear();
    _isInitialized = false;
  }
}

