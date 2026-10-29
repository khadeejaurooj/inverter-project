import 'package:flutterproject/core/models/change_password_request_model.dart';
import 'package:flutterproject/data/repositories/change_password_repository.dart';

class ChangePasswordUseCase {
  final ChangePasswordRepository _changePasswordRepository;

  ChangePasswordUseCase(this._changePasswordRepository);

  Future<String> execute(
      String oldPass, String newPass, String confirmPass, String token) {
    final request = ChangePasswordRequestModel(
      oldPassword: oldPass,
      newPassword: newPass,
      confirmPassword: confirmPass,
    );

    return _changePasswordRepository.changePassword(request, token);
  }
}
