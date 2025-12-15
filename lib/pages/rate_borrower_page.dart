import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/theme/app_theme.dart';
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
  bool isSubmitting = false;

  Future<void> submitRating() async {
    setState(() => isSubmitting = true);

    await _txService.addRating(
      widget.transaction.id,
      selectedRating,
      messageController.text.isEmpty ? null : messageController.text,
    );

    await _userService.addUserRating(
      widget.transaction.borrowerId,
      selectedRating,
    );

    if (!mounted) return;
    Navigator.pop(context);
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
    return MainLayout(
      title: 'Rate Experience',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rate, size: 48, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Rate ${widget.transaction.borrowerName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'How was the condition of the returned book?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        iconSize: 40,
                        icon: Icon(
                          starIndex <= selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() => selectedRating = starIndex);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_ratingLabel',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Optional message',
                      hintText: 'e.g. "Book came back in perfect condition!"',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submitRating,
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Rating'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _ratingLabel {
    switch (selectedRating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}