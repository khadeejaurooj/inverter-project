import '../../core/models/signup_model.dart';
import '../../core/network/signup_service.dart';
import '../../utils/shared_preferences_helper.dart';

class SignupRepository {
  final SignupService _signupService;

  SignupRepository(this._signupService);

  Future<String> signup(SignupModel user) async {
    // A brand-new user has no token yet, so it is sent only when one exists.
    String? token = await SharedPreferencesHelper.getToken();
    return await _signupService.signup(user, token);
  }
}
