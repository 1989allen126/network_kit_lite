import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// 参数信息
class ParameterInfo {
  final String name;
  final String type;
  final bool isNullable;
  final bool isRequired;
  String? queryName;
  String? pathName;

  ParameterInfo({
    required this.name,
    required this.type,
    required this.isNullable,
    required this.isRequired,
    this.queryName,
    this.pathName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ParameterInfo && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// 方法参数信息
class MethodParameters {
  final List<ParameterInfo> fields;
  final List<ParameterInfo> queryParams;
  final ParameterInfo? bodyParam;
  final List<ParameterInfo> pathParams;

  MethodParameters({
    required this.fields,
    required this.queryParams,
    this.bodyParam,
    required this.pathParams,
  });
}

/// 参数解析器
/// 负责解析方法参数并分类
class ParameterParser {
  /// 解析方法参数
  static MethodParameters parseParameters(List<ParameterElement> parameters) {
    final fields = <ParameterInfo>[];
    final queryParams = <ParameterInfo>[];
    ParameterInfo? bodyParam;
    final pathParams = <ParameterInfo>[];

    for (final param in parameters) {
      try {
        // 检查类型是否可空
        final typeString = param.type.getDisplayString(withNullability: true);
        final isNullable = typeString.endsWith('?') || param.type.isDartCoreNull;

        final paramInfo = ParameterInfo(
          name: param.name,
          type: param.type.getDisplayString(withNullability: false),
          isNullable: isNullable,
          isRequired: param.isRequired,
        );

        // 检查参数注解
        final annotations = param.metadata;
        bool isProcessed = false;
        for (final annotation in annotations) {
          try {
            final annotationType = annotation.element?.name;
            if (annotationType == 'ApiQuery') {
              final reader = ConstantReader(annotation.computeConstantValue());
              final queryName = reader.read('name').stringValue;
              paramInfo.queryName = queryName.isEmpty ? null : queryName;
              queryParams.add(paramInfo);
              isProcessed = true;
              break;
            } else if (annotationType == 'ApiBody') {
              bodyParam = paramInfo;
              isProcessed = true;
              break;
            } else if (annotationType == 'ApiPath') {
              final reader = ConstantReader(annotation.computeConstantValue());
              final pathName = reader.read('name').stringValue;
              paramInfo.pathName = pathName.isEmpty ? null : pathName;
              pathParams.add(paramInfo);
              isProcessed = true;
              break;
            }
          } catch (e) {
            // 忽略单个注解的解析错误，继续处理下一个
            continue;
          }
        }

        // 如果没有注解，默认作为字段
        if (!isProcessed) {
          fields.add(paramInfo);
        }
      } catch (e) {
        // 忽略单个参数的解析错误，继续处理下一个
        continue;
      }
    }

    return MethodParameters(
      fields: fields,
      queryParams: queryParams,
      bodyParam: bodyParam,
      pathParams: pathParams,
    );
  }
}
