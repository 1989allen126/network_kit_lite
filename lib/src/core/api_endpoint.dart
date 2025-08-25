import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:dio/dio.dart';
import 'cache/cache_policy.dart';

enum HTTPMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}

enum HTTPContentType {
  json("application/json", "JSON 数据"),
  urlEncoded("application/x-www-form-urlencoded", "表单数据（URL 编码）"),
  formData("multipart/form-data", "包含文件的表单数据"),
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
  String  domain (){
    if(module.isNotEmpty){
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
  String url() {
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
