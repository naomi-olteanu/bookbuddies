import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/forum_post_model.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/pages/create_forum_post_page.dart';
import 'package:bookbuddies/pages/forum_thread_page.dart';
import 'package:bookbuddies/services/auth_service.dart';
import 'package:bookbuddies/services/forum_service.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ForumPostsPage extends StatefulWidget {
  const ForumPostsPage({super.key});

  @override
  State<ForumPostsPage> createState() => _ForumPostsPageState();
}

class _ForumPostsPageState extends State<ForumPostsPage> {
  final ForumService _forumService = ForumService();
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  List<ForumPost> _forums = [];
  AppUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUser();
    await _loadForums();
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final user = await _userService.getUser(uid);
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadForums() async {
    setState(() => _isLoading = true);
    final forums = await _forumService.getAllForums();
    if (!mounted) return;
    setState(() {
      _forums = forums;
      _isLoading = false;
    });
  }

  Future<void> _goToCreateForum() async {
    if (_currentUser == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateForumPostPage(currentUser: _currentUser!),
      ),
    );
    await _loadForums();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      user: _currentUser,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: 40),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
          else
            _buildForumList(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Forums',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join book clubs, discuss genres, and connect with other readers.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          if (_currentUser != null)
            ElevatedButton.icon(
              onPressed: _goToCreateForum,
              icon: const Icon(Icons.add),
              label: const Text('Start Discussion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForumList() {
    if (_forums.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(Icons.forum_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No discussions found. Be the first to start one!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _forums.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final forum = _forums[index];
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (_currentUser == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForumThreadPage(forum: forum, currentUser: _currentUser!),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  _getTypeIcon(forum.type),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(forum.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          forum.type == 'book' ? "Book: ${forum.bookTitle}" : forum.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 20, color: AppColors.primary),
                      Text('${forum.messageCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getTypeIcon(String type) {
    IconData icon;
    Color color;
    if (type == 'book') {
      icon = Icons.book;
      color = AppColors.primary;
    } else if (type == 'genre') {
      icon = Icons.style;
      color = AppColors.secondary;
    } else {
      icon = Icons.chat_bubble;
      color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color),
    );
  }
}