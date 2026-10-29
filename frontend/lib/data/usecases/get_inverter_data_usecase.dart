import '../../data/repositories/main_repository.dart';
import '../../core/models/main_model.dart';

class GetInverterDataUseCase {
  final MainRepository mainRepository;

  GetInverterDataUseCase(this.mainRepository);

  Future<List<MainModel>?> call(String token) async {
    return await mainRepository.fetchInverterData(token);
  }
}
