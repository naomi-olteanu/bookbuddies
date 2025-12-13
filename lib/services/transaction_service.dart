import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');

  Future<void> createRequest(TransactionModel tx) async {
    await transactions.add(tx.toMap());
  }

  Future<List<TransactionModel>> getRequestsByBorrower(String borrowerId) async {
    final snapshot = await transactions
        .where('borrowerId', isEqualTo: borrowerId)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<List<TransactionModel>> getRequestsForOwner(String ownerId) async {
  final snapshot = await transactions
      .where('ownerId', isEqualTo: ownerId)
      .get();

  return snapshot.docs
      .map((doc) => TransactionModel.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ))
      .toList();
}

  Future<List<TransactionModel>> getApprovedBorrowedBooks(String borrowerId) async {
  final snapshot = await transactions
      .where('borrowerId', isEqualTo: borrowerId)
      .where('status', isEqualTo: 'approved')
      .get();

  return snapshot.docs
      .map((doc) => TransactionModel.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ))
      .toList();
}

Future<void> markReturned(String transactionId) async {
  await transactions.doc(transactionId).update({
    'status': 'returned',
  });
}

Future<void> addRating(
  String transactionId,
  int rating,
  String? message,
) async {
  await transactions.doc(transactionId).update({
    'rating': rating,
    'ratingMessage': message,
  });
}


  Future<void> updateStatus(String txId, String status) async {
    await transactions.doc(txId).update({'status': status});
  }
}
