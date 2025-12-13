import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';

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

  void loadBooks() async {
    final userId = _auth.currentUser!.uid;
    final result = await _bookService.getBooksByOwner(userId);
    setState(() {
      books = result;
      isLoading = false;
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
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  trailing: Icon(
                    book.isAvailable
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: book.isAvailable
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              },
            ),
    );
  }
}
