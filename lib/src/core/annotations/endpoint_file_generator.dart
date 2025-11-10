import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'utils/annotation_utils.dart';
import 'utils/endpoint_code_generator.dart';

/// Endpoint 文件生成器
/// 将生成的 endpoint 类统一放到 models 目录下，按功能划分文件
class EndpointFileGenerator {
  /// 生成所有 endpoint 文件
  Future<void> generateFiles(LibraryReader library, BuildStep buildStep) async {
    try {
      // 收集所有带有 API 注解的方法
      final apiMethods = <ClassElement, List<MethodElement>>{};

      for (final element in library.allElements) {
        try {
          if (element is! ClassElement || !element.isAbstract) {
            continue;
          }

          // 检查类是否有 @ApiModule 注解
          final apiModule = AnnotationUtils.getApiModule(element);
          if (apiModule == null) {
            continue;
          }

          // 收集类中所有带有 API 注解的方法
          final methods = <MethodElement>[];
          for (final method in element.methods) {
            try {
              if (AnnotationUtils.hasApiAnnotation(method)) {
                methods.add(method);
              }
            } catch (e) {
              // 忽略单个方法的错误，继续处理下一个
              continue;
            }
          }

          if (methods.isNotEmpty) {
            apiMethods[element] = methods;
          }
        } catch (e) {
          // 忽略单个类的错误，继续处理下一个
          continue;
        }
      }

      if (apiMethods.isEmpty) {
        return;
      }

      // 为每个 API 接口类生成一个独立的文件
      for (final entry in apiMethods.entries) {
        try {
          final apiClass = entry.key;
          final methods = entry.value;

          // 生成文件内容
          final fileContent = _generateFileContent(methods);
          if (fileContent.isNotEmpty) {
            // 生成文件路径：lib/src/core/models/{class_name}_endpoints.dart
            final fileName = _getFileName(apiClass.name);
            final outputId = AssetId(
              buildStep.inputId.package,
              'lib/src/core/models/$fileName',
            );

            // 写入文件
            await buildStep.writeAsString(outputId, fileContent);
          }
        } catch (e) {
          // 忽略单个文件的生成错误，继续处理下一个
          continue;
        }
      }
    } catch (e) {
      // 完善的异常处理，防止文件生成失败导致构建失败
      // 不抛出异常，确保构建过程不会中断
    }
  }

  /// 获取文件名
  String _getFileName(String className) {
    // 将类名转换为文件名：UserApi -> user_api_endpoints.dart
    final fileName = AnnotationUtils.toSnakeCase(className);
    return '${fileName}_endpoints.dart';
  }

  /// 生成文件内容
  String _generateFileContent(List<MethodElement> methods) {
    try {
      final buffer = StringBuffer();

      // 文件头部
      buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
      buffer.writeln();
      buffer.writeln("import 'package:network_kit_lite/network_kit_lite.dart';");
      buffer.writeln();

      // 为每个方法生成 endpoint 类
      for (final method in methods) {
        try {
          final endpointClass = _generateEndpointClass(method);
          if (endpointClass.isNotEmpty) {
            buffer.writeln(endpointClass);
            buffer.writeln();
          }
        } catch (e) {
          // 忽略单个方法的生成错误，继续处理下一个
          continue;
        }
      }

      return buffer.toString();
    } catch (e) {
      // 返回空字符串而不是抛出异常
      return '';
    }
  }

  /// 生成 Endpoint 类
  String _generateEndpointClass(MethodElement method) {
    try {
      // 获取方法注解
      final annotation = AnnotationUtils.getApiAnnotation(method);
      if (annotation == null) {
        return '';
      }

      final annotationType = annotation.element?.name;
      if (annotationType == null || !AnnotationUtils.isApiMethodAnnotation(annotationType)) {
        return '';
      }

      final reader = ConstantReader(annotation.computeConstantValue());
      return EndpointCodeGenerator.generateEndpointClass(
        method: method,
        annotation: reader,
        annotationType: annotationType,
      );
    } catch (e) {
      // 返回空字符串而不是抛出异常
      return '';
    }
  }
}
