import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser(String uid);
}
