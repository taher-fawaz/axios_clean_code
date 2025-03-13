import 'package:axios/core/api/request_status.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:axios/features/github_users/presentation/bloc/github_users_bloc.dart';
import 'package:axios/features/github_users/presentation/pages/user_details_screen.dart';
import 'package:axios/features/github_users/presentation/widgets/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GitHubSearchScreen extends StatelessWidget {
  const GitHubSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub User Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GitHubSearchField(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<GithubUsersBloc, GithubUsersState>(
                listener: (context, state) {
                  // Navigate to details screen when a specific user is loaded
                  if (state.status == RequestStatus.success &&
                      state.gitHubUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GitHubUserDetailsScreen(
                          user: state.gitHubUser!,
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == RequestStatus.initial) {
                    return _buildInitialView();
                  } else if (state.status == RequestStatus.loading) {
                    return _buildLoadingView();
                  } else if (state.status == RequestStatus.success &&
                      state.users.isNotEmpty) {
                    return _buildUsersList(context, state.users);
                  } else if (state.errorMessage != null) {
                    return _buildErrorView(context, state);
                  } else {
                    return _buildInitialView();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Search for GitHub users',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Type in the search box to find users',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, List<GitHubUser> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl!),
          ),
          title: Text(user.login ?? 'Unknown User'),
          subtitle: user.type != null ? Text(user.type!) : null,
          onTap: () {
            context
                .read<GithubUsersBloc>()
                .add(GetGithubUserDetailsEvent(username: user.login!));
          },
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, GithubUsersState state) {
    final errorMessage = state.errorMessage?.message ?? "Something went wrong.";
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Occurred',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Return to initial state
              context
                  .read<GithubUsersBloc>()
                  .add(const GetGithubUsersEvent(query: ''));
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
