import '../../core/models/delete_user_response_model.dart';
import '../repositories/delete_user_repository.dart';

class DeleteUserUseCase {
  final DeleteUserRepository _deleteUserRepository;

  DeleteUserUseCase(this._deleteUserRepository);

  Future<DeleteUserResponseModel> executeDeleteUser(int userId) async {
    print("UseCase: Calling repository to delete user $userId");
    return await _deleteUserRepository.removeUser(userId);
  }
}
