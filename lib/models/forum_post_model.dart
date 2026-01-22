import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String title;
  final String description;
  final String type; // book | genre | general
  final String? bookTitle;
  final String? genre;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastMessageAt;
  final int messageCount;
  final bool isClosed;

  ForumPost({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.bookTitle,
    this.genre,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessageAt,
    required this.messageCount,
    required this.isClosed,
  });

  factory ForumPost.fromMap(String id, Map<String, dynamic> data) {
    return ForumPost(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'general',
      bookTitle: data['bookTitle'],
      genre: data['genre'],
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      messageCount: data['messageCount'] ?? 0,
      isClosed: data['isClosed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'bookTitle': bookTitle,
      'genre': genre,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'messageCount': messageCount,
      'isClosed': isClosed,
    };
  }
}
