import '../../core/models/users_model.dart';
import '../../core/network/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  Future<List<UsersModel>> getAllUsers() async {
    return await _userService.fetchUsers();
  }
}
