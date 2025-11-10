import 'package:dio/dio.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

/// HTTP异常扩展，用于提取服务端错误消息
extension HttpExceptionExtensions on Exception {
  /// 获取智能获取的错误消息，优先级：bizMessage > message > 其他错误消息
  String smartErrorMessage({String? defaultErrorMessage}) {
    if (this is AppException) {
      return (this as AppException).userFriendlyMessage;
    } else if (this is CustomException) {
      return (this as CustomException).message;
    } else if (this is DioException) {
      return _extractDioErrorMessage(this as DioException);
    } else {
      return defaultErrorMessage ?? toString();
    }
  }

  /// 获取服务端错误消息
  /// 优先级：bizMessage > message > 默认错误消息
  String get serverErrorMessage {
    // 如果是AppException，直接返回用户友好消息
    if (this is AppException) {
      return (this as AppException).userFriendlyMessage;
    }

    // 如果是CustomException，返回其消息
    if (this is CustomException) {
      return (this as CustomException).message;
    }

    // 如果是DioException，尝试从响应中提取错误消息
    if (this is DioException) {
      return _extractDioErrorMessage(this as DioException);
    }

    // 其他异常，尝试从字符串中提取错误信息
    return _extractErrorMessageFromString(toString());
  }

  /// 获取服务端业务错误码
  String? get serverErrorCode {
    // 如果是AppException，返回业务码
    if (this is AppException) {
      final appException = this as AppException;
      return appException.bizCode ?? appException.code.toString();
    }

    // 如果是DioException，尝试从响应中提取业务码
    if (this is DioException) {
      return _extractDioErrorCode(this as DioException);
    }

    return null;
  }

  /// 获取HTTP状态码
  int? get httpStatusCode {
    if (this is AppException) {
      return (this as AppException).code;
    }

    if (this is DioException) {
      return (this as DioException).response?.statusCode;
    }

    return null;
  }

  /// 判断是否为业务错误（有业务码或业务消息）
  bool get isBusinessError {
    if (this is AppException) {
      return (this as AppException).isBusinessError;
    }

    if (this is DioException) {
      final dioException = this as DioException;
      final responseData = dioException.response?.data;
      if (responseData is Map<String, dynamic>) {
        return responseData.containsKey('bizCode') || responseData.containsKey('bizMessage');
      }
    }

    return false;
  }

  /// 判断是否为网络错误
  bool get isNetworkError {
    if (this is AppException) {
      return (this as AppException).isNetworkError;
    }

    if (this is DioException) {
      final dioException = this as DioException;
      return dioException.type == DioExceptionType.connectionTimeout ||
          dioException.type == DioExceptionType.sendTimeout ||
          dioException.type == DioExceptionType.receiveTimeout ||
          dioException.type == DioExceptionType.connectionError;
    }

    return false;
  }

  /// 判断是否应该重试
  bool get shouldRetry {
    if (this is AppException) {
      return (this as AppException).shouldRetry;
    }

    if (this is DioException) {
      final dioException = this as DioException;
      final statusCode = dioException.response?.statusCode;

      // 只有超时相关的异常类型才需要延迟重试
      if (dioException.type == DioExceptionType.connectionTimeout ||
          dioException.type == DioExceptionType.sendTimeout ||
          dioException.type == DioExceptionType.receiveTimeout) {
        return true;
      }

      // 根据默认配置判断是否需要重试
      const defaultConfig = SmartRetryConfig();
      if (statusCode != null && defaultConfig.statusCodeRetryCount.containsKey(statusCode)) {
        return true;
      }
      
      // 其他所有错误都不应该重试
      return false;
    }

    return false;
  }

  /// 获取详细的错误信息（用于调试）
  Map<String, dynamic> get errorDetails {
    if (this is AppException) {
      return (this as AppException).toMap();
    }

    if (this is DioException) {
      final dioException = this as DioException;
      return {
        'type': dioException.type.toString(),
        'statusCode': dioException.response?.statusCode,
        'message': dioException.message,
        'responseData': dioException.response?.data,
        'requestOptions': {
          'url': dioException.requestOptions.uri.toString(),
          'method': dioException.requestOptions.method,
          'headers': dioException.requestOptions.headers,
        },
      };
    }

    return {
      'type': runtimeType.toString(),
      'message': toString(),
    };
  }

