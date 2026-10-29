import 'package:flutter/material.dart';
import 'package:flutterproject/views/delete_user_dialog.dart';
import 'package:flutterproject/views/main_screen.dart';
import '../core/models/login_model.dart';
import '../data/usecases/signin_usecase.dart';
import '../utils/shared_preferences_helper.dart'; // Import the helper

class SigninViewModel extends ChangeNotifier {
  final SigninUseCase _signinUseCase;
  bool isLoading = false;

  SigninViewModel(this._signinUseCase);

  Future<void> login({
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    LoginModel user = LoginModel(username: username, password: password);
    final loginResponse = await _signinUseCase.execute(user);

    isLoading = false;
    notifyListeners();

    if (loginResponse != null) {
      // ✅ Retrieve and print the token before navigating
      String? token = await SharedPreferencesHelper.getToken();
      if (token != null && token.isNotEmpty) {
        print("🟢 Token retrieved after login: $token");
      } else {
        print("❌ Token is missing after login!");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login failed. Please check credentials.")),
      );
    }
  }
}
