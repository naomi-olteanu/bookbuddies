import 'package:bookbuddies/pages/community_page.dart';
import 'package:bookbuddies/pages/home_page.dart';
import 'package:bookbuddies/pages/profile_page.dart';
import 'package:bookbuddies/widgets/web_footer.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../pages/all_books_page.dart';
import '../pages/my_books_page.dart';
import '../pages/contact_page.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../pages/owner_requests_page.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final AppUser? user;
  final String title;

  const MainLayout({
    super.key,
    required this.child,
    this.user,
    this.title = 'BookBuddies',
  });

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      drawer: !isDesktop && user != null ? _buildMobileDrawer(context) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              leading: !isDesktop && user != null
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  : null,
              title: InkWell(onTap: () => _goHome(context), child: Text(title)),
              actions: _buildMobileActions(context),
            ),
      body: Column(
        children: [
          if (isDesktop) _buildDesktopNavBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: child,
                    ),
                  ),
                  const WebFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildDesktopNavBar(BuildContext context) {
    final textColor = Theme.of(context).textTheme.titleMedium?.color;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: scaffoldBg,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _goHome(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_stories,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BookBuddies',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 40),
          
          _navButton(
            context,
            'My Books',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBooksPage()),
            ),
          ),
          _navButton(
            context,
            'Browse',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllBooksPage()),
            ),
          ),
          _navButton(
            context,
            'Community',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityPage()),
            ),
          ),
          _navButton(
            context,
            'Contact',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactPage()),
            ),
          ),

          const Spacer(),

          // Right Side Actions
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: ThemeController.toggleTheme,
              );
            },
          ),
          const SizedBox(width: 16),
          if (user != null) ...[
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  user!.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: AuthService().logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(user!.name),
            accountEmail: Text(user!.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user!.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 24, color: AppColors.primary),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('My Books'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBooksPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Browse Books'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllBooksPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inbox),
            title: const Text('Inbox (Requests)'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OwnerRequestsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text('Contact Us'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactPage()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: AuthService().logout,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMobileActions(BuildContext context) {
    return [
      ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.themeMode,
        builder: (context, mode, _) {
          return IconButton(
            icon: Icon(
              mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: ThemeController.toggleTheme,
          );
        },
      ),
    ];
  }

  Widget _navButton(BuildContext context, String label, VoidCallback onTap) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
