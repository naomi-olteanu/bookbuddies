import 'package:flutter/material.dart';
import 'package:bookbuddies/pages/add_book_page.dart';
import 'package:bookbuddies/pages/all_books_page.dart';
import 'package:bookbuddies/pages/my_books_page.dart';
import 'package:bookbuddies/pages/my_borrow_requests_page.dart';
import 'package:bookbuddies/pages/my_borrowed_books_page.dart';
import 'package:bookbuddies/pages/owner_requests_page.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();
  final _userService = UserService();
  AppUser? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final u = await _userService.getUser(_auth.currentUser!.uid);
    setState(() => user = u);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BookBuddies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _auth.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user!.role == 'admin')
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'ADMIN ACCOUNT',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                _heroSection(),

                const SizedBox(height: 32),

                Expanded(child: _actionsGrid(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧠 HERO SECTION
  Widget _heroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${user!.name} 👋',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share books. Build trust. Read together.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),

          Row(
            children: [
              _statCard('Rating', user!.rating.toStringAsFixed(1)),
              const SizedBox(width: 16),
              _statCard('Favors', user!.favors.toString()),
            ],
          ),
        ],
      ),
    );
  }

  // 📊 STAT CARD
  Widget _statCard(String label, String value) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // 🧭 ACTION GRID
  Widget _actionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.6,
      children: [
        _actionCard(
          icon: Icons.person,
          title: 'Profile',
          subtitle: 'View and edit your profile',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
        ),
        _actionCard(
          icon: Icons.add,
          title: 'Add Book',
          subtitle: 'Share a book you own',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookPage()),
          ),
        ),
        _actionCard(
          icon: Icons.menu_book,
          title: 'My Books',
          subtitle: 'Books you listed',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyBooksPage()),
          ),
        ),
        _actionCard(
          icon: Icons.search,
          title: 'Browse Books',
          subtitle: 'Find books to borrow',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllBooksPage()),
          ),
        ),
        _actionCard(
          icon: Icons.schedule,
          title: 'My Requests',
          subtitle: 'Borrow requests you made',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyBorrowRequestsPage()),
          ),
        ),
        _actionCard(
          icon: Icons.handshake,
          title: 'Borrowed Books',
          subtitle: 'Books you currently have',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyBorrowedBooksPage()),
          ),
        ),
        _actionCard(
          icon: Icons.inbox,
          title: 'Requests for My Books',
          subtitle: 'Approve or reject requests',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OwnerRequestsPage()),
          ),
        ),
      ],
    );
  }

  // 🧩 ACTION CARD
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
