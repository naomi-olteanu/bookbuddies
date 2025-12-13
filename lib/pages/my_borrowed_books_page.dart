import 'package:bookbuddies/services/book_service.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class MyBorrowedBooksPage extends StatefulWidget {
  const MyBorrowedBooksPage({super.key});

  @override
  State<MyBorrowedBooksPage> createState() => _MyBorrowedBooksPageState();
}

class _MyBorrowedBooksPageState extends State<MyBorrowedBooksPage> {
  final _auth = AuthService();
  final _txService = TransactionService();
  final _bookService = BookService();
  final _userService = UserService();


  List<TransactionModel> borrowedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final result = await _txService
        .getApprovedBorrowedBooks(_auth.currentUser!.uid);

    setState(() {
      borrowedBooks = result;
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
      appBar: AppBar(title: const Text('My Borrowed Books')),
      body: borrowedBooks.isEmpty
          ? const Center(child: Text('No approved borrowed books'))
          : ListView.builder(
              itemCount: borrowedBooks.length,
              itemBuilder: (context, index) {
                final tx = borrowedBooks[index];
                return ListTile(
                  title: Text(tx.bookTitle),
                  subtitle: Text('Owner: ${tx.ownerName}'),
                  trailing: ElevatedButton(
    onPressed: () => returnBook(tx),
    child: const Text('Return'),
  ),
                );
              },
            ),
    );
  }

  void returnBook(TransactionModel tx) async {
  // 1. Mark transaction as returned
  await _txService.markReturned(tx.id);

  // 2. Make book available again
  await _bookService.setBookAvailability(tx.bookId, true);

  // 3. Reward owner with 1 favor
  await _userService.incrementFavors(tx.ownerId, 1);

  load();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Book returned. Favor awarded to owner.')),
  );
}


}
