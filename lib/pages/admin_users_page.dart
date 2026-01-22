import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../app_layout/main_layout.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final UserService _userService = UserService();
  final AuthService _auth = AuthService();

  List<AppUser> _users = [];
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
    final users = await _userService.getAllUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      user: _currentUser,
      title: 'Moderate Users',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),
                _buildUserTable(),
              ],
            ),
    );
  }

  Widget _buildUserTable() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final bool isBlocked = user.isBlocked;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isBlocked ? Colors.red.withOpacity(0.05) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isBlocked ? Colors.grey : AppColors.primary,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Row(
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isBlocked)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Chip(
                      label: Text(
                        'Blocked',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              'Rating: ${user.rating.toStringAsFixed(1)} | Favors: ${user.favors}',
            ),
            trailing: Wrap(
              children: [
                TextButton(
                  onPressed: !_isAdmin
                      ? null
                      : () async {
                          await _userService.updateUser(user.id, {
                            'isBlocked': !isBlocked,
                          });
                          _loadData();
                        },

                  child: Text(
                    isBlocked ? 'Unblock' : 'Block',
                    style: TextStyle(
                      color: isBlocked ? AppColors.primary : Colors.red,
                    ),
                  ),
                ),
                if (user.role != 'admin')
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: !_isAdmin
                        ? null
                        : () async {
                            await _userService.deleteUser(user.id);
                            _loadData();
                          },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