  /// 从DioException中提取错误消息
  String _extractDioErrorMessage(DioException dioException) {
    final responseData = dioException.response?.data;

    // 如果响应数据是Map，尝试提取错误消息
    if (responseData is Map<String, dynamic>) {
      // 优先返回业务错误消息
      if (responseData['bizMessage'] != null && responseData['bizMessage'].toString().isNotEmpty) {
        return responseData['bizMessage'].toString();
      }

      // 其次返回系统消息
      if (responseData['message'] != null && responseData['message'].toString().isNotEmpty) {
        return responseData['message'].toString();
      }

      // 尝试其他常见的错误消息字段
      final commonErrorFields = ['error', 'msg', 'errorMessage', 'errorMsg'];
      for (final field in commonErrorFields) {
        if (responseData[field] != null && responseData[field].toString().isNotEmpty) {
          return responseData[field].toString();
        }
      }
    }

    // 如果响应数据是String，直接返回
    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    // 根据DioException类型返回相应消息
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络连接';
      case DioExceptionType.sendTimeout:
        return '发送超时，请稍后重试';
      case DioExceptionType.receiveTimeout:
        return '接收超时，请稍后重试';
      case DioExceptionType.badResponse:
        return '服务器响应错误';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badCertificate:
        return '证书验证失败';
      case DioExceptionType.unknown:
      default:
        return dioException.message ?? '未知网络错误';
    }
  }

  /// 从DioException中提取错误码
  String? _extractDioErrorCode(DioException dioException) {
    final responseData = dioException.response?.data;

    if (responseData is Map<String, dynamic>) {
      // 优先返回业务错误码
      if (responseData['bizCode'] != null) {
        return responseData['bizCode'].toString();
      }

      // 其次返回系统错误码
      if (responseData['code'] != null) {
        return responseData['code'].toString();
      }

      // 尝试其他常见的错误码字段
      final commonCodeFields = ['errorCode', 'error_code', 'statusCode'];
      for (final field in commonCodeFields) {
        if (responseData[field] != null) {
          return responseData[field].toString();
        }
      }
    }

    // 返回HTTP状态码
    return dioException.response?.statusCode?.toString();
  }

  /// 从异常字符串中提取错误信息
  String _extractErrorMessageFromString(String errorString) {
    // 尝试匹配常见的错误消息格式
    final patterns = [
      RegExp(r'Exception[^:]*:\s*(.+?)(?:\n|$)'),
      RegExp(r'Error[^:]*:\s*(.+?)(?:\n|$)'),
      RegExp(r'message[^:]*:\s*(.+?)(?:,|$)'),
      RegExp(r'msg[^:]*:\s*(.+?)(?:,|$)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(errorString);
      if (match != null && match.group(1)?.isNotEmpty == true) {
        final extractedMsg = match.group(1)!.trim();
        // 如果提取的消息不是空的异常类型名，则使用它
        if (extractedMsg.isNotEmpty && !extractedMsg.startsWith('Exception') && !extractedMsg.startsWith('Error')) {
          return extractedMsg;
        }
      }
    }

    // 如果无法提取，返回原始字符串
    return errorString;
  }
}

/// 为DioException添加便捷方法
extension DioExceptionExtensions on DioException {
  /// 获取服务端错误消息
  String get serverErrorMessage {
    return _extractServerErrorMessage();
  }

  /// 获取服务端业务错误码
  String? get serverErrorCode {
    return _extractServerErrorCode();
  }

  /// 获取业务错误消息
  String? get businessErrorMessage {
    final responseData = response?.data;
    if (responseData is Map<String, dynamic>) {
      return responseData['bizMessage']?.toString();
    }
    return null;
  }

  /// 获取系统错误消息
  String? get systemErrorMessage {
    final responseData = response?.data;
    if (responseData is Map<String, dynamic>) {
      return responseData['message']?.toString();
    }
    return null;
  }

  /// 判断是否有业务错误
  bool get hasBusinessError {
    final responseData = response?.data;
    if (responseData is Map<String, dynamic>) {
      return responseData.containsKey('bizCode') || responseData.containsKey('bizMessage');
    }
    return false;
  }

  /// 提取服务端错误消息
  String _extractServerErrorMessage() {
    final responseData = response?.data;

    if (responseData is Map<String, dynamic>) {
      // 优先返回业务错误消息
      final bizMessage = responseData['bizMessage']?.toString();
      if (bizMessage != null && bizMessage.isNotEmpty) {
        return bizMessage;
      }

      // 其次返回系统消息
      final message = responseData['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      // 尝试其他常见的错误消息字段
      final commonErrorFields = ['error', 'msg', 'errorMessage', 'errorMsg'];
      for (final field in commonErrorFields) {
        final errorMsg = responseData[field]?.toString();
        if (errorMsg != null && errorMsg.isNotEmpty) {
          return errorMsg;
        }
      }
    }

    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    return message ?? '网络请求失败';
  }

  /// 提取服务端错误码
  String? _extractServerErrorCode() {
    final responseData = response?.data;

    if (responseData is Map<String, dynamic>) {
      // 优先返回业务错误码
      final bizCode = responseData['bizCode']?.toString();
      if (bizCode != null && bizCode.isNotEmpty) {
        return bizCode;
      }

      // 其次返回系统错误码
      final code = responseData['code']?.toString();
      if (code != null && code.isNotEmpty) {
        return code;
      }

      // 尝试其他常见的错误码字段
      final commonCodeFields = ['errorCode', 'error_code', 'statusCode'];
      for (final field in commonCodeFields) {
        final errorCode = responseData[field]?.toString();
        if (errorCode != null && errorCode.isNotEmpty) {
          return errorCode;
        }
      }
    }

    return response?.statusCode?.toString();
  }
}
