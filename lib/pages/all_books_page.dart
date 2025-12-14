import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Adjust these imports to match your actual folder structure
import '../models/transaction_model.dart'; 
import '../services/transaction_service.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';

class AllBooksPage extends StatefulWidget {
  const AllBooksPage({super.key});

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  final _bookService = BookService();
  final _transactionService = TransactionService(); // Instance for consistency
  
  int userFavors = 0;
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
    if (mounted) {
      setState(() {
        books = result;
        isLoading = false;
      });
    }
  }

  Future<void> loadUserFavors() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (mounted) {
      setState(() {
        userFavors = doc.data()?['favors'] ?? 0;
      });
    }
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
      id: '', // Firestore will generate this
      bookId: book.id,
      bookTitle: book.title,
      ownerId: book.ownerId,
      ownerName: book.ownerName,
      borrowerId: user.uid,
      borrowerName: user.email ?? 'Unknown',
      status: 'pending',
    );

    try {
      await _transactionService.createRequest(tx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Borrow request sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
                final isMe = book.ownerId == currentUserId;

                // LOGIC: Use first user image if available, otherwise null
                final String? imageUrl =
                    book.userImages.isNotEmpty ? book.userImages.first : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      // IMAGE SECTION
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 50,
                          height: 75,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, size: 20),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.book, color: Colors.grey),
                                ),
                        ),
                      ),
                      title: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.authors.join(', '), // FIXED: author -> authors
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Owner: ${isMe ? "Me" : book.ownerName}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: isMe
                          ? const Chip(label: Text('Yours', style: TextStyle(fontSize: 10)))
                          : ElevatedButton(
                              onPressed: () => requestBorrow(book),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Text('Borrow'),
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}