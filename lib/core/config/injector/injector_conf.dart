import 'package:axios/core/api/api_helper.dart';
import 'package:axios/core/api/api_interceptor.dart';
import 'package:axios/features/github_users/di/github_users_dependency.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injector.dart';

final injection = GetIt.instance;

Future<void> configureDependencies() async {
  injection.registerLazySingleton<ApiInterceptor>(() => ApiInterceptor());

  final dio = Dio()..interceptors.add(injection<ApiInterceptor>());
  injection.registerLazySingleton<Dio>(() => dio);

  final apiHelper = ApiHelper(injection<Dio>());
  injection.registerLazySingleton<ApiHelper>(() => apiHelper);

  await GithubDependency.init();
}
