import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// 网络取消令牌
class NetworkCancelToken extends CancelToken {
  final String _cancelTokenKey;

  NetworkCancelToken()
      : _cancelTokenKey = const Uuid().v4(),
        super();

  /// 获取取消令牌key
  String get cancelTokenKey => _cancelTokenKey;
}
