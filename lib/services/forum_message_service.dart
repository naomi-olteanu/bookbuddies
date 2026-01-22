import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_message_model.dart';

class ForumMessageService {
  CollectionReference _messagesRef(String postId) {
    return FirebaseFirestore.instance
        .collection('forum_posts')
        .doc(postId)
        .collection('messages');
  }

  // READ --------------------------------------------------

  Future<List<ForumMessage>> getMessages(String postId) async {
    final snapshot = await _messagesRef(postId)
        .orderBy('createdAt')
        .get();

    return snapshot.docs
        .map(
          (doc) => ForumMessage.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // CREATE ------------------------------------------------

  Future<void> sendMessage({
    required String postId,
    required ForumMessage message,
  }) async {
    final postRef =
        FirebaseFirestore.instance.collection('forum_posts').doc(postId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.set(
        _messagesRef(postId).doc(),
        message.toMap(),
      );

      tx.update(postRef, {
        'lastMessageAt': Timestamp.now(),
        'messageCount': FieldValue.increment(1),
      });
    });
  }

  // DELETE ------------------------------------------------

  Future<void> deleteMessage({
    required String postId,
    required String messageId,
  }) async {
    await _messagesRef(postId).doc(messageId).delete();
  }
}
