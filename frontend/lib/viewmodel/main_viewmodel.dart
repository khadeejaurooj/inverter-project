import 'package:flutter/material.dart';
import '../data/usecases/get_inverter_data_usecase.dart';
import '../core/models/main_model.dart';
import '../core/network/api_config.dart';
import '../utils/shared_preferences_helper.dart';

class MainViewModel extends ChangeNotifier {
  final GetInverterDataUseCase getInverterDataUseCase;

  MainViewModel(this.getInverterDataUseCase);

  MainModel? latestInverter;

  /// All readings returned by the API, oldest first (used for the dashboard chart).
  List<MainModel> history = [];
  bool isLoading = true;

  Future<void> fetchInverterData(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    String? token = await SharedPreferencesHelper.getToken();
    String? macAddress = await SharedPreferencesHelper.getMacAddress();

    if (token == null) {
      _showError(context, "Authorization token not found! Please login again.");
      return;
    }

    if (macAddress == null) {
      macAddress = ApiConfig.defaultInverterMac; // Default value
      await SharedPreferencesHelper.saveMacAddress(macAddress);
    }

    List<MainModel>? data = await getInverterDataUseCase(token);

    if (data != null && data.isNotEmpty) {
      history = [...data]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      latestInverter =
          data.reduce((a, b) => a.createdAt.compareTo(b.createdAt) > 0 ? a : b);
    } else {
      _showError(context, "Failed to fetch inverter data.");
    }

    isLoading = false;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
