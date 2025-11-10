import 'package:network_kit_lite/network_kit_lite.dart';

/// API 接口构建器
/// 提供便捷的方法来创建 endpoint
class EndpointApiBuilder {
  EndpointApiBuilder._();

  /// 从 GET 注解创建 endpoint
  static GenericAPIEndpoint<T> fromGET<T>({
    required ApiGET annotation,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    return EndpointAnnotationProcessor.createFromGET<T>(
      annotation: annotation,
      queryParameters: queryParameters,
      headers: headers,
      parser: parser,
    );
  }

  /// 从 POST 注解创建 endpoint
  static GenericAPIEndpoint<T> fromPOST<T>({
    required ApiPOST annotation,
    dynamic requestBody,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    return EndpointAnnotationProcessor.createFromPOST<T>(
      annotation: annotation,
      requestBody: requestBody,
      queryParameters: queryParameters,
      headers: headers,
      parser: parser,
    );
  }

  /// 从 PUT 注解创建 endpoint
  static GenericAPIEndpoint<T> fromPUT<T>({
    required ApiPUT annotation,
    dynamic requestBody,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    return EndpointAnnotationProcessor.createFromPUT<T>(
      annotation: annotation,
      requestBody: requestBody,
      queryParameters: queryParameters,
      headers: headers,
      parser: parser,
    );
  }

  /// 从 DELETE 注解创建 endpoint
  static GenericAPIEndpoint<T> fromDELETE<T>({
    required ApiDELETE annotation,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    return EndpointAnnotationProcessor.createFromDELETE<T>(
      annotation: annotation,
      queryParameters: queryParameters,
      headers: headers,
      parser: parser,
    );
  }

  /// 从 PATCH 注解创建 endpoint
  static GenericAPIEndpoint<T> fromPATCH<T>({
    required ApiPATCH annotation,
    dynamic requestBody,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    return EndpointAnnotationProcessor.createFromPATCH<T>(
      annotation: annotation,
      requestBody: requestBody,
      queryParameters: queryParameters,
      headers: headers,
      parser: parser,
    );
  }
}
