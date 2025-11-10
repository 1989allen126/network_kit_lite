import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

/// 返回数据包装器
class ResponseWrapper<T> extends BaseWrapper {
  ///业务关注的数据（可能为 null）
  final T? data;

  const ResponseWrapper({
    required BaseResponse baseBean,
    this.data,
  }) : super(baseBean);

  /// 是否成功
  bool get isSuccess => succeed;

  /// 是否成功且有数据
  bool get hasData => isSuccess && data != null;

  /// 获取数据或抛出异常
  T getOrThrow() {
    if (!isSuccess) {
      throw AppException(
        code: code,
        message: message,
      );
    }
    if (data == null) {
      throw AppException(
        code: code,
        message: '数据为空',
      );
    }
    return data!;
  }

  /// 获取数据或返回默认值
  T getOrElse(T defaultValue) {
    return data ?? defaultValue;
  }

  /// 当成功时执行回调（链式调用）
  ResponseWrapper<T> onSuccess(void Function(T data) callback) {
    if (hasData) {
      callback(data!);
    }
    return this;
  }

  /// 当失败时执行回调（链式调用）
  ResponseWrapper<T> onError(void Function(AppException error) callback) {
    if (!isSuccess) {
      callback(AppException(
        code: code,
        message: message,
      ));
    }
    return this;
  }

  /// 无论成功或失败都执行回调（链式调用）
  ResponseWrapper<T> onFinally(void Function() callback) {
    callback();
    return this;
  }

  /// 模式匹配（类似 Rust 的 match）
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) error,
  }) {
    if (hasData) {
      return success(data!);
    } else {
      return error(AppException(
        code: code,
        message: message,
      ));
    }
  }

  /// 映射数据
  ResponseWrapper<R> map<R>(R Function(T data) mapper) {
    if (hasData) {
      return ResponseWrapper<R>(
        baseBean: baseBean,
        data: mapper(data!),
      );
    }
    return ResponseWrapper<R>(
      baseBean: baseBean,
      data: null,
    );
  }

  /// 扁平化映射（类似 flatMap）
  ResponseWrapper<R> flatMap<R>(ResponseWrapper<R> Function(T data) mapper) {
    if (hasData) {
      return mapper(data!);
    }
    return ResponseWrapper<R>(
      baseBean: baseBean,
      data: null,
    );
  }

  /// 折叠（类似 fold）
  R fold<R>({
    required R Function(AppException error) onError,
    required R Function(T data) onSuccess,
  }) {
    if (hasData) {
      return onSuccess(data!);
    } else {
      return onError(AppException(
        code: code,
        message: message,
      ));
    }
  }
}

typedef DataCreator<T> = T Function(dynamic json);

/// BaseResponse 扩展方法
extension BaseResponseExtension on BaseResponse {
  ///转换成包装数据格式（使用 creator 函数）
  ResponseWrapper<T> resultWrapper<T>({
    required DataCreator<T> creator,
  }) {
    T? result;
    if (isSuccess && data != null) {
      try {
        result = creator.call(data);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('❌ resultWrapper 解析异常: $e');
          print('堆栈跟踪: $stackTrace');
          print('原始数据: $data');
        }
        result = null;
      }
    }
    return ResponseWrapper<T>(
      baseBean: this,
      data: result,
    );
  }

  ///转换成包装数据格式（简化版本，直接返回原始数据）
  /// 适用于数据已经是目标类型的情况
  ResponseWrapper<T> resultWrapperDirect<T>() {
    T? result;
    if (isSuccess && data != null) {
      try {
        if (data is T) {
          result = data as T;
        } else {
          if (kDebugMode) {
            print('⚠️ 数据类型不匹配，期望: $T, 实际: ${data.runtimeType}');
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('❌ resultWrapperDirect 解析异常: $e');
          print('堆栈跟踪: $stackTrace');
          print('原始数据: $data');
        }
        result = null;
      }
    }
    return ResponseWrapper<T>(
      baseBean: this,
      data: result,
    );
  }

  ///转换成包装数据列格式（使用 creator 函数）
  ResponseWrapper<List<T>> resultWrapperList<T>({
    required DataCreator<T> creator,
  }) {
    final List<T> result = <T>[];
    try {
      if (isSuccess && data != null && data is List) {
        result.addAll((data as List).map<T>(creator).toList());
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ resultWrapperList 解析异常: $e');
      }
    }
    return ResponseWrapper<List<T>>(baseBean: this, data: isSuccess ? result : []);
  }

  ///转换成包装数据列格式（简化版本，直接返回原始数据）
  /// 适用于数据已经是目标类型列表的情况
  ResponseWrapper<List<T>> resultWrapperListDirect<T>() {
    final List<T> result = <T>[];
    try {
      if (isSuccess && data != null && data is List) {
        for (final item in data as List) {
          if (item is T) {
            result.add(item);
          } else {
            if (kDebugMode) {
              print('⚠️ 列表项类型不匹配，期望: $T, 实际: ${item.runtimeType}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ resultWrapperListDirect 解析异常: $e');
      }
    }
    return ResponseWrapper<List<T>>(baseBean: this, data: isSuccess ? result : []);
  }

  ///转换成包装数据格式（简化版本，直接传递 fromJson 方法）
  /// 适用于有 fromJson 方法的模型（如 freezed 生成的模型）
  ResponseWrapper<T> wrapperToModel<T>(T Function(Map<String, dynamic>) fromJson) {
    T? result;
    if (isSuccess && data != null) {
      try {
        if (data is Map<String, dynamic>) {
          result = fromJson(data as Map<String, dynamic>);
        } else {
          if (kDebugMode) {
            print('⚠️ 数据类型不匹配，期望: Map<String, dynamic>, 实际: ${data.runtimeType}');
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('❌ wrapperToModel 解析异常: $e');
          print('堆栈跟踪: $stackTrace');
          print('原始数据: $data');
        }
        result = null;
      }
    }
    return ResponseWrapper<T>(
      baseBean: this,
      data: result,
    );
  }

  ///转换成包装数据列格式（简化版本，直接传递 fromJson 方法）
  /// 适用于有 fromJson 方法的模型（如 freezed 生成的模型）
  ResponseWrapper<List<T>> wrapperToModelList<T>(T Function(Map<String, dynamic>) fromJson) {
    final List<T> result = <T>[];
    try {
      if (isSuccess && data != null && data is List) {
        result.addAll((data as List).map<T>((item) {
          if (item is Map<String, dynamic>) {
            return fromJson(item);
          } else {
            throw ArgumentError('列表项类型不匹配，期望: Map<String, dynamic>, 实际: ${item.runtimeType}');
          }
        }).toList());
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ wrapperToModelList 解析异常: $e');
      }
    }
    return ResponseWrapper<List<T>>(baseBean: this, data: isSuccess ? result : []);
  }
}
