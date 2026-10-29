import '../../core/models/signup_model.dart';
import '../repositories/signup_repository.dart';

class SignupUseCase {
  final SignupRepository _signupRepository;

  SignupUseCase(this._signupRepository);

  Future<String> execute(SignupModel user) async {
    return await _signupRepository.signup(user);
  }
}
