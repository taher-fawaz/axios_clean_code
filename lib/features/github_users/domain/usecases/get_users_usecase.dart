import 'package:axios/core/errors/failures.dart';
import 'package:axios/core/usecases/usecase.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:axios/features/github_users/domain/repositories/github_repositoy.dart';
import 'package:fpdart/fpdart.dart';

class GetGithubUsersUseCase implements UseCase<List<GitHubUser>, String> {
  final GitHubRepository _repository;
  const GetGithubUsersUseCase(this._repository);

  @override
  Future<Either<Failure, List<GitHubUser>>> call(String query) async {
    return await _repository.searchUsers(query);
  }
}
