import 'package:axios/core/config/injector/injector_conf.dart';
import 'package:axios/features/github_users/data/datasources/local_data_source.dart';
import 'package:axios/features/github_users/data/datasources/remote_data_source.dart';
import 'package:axios/features/github_users/data/repositories/github_repositoy_impl.dart';
import 'package:axios/features/github_users/domain/repositories/github_repositoy.dart';
import 'package:axios/features/github_users/domain/usecases/get_user_details_usecase.dart';
import 'package:axios/features/github_users/domain/usecases/get_users_usecase.dart';
import 'package:axios/features/github_users/presentation/bloc/github_users_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GithubDependency {
  GithubDependency._();

  static Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    injection.registerLazySingletonAsync<SharedPreferences>(
      () async => sharedPrefs,
    );
    // DataSources
    injection.registerLazySingleton<GitHubRemoteDataSource>(
        () => GitHubRemoteDataSourceImpl(injection()));
    injection.registerLazySingleton<GitHubSearchLocalDataSource>(
        () => GitHubSearchLocalDataSourceImpl(sharedPrefs));

    // Repository
    injection.registerLazySingleton<GitHubRepository>(
        () => GitHubRepositoryImpl(injection(), injection()));

    // UseCases
    injection.registerLazySingleton<GetGithubUsersUseCase>(
        () => GetGithubUsersUseCase(injection()));

    injection.registerLazySingleton<GetGithubUserDetailsUseCase>(
        () => GetGithubUserDetailsUseCase(injection()));

    // Controller
    injection.registerFactory(
      () => GithubUsersBloc(injection(), injection()),
    );
  }
}
