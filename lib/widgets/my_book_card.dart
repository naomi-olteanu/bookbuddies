import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'network_image_fallback.dart';

class MyBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MyBookCard({
    super.key,
    required this.book,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imageCandidates = book.userImages;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: NetworkImageFallback(
                    key: ValueKey(book.id),
                    urls: imageCandidates,
                    height: 180,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authors.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            book.isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: book.isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            book.isAvailable
                                ? 'Available'
                                : 'Not available',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// DELETE BUTTON
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: onDelete,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child:
                      const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
