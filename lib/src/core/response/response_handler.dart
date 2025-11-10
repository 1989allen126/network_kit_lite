import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/i18n/error_msg_localization_strategy.dart';
import 'package:network_kit_lite/src/utils/error_message_parser.dart';

class ResponseHandler {
  /// 消息最大长度限制（用于 Toast 显示）
  static int get _maxMessageLength => DioClient().maxErrorMessageLength;

  static const List<String> _serviceCodeSet = ['code', 'Code', 'status', 'Status', 'statusCode', 'StatusCode'];
  static const List<String> _serviceDataSet = ['data', 'Data', 'result', 'Result', 'content'];
  static const List<String> _serviceMessageSet = ['msg', 'Msg', 'message', 'Message', 'errorMsg', 'errorMessage'];
  static const List<String> _serviceBizCodeSet = ['bizCode', 'biz_code', 'businessCode', 'errorCode'];
  static const List<String> _serviceBizMessageSet = ['bizMsg', 'biz_msg', 'businessMsg', 'errorDescription'];

  /// 智能截断过长的消息，确保适合 Toast 显示
  /// 优先在句子边界（句号、问号、感叹号）处截断
  /// 其次在逗号、分号处截断
  /// 最后在空格处截断
  static String truncateMessage(String message) {
    return ErrorMessageParser.truncateMessage(message, _maxMessageLength);
  }

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

    // HTTP 状态码错误总是使用国际化处理（因为这是协议层面的错误，不是服务器业务消息）
    // 如果已经有服务器返回的业务消息，优先使用；否则使用 HTTP 状态码的国际化消息
    if (message.isEmpty || message == 'Network error') {
      // 没有有效的业务消息，使用 HTTP 状态码的国际化消息
      try {
        final internationalizedMessage = ErrorCodeIntl.getHttpErrorMessage(statusCode);
        if (internationalizedMessage.isNotEmpty) {
          message = internationalizedMessage;
        }
      } catch (e) {
        // 国际化失败，继续使用原始消息
        if (kDebugMode) {
          print('⚠️ HTTP错误本地化获取失败，使用原始消息: $e');
        }
      }
    }
    // 如果有服务器返回的业务消息，直接使用（不进行国际化处理，因为这是业务消息）

    // 截断过长的消息，避免 Toast 显示过长内容
    message = truncateMessage(message);

