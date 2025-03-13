import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:axios/features/github_users/presentation/bloc/github_users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubUserDetailsScreen extends StatelessWidget {
  final GitHubUser user;

  const GitHubUserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // context.read<GithubUsersBloc>().add(GetGithubUserDetailsEvent(query: query));
    return Scaffold(
      appBar: AppBar(
        title: Text(user.login ?? 'User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _launchUrl(user.htmlUrl!),
            tooltip: 'Open in browser',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 24),
              if (user.bio != null && user.bio!.isNotEmpty) _buildBioSection(),
              const Divider(height: 32),
              _buildPersonalInfo(),
              const Divider(height: 32),
              _buildStatsSection(),
              const Divider(height: 32),
              _buildDatesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl!),
            radius: 50,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.name ?? user.login ?? 'GitHub User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        if (user.login != null)
          Center(
            child: Text(
              '@${user.login}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        const SizedBox(height: 8),
        if (user.type != null)
          Center(
            child: Chip(
              label: Text(user.type!),
              backgroundColor: Colors.blue[100],
            ),
          ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.bio!,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.business, 'Company', user.company),
        _buildInfoRow(Icons.location_on, 'Location', user.location),
        _buildInfoRow(Icons.email, 'Email', user.email),
        if (user.blog != null && user.blog!.isNotEmpty)
          _buildLinkRow(Icons.link, 'Blog', user.blog),
        if (user.twitterUsername != null && user.twitterUsername!.isNotEmpty)
          _buildLinkRow(
              Icons.alternate_email, 'Twitter', '@${user.twitterUsername}'),
        _buildInfoRow(
            Icons.work,
            'Hireable',
            user.hireable == true
                ? 'Yes'
                : user.hireable == false
                    ? 'No'
                    : null),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GitHub Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              'Repositories',
              user.publicRepos?.toString() ?? '0',
              Icons.folder,
              Colors.blue,
            ),
            _buildStatCard(
              'Gists',
              user.publicGists?.toString() ?? '0',
              Icons.note,
              Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard(
              'Followers',
              user.followers?.toString() ?? '0',
              Icons.people,
              Colors.purple,
            ),
            _buildStatCard(
              'Following',
              user.following?.toString() ?? '0',
              Icons.person_add,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    final dateFormat = DateFormat('MMMM d, yyyy');

    String formatDate(String? dateString) {
      if (dateString == null) return 'Unknown';
      try {
        final date = DateTime.parse(dateString);
        return dateFormat.format(date);
      } catch (e) {
        return 'Invalid date';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          Icons.calendar_today,
          'Member since',
          formatDate(user.createdAt),
        ),
        _buildInfoRow(
          Icons.update,
          'Last update',
          formatDate(user.updatedAt),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String label, String? url) {
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (label == 'Twitter') {
                      _launchUrl('https://twitter.com/${user.twitterUsername}');
                    } else {
                      String validUrl = url;
                      if (!url.startsWith('http')) {
                        validUrl = 'https://$url';
                      }
                      _launchUrl(validUrl);
                    }
                  },
                  child: Text(
                    url,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
