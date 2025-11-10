import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

enum HTTPMethod {
  @JsonValue('get')
  get('GET', '从服务器获取资源'),
  @JsonValue('post')
  post('POST', '向服务器提交数据，常用于创建资源'),
  @JsonValue('put')
  put('PUT', '更新服务器上的资源，通常需要提供完整的资源数据'),
  @JsonValue('patch')
  patch('PATCH', '部分更新服务器上的资源，只需提供需要修改的字段'),
  @JsonValue('delete')
  delete('DELETE', '删除服务器上的资源'),
  @JsonValue('head')
  head('HEAD', '获取资源的元信息（如响应头），不返回响应体');

  final String method;
  final String description;

  const HTTPMethod(this.method, this.description);

  /// 转换为大写字符串（用于 Dio Options）
  String toUpperCase() => method.toUpperCase();

  @override
  String toString() => method;
}

enum HTTPContentType {
  @JsonValue('application/json')
  json("application/json", "JSON 数据"),
  @JsonValue('application/x-www-form-urlencoded')
  urlEncoded("application/x-www-form-urlencoded", "表单数据（URL 编码）"),
  @JsonValue('multipart/form-data')
  formData("multipart/form-data", "包含文件的表单数据"),
  @JsonValue('text/plain')
  plain("text/plain", "纯文本数据");

  final String value;
  final String description;

  const HTTPContentType(this.value, this.description);

  // 添加便捷方法：从字符串值解析为枚举
  static HTTPContentType? fromValue(String? value) {
    if (value == null) return null;
    return HTTPContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid content type: $value'),
    );
  }

  // 转换为Dio可用的Headers常量
  String? toDioHeader() {
    switch (this) {
      case HTTPContentType.json:
        return Headers.jsonContentType;
      case HTTPContentType.urlEncoded:
        return Headers.formUrlEncodedContentType;
      case HTTPContentType.formData:
        return Headers.multipartFormDataContentType;
      case HTTPContentType.plain:
        return Headers.textPlainContentType;
    }
  }
}

abstract class APIEndpoint {
  // 域名
  String domain() {
    if (module.isNotEmpty) {
      return DomainConfig.getBaseUrl(module);
    }
    return "";
  }

  String get path;
  HTTPMethod get httpMethod;
  // 公共头信息（默认使用app公共头信息）
  Map<String, String>? get headers => HttpConfig.getAppCommonHeaders();

  Map<String, dynamic>? get queryParameters;
  dynamic get requestBody;
  String get module;
  String? get contentType => null; // Dio里面默认没有设置

  // 请求的url
  String get url {
    return domain() + path;
  }

  /// 连接超时时间（单位：秒）
  int get connectTimeoutSeconds => HttpConfig.defaultConnectTimeout;

  /// 发送超时时间（单位：秒）
  int get sendTimeoutSeconds => HttpConfig.defaultConnectTimeout;

  /// 接收超时时间（单位：秒）
  int get receiveTimeoutSeconds => HttpConfig.defaultReceiveTimeout;

  // 缓存策略
  CachePolicy get cachePolicy => CachePolicy.networkOnly;
  Duration get cacheDuration => const Duration(minutes: 5);

  // 重试配置
  bool get shouldRetry => false;
  int get maxRetries => 3;
  Duration get retryDelay => const Duration(seconds: 1);

  // 解析响应数据
  dynamic parseResponse(dynamic response);

  // 添加此方法，用于将原始数据转换为标准响应中的数据类型
  T parseData<T>(dynamic rawData) => rawData as T;

  // 打印请求参数
  bool get enableLogging => HttpConfig.enableLogging;

  /// 是否跳过 Auth 鉴权校验导致的退出登录
  /// 当设置为 true 时，即使鉴权失败（如 401），也不会清除 token 和触发登录回调
  /// 适用于部分接口报错不影响 App 正常使用的场景
  bool get skipAuthLogout => false;

  // 转换为JSON字符串
  Map<String, dynamic> disposeBagJson() {
    return {
      'domain': domain(),
      'path': path,
      'httpMethod': httpMethod.method,
      'headers': headers,
      'queryParameters': queryParameters,
      'module': module,
      'contentType': contentType,
      'connectTimeoutSeconds': connectTimeoutSeconds,
      'sendTimeoutSeconds': sendTimeoutSeconds,
      'receiveTimeoutSeconds': receiveTimeoutSeconds,
      'cachePolicy': cachePolicy.name,
      'cacheDuration': cacheDuration.inMinutes,
      'shouldRetry': shouldRetry,
      'maxRetries': maxRetries,
      'retryDelay': retryDelay.inSeconds,
      'enableLogging': enableLogging,
    };
  }
}

// 泛型API端点，用于单个对象响应
abstract class GenericAPIEndpoint<T> extends APIEndpoint {
  T parseItem(dynamic item);

  @override
  T parseResponse(dynamic response) {
    try {
      final data = response['data'];
      return parseItem(data);
    } catch (e) {
      print('数据解析错误: $e');
      throw AppException.unknownError('数据解析错误: $e');
    }
  }
}

// 列表API端点，用于列表响应
abstract class ListAPIEndpoint<T> extends APIEndpoint {
  T parseElement(dynamic element);

  @override
  List<T> parseResponse(dynamic response) {
    try {
      final data = response['data'];
      if (data is List) {
        return data.map((e) => parseElement(e)).toList();
      }
      return [];
    } catch (e) {
      print('数据解析错误: $e');
      throw AppException.unknownError('数据解析错误: $e');
    }
  }
}
