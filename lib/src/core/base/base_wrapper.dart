import 'package:network_kit_lite/src/core/base/base_response.dart';

abstract class BaseWrapper {
  final BaseResponse baseBean;

  const BaseWrapper(this.baseBean);

  dynamic get code => baseBean.code;

  bool get succeed => baseBean.isSuccess;

  bool get isSuccessWithData => baseBean.isSuccessWithData;

  String get message => baseBean.message ?? '';
}
