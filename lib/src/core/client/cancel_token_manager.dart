import '../models/network_cancel_token.dart';

/// 取消令牌管理器
class CancelTokenManager {
  final Map<String, NetworkCancelToken> _cancelTokens = {};

  /// 管理取消令牌
  NetworkCancelToken? manageCancelToken(NetworkCancelToken? cancelToken) {
    if (cancelToken == null) return null;
    final key = cancelToken.cancelTokenKey;
    cancelRequest(cancelToken);
    _cancelTokens[key] = cancelToken;
    return cancelToken;
  }

  /// 移除取消令牌
  void removeCancelToken(NetworkCancelToken? cancelToken) {
    if (cancelToken != null) {
      _cancelTokens.remove(cancelToken.cancelTokenKey);
    }
  }

  /// 取消特定请求
  /// [cancelToken] 取消令牌，可以是 NetworkCancelToken 或 String
  void cancelRequest(dynamic cancelToken) {
    NetworkCancelToken? token;
    String? key;
    if (cancelToken is NetworkCancelToken) {
      token = cancelToken;
      key = cancelToken.cancelTokenKey;
    } else if (cancelToken is String) {
      key = cancelToken;
      token = _cancelTokens[key];
    } else {
      return;
    }
    if (token != null && !token.isCancelled) {
      token.cancel('Request cancelled by user: $key');
    }
    _cancelTokens.remove(key);
  }

  /// 取消所有请求
  void cancelAllRequests() {
    _cancelTokens.forEach((key, token) {
      if (!token.isCancelled) {
        token.cancel('All requests cancelled by user');
      }
    });
    _cancelTokens.clear();
  }

  /// 清空所有令牌
  void clear() {
    _cancelTokens.clear();
  }
}

