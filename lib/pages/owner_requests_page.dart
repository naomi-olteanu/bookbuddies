import 'package:bookbuddies/pages/rate_borrower_page.dart';
import 'package:bookbuddies/services/book_service.dart';
import 'package:bookbuddies/services/user_service.dart';
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
    final result =
        await _txService.getRequestsForOwner(_auth.currentUser!.uid);
    setState(() {
      requests = result;
      isLoading = false;
    });
  }

  void approve(TransactionModel tx) async {
  // 1. Approve transaction
  await _txService.updateStatus(tx.id, 'approved');

  // 2. Make book unavailable
  await _bookService.setBookAvailability(tx.bookId, false);

  // 3. Deduct 1 favor from borrower
  await _userService.incrementFavors(tx.borrowerId, -1);

  load();
}



  void reject(String id) async {
    await _txService.updateStatus(id, 'rejected');
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Requests for My Books')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          return ListTile(
  title: Text(r.bookTitle),
  subtitle: Text('Borrower: ${r.borrowerName}'),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // ✅ APPROVE (only if pending)
      if (r.status == 'pending')
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => approve(r),
        ),

      if (r.status == 'pending')
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => reject(r.id),
        ),

      // ⭐ RATE (only if returned & not rated)
      if (r.status == 'returned' && r.rating == null)
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RateBorrowerPage(transaction: r),
            ),
          ),
          child: const Text('Rate'),
        ),
    ],
  ),
);

        },
      ),
    );
  }
}
