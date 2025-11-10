import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:network_kit_lite/network_kit_lite.dart';

part 'options_extra_data.freezed.dart';

/// 请求选项额外数据
@freezed
class OptionsExtraData with _$OptionsExtraData {
  const factory OptionsExtraData({
    /// 缓存策略
    @Default(CachePolicy.networkOnly) CachePolicy cachePolicy,

    /// 打印日志
    @Default(true) bool enableLogging,

    /// 缓存时间
    @Default(Duration(minutes: 5)) Duration cacheDuration,

    /// 重试配置
    @Default(false) bool shouldRetry,

    /// 重试次数
    @Default(3) int maxRetries,

    /// 是否跳过 Auth 鉴权校验导致的退出登录
    /// 当设置为 true 时，即使鉴权失败（如 401），也不会清除 token 和触发登录回调
    /// 适用于部分接口报错不影响 App 正常使用的场景
    @Default(false) bool skipAuthLogout,
  }) = _OptionsExtraData;

  /// 从 APIEndpoint 创建 OptionsExtraData
  factory OptionsExtraData.fromEndpoint({
    required APIEndpoint endPoint,
    bool customTimeOut = false,
    bool enableLogging = true,
  }) {
    return OptionsExtraData(
      cachePolicy: endPoint.cachePolicy,
      cacheDuration: endPoint.cacheDuration,
      shouldRetry: endPoint.shouldRetry,
      maxRetries: endPoint.maxRetries,
      enableLogging: enableLogging,
      skipAuthLogout: endPoint.skipAuthLogout,
    );
  }
}

/// OptionsExtraData 扩展方法
extension OptionsExtraDataExtension on OptionsExtraData {
  /// 转换为Map（用于 Dio Options.extra）
  Map<String, dynamic> toMap() {
    return {
      'cachePolicy': cachePolicy,
      'cacheDuration': cacheDuration,
      'shouldRetry': shouldRetry,
      'maxRetries': maxRetries,
      'enableLogging': enableLogging,
      'skipAuthLogout': this.skipAuthLogout,
    };
  }
}
