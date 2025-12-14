import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import '../widgets/my_book_card.dart';
import 'my_book_details_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  final _auth = AuthService();
  final _bookService = BookService();

  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final userId = _auth.currentUser!.uid;
    final result = await _bookService.getBooksByOwner(userId);
    setState(() {
      books = result;
      isLoading = false;
    });
  }

  Future<void> deletePopupBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete book'),
        content: const Text(
            'Are you sure you want to delete this book? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 1. Delete images from Storage
    final folderRef =
        FirebaseStorage.instance.ref('books/${book.id}');
    final items = await folderRef.listAll();
    for (final item in items.items) {
      await item.delete();
    }

    // 2. Delete Firestore document
    await _bookService.deleteBook(book.id);

    // 3. Refresh UI
    setState(() {
      books.removeWhere((b) => b.id == book.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Books')),
      body: books.isEmpty
          ? const Center(child: Text('No books added yet'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: books.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
                          builder: (_) =>
                              MyBookDetailsPage(book: book),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}


