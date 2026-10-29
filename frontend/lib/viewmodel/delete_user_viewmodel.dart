import 'package:flutter/material.dart';
import 'package:flutterproject/core/models/delete_user_response_model.dart';
import '../data/usecases/delete_user_usecase.dart';

class DeleteUserViewModel extends ChangeNotifier {
  final DeleteUserUseCase _deleteUserUseCase;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;
  bool _isDeleted = false;

  DeleteUserViewModel(this._deleteUserUseCase);

  bool get isLoading => _isLoading;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;
  bool get isDeleted => _isDeleted;

  Future<void> deleteUser(int userId) async {
    print("deleteUser() called with userId: $userId");

    _isLoading = true;
    _successMessage = null;
    _errorMessage = null;
    _isDeleted = false;
    notifyListeners();

    try {
      DeleteUserResponseModel response =
          await _deleteUserUseCase.executeDeleteUser(userId);
      _successMessage = response.message;
      _isDeleted = true;
    } catch (e) {
      print("Error in ViewModel: $e");
      _errorMessage = "Error deleting user: $e";
      _isDeleted = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
