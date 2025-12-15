import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class MyBorrowRequestsPage extends StatefulWidget {
  const MyBorrowRequestsPage({super.key});

  @override
  State<MyBorrowRequestsPage> createState() => _MyBorrowRequestsPageState();
}

class _MyBorrowRequestsPageState extends State<MyBorrowRequestsPage> {
  final _auth = AuthService();
  final _txService = TransactionService();

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
    
    final result = await _txService.getRequestsByBorrower(uid);
    if (mounted) {
      setState(() {
        requests = result;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainLayout(
      title: 'My Requests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sent Requests',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track the status of books you want to borrow.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          requests.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, i) {
                    final r = requests[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.outbox, color: AppColors.primary),
                        ),
                        title: Text(
                          r.bookTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Owner: ${r.ownerName}'),
                        trailing: _buildStatusBadge(r.status),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'returned':
        color = Colors.blue;
        icon = Icons.assignment_return;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No requests found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}