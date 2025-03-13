import 'dart:async';

import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:axios/features/github_users/presentation/bloc/github_users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GitHubSearchField extends StatefulWidget {
  const GitHubSearchField({super.key});

  @override
  State<GitHubSearchField> createState() => _GitHubSearchFieldState();
}

class _GitHubSearchFieldState extends State<GitHubSearchField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showSuggestions = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showSuggestions = true;
      _updateOverlay();
    } else {
      _showSuggestions = false;
      _removeOverlay();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<GithubUsersBloc>().add(GetGithubUsersEvent(query: query));
        _updateOverlay();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _removeOverlay();

    if (!_showSuggestions) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => BlocBuilder<GithubUsersBloc, GithubUsersState>(
        builder: (context, state) {
          final List<GitHubUser> users = state.users;

          if (users.isEmpty) return const SizedBox.shrink();

          return Positioned(
            width: _getWidth(),
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, _getSearchFieldHeight()),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: users.length > 10 ? 10 : users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final bool isSelected = index == _selectedIndex;

                      return InkWell(
                        onTap: () => _selectUser(user.login!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          color: isSelected ? Colors.grey.shade200 : null,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.avatarUrl!),
                                radius: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.login!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (user.name != null)
                                      Text(
                                        user.name!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  double _getWidth() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.size.width;
  }

  double _getSearchFieldHeight() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  void _selectUser(String username) {
    _removeOverlay();
    _searchController.text = username;
    _focusNode.unfocus();
    context
        .read<GithubUsersBloc>()
        .add(GetGithubUserDetailsEvent(username: username));
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final state = context.read<GithubUsersBloc>().state;
    final users = state.users;
    if (users.isEmpty || !_showSuggestions) return;

    final int itemCount = users.length > 10 ? 10 : users.length;

    switch (event.logicalKey.keyLabel) {
      case 'Arrow Down':
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % itemCount;
          _updateOverlay();
        });
        break;
      case 'Arrow Up':
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + itemCount) % itemCount;
          _updateOverlay();
        });
        break;
      case 'Enter':
        if (_selectedIndex >= 0 && _selectedIndex < itemCount) {
          _selectUser(users[_selectedIndex].login!);
        } else if (_searchController.text.isNotEmpty) {
          _selectUser(_searchController.text);
        }
        break;
      case 'Escape':
        _removeOverlay();
        _focusNode.unfocus();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyEvent,
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search GitHub users...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _removeOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _selectUser(value);
            }
          },
        ),
      ),
    );
  }
}
