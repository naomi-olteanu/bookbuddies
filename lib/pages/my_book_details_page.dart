import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/models/transaction_model.dart';
import 'package:bookbuddies/models/user_model.dart';
import 'package:bookbuddies/pages/add_book_page.dart';
import 'package:bookbuddies/services/transaction_service.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book_model.dart';

class MyBookDetailsPage extends StatefulWidget {
  final Book book;

  const MyBookDetailsPage({super.key, required this.book});

  @override
  State<MyBookDetailsPage> createState() => _MyBookDetailsPageState();
}

class _MyBookDetailsPageState extends State<MyBookDetailsPage> {
  final _userService = UserService();
  final _transactionService = TransactionService();

  AppUser? _currentUser;
  int _selectedImageIndex = 0;
  bool _isLoading = true;
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await _userService.getUser(uid);
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestBorrow() async {
    if (_currentUser == null) return;

    if (_currentUser!.favors < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough favor points to borrow.')),
      );
      return;
    }

    setState(() => _isSendingRequest = true);

    final tx = TransactionModel(
      id: '',
      bookId: widget.book.id,
      bookTitle: widget.book.title,
      ownerId: widget.book.ownerId,
      ownerName: widget.book.ownerName,
      borrowerId: _currentUser!.id,
      borrowerName: _currentUser!.email,
      status: 'pending',
    );

    try {
      await _transactionService.createRequest(tx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Borrow request sent successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSendingRequest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isOwner = _currentUser?.id == widget.book.ownerId;

    return MainLayout(
      title: widget.book.title,
      user: _currentUser,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          const SizedBox(height: 16),

          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: _buildImageGallery(context)),
                const SizedBox(width: 40),
                Expanded(flex: 5, child: _buildBookInfo(context, isOwner)),
              ],
            )
          else
            Column(
              children: [
                _buildImageGallery(context),
                const SizedBox(height: 32),
                _buildBookInfo(context, isOwner),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final images = widget.book.userImages;
    if (images.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.book, size: 80, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black12,
            image: DecorationImage(
              image: NetworkImage(images[_selectedImageIndex]),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedImageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBookInfo(BuildContext context, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Availability Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.book.isAvailable
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.book.isAvailable ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Text(
            widget.book.isAvailable ? 'Available Now' : 'Currently Unavailable',
            style: TextStyle(
              color: widget.book.isAvailable
                  ? Colors.green[800]
                  : Colors.red[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 🏷️ TITLE HEADER & EDIT BUTTON (MOVED HERE)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${widget.book.authors.join(", ")}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // Edit button sits to the right of the title block
            if (isOwner) ...[
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddBookPage(
                        bookToEdit: widget.book,
                      ), // 🆕 Pass the book!
                    ),
                  ).then((_) {
                    // 🆕 Reload user or refresh logic if needed when coming back
                  });
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  // Make it slightly more compact for the header
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 32),

        // Owner Info
        Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwner
                      ? 'You own this book'
                      : 'Owned by ${widget.book.ownerName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (!isOwner)
                  const Text(
                    'Reliable lender (4.8 ★)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        // 📦 METADATA CHIPS (MOVED ABOVE DESCRIPTION)
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _detailChip(
              context,
              'Condition',
              widget.book.condition.name.replaceAll('_', ' '),
            ),
            _detailChip(
              context,
              'Language',
              widget.book.language.toUpperCase(),
            ),
            _detailChip(context, 'Edition', widget.book.edition),
          ],
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),

        // Description
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.book.description,
          style: const TextStyle(height: 1.6, fontSize: 16),
        ),

        const SizedBox(height: 40),

        // 🚀 ACTION BUTTON (ONLY FOR BORROWERS NOW)
        if (!isOwner)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isSendingRequest || !widget.book.isAvailable
                  ? null
                  : _requestBorrow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSendingRequest
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Request to Borrow',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
        // Add some bottom padding for the owner view so it doesn't look cut off
        if (isOwner) const SizedBox(height: 20),
      ],
    );
  }

  Widget _detailChip(BuildContext context, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
