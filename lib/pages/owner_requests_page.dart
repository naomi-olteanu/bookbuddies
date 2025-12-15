import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/pages/rate_borrower_page.dart';
import 'package:bookbuddies/services/book_service.dart';
import 'package:bookbuddies/services/user_service.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class OwnerRequestsPage extends StatefulWidget {
  const OwnerRequestsPage({super.key});

  @override
  State<OwnerRequestsPage> createState() => _OwnerRequestsPageState();
}

class _OwnerRequestsPageState extends State<OwnerRequestsPage> {
  final _auth = AuthService();
  final _txService = TransactionService();
  final _bookService = BookService();
  final _userService = UserService();

  List<TransactionModel> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final result = await _txService.getRequestsForOwner(uid);
    if (mounted) {
      setState(() {
        requests = result;
        isLoading = false;
      });
    }
  }

  Future<void> approve(TransactionModel tx) async {
    await _txService.updateStatus(tx.id, 'approved');
    await _bookService.setBookAvailability(tx.bookId, false);
    await _userService.incrementFavors(tx.borrowerId, -1);
    load();
  }

  Future<void> reject(String id) async {
    await _txService.updateStatus(id, 'rejected');
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainLayout(
      title: 'Incoming Requests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lending Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage requests for your books. Approve loans or rate returned items.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          requests.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    return _buildRequestCard(requests[i]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(TransactionModel r) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getStatusColor(r.status).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(r.status), color: _getStatusColor(r.status)),
            ),
            const SizedBox(width: 16),
            
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.bookTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Borrower: ${r.borrowerName}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  if (r.status != 'pending') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${r.status.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(r.status),
                      ),
                    ),
                  ]
                ],
              ),
            ),

            // Actions
            if (r.status == 'pending') ...[
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                tooltip: 'Approve',
                onPressed: () => approve(r),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                tooltip: 'Reject',
                onPressed: () => reject(r.id),
              ),
            ] else if (r.status == 'returned' && r.rating == null) ...[
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RateBorrowerPage(transaction: r)),
                ).then((_) => load()), // Refresh after rating
                icon: const Icon(Icons.star, size: 16),
                label: const Text('Rate User'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'returned': return Colors.blue;
      default: return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check;
      case 'rejected': return Icons.close;
      case 'returned': return Icons.assignment_return;
      default: return Icons.access_time;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No requests yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}