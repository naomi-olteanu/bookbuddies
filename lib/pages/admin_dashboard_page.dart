import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'admin_users_page.dart';
import 'admin_books_page.dart';
import 'admin_forums_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  AppUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _denyAccess();
      return;
    }

    final user = await _userService.getUser(uid);
    if (!mounted) return;

    if (user == null || user.role != 'admin') {
      _denyAccess();
      return;
    }

    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  void _denyAccess() {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin access required')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Moderate Users'),
            subtitle: const Text('Block or unblock users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminUsersPage(),
                ),
              );
            },
          ),
          const Divider(),

          ListTile(
            title: const Text('Moderate Books'),
            subtitle: const Text('Delete inappropriate books'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminBooksPage(),
                ),
              );
            },
          ),
          const Divider(),

          ListTile(
            title: const Text('Moderate Forums'),
            subtitle: const Text('Delete or close forum discussions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminForumsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
