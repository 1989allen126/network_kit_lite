import 'dart:convert';

class JsonConverter {
  // 将对象转换为JSON字符串
  static String toJsonString(dynamic object) {
    try {
      if (object == null) return 'null';

      // 处理基础类型
      if (object is String || object is num || object is bool) {
        return json.encode(object);
      }

      // 处理集合类型
      if (object is List) {
        final list = object.map((e) => convertToJson(e)).toList();
        return json.encode(list);
      }

      if (object is Map) {
        final map = <String, dynamic>{};
        object.forEach((key, value) {
          map[key.toString()] = convertToJson(value);
        });
        return json.encode(map);
      }

      // 处理有toJson方法的对象
      if (object && object is! Function) {
        try {
          final dynamic jsonData = (object as dynamic).toJson();
          return json.encode(jsonData);
        } catch (e) {
          // 回退到toString
          return json.encode(object.toString());
        }
      }

      // 默认情况
      return json.encode(object.toString());
    } catch (e) {
      // 异常处理
      return json.encode(object?.toString() ?? 'null');
    }
  }

  // 辅助方法：将对象转换为可JSON序列化的格式
  static dynamic convertToJson(dynamic value) {
    if (value == null) return null;

    if (value is String || value is num || value is bool) {
      return value;
    }

    if (value is List) {
      return value.map((e) => convertToJson(e)).toList();
    }

    if (value is Map) {
      final map = <String, dynamic>{};
      value.forEach((key, value) {
        map[key.toString()] = convertToJson(value);
      });
      return map;
    }

    try {
      return (value as dynamic).toJson();
    } catch (e) {
      return value.toString();
    }
  }
}
