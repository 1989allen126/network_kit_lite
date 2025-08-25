// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:network_kit_lite/src/core/cache/cache_policy.dart';

class OptionsExtraData {
  // 缓存策略
  CachePolicy cachePolicy = CachePolicy.networkOnly;
  // 缓存时间
  Duration cacheDuration = const Duration(minutes: 5);
  // 重试配置
  bool shouldRetry = false;
  // 重试次数
  int maxRetries = 3;
  // 端点信息
  APIEndpoint? endpoint;

  OptionsExtraData({
    this.cachePolicy = CachePolicy.networkOnly,
    this.cacheDuration = const Duration(minutes: 5),
    this.shouldRetry = false,
    this.maxRetries = 3,
    this.endpoint
  });

  factory OptionsExtraData.copyWith({
    required APIEndpoint endPoint,
    bool customTimeOut = false,
  }) {
    // 只有自定义超时的时候（customTimeOut=true）, endpoint才会被赋值
    return OptionsExtraData()
      ..endpoint = customTimeOut ? endPoint:null
      ..cachePolicy = endPoint.cachePolicy
      ..cacheDuration = endPoint.cacheDuration
      ..shouldRetry = endPoint.shouldRetry
      ..maxRetries = endPoint.maxRetries;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cachePolicy': cachePolicy,
      'cacheDuration': cacheDuration,
      'shouldRetry': shouldRetry,
      'maxRetries': maxRetries,
      'endpoint':endpoint
    };
  }
}
