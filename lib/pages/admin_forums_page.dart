import 'package:flutter/material.dart';
import '../models/forum_post_model.dart';
import '../services/forum_service.dart';
import '../app_layout/main_layout.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AdminForumsPage extends StatefulWidget {
  const AdminForumsPage({super.key});

  @override
  State<AdminForumsPage> createState() => _AdminForumsPageState();
}

class _AdminForumsPageState extends State<AdminForumsPage> {
  final ForumService _forumService = ForumService();
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  List<ForumPost> _forums = [];
  AppUser? _currentUser;
  bool _isLoading = true;
  bool get _isAdmin => _currentUser?.role == 'admin';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _currentUser = await _userService.getUser(uid);
    }
    final forums = await _forumService.getAllForums();
    if (!mounted) return;
    setState(() {
      _forums = forums;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      user: _currentUser,
      title: 'Moderate Forums',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Discussions',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _forums.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final forum = _forums[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: forum.isClosed
                                ? Colors.grey
                                : AppColors.primary,
                            child: Icon(
                              forum.isClosed ? Icons.lock : Icons.forum,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            forum.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            forum.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              if (!forum.isClosed)
                                ElevatedButton(
                                  onPressed: !_isAdmin
                                      ? null
                                      : () async {
                                          await _forumService.closeForum(
                                            forum.id,
                                          );
                                          _loadData();
                                        },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                  ),
                                  child: const Text('Close'),
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: !_isAdmin
                                    ? null
                                    : () async {
                                        await _forumService.deleteForum(
                                          forum.id,
                                        );
                                        _loadData();
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
