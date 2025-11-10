import 'package:network_kit_lite/network_kit_lite.dart';

/// HTTP 方法策略接口
abstract class HttpMethodStrategy {
  /// 创建 Endpoint
  GenericAPIEndpoint<T> createEndpoint<T>({
    required String path,
    required String module,
    String? responseType,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  });
}

/// GET 方法策略
class GetMethodStrategy implements HttpMethodStrategy {
  @override
  GenericAPIEndpoint<T> createEndpoint<T>({
    required String path,
    required String module,
    String? responseType,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    final config = EndpointConfig(
      name: path,
      path: path,
      method: HTTPMethod.get,
      module: module,
      responseType: _parseResponseType(responseType),
    );
    return EndpointFactory.createSingleEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser ?? ((dynamic item) => item as T),
    );
  }

  EndpointResponseType _parseResponseType(String? type) {
    switch (type) {
      case 'list':
        return EndpointResponseType.list;
      case 'raw':
        return EndpointResponseType.raw;
      case 'single':
      default:
        return EndpointResponseType.single;
    }
  }
}

/// POST 方法策略
class PostMethodStrategy implements HttpMethodStrategy {
  @override
  GenericAPIEndpoint<T> createEndpoint<T>({
    required String path,
    required String module,
    String? responseType,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    final config = EndpointConfig(
      name: path,
      path: path,
      method: HTTPMethod.post,
      module: module,
      responseType: _parseResponseType(responseType),
    );
    return EndpointFactory.createSingleEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser ?? ((dynamic item) => item as T),
    );
  }

  EndpointResponseType _parseResponseType(String? type) {
    switch (type) {
      case 'list':
        return EndpointResponseType.list;
      case 'raw':
        return EndpointResponseType.raw;
      case 'single':
      default:
        return EndpointResponseType.single;
    }
  }
}

/// PUT 方法策略
class PutMethodStrategy implements HttpMethodStrategy {
  @override
  GenericAPIEndpoint<T> createEndpoint<T>({
    required String path,
    required String module,
    String? responseType,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    final config = EndpointConfig(
      name: path,
      path: path,
      method: HTTPMethod.put,
      module: module,
      responseType: _parseResponseType(responseType),
    );
    return EndpointFactory.createSingleEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser ?? ((dynamic item) => item as T),
    );
  }

  EndpointResponseType _parseResponseType(String? type) {
    switch (type) {
      case 'list':
        return EndpointResponseType.list;
      case 'raw':
        return EndpointResponseType.raw;
      case 'single':
      default:
        return EndpointResponseType.single;
    }
  }
}

/// DELETE 方法策略
class DeleteMethodStrategy implements HttpMethodStrategy {
  @override
  GenericAPIEndpoint<T> createEndpoint<T>({
    required String path,
    required String module,
    String? responseType,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    final config = EndpointConfig(
      name: path,
      path: path,
      method: HTTPMethod.delete,
      module: module,
      responseType: _parseResponseType(responseType),
    );
    return EndpointFactory.createSingleEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser ?? ((dynamic item) => item as T),
    );
  }

  EndpointResponseType _parseResponseType(String? type) {
    switch (type) {
      case 'list':
        return EndpointResponseType.list;
      case 'raw':
        return EndpointResponseType.raw;
      case 'single':
      default:
        return EndpointResponseType.single;
    }
  }
}

/// PATCH 方法策略
class PatchMethodStrategy implements HttpMethodStrategy {
  @override
  GenericAPIEndpoint<T> createEndpoint<T>({
    required String path,
    required String module,
    String? responseType,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    final config = EndpointConfig(
      name: path,
      path: path,
      method: HTTPMethod.patch,
      module: module,
      responseType: _parseResponseType(responseType),
    );
    return EndpointFactory.createSingleEndpoint<T>(
      config: config,
      queryParameters: queryParameters,
      requestBody: requestBody,
      headers: headers,
      parser: parser ?? ((dynamic item) => item as T),
    );
  }

  EndpointResponseType _parseResponseType(String? type) {
    switch (type) {
      case 'list':
        return EndpointResponseType.list;
      case 'raw':
        return EndpointResponseType.raw;
      case 'single':
      default:
        return EndpointResponseType.single;
    }
  }
}

/// HTTP 方法策略工厂
class HttpMethodStrategyFactory {
  static final Map<String, HttpMethodStrategy> _strategies = {
    'ApiGET': GetMethodStrategy(),
    'ApiPOST': PostMethodStrategy(),
    'ApiPUT': PutMethodStrategy(),
    'ApiDELETE': DeleteMethodStrategy(),
    'ApiPATCH': PatchMethodStrategy(),
  };

  /// 获取策略
  static HttpMethodStrategy? getStrategy(String annotationType) {
    return _strategies[annotationType];
  }
}
