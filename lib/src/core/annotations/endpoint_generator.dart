import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'utils/annotation_utils.dart';
import 'utils/endpoint_code_generator.dart';

/// Endpoint 代码生成器
/// 读取注解并生成 endpoint 类
class EndpointGenerator extends GeneratorForAnnotation<Object> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    try {
      // 只处理方法元素
      if (element is! MethodElement) {
        return '';
      }

      final method = element;

      // 获取注解类型名称
      String? annotationType;
      try {
        // 尝试从注解对象中获取类型
        final annotationValue = annotation.objectValue;
        final annotationClass = annotationValue.type?.element?.name;
        annotationType = annotationClass;
      } catch (e) {
        // 如果无法获取，返回空字符串
        return '';
      }

      // 检查是否是 API 方法注解
      if (annotationType == null || !AnnotationUtils.isApiMethodAnnotation(annotationType)) {
        return '';
      }

      // 生成 Endpoint 类
      return EndpointCodeGenerator.generateEndpointClass(
        method: method,
        annotation: annotation,
        annotationType: annotationType,
      );
    } catch (e) {
      // 完善的异常处理，防止代码生成失败导致构建失败
      // 返回空字符串而不是抛出异常，确保构建过程不会中断
      return '';
    }
  }
}
