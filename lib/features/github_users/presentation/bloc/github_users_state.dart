part of 'github_users_bloc.dart';

class GithubUsersState extends Equatable {
  final List<GitHubUser> users;

  final Failure? errorMessage;
  final GitHubUser? gitHubUser;
  final RequestStatus status;

  const GithubUsersState({
    this.users = const [],
    this.errorMessage,
    this.gitHubUser,
    this.status = RequestStatus.initial,
  });

  GithubUsersState copyWith({
    List<GitHubUser>? users,
    Failure? errorMessage,
    GitHubUser? gitHubUser,
    RequestStatus? status,
  }) {
    return GithubUsersState(
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      gitHubUser: gitHubUser ?? this.gitHubUser,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        users,
        errorMessage,
        gitHubUser,
        status,
      ];
}
