import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/utils/error_message_parser.dart';
import 'package:network_kit_lite/src/utils/json_convert.dart';

class BaseResponse<T> {
  final int code; // App侧统一的code
  final String? message; // 消息、错误提醒
  final String? bizCode; // 业务码（业务错误码不允许转化）
  final String? bizMessage; // 业务消息（业务错误消息不允许转化）
  dynamic data;
  final dynamic originData; // 原始数据（原始数据不允许转化）
  final bool success;

  // 是否成功
  bool get isSuccess => success;
  bool get isSuccessWithData => success && data != null;
  bool get hasError => !success || message != null;

  /// 安全获取数据，带类型检查
  T? getSafeData<T>() {
    if (data == null) return null;
    if (data is T) return data;
    return null;
  }

  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    return ErrorMessageParser.parseUserFriendlyMessage(
      message: message,
      bizMessage: bizMessage,
      success: success,
    );
  }

  /// 验证响应数据的完整性
  bool get isValidResponse {
    return (message?.isNotEmpty == true || success);
  }

  /// 获取详细的调试信息
  Map<String, dynamic> get debugInfo {
    return {
      'code': code,
      'message': message,
      'bizCode': bizCode,
      'bizMessage': bizMessage,
      'success': success,
      'hasData': data != null,
      'dataType': data?.runtimeType.toString(),
    };
  }

  BaseResponse({required this.code, required this.message, this.bizCode, this.bizMessage, this.data, this.originData})
      : success = (HttpConfig.successCodes.contains(code) &&
            (bizCode == null || HttpConfig.successCodes.contains(int.tryParse(bizCode) ?? 0)));

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse<T>(
      code: json['code'] ?? 0,
      message: json['message'],
      bizCode: json['bizCode'],
      bizMessage: json['bizMessage'],
      data: json['data'],
      originData: json['originData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {
      'code': code,
      'message': message,
      'success': success,
    };

    if (bizCode != null) {
      dataMap['bizCode'] = bizCode;
    }

    if (bizMessage != null) {
      dataMap['bizMessage'] = bizMessage;
    }

    // 使用JsonConverter处理data字段
    if (data != null) {
      dataMap['data'] = JsonConverter.convertToJson(data);
    }

    // 填充原始数据
    if (originData != null) {
      dataMap['originData'] = originData ?? {};
    }
    return dataMap;
  }
}
