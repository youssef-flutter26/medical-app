import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';

class GetCategoriesStream {
  final HomeRepository repository;

  GetCategoriesStream(this.repository);

  Stream<List<CategoryEntity>> call() {
    return repository.getCategoriesStream();
  }
}
