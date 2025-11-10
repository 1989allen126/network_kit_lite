import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/response/result_wrapper.dart';

/// ResponseWrapper 扩展方法（同步版本）
extension ResponseWrapperExtension<T> on ResponseWrapper<T> {
  /// 无论成功或失败都执行回调（链式调用）
  ResponseWrapper<T> onFinally(void Function() callback) {
    callback();
    return this;
  }
}

/// Future<ResponseWrapper<T>> 扩展方法
extension FutureResponseWrapperExtension<T> on Future<ResponseWrapper<T>> {
  /// 当成功时执行回调
  Future<ResponseWrapper<T>> onSuccess(void Function(T data) callback) async {
    final response = await this;
    return response.onSuccess(callback);
  }

  /// 当失败时执行回调
  Future<ResponseWrapper<T>> onError(void Function(AppException error) callback) async {
    final response = await this;
    return response.onError(callback);
  }

  /// 无论成功或失败都执行回调
  Future<ResponseWrapper<T>> onFinally(void Function() callback) async {
    final response = await this;
    return response.onFinally(callback);
  }

  /// 模式匹配（类似 Rust 的 match）
  Future<R> when<R>({
    required R Function(T data) success,
    required R Function(AppException error) error,
  }) async {
    final response = await this;
    return response.when(success: success, error: error);
  }

  /// 获取数据或抛出异常
  Future<T> getOrThrow() async {
    final response = await this;
    return response.getOrThrow();
  }

  /// 获取数据或返回默认值
  Future<T> getOrElse(T defaultValue) async {
    final response = await this;
    return response.getOrElse(defaultValue);
  }

  /// 映射数据
  Future<ResponseWrapper<R>> map<R>(R Function(T data) mapper) async {
    final response = await this;
    return response.map(mapper);
  }

  /// 扁平化映射（类似 flatMap）
  Future<ResponseWrapper<R>> flatMap<R>(ResponseWrapper<R> Function(T data) mapper) async {
    final response = await this;
    return response.flatMap(mapper);
  }

  /// 折叠（类似 fold）
  Future<R> fold<R>({
    required R Function(AppException error) onError,
    required R Function(T data) onSuccess,
  }) async {
    final response = await this;
    return response.fold(onError: onError, onSuccess: onSuccess);
  }
}

/// BaseResponse 扩展方法（用于 Future<BaseResponse>）
extension FutureBaseResponseExtension on Future<BaseResponse> {
  /// 转换为模型（简化版本，直接传递 fromJson 方法）
  /// 适用于有 fromJson 方法的模型（如 freezed 生成的模型）
  Future<ResponseWrapper<T>> wrapperToModel<T>(T Function(Map<String, dynamic>) fromJson) async {
    final response = await this;
    return response.wrapperToModel<T>(fromJson);
  }

  /// 转换为模型列表（简化版本，直接传递 fromJson 方法）
  /// 适用于有 fromJson 方法的模型（如 freezed 生成的模型）
  Future<ResponseWrapper<List<T>>> wrapperToModelList<T>(T Function(Map<String, dynamic>) fromJson) async {
    final response = await this;
    return response.wrapperToModelList<T>(fromJson);
  }
}
