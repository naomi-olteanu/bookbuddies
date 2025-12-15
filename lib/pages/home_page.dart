import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/book_model.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/pages/add_book_page.dart';
import 'package:bookbuddies/pages/all_books_page.dart';
import 'package:bookbuddies/pages/book_details_page.dart';
import 'package:bookbuddies/services/book_service.dart';
import 'package:bookbuddies/widgets/web_carousel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();
  final _userService = UserService();
  final _bookService = BookService();

  AppUser? user;
  List<Book> recentBooks = [];
  List<AppUser> topUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // fetch Current User
    final u = await _userService.getUser(currentUser.uid);

    // fetch Books
    final books = await _bookService.getAllAvailableBooks();

    // fetch all Users (leaderboard)
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    final allUsers = userSnapshot.docs
        .map((d) => AppUser.fromMap(d.id, d.data()))
        .toList();

    // Score = (Rating * 10) + (Favors * 2)
    allUsers.sort((a, b) {
      final scoreA = (a.rating * 10) + (a.favors * 2);
      final scoreB = (b.rating * 10) + (b.favors * 2);
      return scoreB.compareTo(scoreA); // Descending order
    });

    if (mounted) {
      setState(() {
        user = u;
        recentBooks = books.take(5).toList();
        topUsers = allUsers.take(5).toList(); // Take top 5 
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return MainLayout(
      user: user,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(context, isDesktop),
          const SizedBox(height: 60),
          _buildBooksCarousel(context),
          const SizedBox(height: 60),
          _buildUsersCarousel(context),
          const SizedBox(height: 60),
          _buildCallToAction(context, isDesktop),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    final textSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${user!.name}!',
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 36 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Discover your next favorite story or share the magic of reading with your community.',
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllBooksPage()),
          ),
          icon: const Icon(Icons.search),
          label: const Text('Start Browsing'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );

    final statsSection = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _heroStat('Rating', user!.rating.toStringAsFixed(1), Icons.star),
          Container(
            height: 50,
            width: 1,
            color: Colors.white30,
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
          _heroStat('Favors', user!.favors.toString(), Icons.handshake),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
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
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: textSection),
                const SizedBox(width: 40),
                statsSection,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [textSection, const SizedBox(height: 32), statsSection],
            ),
    );
  }

  Widget _heroStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBooksCarousel(BuildContext context) {
    return WebCarousel<Book>(
      title: 'Trending Books',
      items: recentBooks,
      onSeeAll: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllBooksPage()),
      ),
      itemBuilder: (context, book) {
        final imageUrl = book.userImages.isNotEmpty
            ? book.userImages.first
            : null;

        // ✅ MADE CLICKABLE
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MyBookDetailsPage(book: book)),
            );
          },
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.book, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authors.join(', '),
                        maxLines: 1,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersCarousel(BuildContext context) {
    return WebCarousel<AppUser>(
      title: 'Top Contributors',
      items: topUsers,
      height: 200,
      itemBuilder: (context, userItem) {
        return Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondary,
                child: Text(
                  userItem.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                userItem.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  Text(
                    ' ${userItem.rating.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallToAction(BuildContext context, bool isDesktop) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Have books gathering dust?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Share them with the community and earn Favor Points to borrow new reads!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );

    final buttonContent = ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBookPage()),
        ).then((_) {
          _loadData();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        minimumSize: isDesktop ? null : const Size(double.infinity, 50),
      ),
      child: const Text('Add a Book Now'),
    );

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: textContent),
                buttonContent,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textContent,
                const SizedBox(height: 24),
                buttonContent,
              ],
            ),
    );
  }
}
