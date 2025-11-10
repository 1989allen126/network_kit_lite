import 'package:dio/dio.dart';
import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/interceptors/retry_interceptor.dart';
import 'package:network_kit_lite/src/i18n/error_code_intl.dart';
import 'package:network_kit_lite/src/utils/error_message_parser.dart';

/// 简单的本地化工具类，用于第三方库
class LocalizationHelper {
  static String tr(String key, {Map<String, String>? namedArgs}) {
    // 这里返回中文，因为这是第三方库，暂时使用硬编码
    switch (key) {
      case 'HTTP_CLIENT_ERROR_CODE_400':
        return '错误请求，参数可能不正确';
      case 'HTTP_CLIENT_ERROR_CODE_401':
        return '未授权，请登录';
      case 'HTTP_CLIENT_ERROR_CODE_403':
        return '禁止访问，没有权限';
      case 'HTTP_CLIENT_ERROR_CODE_404':
        return '请求的资源不存在';
      case 'HTTP_CLIENT_ERROR_CODE_500':
        return '服务器内部错误';
      case 'HTTP_CLIENT_ERROR_CODE_502':
        return '错误网关';
      case 'HTTP_CLIENT_ERROR_CODE_503':
        return '服务不可用';
      case 'HTTP_CLIENT_ERROR_CODE_504':
        return '网关超时';
      case 'HTTP_CLIENT_ERROR_CODE_UNKNOWN':
        if (namedArgs != null && namedArgs.containsKey('statusCode')) {
          return '未知错误，状态码:${namedArgs['statusCode']}';
        }
        return '未知错误，状态码:';
      default:
        return key;
    }
  }
}

/// 自定义异常
class CustomException implements Exception {
  final String message;
  CustomException(this.message);
  @override
  String toString() => message;
}

/// 异常扩展，用于将异常转换为消息(Toast显示)
extension AppExceptionExtensions on AppException {
  String get asToastMessage => message;
}

class AppException implements Exception {
  final int code;
  final String message;
  final String? bizCode;
  final String? bizMessage;
  final dynamic data;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final String? requestId;

  AppException({
    required this.code,
    required this.message,
    this.bizCode,
    this.bizMessage,
    this.data,
    this.stackTrace,
    this.requestId,
  }) : timestamp = DateTime.now();

