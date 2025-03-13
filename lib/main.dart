import 'package:axios/core/config/injector/injector_conf.dart';
import 'package:axios/features/github_users/presentation/bloc/github_users_bloc.dart';
import 'package:axios/features/github_users/presentation/pages/github_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<GithubUsersBloc>(
      create: (context) => GithubUsersBloc(injection(), injection()),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: GitHubSearchScreen(),
      ),
    );
  }
}
