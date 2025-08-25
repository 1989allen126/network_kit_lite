import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TimeoutInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final endpoint = options.extra['endpoint'] as APIEndpoint?;
    if (endpoint != null) {
      options.connectTimeout = Duration(milliseconds: endpoint.connectTimeoutSeconds);
      options.sendTimeout = Duration(milliseconds: endpoint.sendTimeoutSeconds);
      options.receiveTimeout = Duration(milliseconds: endpoint.receiveTimeoutSeconds);

      if (kDebugMode) {
        print('⏱️ 应用自定义超时: ${endpoint.runtimeType}');
        print('   - 连接超时: ${endpoint.connectTimeoutSeconds}ms');
        print('   - 发送超时: ${endpoint.sendTimeoutSeconds}ms');
        print('   - 接收超时: ${endpoint.receiveTimeoutSeconds}ms');
      }
    }

    super.onRequest(options, handler);
  }
}
