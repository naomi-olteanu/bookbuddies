import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String ownerId;
  final String ownerName;
  final bool isAvailable;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.isAvailable,
  });

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.now(),
    };
  }
}
