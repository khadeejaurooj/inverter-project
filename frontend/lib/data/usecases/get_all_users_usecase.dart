import '../../core/models/users_model.dart';
import '../repositories/user_repository.dart';

class GetAllUsersUseCase {
  final UserRepository _userRepository;

  GetAllUsersUseCase(this._userRepository);

  Future<List<UsersModel>> execute() async {
    return await _userRepository.getAllUsers();
  }
}
