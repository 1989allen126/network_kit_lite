import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

/// 注解工具类
/// 提供公共的注解处理方法
class AnnotationUtils {
  /// 检查是否是 API 方法注解
  static bool isApiMethodAnnotation(String? annotationType) {
    return annotationType == 'ApiGET' ||
        annotationType == 'ApiPOST' ||
        annotationType == 'ApiPUT' ||
        annotationType == 'ApiDELETE' ||
        annotationType == 'ApiPATCH';
  }

  /// 获取 HTTP 方法名
  static String getHttpMethod(String annotationType) {
    switch (annotationType) {
      case 'ApiGET':
        return 'get';
      case 'ApiPOST':
        return 'post';
      case 'ApiPUT':
        return 'put';
      case 'ApiDELETE':
        return 'delete';
      case 'ApiPATCH':
        return 'patch';
      default:
        return 'get';
    }
  }

  /// 获取 Endpoint 类名
  static String getEndpointClassName(String methodName) {
    if (methodName.isEmpty) return 'Endpoint';
    // 将方法名转换为类名：test -> TestEndpoint, getUserInfo -> GetUserInfoEndpoint
    final className = methodName[0].toUpperCase() + methodName.substring(1);
    return '${className}Endpoint';
  }

  /// 获取返回类型字符串
  static String getReturnType(DartType returnType) {
    return returnType.getDisplayString(withNullability: false);
  }

  /// 提取泛型类型
  static String extractGenericType(String returnType) {
    // 从 Future<BaseResponse<T>> 中提取 T
    final match = RegExp(r'BaseResponse<([^>]+)>').firstMatch(returnType);
    if (match != null) {
      return match.group(1) ?? 'dynamic';
    }
    // 从 Future<List<T>> 中提取 T
    final listMatch = RegExp(r'List<([^>]+)>').firstMatch(returnType);
    if (listMatch != null) {
      return listMatch.group(1) ?? 'dynamic';
    }
    return 'dynamic';
  }

  /// 获取 API 模块名称
  static String? getApiModule(ClassElement classElement) {
    try {
      for (final annotation in classElement.metadata) {
        final annotationType = annotation.element?.name;
        if (annotationType == 'ApiModule') {
          final reader = ConstantReader(annotation.computeConstantValue());
          return reader.read('module').stringValue;
        }
      }
    } catch (e) {
      // 忽略异常，返回 null
    }
    return null;
  }

  /// 检查方法是否有 API 注解
  static bool hasApiAnnotation(MethodElement method) {
    try {
      for (final annotation in method.metadata) {
        final annotationType = annotation.element?.name;
        if (isApiMethodAnnotation(annotationType)) {
          return true;
        }
      }
    } catch (e) {
      // 忽略异常，返回 false
    }
    return false;
  }

  /// 获取 API 注解
  static ElementAnnotation? getApiAnnotation(MethodElement method) {
    try {
      for (final annotation in method.metadata) {
        final annotationType = annotation.element?.name;
        if (isApiMethodAnnotation(annotationType)) {
          return annotation;
        }
      }
    } catch (e) {
      // 忽略异常，返回 null
    }
    return null;
  }

  /// 转换为下划线命名法
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == char.toUpperCase() && i > 0) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }
}