  AppException._internal({
    required this.code,
    required this.message,
    this.bizCode,
    this.bizMessage,
    this.data,
    this.stackTrace,
    this.requestId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AppException.httpError(int statusCode, {String? message, String? requestId}) {
    // 如果提供了自定义消息，优先使用
    if (message != null && message.isNotEmpty) {
      return AppException._internal(
        code: statusCode,
        message: message,
        requestId: requestId,
      );
    }

    // HTTP 状态码错误总是使用国际化处理（因为这是协议层面的错误，不是服务器业务消息）
    // 尝试使用国际化消息，如果失败则使用兜底消息
    String finalMessage;
    try {
      finalMessage = ErrorCodeIntl.getHttpErrorMessage(statusCode);
    } catch (e) {
      // 国际化失败，使用兜底消息
      finalMessage = _httpErrorMessage(statusCode);
    }

    return AppException._internal(
      code: statusCode,
      message: finalMessage,
      requestId: requestId,
    );
  }

  factory AppException.httpException(DioException exception, {String? requestId}) {
    final statusCode = exception.response?.statusCode ?? -1;
    String message;

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络连接';
        break;
      case DioExceptionType.sendTimeout:
        message = '发送超时，请稍后重试';
        break;
      case DioExceptionType.receiveTimeout:
        message = '接收超时，请稍后重试';
        break;
      case DioExceptionType.badResponse:
        // 优先使用服务器返回的消息（业务错误消息）
        final serverMessage = exception.response?.data?['message'] ?? exception.response?.data?['msg'];
        if (serverMessage != null && serverMessage.toString().isNotEmpty) {
          message = serverMessage.toString();
        } else {
          // HTTP 状态码错误总是使用国际化处理（因为这是协议层面的错误，不是服务器业务消息）
          try {
            message = ErrorCodeIntl.getHttpErrorMessage(statusCode);
          } catch (e) {
            // 国际化失败，使用兜底消息
            message = _httpErrorMessage(statusCode);
          }
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络设置';
        break;
      case DioExceptionType.badCertificate:
        message = '证书验证失败';
        break;
      case DioExceptionType.unknown:
      default:
        // 根据错误消息进行更精确的分类
        final errorMessage = exception.message?.toLowerCase() ?? '';
        if (errorMessage.contains('certificate') || errorMessage.contains('ssl')) {
          message = 'SSL证书验证失败';
        } else if (errorMessage.contains('handshake')) {
          message = 'SSL握手失败';
        } else if (errorMessage.contains('dns')) {
          message = 'DNS解析失败，请检查网络连接';
        } else if (errorMessage.contains('timeout')) {
          message = '请求超时，请稍后重试';
        } else if (errorMessage.contains('connection refused')) {
          message = '连接被拒绝，服务器可能不可用';
        } else if (errorMessage.contains('no route to host')) {
          message = '无法连接到服务器，请检查网络设置';
        } else {
          message = exception.message ?? '未知网络错误';
        }
        break;
    }

    return AppException._internal(
      code: statusCode,
      message: message,
      bizCode: exception.response?.data?['bizCode']?.toString(),
      bizMessage: exception.response?.data?['bizMessage']?.toString(),
      data: exception.response?.data,
      stackTrace: exception.stackTrace,
      requestId: requestId,
    );
  }

  factory AppException.timeoutError({String? requestId}) {
    return AppException._internal(
      code: -1001,
      message: '请求超时，请稍后重试',
      requestId: requestId,
    );
  }

  factory AppException.networkError({String? message, String? requestId}) {
    return AppException._internal(
      code: -1002,
      message: message ?? '网络连接失败，请检查网络设置',
      requestId: requestId,
    );
  }

  factory AppException.unknownError([String? message, StackTrace? stackTrace, String? requestId]) {
    return AppException._internal(
      code: -9999,
      message: message ?? '未知错误，请稍后重试',
      stackTrace: stackTrace,
      requestId: requestId,
    );
  }

  factory AppException.businessError({
    required String bizCode,
    required String bizMessage,
    String? requestId,
  }) {
    return AppException._internal(
      code: 200,
      message: 'Business Error',
      bizCode: bizCode,
      bizMessage: bizMessage,
      requestId: requestId,
    );
  }

  static String _httpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误，请检查输入信息';
      case 401:
        return '身份验证失败，请重新登录';
      case 403:
        return '权限不足，无法访问该资源';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不被允许';
      case 408:
        return '请求超时，请稍后重试';
      case 409:
        return '请求冲突，资源已存在';
      case 422:
        return '请求格式正确，但语义错误';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误，请稍后重试';
      case 502:
        return '网关错误，请稍后重试';
      case 503:
        return '服务暂时不可用，请稍后重试';
      case 504:
        return '网关超时，请稍后重试';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return '客户端请求错误 ($statusCode)';
        } else if (statusCode >= 500) {
          return '服务器错误 ($statusCode)';
        }
        return '网络请求失败 ($statusCode)';
    }
  }

  /// 获取用户友好的错误描述（已智能截断过长消息）
  String get userFriendlyMessage {
    return ErrorMessageParser.parseUserFriendlyMessage(
      message: message,
      bizMessage: bizMessage,
      maxLength: 100,
    );
  }

  /// 获取详细的错误信息（用于调试）
  String get detailedMessage {
    final buffer = StringBuffer();
    buffer.write('错误代码: $code');
    if (bizCode != null) {
      buffer.write(', 业务代码: $bizCode');
    }
    buffer.write('\n错误信息: $message');
    if (bizMessage != null && bizMessage != message) {
      buffer.write('\n业务信息: $bizMessage');
    }
    if (requestId != null) {
      buffer.write('\n请求ID: $requestId');
    }
    buffer.write('\n时间戳: ${timestamp.toIso8601String()}');
    return buffer.toString();
  }

  /// 判断是否为网络相关错误
  bool get isNetworkError {
    return code == -1001 ||
        code == -1002 ||
        (code >= 500 && code < 600) ||
        code == 408 ||
        code == 502 ||
        code == 503 ||
        code == 504;
  }

  /// 判断是否为客户端错误
  bool get isClientError {
    return code >= 400 && code < 500;
  }

  /// 判断是否为服务器错误
  bool get isServerError {
    return code >= 500 && code < 600;
  }

  /// 判断是否为业务逻辑错误
  bool get isBusinessError {
    return bizCode != null && bizCode!.isNotEmpty;
  }

  /// 判断错误是否应该重试
  bool get shouldRetry {
    // 网络相关错误可以重试
    if (isNetworkError) {
      // 但某些网络错误不应该重试
      final message = this.message.toLowerCase();
      if (message.contains('certificate') ||
          message.contains('ssl') ||
          message.contains('handshake') ||
          message.contains('unauthorized') ||
          message.contains('forbidden') ||
          message.contains('not found') ||
          message.contains('bad request')) {
        return false;
      }
      return true;
    }

    // 根据默认配置判断是否需要重试
    const defaultConfig = SmartRetryConfig();
    if (defaultConfig.statusCodeRetryCount.containsKey(code)) {
      return true;
    }
    
    // 其他所有错误都不应该重试
    return false;
  }

  //TODO: 国际化适配
  // ignore: unused_element
  static String _httpDioExceptionMessage(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return 'connection timeout';
      case DioExceptionType.sendTimeout:
        return 'send timeout';
      case DioExceptionType.receiveTimeout:
        return 'receive timeout';
      case DioExceptionType.badCertificate:
        return 'bad certificate';
      case DioExceptionType.badResponse:
        return 'bad response';
      case DioExceptionType.cancel:
        return 'request cancelled';
      case DioExceptionType.connectionError:
        return 'connection error';
      case DioExceptionType.unknown:
        return 'unknown';
    }
  }

  @override
  String toString() {
    return userFriendlyMessage;
  }

  /// 转换为Map，便于序列化
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'bizCode': bizCode,
      'bizMessage': bizMessage,
      'timestamp': timestamp.toIso8601String(),
      'requestId': requestId,
      'isNetworkError': isNetworkError,
      'isClientError': isClientError,
      'isServerError': isServerError,
      'isBusinessError': isBusinessError,
    };
  }
}
