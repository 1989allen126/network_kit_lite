import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/base/result_wrapper.dart';

// 扩展：ResultWrapper 便捷方法
extension ResponseExtension<T> on Future<ResponseWrapper<T>> {
  Future<void> when({
    void Function(T data)? success,
    void Function(AppException error)? error,
    void Function()? finished,
  }) async {
    try {
      final response = await this;
      if (response.data != null) {
        success?.call(response.data!);
      }
    } catch (e) {
      error?.call(e as AppException);
    } finally {
      finished?.call();
    }
  }
}
