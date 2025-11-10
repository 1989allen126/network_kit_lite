import 'package:network_kit_lite/network_kit_lite.dart';

/// API响应扩展，提供更简洁的请求和解析方式
extension APIResponseExtension<T> on APIEndpoint {
  /// 执行请求并自动解析响应
  Future<T> executeAndParse() async {
    final dioClient = DioClient();
    final response = await dioClient.execute(this);
    return parseResponse(response.data) as T;
  }
}

/// 为DioClient添加扩展方法，支持直接使用端点执行请求
extension DioClientExtension on DioClient {
  /// 执行API端点并返回解析后的结果
  Future<T> executeEndpoint<T>(APIEndpoint endpoint) async {
    final response = await execute(endpoint);
    return endpoint.parseResponse(response.data) as T;
  }
}
