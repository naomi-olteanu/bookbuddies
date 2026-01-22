import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';
import '../app_layout/main_layout.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AdminBooksPage extends StatefulWidget {
  const AdminBooksPage({super.key});

  @override
  State<AdminBooksPage> createState() => _AdminBooksPageState();
}

class _AdminBooksPageState extends State<AdminBooksPage> {
  final BookService _bookService = BookService();
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  List<Book> _books = [];
  AppUser? _currentUser;
  bool _isLoading = true;

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
    
    final snapshot = await _bookService.books.get();
    final books = snapshot.docs
        .map((d) => Book.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();

    if (!mounted) return;
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  Future<void> _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book?'),
        content: Text('Are you sure you want to remove "${book.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _bookService.deleteBook(book.id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      user: _currentUser,
      title: 'Moderate Books',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Book Inventory', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 24),
                _buildBookGrid(),
              ],
            ),
    );
  }

  Widget _buildBookGrid() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        mainAxisExtent: 100,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, color: AppColors.primary),
            ),
            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Owner: ${book.ownerName}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteBook(book),
            ),
          ),
        );
      },
    );
  }
}