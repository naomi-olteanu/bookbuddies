import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/services/book_service.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:bookbuddies/theme/app_theme.dart';
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
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final result = await _txService.getApprovedBorrowedBooks(uid);

    if (mounted) {
      setState(() {
        borrowedBooks = result;
        isLoading = false;
      });
    }
  }

  Future<void> returnBook(TransactionModel tx) async {
    await _txService.markReturned(tx.id);
    await _bookService.setBookAvailability(tx.bookId, true);
    await _userService.incrementFavors(tx.ownerId, 1);

    load();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book returned. Favor awarded to owner.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainLayout(
      title: 'Borrowed Books',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Loans',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Books you are currently reading. Please return them in good condition.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          borrowedBooks.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: borrowedBooks.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final tx = borrowedBooks[index];
                    return _buildBorrowedCard(tx);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBorrowedCard(TransactionModel tx) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon Placeholder
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tx.bookTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Owner: ${tx.ownerName}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => returnBook(tx),
                      icon: const Icon(Icons.keyboard_return, size: 16),
                      label: const Text('Return Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('You are not borrowing any books right now.', 
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}