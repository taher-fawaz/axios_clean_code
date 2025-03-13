import 'dart:convert';

import 'package:axios/features/github_users/data/models/github_user_model.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GitHubSearchLocalDataSource {
  Future<void> cacheSearchResults(String query, List<GitHubUser> users);
  Future<List<GitHubUser>?> getCachedSearchResults(String query);
  Future<void> cacheUserDetails(GitHubUser user);
  Future<GitHubUser?> getCachedUserDetails(String username);
  Future<void> clearCache();
}

class GitHubSearchLocalDataSourceImpl extends GitHubSearchLocalDataSource {
  static const String _searchPrefix = 'github_search_';
  static const String _userPrefix = 'github_user_';
  static const Duration _cacheExpiry = Duration(hours: 24);
  final SharedPreferences prefs;
  GitHubSearchLocalDataSourceImpl(this.prefs);

  // Cache search results
  @override
  Future<void> cacheSearchResults(String query, List<GitHubUser> users) async {
    try {
      final key = _searchPrefix + query.toLowerCase();

      final List<Map<String, dynamic>> jsonList = [];
      for (var user in users) {
        if (user is GitHubUserModel) {
          jsonList.add(user.toJson());
        }
      }

      final cacheEntry = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'results': jsonList,
      };

      await prefs.setString(key, jsonEncode(cacheEntry));
    } catch (e) {
      // Silent error handling for cache operations
      print('Error caching search results: $e');
    }
  }

  // Retrieve cached search results
  @override
  Future<List<GitHubUser>?> getCachedSearchResults(String query) async {
    try {
      final key = _searchPrefix + query.toLowerCase();

      final cachedData = prefs.getString(key);
      if (cachedData == null) return null;

      final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = cacheEntry['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Check if cache is expired
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        await prefs.remove(key);
        return null;
      }

      final List<dynamic> jsonList = cacheEntry['results'];
      return jsonList.map((json) => GitHubUserModel.fromJson(json)).toList();
    } catch (e) {
      // Silent error handling for cache operations
      print('Error retrieving cached search results: $e');
      return null;
    }
  }

  // Cache user details
  @override
  Future<void> cacheUserDetails(GitHubUser user) async {
    try {
      if (user is! GitHubUserModel) return;

      final key = _userPrefix + user.login!.toLowerCase();

      final cacheEntry = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'user': user.toJson(),
      };

      await prefs.setString(key, jsonEncode(cacheEntry));
    } catch (e) {
      // Silent error handling for cache operations
      print('Error caching user details: $e');
    }
  }

  // Retrieve cached user details
  @override
  Future<GitHubUser?> getCachedUserDetails(String username) async {
    try {
      final key = _userPrefix + username.toLowerCase();

      final cachedData = prefs.getString(key);
      if (cachedData == null) return null;

      final cacheEntry = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = cacheEntry['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Check if cache is expired
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        await prefs.remove(key);
        return null;
      }

      return GitHubUserModel.fromJson(cacheEntry['user']);
    } catch (e) {
      // Silent error handling for cache operations
      print('Error retrieving cached user details: $e');
      return null;
    }
  }

  // Clear all cached data
  @override
  Future<void> clearCache() async {
    try {
      final allKeys = prefs.getKeys();
      for (var key in allKeys) {
        if (key.startsWith(_searchPrefix) || key.startsWith(_userPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
