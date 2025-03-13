import 'package:axios/core/errors/failures.dart';
import 'package:axios/core/usecases/usecase.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:axios/features/github_users/domain/repositories/github_repositoy.dart';
import 'package:fpdart/fpdart.dart';

class GetGithubUserDetailsUseCase implements UseCase<GitHubUser, String> {
  final GitHubRepository _repository;
  const GetGithubUserDetailsUseCase(this._repository);

  @override
  Future<Either<Failure, GitHubUser>> call(String username) async {
    return await _repository.getUserDetails(username);
  }
}