    return BaseResponse<T>(
      code: statusCode,
      message: message,
    );
  }

  // 组装返回结果
  static BaseResponse<T> handleCancelError<T>(DioException exception, int statusCode) {
    return BaseResponse<T>(
        code: 200,
        message: 'OK',
        bizCode: "$statusCode",
        bizMessage: TypeSafetyUtils.safeString(exception.message,
            defaultValue: "The request was manually cancelled by the user"));
  }

  /// 处理响应数据
  static BaseResponse<T> handleResponse<T>(Response response) {
    try {
      final statusCode = TypeSafetyUtils.safeInt(response.statusCode, defaultValue: 0);

      // 处理标准HTTP错误 - 检查是否在成功状态码列表中
      final successCodes = HttpConfig.successCodes;
      if (!successCodes.contains(statusCode) && (statusCode < 200 || statusCode >= 300)) {
        throw AppException.httpError(statusCode);
      }

      // 安全地处理响应数据 - 使用类型安全的方式转换Map
      final json = TypeSafetyUtils.safeMap(response.data);

      // 如果成功转换为Map，说明是JSON响应
      if (json.isNotEmpty || response.data is Map) {
        // 使用类型安全的方式提取值
        int code = TypeSafetyUtils.safeInt(_extractIntField(json, _serviceCodeSet), defaultValue: 0);
        String message = TypeSafetyUtils.safeString(_extractStringField(json, _serviceMessageSet));
        String bizCode = TypeSafetyUtils.safeString(_extractStringField(json, _serviceBizCodeSet));
        String bizMessage = TypeSafetyUtils.safeString(_extractStringField(json, _serviceBizMessageSet));
        dynamic rawData = _extractField(json, _serviceDataSet);

        // 先检查HTTP状态码 - 使用配置的成功状态码列表
        if (!successCodes.contains(statusCode) && (statusCode < 200 || statusCode >= 300)) {
          throw AppException.httpError(statusCode);
        }

        // 再检查业务状态码
        final codes = HttpConfig.successCodes;
        String finalMessage = message;
        String? finalBizMessage = bizMessage.isNotEmpty ? bizMessage : null;

        if (codes.contains(code)) {
          // 业务成功 - 不需要国际化处理，直接使用服务器消息
          // 截断过长的消息，避免 Toast 显示过长内容
          finalMessage = truncateMessage(finalMessage);
        } else {
          // 业务失败 - 根据配置决定是否进行国际化处理
          String localMessage = finalMessage.isNotEmpty ? finalMessage : 'Unknown error';

          // 根据 errorMsgLocalizationStrategy 配置决定处理方式
          if (DomainConfig.errorMsgLocalizationStrategy == ErrorMsgLocalizationStrategy.localize) {
            // 使用本地化文件进行国际化
            try {
              final internationalizedMessage = ErrorCodeIntl.getMessage(
                bizCode.isNotEmpty ? bizCode : '',
                serverMessage: finalMessage,
              );
              if (internationalizedMessage.isNotEmpty) {
                localMessage = internationalizedMessage;
              }
            } catch (e) {
              // 国际化失败，继续使用服务器消息
              if (kDebugMode) {
                print('⚠️ 本地化获取失败，使用服务器消息: $e');
              }
            }
          } else {
            // 直接使用服务器返回的消息，不进行本地化处理
            if (kDebugMode) {
              print('🌍 使用服务器消息（不进行本地化）: $finalMessage');
            }
          }

          // 截断过长的消息，避免 Toast 显示过长内容
          finalMessage = truncateMessage(localMessage);
          if (finalBizMessage != null && finalBizMessage.isNotEmpty) {
            finalBizMessage = truncateMessage(finalBizMessage);
          }
        }

        // 封装统一的响应结构（业务成功或失败都返回 BaseResponse）
        // BaseResponse 的 success 字段会根据 code 和 bizCode 自动判断
        return BaseResponse<T>(
            code: code,
            message: finalMessage,
            bizCode: bizCode.isNotEmpty ? bizCode : null,
            bizMessage: (finalBizMessage != null && finalBizMessage.isNotEmpty) ? finalBizMessage : null,
            data: rawData,
            originData: response.data);
      }

      // 非JSON响应直接返回
      return BaseResponse<T>(code: 200, message: 'OK', data: response.data, originData: response.data);
    } catch (e) {
      // 如果已经是 AppException（业务错误），直接重新抛出，不记录为解析错误
      if (e is AppException) {
        // 业务错误是预期的，不需要记录为解析错误
        rethrow;
      }

      // 以下是真正的解析错误
      if (kDebugMode) {
        print('⚠️ 响应解析错误: $e');
        print('错误类型: ${e.runtimeType}');
        print('响应状态码: ${response.statusCode}');
        print('响应数据类型: ${response.data.runtimeType}');
        print('响应数据内容: ${response.data}');
        if (e is Error) {
          print('错误堆栈: ${e.stackTrace}');
        } else if (e is Exception) {
          print('异常详情: ${e.toString()}');
        }
      }

      // 处理类型不匹配异常
      if (e is TypeError) {
        final statusCode = TypeSafetyUtils.safeInt(response.statusCode, defaultValue: 500);
        if (kDebugMode) {
          print('⚠️ 响应数据类型不匹配: ${e.toString()}');
          print('响应数据类型: ${response.data.runtimeType}');
          print('响应状态码: $statusCode');
          print('尝试转换的数据: ${response.data}');
        }
        throw AppException(
          code: statusCode,
          message: truncateMessage('响应数据格式错误，类型不匹配'),
          data: response.data,
        );
      }

      // 处理格式异常（如JSON解析错误）
      if (e is FormatException) {
        final statusCode = TypeSafetyUtils.safeInt(response.statusCode, defaultValue: 500);
        if (kDebugMode) {
          print('⚠️ 响应数据格式异常: ${e.message}');
          print('响应状态码: $statusCode');
          print('原始数据: ${response.data}');
        }
        throw AppException(
          code: statusCode,
          message: truncateMessage('响应数据格式错误: ${e.message}'),
          data: response.data,
        );
      }

      // 其他异常才转换为 HTTP 错误
      final statusCode = TypeSafetyUtils.safeInt(response.statusCode, defaultValue: 500);
      if (kDebugMode) {
        print('⚠️ 未知解析错误，转换为HTTP错误: $statusCode');
      }
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

  static String? _extractStringField(Map<String, dynamic> json, List<String> keys) {
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
  T? extractTypedValue<T>(Map<String, dynamic> json, List<String> keys) {
    final value = _extractField(json, keys);
    return TypeSafetyUtils.safeCast<T>(value);
  }

  /// 验证响应数据的完整性
  bool validateResponseData(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return false;

    // 检查是否包含基本的响应字段
    final hasCode = _serviceCodeSet.any((key) => json.containsKey(key));
    final hasMessage = _serviceMessageSet.any((key) => json.containsKey(key));

    return hasCode || hasMessage;
  }
}
