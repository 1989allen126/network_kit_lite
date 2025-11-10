import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'endpoint_file_generator.dart';

/// Endpoint 文件生成器 Builder
/// 将生成的 endpoint 类统一放到 models 目录下，按功能划分文件
Builder endpointFileBuilder(BuilderOptions options) {
  return _EndpointFileBuilder();
}

/// Endpoint 文件生成器 Builder 实现
class _EndpointFileBuilder implements Builder {
  final EndpointFileGenerator _generator = EndpointFileGenerator();

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.dart'], // 输入文件，输出到 models 目录
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // 只处理包含 API 注解的文件
    final inputId = buildStep.inputId;
    if (!inputId.path.endsWith('.dart')) {
      return;
    }

    // 读取库
    final library = await buildStep.resolver.libraryFor(inputId);
    final libraryReader = LibraryReader(library);

    // 生成文件
    await _generator.generateFiles(libraryReader, buildStep);
  }
}

