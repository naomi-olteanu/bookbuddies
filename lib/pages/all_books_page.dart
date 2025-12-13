import 'package:bookbuddies/models/transaction_model.dart';
import 'package:bookbuddies/services/transaction_service.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';

class AllBooksPage extends StatefulWidget {
  const AllBooksPage({super.key});

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  final _bookService = BookService();
  int userFavors = 0;
  final _userService = UserService();
  late final String currentUserId;

  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    loadBooks();
    loadUserFavors();
  }

  void loadBooks() async {
    final result = await _bookService.getAllAvailableBooks();
    setState(() {
      books = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Available Books')),
      body: books.isEmpty
          ? const Center(child: Text('No available books'))
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.author} • ${book.ownerId == currentUserId ? "me" : book.ownerName}',
                  ),
                  trailing: book.ownerId == currentUserId
                      ? const SizedBox.shrink()
                      : ElevatedButton(
                          child: const Text('Borrow'),
                          onPressed: () => requestBorrow(book),
                        ),
                );
              },
            ),
    );
  }

  void requestBorrow(Book book) async {
  if (book.ownerId == currentUserId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You cannot borrow your own book')),
    );
    return;
  }

  if (userFavors <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not enough favor points')),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser!;

  final tx = TransactionModel(
    id: '',
    bookId: book.id,
    bookTitle: book.title,
    ownerId: book.ownerId,
    ownerName: book.ownerName,
    borrowerId: user.uid,
    borrowerName: user.email ?? '',
    status: 'pending',
  );

  await TransactionService().createRequest(tx);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Borrow request sent')),
  );
}


  Future<void> loadUserFavors() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      userFavors = doc.data()?['favors'] ?? 0;
    });
  }
}
