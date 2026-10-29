import 'package:flutter/material.dart';
import '../data/usecases/change_password_usecase.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordUseCase _useCase;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  ChangePasswordViewModel(this._useCase);

  Future<void> changePassword(
      String oldPass, String newPass, String confirmPass, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final message =
          await _useCase.execute(oldPass, newPass, confirmPass, token);
      successMessage = message;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Failed to change password";
      successMessage = null;
    }
    isLoading = false;
    notifyListeners();
  }
}
