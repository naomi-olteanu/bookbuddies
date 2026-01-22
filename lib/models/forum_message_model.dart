import 'package:cloud_firestore/cloud_firestore.dart';

class ForumMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  ForumMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory ForumMessage.fromMap(String id, Map<String, dynamic> data) {
    return ForumMessage(
      id: id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
