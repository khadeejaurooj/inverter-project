import 'package:flutterproject/core/models/change_password_request_model.dart';
import 'package:flutterproject/core/network/change_password_service.dart';

class ChangePasswordRepository {
  final ChangePasswordService _changePasswordService;

  ChangePasswordRepository(this._changePasswordService);

  Future<String> changePassword(
      ChangePasswordRequestModel request, String token) {
    return _changePasswordService.changePassword(request, token);
  }
}
