import 'package:flutter/material.dart';
import '../core/models/signup_model.dart';
import '../data/usecases/signup_usecase.dart';
import '../views/login_screen.dart';

class SignupViewModel extends ChangeNotifier {
  final SignupUseCase _signupUseCase;
  bool isLoading = false;

  SignupViewModel(this._signupUseCase);

  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String username,
    required String lastname,
    required BuildContext context,
  }) async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    SignupModel user = SignupModel(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      username: username,
      lastname: lastname,
    );

    String responseMessage = await _signupUseCase.execute(user);

    isLoading = false;
    notifyListeners();

    if (responseMessage == "Signup Successful") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
    }
  }
}
