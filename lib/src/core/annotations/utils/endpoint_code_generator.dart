import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation_utils.dart';
import 'parameter_parser.dart';

/// Endpoint 代码生成器
/// 负责生成 Endpoint 类的代码
class EndpointCodeGenerator {
  /// 生成 Endpoint 类代码
  static String generateEndpointClass({
    required MethodElement method,
    required ConstantReader annotation,
    required String annotationType,
  }) {
    try {
      final className = AnnotationUtils.getEndpointClassName(method.name);
      final path = annotation.read('path').stringValue;
      final module = annotation.read('module').stringValue;
      final responseType = annotation.read('responseType').stringValue;

      // 获取返回类型
      final returnType = AnnotationUtils.getReturnType(method.returnType);
      final genericType = AnnotationUtils.extractGenericType(returnType);

      // 获取 HTTP 方法
      final httpMethod = AnnotationUtils.getHttpMethod(annotationType);

      // 解析方法参数
      final parameters = ParameterParser.parseParameters(method.parameters);

      // 生成类代码
      final buffer = StringBuffer();
      buffer.writeln('/// ${method.documentationComment ?? method.name} API 端点');
      buffer.writeln('class $className extends ${_getEndpointBaseClass(responseType, genericType)} {');

      // 生成字段
      for (final param in parameters.fields) {
        buffer.writeln('  final ${param.type} ${param.name};');
      }

      // 生成构造函数
      if (parameters.fields.isNotEmpty) {
        buffer.write('  $className({');
        for (var i = 0; i < parameters.fields.length; i++) {
          final param = parameters.fields[i];
          if (i > 0) buffer.write(', ');
          if (param.isRequired) {
            buffer.write('required this.${param.name}');
          } else {
            buffer.write('this.${param.name}');
          }
        }
        buffer.writeln('});');
      } else {
        buffer.writeln('  $className();');
      }

      // 生成 path getter
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  String get path => \'$path\';');

      // 生成 httpMethod getter
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  HTTPMethod get httpMethod => HTTPMethod.$httpMethod;');

      // 生成 module getter
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  String get module => \'$module\';');

      // 生成 queryParameters getter
      if (parameters.queryParams.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('  @override');
        buffer.writeln('  Map<String, dynamic>? get queryParameters => {');
        for (final param in parameters.queryParams) {
          final paramName = param.name;
          final queryName = param.queryName ?? paramName;
          if (param.isNullable) {
            buffer.writeln('        if ($paramName != null) \'$queryName\': $paramName,');
          } else {
            buffer.writeln('        \'$queryName\': $paramName,');
          }
        }
        buffer.writeln('      };');
      } else {
        buffer.writeln();
        buffer.writeln('  @override');
        buffer.writeln('  Map<String, dynamic>? get queryParameters => null;');
      }

      // 生成 requestBody getter
      if (parameters.bodyParam != null) {
        buffer.writeln();
        buffer.writeln('  @override');
        buffer.writeln('  dynamic get requestBody => ${parameters.bodyParam!.name};');
      } else {
        buffer.writeln();
        buffer.writeln('  @override');
        buffer.writeln('  dynamic get requestBody => null;');
      }

      // 生成 parseItem 或 parseElement 方法
      if (responseType == 'list') {
        buffer.writeln();
        buffer.writeln('  @override');
        buffer.writeln('  $genericType parseElement(dynamic element) {');
        buffer.writeln('    return $genericType.fromJson(element);');
        buffer.writeln('  }');
      } else {
        buffer.writeln();
        buffer.writeln('  @override');
        buffer.writeln('  $genericType parseItem(dynamic item) {');
        if (genericType == 'Map<String, dynamic>') {
          buffer.writeln('    return item as Map<String, dynamic>;');
        } else {
          buffer.writeln('    return $genericType.fromJson(item);');
        }
        buffer.writeln('  }');
      }

      buffer.writeln('}');
      return buffer.toString();
    } catch (e, stackTrace) {
      // 完善的异常处理，防止代码生成失败导致构建失败
      throw Exception('生成 Endpoint 类失败: $e\n堆栈跟踪: $stackTrace');
    }
  }

  /// 获取 Endpoint 基类
  static String _getEndpointBaseClass(String responseType, String genericType) {
    if (responseType == 'list') {
      return 'ListAPIEndpoint<$genericType>';
    } else if (responseType == 'raw') {
      return 'RawAPIEndpoint';
    } else {
      return 'GenericAPIEndpoint<$genericType>';
    }
  }
}

