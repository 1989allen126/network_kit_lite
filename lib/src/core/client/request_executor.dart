import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

import '../../utils/request_queue_manager.dart';
import 'cancel_token_manager.dart';

/// 请求执行器
/// 负责执行网络请求的公共逻辑
class RequestExecutor {
  final Dio _dio;
  final RequestQueueManager? _requestQueueManager;
  final CancelTokenManager _cancelTokenManager;
  final NetworkConnectivity _networkConnectivity;

  RequestExecutor({
    required Dio dio,
    RequestQueueManager? requestQueueManager,
    required CancelTokenManager cancelTokenManager,
    required NetworkConnectivity networkConnectivity,
  })  : _dio = dio,
        _requestQueueManager = requestQueueManager,
        _cancelTokenManager = cancelTokenManager,
        _networkConnectivity = networkConnectivity;

  /// 执行请求
  /// [url] 请求URL
  /// [options] 请求选项
  /// [queryParameters] 查询参数
  /// [data] 请求体数据
  /// [cancelToken] 取消令牌
  /// [checkNetworkBeforeRequest] 是否在请求前检查网络状态
  Future<Response> executeRequest({
    required String url,
    required Options options,
    Map<String, dynamic>? queryParameters,
    Object? data,
    NetworkCancelToken? cancelToken,
    bool checkNetworkBeforeRequest = true,
  }) async {
    // 管理取消令牌
    final token = _cancelTokenManager.manageCancelToken(cancelToken);
    try {
      // 请求前检查网络状态
      if (checkNetworkBeforeRequest) {
        final isNetworkAvailable = await _networkConnectivity.isNetworkAvailable();
        if (!isNetworkAvailable) {
          throw AppException.networkError(message: 'module.network_unavailable'.tr());
        }
      }

      // 优先从请求头中获取 requestId，如果没有则从 URL 中提取
      // 例如：GET /api/home/deviceInfo/1234567890
      final requestId = _extractRequestId(url, options.method ?? 'GET', options.headers);

      // 使用队列管理器执行请求
      return await _executeRequest(
        () => _dio.request(
          url,
          options: options,
          queryParameters: queryParameters,
          data: data,
          cancelToken: token,
        ),
        requestId: requestId,
      );
    } finally {
      // 确保取消令牌被移除，无论请求成功或失败
      _cancelTokenManager.removeCancelToken(cancelToken);
    }
  }

  /// 执行请求（通过队列管理器）
  /// [request] 请求函数
  /// [requestId] 请求标识，用于区分不同的接口
  Future<T> _executeRequest<T>(Future<T> Function() request, {String? requestId}) async {
    if (_requestQueueManager != null) {
      return _requestQueueManager!.execute(request, requestId: requestId);
    }
    return request();
  }

  /// 提取请求标识
  /// 优先从请求头中查找 requestId，如果没有则从 URL 中提取
  /// [url] 请求URL
  /// [method] HTTP方法
  /// [headers] 请求头
  String _extractRequestId(String url, String method, Map<String, dynamic>? headers) {
    // 优先从请求头中查找 requestId
    // 只检查 RequestId 或 requestId 字段（不带连字符）
    if (headers != null) {
      final requestIdFromHeader = headers['Request-Id'] ?? headers['RequestId'] ?? headers['requestId'];
      if (requestIdFromHeader != null && requestIdFromHeader.toString().isNotEmpty) {
        return requestIdFromHeader.toString();
      }
    }

    // 如果请求头中没有，则从 URL 中提取（使用 method + path）
    try {
      final uri = Uri.parse(url);
      // 使用 method + path 作为 requestId
      // 例如：GET /api/home/getmydeviceselect
      return '${method.toUpperCase()} ${uri.path}';
    } catch (e) {
      // 如果解析失败，使用整个 URL 作为 requestId
      return '${method.toUpperCase()} $url';
    }
  }

  /// 处理响应
  /// [response] Dio响应
  /// [responseTransformer] 响应数据转换器
  BaseResponse<T> handleResponse<T>(
    Response response, {
    T Function(dynamic)? responseTransformer,
  }) {
    // 验证响应数据
    final baseResponse = ResponseHandler.handleResponse<T>(response);

    // 安全的响应转换
    if (responseTransformer != null && baseResponse.data != null) {
      try {
        baseResponse.data = responseTransformer(baseResponse.data);
      } catch (transformError) {
        // 转换失败时，保持原始数据
      }
    }

    return baseResponse;
  }

  /// 处理错误
  /// [error] 错误对象
  BaseResponse<T> handleError<T>(dynamic error) {
    if (error is DioException) {
      if (CancelToken.isCancel(error)) {
        return ResponseHandler.handleCancelError<T>(error, -1);
      }
      return ResponseHandler.handleDioException<T>(error);
    } else if (error is AppException) {
      return ResponseHandler.handleError<T>(error);
    }
    return ResponseHandler.handleError<T>(
      AppException.unknownError(error.toString()),
    );
  }
}
