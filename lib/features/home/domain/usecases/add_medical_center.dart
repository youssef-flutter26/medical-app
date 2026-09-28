import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class AddMedicalCenter {
  final HomeRepository repository;

  AddMedicalCenter(this.repository);

  Future<Result<void>> call(MedicalCenterEntity center) {
    return repository.addMedicalCenter(center);
  }
}
