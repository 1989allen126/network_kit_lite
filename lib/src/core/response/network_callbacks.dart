import 'base_response.dart';

/// 网络请求回调处理器
class NetworkCallbacks<T> {
  /// 实时数据回调（onData）
  final void Function(BaseResponse<T> data)? onData;

  /// 错误回调（onError）
  final void Function(dynamic error)? onError;

  /// 完成回调（complete）
  final void Function()? onComplete;

  const NetworkCallbacks({
    this.onData,
    this.onError,
    this.onComplete,
  });

  /// 调用onData回调
  void callOnData(BaseResponse<T> data) {
    onData?.call(data);
  }

  /// 调用onError回调
  void callOnError(dynamic error) {
    onError?.call(error);
  }

  /// 调用onComplete回调
  void callOnComplete() {
    onComplete?.call();
  }
}
