import '../../core/models/login_model.dart';
import '../../core/models/login_response_model.dart';
import '../repositories/signin_repository.dart';

class SigninUseCase {
  final SigninRepository _signinRepository;

  SigninUseCase(this._signinRepository);

  Future<LoginResponseModel?> execute(LoginModel user) async {
    return await _signinRepository.login(user);
  }
}
