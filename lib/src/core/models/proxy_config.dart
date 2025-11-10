import 'package:freezed_annotation/freezed_annotation.dart';

part 'proxy_config.freezed.dart';
part 'proxy_config.g.dart';

/// 代理类型
enum ProxyType {
  /// HTTP 代理
  http,

  /// HTTPS 代理
  https,

  /// SOCKS5 代理
  socks5,
}

/// 代理配置
@freezed
class ProxyConfig with _$ProxyConfig {
  const factory ProxyConfig({
    /// 代理主机地址
    required String host,

    /// 代理端口
    required int port,

    /// 代理类型
    @Default(ProxyType.http) ProxyType type,

    /// 代理用户名（可选）
    String? username,

    /// 代理密码（可选）
    String? password,
  }) = _ProxyConfig;

  /// 从字符串创建代理配置
  /// [proxy] 代理地址（格式：http://host:port 或 socks5://host:port）
  /// [username] 代理用户名（可选）
  /// [password] 代理密码（可选）
  factory ProxyConfig.fromString({
    required String proxy,
    String? username,
    String? password,
  }) {
    try {
      final uri = Uri.parse(proxy);
      final host = uri.host;
      final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      final scheme = uri.scheme.toLowerCase();

      ProxyType type;
      if (scheme == 'socks5' || scheme == 'socks') {
        type = ProxyType.socks5;
      } else if (scheme == 'https') {
        type = ProxyType.https;
      } else {
        type = ProxyType.http;
      }

      return ProxyConfig(
        host: host,
        port: port,
        type: type,
        username: username,
        password: password,
      );
    } catch (e) {
      throw ArgumentError('无效的代理地址: $proxy');
    }
  }

  /// 从 JSON 创建
  factory ProxyConfig.fromJson(Map<String, dynamic> json) => _$ProxyConfigFromJson(json);
}

/// ProxyConfig 扩展方法
extension ProxyConfigExtension on ProxyConfig {
  /// 转换为代理字符串（用于 HttpClient.findProxy）
  String toProxyString() {
    switch (type) {
      case ProxyType.socks5:
        return 'PROXY $host:$port';
      case ProxyType.https:
      case ProxyType.http:
      default:
        return 'PROXY $host:$port';
    }
  }

  /// 转换为 URI 字符串
  String toUriString() {
    final scheme = type == ProxyType.socks5 ? 'socks5' : (type == ProxyType.https ? 'https' : 'http');
    if (username != null && password != null) {
      return '$scheme://$username:$password@$host:$port';
    }
    return '$scheme://$host:$port';
  }

  /// 是否启用认证
  bool get hasAuthentication => username != null && password != null;
}
