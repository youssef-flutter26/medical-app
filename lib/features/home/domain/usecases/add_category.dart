import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class AddCategory {
  final HomeRepository repository;

  AddCategory(this.repository);

  Future<Result<void>> call(CategoryEntity category) {
    return repository.addCategory(category);
  }
}
