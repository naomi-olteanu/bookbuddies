import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final descriptionController = TextEditingController();

  final _auth = AuthService();
  final _bookService = BookService();

  void saveBook() async {
    final user = _auth.currentUser!;

    final book = Book(
      id: '',
      title: titleController.text,
      author: authorController.text,
      description: descriptionController.text,
      ownerId: user.uid,
      ownerName: user.email ?? '',
      isAvailable: true,
    );

    await _bookService.addBook(book);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Author')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: saveBook, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
