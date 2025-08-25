import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/base/base_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ResponseHandler {
  static const List<String> _serviceCodeSet = [
    'code',
    'Code',
    'status',
    'Status',
    'statusCode',
    'StatusCode'
  ];
  static const List<String> _serviceDataSet = [
    'data',
    'Data',
    'result',
    'Result',
    'content'
  ];
  static const List<String> _serviceMessageSet = [
    'msg',
    'Msg',
    'message',
    'Message',
    'errorMsg',
    'errorMessage'
  ];
  static const List<String> _serviceBizCodeSet = [
    'bizCode',
    'biz_code',
    'businessCode',
    'errorCode'
  ];
  static const List<String> _serviceBizMessageSet = [
    'bizMsg',
    'biz_msg',
    'businessMsg',
    'errorDescription'
  ];

  static BaseResponse<T> handleError<T>(AppException exception) {
    return BaseResponse<T>(
        code: exception.code,
        message: exception.message,
        bizCode: exception.bizCode ?? "-1",
        bizMessage: exception.bizMessage ?? exception.message,
        data: exception.data,
        originData: exception.data);
  }

  static BaseResponse<T> handleDioException<T>(DioException exception) {
    final statusCode = TypeSafetyUtils.safeInt(exception.response?.statusCode, defaultValue: -1);
    String message = TypeSafetyUtils.safeString(exception.message, defaultValue: 'Network error');

    // 安全地尝试从响应中提取错误信息
    final responseData = TypeSafetyUtils.safeMap(exception.response?.data);
    if (responseData.isNotEmpty) {
      final extractedMessage = TypeSafetyUtils.safeString(_extractField(responseData, _serviceMessageSet));
      if (extractedMessage.isNotEmpty) {
        message = extractedMessage;
      }
    }

    return BaseResponse<T>(
      code: statusCode,
      message: message,
    );
  }

  // 组装返回结果
  static BaseResponse<T> handleCancelError<T>(
      DioException exception, int statusCode) {
    return BaseResponse<T>(
        code: 200,
        message: 'OK',
        bizCode: "$statusCode",
        bizMessage: TypeSafetyUtils.safeString(exception.message,
            defaultValue: "The request was manually cancelled by the user"));
  }

  static BaseResponse<T> handleResponse<T>(Response response) {
    try {
      final statusCode = TypeSafetyUtils.safeInt(response.statusCode, defaultValue: 0);

      // 处理标准HTTP错误
      if (statusCode < 200 || statusCode >= 300) {
        throw AppException.httpError(statusCode);
      }

      // 处理JSON响应
      if (response.data is Map) {
        final json = response.data as Map<String, dynamic>;

        // 使用类型安全的方式提取值
        int code = TypeSafetyUtils.safeInt(_extractIntField(json, _serviceCodeSet), defaultValue: 0);
        String? message = TypeSafetyUtils.safeString(_extractStringField(json, _serviceMessageSet));
        String? bizCode = TypeSafetyUtils.safeString(_extractStringField(json, _serviceBizCodeSet));
        String? bizMessage = TypeSafetyUtils.safeString(_extractStringField(json, _serviceBizMessageSet));
        dynamic rawData = _extractField(json, _serviceDataSet);

        // 检查业务错误
        final codes = HttpConfig.successCodes;
        if (statusCode == 200 || codes.contains(code)) {
          // 使用ErrorCodeIntl进行错误消息国际化
          if (message.isEmpty) {
              message = ErrorCodeIntl.getMessage(
                          bizCode,
                          serverMessage: message,
                        );
          }
        } else {
          // 使用ErrorCodeIntl进行错误消息国际化
          final localMessage = ErrorCodeIntl.getMessage(
            bizCode,
            serverMessage: message,
          );
          throw AppException(
            code: code,
            message: localMessage,
            bizCode: bizCode,
            bizMessage: bizMessage,
          );
        }

        // 封装统一的响应结构
        return BaseResponse<T>(
            code: code,
            message: message,
            bizCode: bizCode.isNotEmpty ? bizCode : null,
            bizMessage: bizMessage.isNotEmpty ? bizMessage : null,
            data: rawData,
            originData: response.data);
      }

      // 非JSON响应直接返回
      return BaseResponse<T>(
          code: 200,
          message: 'OK',
          data: response.data,
          originData: response.data);
    } catch (e) {
      if (kDebugMode) {
        print('响应解析错误: $e');
      }
      final statusCode = TypeSafetyUtils.safeInt(response.statusCode, defaultValue: 500);
      throw AppException.httpError(statusCode);
    }
  }

  static int? _extractIntField(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        final value = json[key];
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
        if (value is double) return value.toInt();
      }
    }
    return null;
  }

  static String? _extractStringField(
      Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        final value = json[key];
        if (value is String) return value;
        if (value != null) return value.toString();
      }
    }
    return null;
  }

  static dynamic _extractField(Map<String, dynamic> json, List<String> keys) {
    if (json.isEmpty) {
      return null;
    }

    for (final key in keys) {
      if (json.containsKey(key)) {
        return json[key];
      }
    }
    return null;
  }

  /// 安全的数据提取方法
  static T? extractTypedValue<T>(Map<String, dynamic> json, List<String> keys) {
    final value = _extractField(json, keys);
    return TypeSafetyUtils.safeCast<T>(value);
  }

  /// 验证响应数据的完整性
  static bool validateResponseData(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return false;

    // 检查是否包含基本的响应字段
    final hasCode = _serviceCodeSet.any((key) => json.containsKey(key));
    final hasMessage = _serviceMessageSet.any((key) => json.containsKey(key));

    return hasCode || hasMessage;
  }
}
