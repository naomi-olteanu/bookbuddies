import 'package:flutter/material.dart';
import '../models/book_model.dart';

class MyBookDetailsPage extends StatelessWidget {
  final Book book;

  const MyBookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final images = book.userImages;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarousel(images),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(book.authors.join(', ')),
                  const SizedBox(height: 12),
                  Text(book.description),
                  const SizedBox(height: 16),
                  _infoRow('Language', book.language),
                  _infoRow('Edition', book.edition),
                  _infoRow('Condition', book.condition.name),
                  _infoRow(
                    'Availability',
                    book.isAvailable
                        ? 'Available'
                        : 'Not available',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(List<String> images) {
    if (images.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Icon(Icons.book, size: 80)),
      );
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image, size: 48)),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
