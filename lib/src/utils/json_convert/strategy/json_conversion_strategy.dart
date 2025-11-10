/// JSON 转换策略接口
/// 定义不同类型数据的转换策略
abstract class JsonConversionStrategy {
  /// 判断是否支持该类型
  bool canHandle(dynamic value);

  /// 执行转换
  /// [value] 要转换的值
  /// [visited] 已访问的对象集合（用于检测循环引用）
  /// 返回转换后的值，如果转换失败则返回 null
  dynamic convert(dynamic value, {Set<Object?>? visited});
}
