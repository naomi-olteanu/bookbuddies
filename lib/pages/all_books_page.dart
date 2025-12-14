import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final _transactionService = TransactionService();
  final _userService = UserService();

  // State
  List<Book> _allBooks = []; // Master list
  List<Book> _filteredBooks = []; // Display list
  AppUser? _currentUser;
  int _userFavors = 0;
  bool _isLoading = true;
  String _currentUserId = '';

  // Search Controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Fetch data in parallel
    final results = await Future.wait([
      _bookService.getAllAvailableBooks(),
      _userService.getUser(uid),
      FirebaseFirestore.instance.collection('users').doc(uid).get(),
    ]);

    if (mounted) {
      setState(() {
        _allBooks = results[0] as List<Book>;
        _filteredBooks = _allBooks; // Initially show all
        _currentUser = results[1] as AppUser?;
        
        final userDoc = results[2] as DocumentSnapshot;
        _userFavors = (userDoc.data() as Map<String, dynamic>?)?['favors'] ?? 0;
        
        _isLoading = false;
      });
    }
  }

  // 🔍 SEARCH LOGIC
  void _onSearchChanged(String query) {
    final lowerQuery = query.toLowerCase().trim();

    setState(() {
      if (lowerQuery.isEmpty) {
        _filteredBooks = _allBooks;
      } else {
        _filteredBooks = _allBooks.where((book) {
          final titleMatch = book.title.toLowerCase().contains(lowerQuery);
          // Check if ANY author matches
          final authorMatch = book.authors.any((author) => 
            author.toLowerCase().contains(lowerQuery));
          
          return titleMatch || authorMatch;
        }).toList();
      }
    });
  }

  // 🤝 BORROW LOGIC
  void requestBorrow(Book book) async {
    if (book.ownerId == _currentUserId) return;

    if (_userFavors <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough favor points to borrow.')),
      );
      return;
    }

    final tx = TransactionModel(
      id: '',
      bookId: book.id,
      bookTitle: book.title,
      ownerId: book.ownerId,
      ownerName: book.ownerName,
      borrowerId: _currentUserId,
      borrowerName: _currentUser?.email ?? 'Unknown',
      status: 'pending',
    );

    try {
      await _transactionService.createRequest(tx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent! Waiting for owner approval.')),
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainLayout(
      title: 'Browse Books',
      user: _currentUser,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ HEADER
          Text(
            'Explore Library',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your next adventure. You have $_userFavors favor points available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 32),

          // 🔎 SEARCH BAR
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              labelText: 'Search by Title or Author',
              hintText: 'e.g. Harry Potter, Austen...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 📚 GRID CONTENT
          if (_filteredBooks.isEmpty)
            _buildEmptyState()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredBooks.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280, // Slightly wider cards for browse view
                childAspectRatio: 0.75,  // Taller cards
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemBuilder: (context, index) {
                return _buildBookCard(_filteredBooks[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search terms.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    final isMe = book.ownerId == _currentUserId;
    final imageUrl = book.userImages.isNotEmpty ? book.userImages.first : null;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🖼️ IMAGE
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, size: 48, color: Colors.grey),
                      ),
                if (isMe)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('YOURS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          
          // ℹ️ DETAILS
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  book.authors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isMe ? 'You' : book.ownerName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 🔘 ACTION BUTTON
                SizedBox(
                  width: double.infinity,
                  child: isMe
                      ? OutlinedButton(
                          onPressed: null, // Disabled
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text('Your Listing', style: TextStyle(color: Colors.grey)),
                        )
                      : ElevatedButton(
                          onPressed: () => requestBorrow(book),
                          child: const Text('Request Borrow'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}