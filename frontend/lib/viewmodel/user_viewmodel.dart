import 'package:flutter/material.dart';
import '../core/models/users_model.dart';
import '../data/usecases/get_all_users_usecase.dart';

class UserViewModel extends ChangeNotifier {
  final GetAllUsersUseCase _getAllUsersUseCase;
  List<UsersModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserViewModel(this._getAllUsersUseCase);

  List<UsersModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _getAllUsersUseCase.execute();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
