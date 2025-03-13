import 'package:axios/core/errors/failures.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:fpdart/fpdart.dart';

abstract class GitHubRepository {
  Future<Either<Failure, List<GitHubUser>>> searchUsers(String query);
  Future<Either<Failure, GitHubUser>> getUserDetails(String username);
}
