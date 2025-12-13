import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String ownerId;
  final String ownerName;
  final String borrowerId;
  final String borrowerName;
  final String status;
  final int? rating;
  final String? ratingMessage;

  TransactionModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.ownerId,
    required this.ownerName,
    required this.borrowerId,
    required this.borrowerName,
    required this.status,
    this.rating,
    this.ratingMessage,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      bookId: data['bookId'],
      bookTitle: data['bookTitle'],
      ownerId: data['ownerId'],
      ownerName: data['ownerName'],
      borrowerId: data['borrowerId'],
      borrowerName: data['borrowerName'],
      status: data['status'],
      rating: data['rating'],
      ratingMessage: data['ratingMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'status': status,
      'createdAt': Timestamp.now(),
      'rating': rating,
      'ratingMessage': ratingMessage,
    };
  }
}
