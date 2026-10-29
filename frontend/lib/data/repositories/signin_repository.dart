import '../../core/models/login_model.dart';
import '../../core/models/login_response_model.dart';
import '../../core/network/signin_service.dart';
import '../../utils/shared_preferences_helper.dart'; // Import the helper

class SigninRepository {
  final SigninService _signinService;

  SigninRepository(this._signinService);

  Future<LoginResponseModel?> login(LoginModel user) async {
    LoginResponseModel? response = await _signinService.login(user);

    if (response != null && response.token.isNotEmpty) {
      await SharedPreferencesHelper.saveToken(
          response.token); // ✅ Save the token using helper
      print("🟢 Token saved successfully: ${response.token}");
    } else {
      print("❌ Login failed or token is empty!");
    }

    return response;
  }
}
