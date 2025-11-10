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

      // 使用队列管理器执行请求
      return await _executeRequest(() => _dio.request(
            url,
            options: options,
            queryParameters: queryParameters,
            data: data,
            cancelToken: token,
          ));
    } finally {
      // 确保取消令牌被移除，无论请求成功或失败
      _cancelTokenManager.removeCancelToken(cancelToken);
    }
  }

  /// 执行请求（通过队列管理器）
  Future<T> _executeRequest<T>(Future<T> Function() request) async {
    if (_requestQueueManager != null) {
      return _requestQueueManager!.execute(request);
    }
    return request();
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
