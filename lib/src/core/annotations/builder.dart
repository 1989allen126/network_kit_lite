import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'endpoint_generator.dart';

/// Endpoint 代码生成器 Builder
/// 用于注册代码生成器
Builder endpointBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [EndpointGenerator()],
    'endpoint',
  );
}

