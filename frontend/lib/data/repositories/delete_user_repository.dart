import '../../core/models/delete_user_response_model.dart';
import '../../core/network/delete_user_service.dart';

class DeleteUserRepository {
  final DeleteUserService _deleteUserService;

  DeleteUserRepository(this._deleteUserService);

  Future<DeleteUserResponseModel> removeUser(int userId) async {
    print("Repository: Calling service to delete user $userId");
    return await _deleteUserService.deleteUser(userId);
  }
}
