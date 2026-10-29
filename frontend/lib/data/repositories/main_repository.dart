import '../../core/models/main_model.dart';
import '../../core/network/main_services.dart';

class MainRepository {
  final MainServices mainServices;

  MainRepository(this.mainServices);

  Future<List<MainModel>?> fetchInverterData(String token) async {
    return await mainServices.getInverterData(token);
  }
}
