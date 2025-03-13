import 'package:axios/features/github_users/data/models/github_user_model.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';

import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_url.dart';

sealed class GitHubRemoteDataSource {
  Future<List<GitHubUser>> searchUsers(String query);
  Future<GitHubUser> getUserDetails(String username);
}

class GitHubRemoteDataSourceImpl implements GitHubRemoteDataSource {
  final ApiHelper _helper;

  const GitHubRemoteDataSourceImpl(this._helper);

  @override
  Future<GitHubUser> getUserDetails(String username) async {
    final endPoint = "${ApiUrl.users}$username";
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: endPoint,
      );
      return GitHubUserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GitHubUser>> searchUsers(String query) async {
    final endPoint = "${ApiUrl.searchUsers}?q=$query";
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: endPoint,
      );
      return (response['items'] as List)
          .map((json) => GitHubUserModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
