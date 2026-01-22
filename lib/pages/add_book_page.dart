import 'dart:io';
import 'package:bookbuddies/app_layout/main_layout.dart';
import 'package:bookbuddies/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bookbuddies/services/google_books_service.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import '../models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddBookPage extends StatefulWidget {
  final Book? bookToEdit;
  final AppUser currentUser;

  const AddBookPage({
    super.key,
    this.bookToEdit,
    required this.currentUser,
  });

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _auth = AuthService();
  final _bookService = BookService();
  final _googleBooksService = GoogleBooksService();

  // Controllers
  late TextEditingController titleController;
  late TextEditingController authorsController;
  late TextEditingController descriptionController;
  late TextEditingController languageController;
  late TextEditingController editionController;
  final googleSearchController = TextEditingController();

  // State
  List<GoogleBookResult> searchResults = [];
  GoogleBookResult? selectedGoogleBook;
  bool manualMode = false;
  BookCondition selectedCondition = BookCondition.GOOD;

  // Images
  final ImagePicker _picker = ImagePicker();
  List<XFile> newImages = [];
  List<String> existingImages = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bookToEdit;

    titleController = TextEditingController(text: b?.title ?? '');
    authorsController =
        TextEditingController(text: b?.authors.join(', ') ?? '');
    descriptionController =
        TextEditingController(text: b?.description ?? '');
    languageController = TextEditingController(text: b?.language ?? 'en');
    editionController = TextEditingController(text: b?.edition ?? '');

    if (b != null) {
      selectedCondition = b.condition;
      existingImages = List.from(b.userImages);
      manualMode = true;
    }
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

  Future<void> saveBook() async {
    if (widget.currentUser.isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account is blocked')),
      );
      return;
    }

    if (titleController.text.isEmpty ||
        authorsController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (existingImages.isEmpty && newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one book photo')),
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

      final bookId = widget.bookToEdit?.id ?? '';
      List<String> finalImageUrls = [...existingImages];

      if (widget.bookToEdit != null) {
        final newUrls = await uploadImages(bookId);
        finalImageUrls.addAll(newUrls);
      }

      final bookData = Book(
        id: bookId,
        title: titleController.text.trim(),
        authors: authors,
        description: descriptionController.text.trim(),
        categories:
            selectedGoogleBook?.categories ??
                widget.bookToEdit?.categories ??
                [],
        isbn: widget.bookToEdit?.isbn,
        googleBookId:
            selectedGoogleBook?.id ?? widget.bookToEdit?.googleBookId,
        googleCoverUrl:
            selectedGoogleBook?.thumbnail ??
                widget.bookToEdit?.googleCoverUrl,
        language: languageController.text.trim(),
        edition: editionController.text.trim(),
        condition: selectedCondition,
        userImages: finalImageUrls,
        ownerId: user.uid,
        ownerName: user.email ?? '',
        isAvailable: widget.bookToEdit?.isAvailable ?? true,
      );

      if (widget.bookToEdit != null) {
        await _bookService.updateBook(bookData);
      } else {
        final docRef = await _bookService.addBookAndReturnRef(bookData);
        final newUrls = await uploadImages(docRef.id);
        await docRef.update({'userImages': newUrls});
      }

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.bookToEdit != null
                ? 'Changes saved!'
                : 'Book published!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving book: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> pickImages() async {
    final totalImages = existingImages.length + newImages.length;
    if (totalImages >= 5) return;

    final images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    setState(() {
      final remaining = 5 - totalImages;
      newImages.addAll(images.take(remaining));
    });
  }

  Future<List<String>> uploadImages(String bookId) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [];

    for (int i = 0; i < newImages.length; i++) {
      try {
        final image = newImages[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ref =
            storage.ref('books/$bookId/photo_${timestamp}_$i.jpg');

        final data = await image.readAsBytes();
        await ref.putData(data);
        final url = await ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        debugPrint('Image upload failed: $e');
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isEditing = widget.bookToEdit != null;

    return MainLayout(
      title: isEditing ? 'Edit Book' : 'Add Book',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Listing' : 'List a Book',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isEditing
                ? 'Update details or add more photos.'
                : 'Share your library with the world.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildImageSection(context)),
                const SizedBox(width: 40),
                Expanded(flex: 2, child: _buildFormSection(context, isEditing)),
              ],
            )
          else
            Column(
              children: [
                _buildImageSection(context),
                const SizedBox(height: 32),
                _buildFormSection(context, isEditing),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final totalCount = existingImages.length + newImages.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload up to 5 photos.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            
            if (totalCount < 5)
              InkWell(
                onTap: pickImages,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5
                    ), 
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Click to upload',
                        style: TextStyle(
                          color: AppColors.primary, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...existingImages.asMap().entries.map((entry) {
                  return _imageThumbnail(
                    isNetwork: true, 
                    path: entry.value, 
                    onDelete: () => setState(() => existingImages.removeAt(entry.key))
                  );
                }),
                ...newImages.asMap().entries.map((entry) {
                  return _imageThumbnail(
                    isNetwork: false, 
                    path: entry.value.path, 
                    onDelete: () => setState(() => newImages.removeAt(entry.key))
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageThumbnail({required bool isNetwork, required String path, required VoidCallback onDelete}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 110,
            child: isNetwork 
              ? Image.network(
                  path, 
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                )
              : (kIsWeb 
                  ? Image.network(path, fit: BoxFit.cover) 
                  : Image.file(File(path), fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onDelete,
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isEditing && !manualMode && selectedGoogleBook == null) 
          _buildGoogleSearch(),

        if (selectedGoogleBook != null) _buildSelectedBookCard(),
        const SizedBox(height: 24),

        _buildTextField('Title *', titleController, 'Book Title'),
        const SizedBox(height: 16),
        _buildTextField('Authors *', authorsController, 'Separate with commas'),
        const SizedBox(height: 16),
        _buildTextField('Description *', descriptionController, '', maxLines: 5),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<BookCondition>(
                value: selectedCondition,
                decoration: _inputDecoration('Condition'),
                items: BookCondition.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.name.replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCondition = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField('Language', languageController, 'e.g. en'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Edition', editionController, 'e.g. 1st, 2023'),

        const SizedBox(height: 40),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: isSaving ? null : saveBook,
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(isEditing ? 'Save Changes' : 'Publish Book', style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSearch() {
    return Column(
      children: [
        TextField(
          controller: googleSearchController,
          decoration: _inputDecoration('Auto-fill from Google Books')
            .copyWith(prefixIcon: const Icon(Icons.search)),
          onChanged: (value) async {
            if(value.length > 2) {
              final results = await _googleBooksService.search(value);
              setState(() => searchResults = results);
            }
          },
        ),
        if (searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: searchResults.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final book = searchResults[index];
                return ListTile(
                  leading: SizedBox( 
                    width: 40,
                    height: 60,
                    child: book.thumbnail != null 
                      ? Image.network(
                          book.thumbnail!, 
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => const Icon(Icons.book),
                        )
                      : const Icon(Icons.book),
                  ),
                  title: Text(book.title, maxLines: 1),
                  subtitle: Text(book.authors.join(', '), maxLines: 1),
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
          onPressed: () => setState(() => manualMode = true),
          child: const Text('Book not found? Enter details manually'),
        ),
      ],
    );
  }

  Widget _buildSelectedBookCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (selectedGoogleBook!.thumbnail != null)
            SizedBox(
              width: 60,
              height: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  selectedGoogleBook!.thumbnail!, 
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => const Icon(Icons.book),
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedGoogleBook!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(selectedGoogleBook!.authors.join(', ')),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedGoogleBook = null;
                manualMode = false;
                googleSearchController.clear();
              });
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).cardTheme.color,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
    );
  }
}