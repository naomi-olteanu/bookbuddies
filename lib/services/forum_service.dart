import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post_model.dart';

class ForumService {
  final CollectionReference forumPosts =
      FirebaseFirestore.instance.collection('forum_posts');

  // CREATE --------------------------------------------------

  Future<DocumentReference> addForumPost(ForumPost post) async {
    return forumPosts.add(post.toMap());
  }

  // ONE FORUM PER BOOK PER USER CHECK ----------------------

  Future<bool> userCanCreateForumForBook({
    required String userId,
    required String bookTitle,
  }) async {
    final snapshot = await forumPosts
        .where('createdBy', isEqualTo: userId)
        .where('bookTitle', isEqualTo: bookTitle)
        .limit(1)
        .get();

    return snapshot.docs.isEmpty;
  }

  // READ ----------------------------------------------------

  Future<List<ForumPost>> getAllForums() async {
    final snapshot = await forumPosts
        .orderBy('lastMessageAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              ForumPost.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<ForumPost>> getForumsByType(String type) async {
    final snapshot = await forumPosts
        .where('type', isEqualTo: type)
        .orderBy('lastMessageAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              ForumPost.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<ForumPost>> getForumsByBook(String bookTitle) async {
    final snapshot = await forumPosts
        .where('bookTitle', isEqualTo: bookTitle)
        .orderBy('lastMessageAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              ForumPost.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<ForumPost?> getForumById(String id) async {
    final doc = await forumPosts.doc(id).get();
    if (!doc.exists) return null;

    return ForumPost.fromMap(
      doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }

  // UPDATE --------------------------------------------------

  Future<void> updateForumPost({
    required String postId,
    required String title,
    required String description,
  }) async {
    await forumPosts.doc(postId).update({
      'title': title,
      'description': description,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> closeForum(String postId) async {
    await forumPosts.doc(postId).update({
      'isClosed': true,
      'updatedAt': Timestamp.now(),
    });
  }

  // DELETE --------------------------------------------------

  Future<void> deleteForum(String postId) async {
    final doc = forumPosts.doc(postId);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
    }
  }

  // MESSAGE METADATA ---------------------------------------

  Future<void> updateAfterNewMessage(String postId) async {
    await forumPosts.doc(postId).update({
      'lastMessageAt': Timestamp.now(),
      'messageCount': FieldValue.increment(1),
    });
  }
}
