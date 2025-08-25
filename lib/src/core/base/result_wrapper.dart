import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/base/base_response.dart';
import 'package:network_kit_lite/src/core/base/base_wrapper.dart';

/// 返回数据包装器
class ResponseWrapper<T> extends BaseWrapper {
  ///业务关注的数据（可能为 null）
  final T? data;

  const ResponseWrapper({
    required BaseResponse baseBean,
    this.data,
  }) : super(baseBean);
}

typedef DataCreator<T> = T Function(dynamic json);
extension BaseBeanExt on BaseResponse {
  ///转换成包装数据格式
  ResponseWrapper<T> resultWrapper<T>({
    required DataCreator<T> creator,
  }) {
    return ResponseWrapper<T>(
      baseBean: this,
      data: isSuccess && data != null ? creator.call(data) : null,
    );
  }

  ///转换成包装数据列格式
  ResponseWrapper<List<T>> resultWrapperList<T>({
    required DataCreator<T> creator,
  }) {
    final List<T> result = <T>[];
    try {
      if (kDebugMode) {
        print('🔍 resultWrapperList 调试信息:');
        print('  - isSuccess: $isSuccess');
        print('  - data: $data');
        print('  - data type: ${data.runtimeType}');
        print('  - data is List: ${data is List}');
        print('  - successCodes: ${HttpConfig.successCodes}');
        print('  - code: $code');
      }

      if (isSuccess && data != null && data is List) {
        result.addAll((data as List).map<T>(creator).toList());
        if (kDebugMode) {
          print('  - 解析结果数量: ${result.length}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ resultWrapperList 解析异常: $e');
      }
    }

    return ResponseWrapper<List<T>>(baseBean: this, data: isSuccess ? result : []);
  }
}
