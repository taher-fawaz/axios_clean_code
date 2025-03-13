import 'package:axios/core/api/api_exception.dart';
import 'package:axios/core/errors/exceptions.dart';
import 'package:axios/core/errors/failures.dart';
import 'package:axios/core/utils/helper_functions.dart';
import 'package:axios/features/github_users/data/datasources/local_data_source.dart';
import 'package:axios/features/github_users/data/datasources/remote_data_source.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:axios/features/github_users/domain/repositories/github_repositoy.dart';
import 'package:fpdart/fpdart.dart';

class GitHubRepositoryImpl implements GitHubRepository {
  final GitHubRemoteDataSource _remoteDataSource;
  final GitHubSearchLocalDataSource _localDataSource;

  const GitHubRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, GitHubUser>> getUserDetails(String username) async {
    try {
      // Try to get from cache first
      final cachedUser = await _localDataSource.getCachedUserDetails(username);
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      final result = await _remoteDataSource.getUserDetails(username);

      // Cache the result for future use
      await _localDataSource.cacheUserDetails(result);

      return Right(result);
    } on BadRequestException {
      return Left(ServerFailure(message: "error"));
    } on ServerException {
      return Left(ServerFailure(message: "error"));
    } catch (e) {
      return Left(ServerFailure(message: "error"));
    }
  }

  @override
  Future<Either<Failure, List<GitHubUser>>> searchUsers(String query) async {
    final cachedResults = await _localDataSource.getCachedSearchResults(query);
    if (cachedResults != null) {
      return Right(cachedResults);
    }

    try {
      final result = await _remoteDataSource.searchUsers(query);

      // Cache the results for future use
      await _localDataSource.cacheSearchResults(query, result);

      return Right(result);
    } on BadRequestException {
      return Left(ServerFailure(message: "Bad request error"));
    } on ServerException {
      return Left(ServerFailure(message: "server error"));
    } catch (e) {
      return Left(ServerFailure(message: "error"));
    }
  }
}
