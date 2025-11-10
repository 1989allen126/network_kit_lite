import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

import 'utils/http_method_strategy.dart';

/// Endpoint 注解处理器
/// 运行时根据注解动态创建 endpoint
class EndpointAnnotationProcessor {
  EndpointAnnotationProcessor._();

  /// 根据 GET 注解创建 endpoint
  static GenericAPIEndpoint<T> createFromGET<T>({
    required ApiGET annotation,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    try {
      final strategy = HttpMethodStrategyFactory.getStrategy('ApiGET');
      if (strategy == null) {
        throw Exception('无法找到 GET 方法策略');
      }
      return strategy.createEndpoint<T>(
        path: annotation.path,
        module: annotation.module,
        responseType: annotation.responseType,
        queryParameters: queryParameters,
        requestBody: requestBody,
        headers: headers,
        parser: parser,
      );
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ EndpointAnnotationProcessor.createFromGET 创建失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      // 返回一个默认的 endpoint，避免页面崩溃
      return _createDefaultEndpoint<T>(annotation.path, annotation.module);
    }
  }

  /// 根据 POST 注解创建 endpoint
  static GenericAPIEndpoint<T> createFromPOST<T>({
    required ApiPOST annotation,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    try {
      final strategy = HttpMethodStrategyFactory.getStrategy('ApiPOST');
      if (strategy == null) {
        throw Exception('无法找到 POST 方法策略');
      }
      return strategy.createEndpoint<T>(
        path: annotation.path,
        module: annotation.module,
        responseType: annotation.responseType,
        queryParameters: queryParameters,
        requestBody: requestBody,
        headers: headers,
        parser: parser,
      );
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ EndpointAnnotationProcessor.createFromPOST 创建失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      // 返回一个默认的 endpoint，避免页面崩溃
      return _createDefaultEndpoint<T>(annotation.path, annotation.module);
    }
  }

  /// 根据 PUT 注解创建 endpoint
  static GenericAPIEndpoint<T> createFromPUT<T>({
    required ApiPUT annotation,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    try {
      final strategy = HttpMethodStrategyFactory.getStrategy('ApiPUT');
      if (strategy == null) {
        throw Exception('无法找到 PUT 方法策略');
      }
      return strategy.createEndpoint<T>(
        path: annotation.path,
        module: annotation.module,
        responseType: annotation.responseType,
        queryParameters: queryParameters,
        requestBody: requestBody,
        headers: headers,
        parser: parser,
      );
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ EndpointAnnotationProcessor.createFromPUT 创建失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      // 返回一个默认的 endpoint，避免页面崩溃
      return _createDefaultEndpoint<T>(annotation.path, annotation.module);
    }
  }

  /// 根据 DELETE 注解创建 endpoint
  static GenericAPIEndpoint<T> createFromDELETE<T>({
    required ApiDELETE annotation,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    try {
      final strategy = HttpMethodStrategyFactory.getStrategy('ApiDELETE');
      if (strategy == null) {
        throw Exception('无法找到 DELETE 方法策略');
      }
      return strategy.createEndpoint<T>(
        path: annotation.path,
        module: annotation.module,
        responseType: annotation.responseType,
        queryParameters: queryParameters,
        requestBody: requestBody,
        headers: headers,
        parser: parser,
      );
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ EndpointAnnotationProcessor.createFromDELETE 创建失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      // 返回一个默认的 endpoint，避免页面崩溃
      return _createDefaultEndpoint<T>(annotation.path, annotation.module);
    }
  }

  /// 根据 PATCH 注解创建 endpoint
  static GenericAPIEndpoint<T> createFromPATCH<T>({
    required ApiPATCH annotation,
    Map<String, dynamic>? queryParameters,
    dynamic requestBody,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) {
    try {
      final strategy = HttpMethodStrategyFactory.getStrategy('ApiPATCH');
      if (strategy == null) {
        throw Exception('无法找到 PATCH 方法策略');
      }
      return strategy.createEndpoint<T>(
        path: annotation.path,
        module: annotation.module,
        responseType: annotation.responseType,
        queryParameters: queryParameters,
        requestBody: requestBody,
        headers: headers,
        parser: parser,
      );
    } catch (e, stackTrace) {
      // 完善的异常处理，防止网络请求导致页面布局异常
      if (kDebugMode) {
        print('❌ EndpointAnnotationProcessor.createFromPATCH 创建失败: $e');
        print('堆栈跟踪: $stackTrace');
      }
      // 返回一个默认的 endpoint，避免页面崩溃
      return _createDefaultEndpoint<T>(annotation.path, annotation.module);
    }
  }

  /// 创建默认的 endpoint（用于异常情况）
  static GenericAPIEndpoint<T> _createDefaultEndpoint<T>(String path, String module) {
    final config = EndpointConfig(
      name: path,
      path: path,
      method: HTTPMethod.get,
      module: module,
      responseType: EndpointResponseType.single,
    );
    return EndpointFactory.createSingleEndpoint<T>(
      config: config,
      parser: (dynamic item) => item as T,
    );
  }
}
