import '../core/config/http_config.dart';

/// 错误消息解析工具
/// 负责清理和截断错误消息，使其适合用户界面显示
class ErrorMessageParser {
  /// 解析用户友好的错误消息
  /// [message] 原始消息
  /// [bizMessage] 业务消息（优先使用）
  /// [maxLength] 最大长度限制，默认使用 HttpConfig.defaultErrorMessageMaxLength
  /// [success] 是否成功，成功时返回默认成功消息
  static String parseUserFriendlyMessage({
    String? message,
    String? bizMessage,
    int? maxLength,
    bool success = false,
  }) {
    final int maxLen = maxLength ?? HttpConfig.defaultErrorMessageMaxLength;
    String result;
    if (success) {
      result = message ?? 'Success';
    } else {
      // 优先返回业务错误消息
      if (bizMessage?.isNotEmpty == true) {
        result = bizMessage!;
      } else if (message?.isNotEmpty == true) {
        // 其次返回系统消息
        result = message!;
      } else {
        // 最后返回默认错误消息
        result = 'Unknown error occurred';
      }
    }
    // 智能截断过长的消息，避免 Toast 显示过长内容
    return truncateMessage(result, maxLen);
  }

  /// 智能截断过长的消息
  /// [message] 原始消息
  /// [maxLength] 最大长度限制
  /// 优先在句子边界（句号、问号、感叹号）处截断
  /// 其次在逗号、分号处截断
  /// 最后在空格处截断
  static String truncateMessage(String message, int maxLength) {
    if (message.length <= maxLength) {
      return message;
    }
    // 过滤掉堆栈跟踪和调试信息
    final cleanedMessage = cleanMessage(message);
    if (cleanedMessage.length <= maxLength) {
      return cleanedMessage;
    }
    // 尝试在句子边界截断（句号、问号、感叹号）
    final sentenceEndIndex = findBestBreakPoint(cleanedMessage, maxLength, ['.', '。', '!', '！', '?', '？']);
    if (sentenceEndIndex > 0) {
      return cleanedMessage.substring(0, sentenceEndIndex);
    }
    // 尝试在逗号、分号处截断
    final commaEndIndex = findBestBreakPoint(cleanedMessage, maxLength, [',', '，', ';', '；']);
    if (commaEndIndex > 0) {
      return '${cleanedMessage.substring(0, commaEndIndex)}...';
    }
    // 尝试在空格处截断
    final spaceEndIndex = findBestBreakPoint(cleanedMessage, maxLength, [' ', '\t']);
    if (spaceEndIndex > 0) {
      return '${cleanedMessage.substring(0, spaceEndIndex)}...';
    }
    // 最后才粗暴截断
    return '${cleanedMessage.substring(0, maxLength)}...';
  }

  /// 清理消息，移除堆栈跟踪等调试信息
  /// [message] 原始消息
  static String cleanMessage(String message) {
    final patterns = [
      RegExp(r'at\s+[a-zA-Z0-9._]+\([^)]+\)', multiLine: true),
      RegExp(r'Stack trace:', caseSensitive: false),
      RegExp(r'File "[^"]+", line \d+', caseSensitive: false),
      RegExp(r'#[0-9]+\s+[a-zA-Z0-9._]+', multiLine: true),
      RegExp(r'Exception in thread', caseSensitive: false),
    ];
    String cleaned = message;
    for (final pattern in patterns) {
      cleaned = cleaned.split(pattern).first.trim();
    }
    if (cleaned.isEmpty) {
      cleaned = message;
    }
    return cleaned;
  }

  /// 查找最佳的截断点
  /// [message] 消息内容
  /// [maxLength] 最大长度
  /// [breakChars] 可截断的字符列表
  /// 从maxLength往前查找，找到第一个匹配的字符位置
  static int findBestBreakPoint(String message, int maxLength, List<String> breakChars) {
    if (maxLength >= message.length) {
      return message.length;
    }
    final searchRange = maxLength > 20 ? 20 : maxLength;
    for (int i = maxLength - 1; i >= maxLength - searchRange && i >= 0; i--) {
      if (breakChars.contains(message[i])) {
        return i + 1;
      }
    }
    return 0;
  }
}

