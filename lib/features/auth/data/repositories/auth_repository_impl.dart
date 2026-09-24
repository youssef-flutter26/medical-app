import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      return SuccessAPI(
        UserModel.fromFirebase(
          id: user.uid,
          email: user.email ?? email,
          name: user.displayName,
        ),
      );
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } on NetworkException catch (_) {
      return const ErrorAPI(NetworkFailure());
    } on ServerException catch (e) {
      return ErrorAPI(ServerFailure(statusCode: e.statusCode));
    } on ParsingException catch (_) {
      return const ErrorAPI(ParsingFailure());
    } catch (_) {
      return const ErrorAPI(UnknownFailure());
    }
  }

  @override
  Future<Result<UserEntity>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await remoteDataSource.signup(
        email: email,
        password: password,
        name: name,
      );

      return SuccessAPI(
        UserModel.fromFirebase(
          id: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? name,
        ),
      );
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } on NetworkException catch (_) {
      return const ErrorAPI(NetworkFailure());
    } on ServerException catch (e) {
      return ErrorAPI(ServerFailure(statusCode: e.statusCode));
    } on ParsingException catch (_) {
      return const ErrorAPI(ParsingFailure());
    } catch (_) {
      return const ErrorAPI(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();

      return const SuccessAPI(null);
    } on AuthException catch (e) {
      return ErrorAPI(_mapAuthException(e));
    } catch (_) {
      return const ErrorAPI(UnknownFailure());
    }
  }

  Failure _mapAuthException(AuthException exception) {
    return AuthFailure(exception.message);
  }
}
