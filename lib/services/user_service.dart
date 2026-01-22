import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUser(AppUser user) async {
    await users.doc(user.id).set(user.toMap());
  }

  Future<AppUser> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await users.get();
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateProfile(String uid, String name, String bio) async {
    await users.doc(uid).update({
      'name': name,
      'bio': bio,
    });
  }

  Future<void> updateFavors(String userId, int newValue) async {
  await users.doc(userId).update({
    'favors': newValue,
  });
}

Future<void> incrementFavors(String userId, int amount) async {
  await users.doc(userId).update({
    'favors': FieldValue.increment(amount),
  });
}

Future<void> updateUserRating(String userId, double newRating) async {
  await users.doc(userId).update({
    'rating': newRating,
  });
}

Future<void> addUserRating(String userId, int newRating) async {
  final userRef = users.doc(userId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(userRef);

    final currentSum = snapshot['ratingSum'] ?? 0;
    final currentCount = snapshot['ratingCount'] ?? 0;

    final updatedSum = currentSum + newRating;
    final updatedCount = currentCount + 1;
    final updatedAverage = updatedSum / updatedCount;

    transaction.update(userRef, {
      'ratingSum': updatedSum,
      'ratingCount': updatedCount,
      'rating': updatedAverage,
    });
  });
}

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await users.doc(userId).update(updates);
  }

  Future<void> deleteUser(String userId) async {
    await users.doc(userId).delete();
  }
}
