part of 'github_users_bloc.dart';

abstract class GithubUsersEvent extends Equatable {
  const GithubUsersEvent();

  @override
  List<Object> get props => [];
}

class GetGithubUsersEvent extends GithubUsersEvent {
  final String query;
  const GetGithubUsersEvent({required this.query});
  @override
  List<Object> get props => [query];
}

class GetGithubUserDetailsEvent extends GithubUsersEvent {
  final String username;
  const GetGithubUserDetailsEvent({required this.username});
  @override
  List<Object> get props => [username];
}
