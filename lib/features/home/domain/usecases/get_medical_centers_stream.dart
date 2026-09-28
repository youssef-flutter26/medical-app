import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class GetMedicalCentersStream {
  final HomeRepository repository;

  GetMedicalCentersStream(this.repository);

  Stream<List<MedicalCenterEntity>> call() {
    return repository.getMedicalCentersStream();
  }
}
