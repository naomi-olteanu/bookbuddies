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
    final result =
        await _txService.getRequestsByBorrower(_auth.currentUser!.uid);
    setState(() {
      requests = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Borrow Requests')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          return ListTile(
            title: Text(r.bookTitle),
            subtitle: Text('Status: ${r.status}'),
          );
        },
      ),
    );
  }
}
