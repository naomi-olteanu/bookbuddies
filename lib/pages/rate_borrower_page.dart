import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/user_service.dart';

class RateBorrowerPage extends StatefulWidget {
  final TransactionModel transaction;

  const RateBorrowerPage({
    super.key,
    required this.transaction,
  });

  @override
  State<RateBorrowerPage> createState() => _RateBorrowerPageState();
}

class _RateBorrowerPageState extends State<RateBorrowerPage> {
  int selectedRating = 5;

  final TransactionService _txService = TransactionService();
  final UserService _userService = UserService();

  final TextEditingController messageController = TextEditingController();

  Future<void> submitRating() async {
    // 1️⃣ Save rating + optional message in transaction
    await _txService.addRating(
      widget.transaction.id,
      selectedRating,
      messageController.text.isEmpty ? null : messageController.text,
    );

    // 2️⃣ Update borrower rating using sum / count
    await _userService.addUserRating(
      widget.transaction.borrowerId,
      selectedRating,
    );

    if (!mounted) return;

    // 3️⃣ Go back
    Navigator.pop(context);

    // 4️⃣ Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating submitted successfully')),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Borrower'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate the borrower (1–5)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            DropdownButton<int>(
              value: selectedRating,
              items: [1, 2, 3, 4, 5]
                  .map(
                    (rating) => DropdownMenuItem<int>(
                      value: rating,
                      child: Text(rating.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedRating = value);
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Optional message',
                hintText: 'Condition of the book, behavior, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: submitRating,
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
