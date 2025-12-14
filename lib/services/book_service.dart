import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final CollectionReference books = FirebaseFirestore.instance.collection(
    'books',
  );

  Future<void> addBook(Book book) async {
    await books.add(book.toMap());
  }

  Future<List<Book>> getBooksByOwner(String ownerId) async {
    final snapshot = await books.where('ownerId', isEqualTo: ownerId).get();

    return snapshot.docs
        .map((doc) => Book.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Book>> getAllAvailableBooks() async {
    final snapshot = await books.where('isAvailable', isEqualTo: true).get();

    return snapshot.docs
        .map((doc) => Book.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> setBookAvailability(String bookId, bool isAvailable) async {
    await books.doc(bookId).update({'isAvailable': isAvailable});
  }

  Future<DocumentReference> addBookAndReturnRef(Book book) async {
    return FirebaseFirestore.instance.collection('books').add(book.toMap());
  }

  Future<void> deleteBook(String id) async {
    final doc = books.doc(id);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
    }
  }

  Future<void> updateBook(Book book) async {
    await books.doc(book.id).update(book.toMap());
  }
}
