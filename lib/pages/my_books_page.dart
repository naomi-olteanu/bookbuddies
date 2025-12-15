import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/pages/add_book_page.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import '../widgets/my_book_card.dart';
import 'book_details_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  final _auth = AuthService();
  final _bookService = BookService();
  final _userService = UserService();

  List<Book> books = [];
  AppUser? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final results = await Future.wait([
      _bookService.getBooksByOwner(uid),
      _userService.getUser(uid),
    ]);

    if (mounted) {
      setState(() {
        books = results[0] as List<Book>;
        currentUser = results[1] as AppUser?;
        isLoading = false;
      });
    }
  }

  Future<void> deletePopupBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete book'),
        content: const Text(
          'Are you sure you want to delete this book? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      final folderRef = FirebaseStorage.instance.ref('books/${book.id}');
      final items = await folderRef.listAll();
      for (final item in items.items) {
        await item.delete();
      }
      await _bookService.deleteBook(book.id);

      if (mounted) {
        setState(() {
          books.removeWhere((b) => b.id == book.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting book: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainLayout(
      title: 'My Books',
      user: currentUser,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookshelf',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage the books you are sharing with the community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              if (MediaQuery.of(context).size.width > 600)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddBookPage()),
                    ).then((_) {
                      _loadData();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Book'),
                ),
            ],
          ),

          const SizedBox(height: 32),

          books.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: books.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return MyBookCard(
                      book: book,
                      onDelete: () => deletePopupBook(book),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyBookDetailsPage(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your bookshelf is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some books to start sharing with the community!',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddBookPage()),
            ),
            child: const Text('Add Your First Book'),
          ),
        ],
      ),
    );
  }
}
