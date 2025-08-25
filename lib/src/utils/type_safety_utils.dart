import 'dart:convert';

/// 类型安全工具类
class TypeSafetyUtils {
  /// 安全的类型转换
  static T? safeCast<T>(dynamic value) {
    if (value == null) return null;
    if (value is T) return value;
    return null;
  }

  /// 安全的字符串转换
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// 安全的整数转换
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// 安全的双精度浮点数转换
  static double safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// 安全的布尔值转换
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == 'true' || lowerValue == '1') return true;
      if (lowerValue == 'false' || lowerValue == '0') return false;
    }
    if (value is int) {
      return value != 0;
    }
    return defaultValue;
  }

  /// 安全的列表转换
  static List<T> safeList<T>(dynamic value, {
    List<T> defaultValue = const [],
    T Function(dynamic)? itemConverter,
  }) {
    if (value == null) return List.from(defaultValue);
    if (value is! List) return List.from(defaultValue);
    
    if (itemConverter != null) {
      return value.map((item) {
        try {
          return itemConverter(item);
        } catch (e) {
          return null;
        }
      }).where((item) => item != null).cast<T>().toList();
    }
    
    return value.whereType<T>().toList();
  }

  /// 安全的Map转换
  static Map<String, dynamic> safeMap(dynamic value, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    if (value == null) return Map.from(defaultValue);
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return Map.from(defaultValue);
  }

  /// 安全的JSON解析
  static Map<String, dynamic>? safeJsonDecode(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    
    try {
      final decoded = json.decode(jsonString);
      return safeMap(decoded);
    } catch (e) {
      return null;
    }
  }

  /// 安全的JSON编码
  static String? safeJsonEncode(dynamic value) {
    if (value == null) return null;
    
    try {
      return json.encode(value);
    } catch (e) {
      return null;
    }
  }

  /// 验证非空字符串
  static bool isNonEmptyString(dynamic value) {
    return value is String && value.trim().isNotEmpty;
  }

  /// 验证字符串是否有效（非空且不为null）
  static bool isValidString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// 验证有效的数字
  static bool isValidNumber(dynamic value) {
    if (value is num) return !value.isNaN && value.isFinite;
    if (value is String) {
      final parsed = num.tryParse(value);
      return parsed != null && !parsed.isNaN && parsed.isFinite;
    }
    return false;
  }

  /// 验证有效的邮箱格式
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 验证有效的URL格式
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 深度复制Map
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic> original) {
    final jsonString = safeJsonEncode(original);
    if (jsonString == null) return {};
    return safeJsonDecode(jsonString) ?? {};
  }

  /// 安全的枚举转换
  static T? safeEnum<T extends Enum>(List<T> values, dynamic value) {
    if (value == null) return null;
    
    if (value is T) return value;
    
    if (value is String) {
      try {
        return values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
        );
      } catch (e) {
        return null;
      }
    }
    
    if (value is int && value >= 0 && value < values.length) {
      return values[value];
    }
    
    return null;
  }
}

/// 可空类型扩展
extension NullableExtensions<T> on T? {
  /// 如果为null则使用默认值
  T orDefault(T defaultValue) {
    return this ?? defaultValue;
  }

  /// 如果不为null则执行操作
  R? let<R>(R Function(T) operation) {
    final value = this;
    return value != null ? operation(value) : null;
  }

  /// 如果为null则执行操作
  T orElse(T Function() operation) {
    return this ?? operation();
  }
}

/// 字符串类型安全扩展
extension StringSafetyExtensions on String? {
  /// 安全的trim操作
  String? get safeTrim => this?.trim();
  
  /// 检查是否为空或null
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// 检查是否为空白或null
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  
  /// 安全的substring操作
  String? safeSubstring(int start, [int? end]) {
    final str = this;
    if (str == null || start < 0 || start >= str.length) return null;
    
    final actualEnd = end != null && end <= str.length ? end : str.length;
    if (actualEnd <= start) return null;
    
    return str.substring(start, actualEnd);
  }
}

/// 列表类型安全扩展
extension ListSafetyExtensions<T> on List<T>? {
  /// 安全的获取元素
  T? safeGet(int index) {
    final list = this;
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }
  
  /// 检查是否为空或null
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// 安全的第一个元素
  T? get safeFirst {
    final list = this;
    return list != null && list.isNotEmpty ? list.first : null;
  }
  
  /// 安全的最后一个元素
  T? get safeLast {
    final list = this;
    return list != null && list.isNotEmpty ? list.last : null;
  }
}

/// Map类型安全扩展
extension MapSafetyExtensions<K, V> on Map<K, V>? {
  /// 安全的获取值
  V? safeGet(K key) {
    return this?[key];
  }
  
  /// 检查是否为空或null
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// 安全的获取字符串值
  String? safeGetString(K key, {String? defaultValue}) {
    final value = this?[key];
    return TypeSafetyUtils.safeCast<String>(value) ?? defaultValue;
  }
  
  /// 安全的获取整数值
  int? safeGetInt(K key, {int? defaultValue}) {
    final value = this?[key];
    if (value == null) return defaultValue;
    return TypeSafetyUtils.safeInt(value, defaultValue: defaultValue ?? 0);
  }
  
  /// 安全的获取布尔值
  bool? safeGetBool(K key, {bool? defaultValue}) {
    final value = this?[key];
    if (value == null) return defaultValue;
    return TypeSafetyUtils.safeBool(value, defaultValue: defaultValue ?? false);
  }
}