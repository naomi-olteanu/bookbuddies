import 'package:flutter/material.dart';
import 'package:bookbuddies/services/google_books_service.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _auth = AuthService();
  final _bookService = BookService();
  final _googleBooksService = GoogleBooksService();

  // Controllers
  final titleController = TextEditingController();
  final authorsController = TextEditingController();
  final descriptionController = TextEditingController();
  final languageController = TextEditingController(text: 'en');
  final editionController = TextEditingController();
  final googleSearchController = TextEditingController();

  // Google Books state
  List<GoogleBookResult> searchResults = [];
  GoogleBookResult? selectedGoogleBook;
  bool manualMode = false;

  // Condition
  BookCondition selectedCondition = BookCondition.GOOD;

  // Images
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  bool isSaving = false;

  Future<void> saveBook() async {
  if (titleController.text.isEmpty ||
      authorsController.text.isEmpty ||
      descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields')),
    );
    return;
  }

  if (selectedImages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please add at least one real book photo')),
    );
    return;
  }

  setState(() => isSaving = true);

  try {
    final user = _auth.currentUser!;

    final authors = authorsController.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    final book = Book(
      id: '',
      title: titleController.text.trim(),
      authors: authors,
      description: descriptionController.text.trim(),
      categories: selectedGoogleBook?.categories ?? const [],
      isbn: null,
      googleBookId: selectedGoogleBook?.id,
      googleCoverUrl: selectedGoogleBook?.thumbnail,
      language: languageController.text.trim(),
      edition: editionController.text.trim(),
      condition: selectedCondition,
      userImages: const [],
      ownerId: user.uid,
      ownerName: user.email ?? '',
      isAvailable: true,
    );


    final docRef = await _bookService.addBookAndReturnRef(book);
    final imageUrls = await uploadImages(docRef.id);
    await docRef.update({'userImages': imageUrls});

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book added successfully')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving book: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => isSaving = false);
    }
  }
}


  Future<void> pickImages() async {
    if (selectedImages.length >= 5) return;

    final images = await _picker.pickMultiImage();

    if (images.isEmpty) return;

    setState(() {
      final remaining = 5 - selectedImages.length;
      selectedImages.addAll(images.take(remaining));
    });
  }

  Future<List<String>> uploadImages(String bookId) async {
  final storage = FirebaseStorage.instance;
  List<String> urls = [];

  for (int i = 0; i < selectedImages.length; i++) {
    try {
      final image = selectedImages[i];
      final ref = storage.ref('books/$bookId/photo_$i.jpg');

      final data = await image.readAsBytes()
          .timeout(const Duration(seconds: 10));

      await ref.putData(data)
          .timeout(const Duration(seconds: 30));

      final url = await ref.getDownloadURL()
          .timeout(const Duration(seconds: 10));

      urls.add(url);
    } catch (e) {
      debugPrint('Image upload failed: $e');
      throw Exception('Image upload failed');
    }
  }

  return urls;
}


  @override
  void dispose() {
    titleController.dispose();
    authorsController.dispose();
    descriptionController.dispose();
    languageController.dispose();
    editionController.dispose();
    googleSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // 🔍 GOOGLE BOOKS SEARCH
            if (!manualMode && selectedGoogleBook == null) ...[
              TextField(
                controller: googleSearchController,
                decoration: const InputDecoration(
                  labelText: 'Search book (Google Books)',
                  hintText: 'Start typing a title...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) async {
                  final results = await _googleBooksService.search(value);
                  setState(() => searchResults = results);
                },
              ),

              const SizedBox(height: 8),

              if (searchResults.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final book = searchResults[index];
                      return ListTile(
                        leading: book.thumbnail != null
                            ? SizedBox(
                                width: 40,
                                height: 60,
                                child: const Icon(Icons.book),
                              )
                            : const Icon(Icons.book),
                        title: Text(book.title),
                        subtitle: Text(book.authors.join(', ')),
                        onTap: () {
                          setState(() {
                            selectedGoogleBook = book;
                            titleController.text = book.title;
                            authorsController.text = book.authors.join(', ');
                            descriptionController.text = book.description ?? '';
                            searchResults.clear();
                          });
                        },
                      );
                    },
                  ),
                ),

              TextButton(
                onPressed: () {
                  setState(() {
                    manualMode = true;
                    selectedGoogleBook = null;
                  });
                },
                child: const Text('Can’t find your book? Add manually'),
              ),
            ],

            if (selectedGoogleBook != null) ...[
              Card(
                child: ListTile(
                  leading: selectedGoogleBook!.thumbnail != null
                      ? SizedBox(
                          width: 50,
                          height: 70,
                          child: Image.network(
                            selectedGoogleBook!.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.book),
                          ),
                        )
                      : const Icon(Icons.book),
                  title: Text(selectedGoogleBook!.title),
                  subtitle: Text(selectedGoogleBook!.authors.join(', ')),
                  trailing: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedGoogleBook = null;
                        manualMode = false;
                        googleSearchController.clear();
                      });
                    },
                    child: const Text('Change'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: authorsController,
              decoration: const InputDecoration(
                labelText: 'Authors *',
                hintText: 'Separate multiple authors with commas',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Additional information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<BookCondition>(
              value: selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: BookCondition.values.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition.name.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCondition = value);
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: languageController,
              decoration: const InputDecoration(
                labelText: 'Language (ISO code)',
                hintText: 'e.g. en, ro, fr',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: editionController,
              decoration: const InputDecoration(
                labelText: 'Edition',
                hintText: 'e.g. 1st, 2nd, Revised',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            const SizedBox(height: 24),

            const Text(
              'Real book photos (up to 5)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          image.path,
                          width: 100,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() => selectedImages.removeAt(index));
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                if (selectedImages.length < 5)
                  InkWell(
                    onTap: pickImages,
                    child: Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveBook,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Add Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
