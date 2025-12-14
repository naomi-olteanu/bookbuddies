import 'package:flutter/material.dart';

class NetworkImageFallback extends StatefulWidget {
  final List<String> urls;
  final double height;

  const NetworkImageFallback({
    super.key, // Added super.key to support the ValueKey usage
    required this.urls,
    required this.height,
  });

  @override
  State<NetworkImageFallback> createState() =>
      _NetworkImageFallbackState();
}

class _NetworkImageFallbackState extends State<NetworkImageFallback> {
  int index = 0;

  @override
  void didUpdateWidget(covariant NetworkImageFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the list of URLs changes (e.g., data refresh), reset the index to 0
    if (widget.urls != oldWidget.urls) {
      index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no images exist, or we've exhausted the list, show placeholder
    if (widget.urls.isEmpty || index >= widget.urls.length) {
      return _placeholder();
    }

    return Image.network(
      widget.urls[index],
      height: widget.height,
      width: double.infinity,
      fit: BoxFit.cover,
      // If the image fails to load (e.g. 404 or CORS error),
      // this builder triggers and we move to the next image.
      errorBuilder: (_, __, ___) {
        // Use addPostFrameCallback to avoid "setState during build" errors
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => index++);
          }
        });
        // Return a temporary blank box while we switch to the next index
        return SizedBox(height: widget.height); 
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: widget.height,
          color: Colors.grey.shade100,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      height: widget.height,
      width: double.infinity, // Ensure placeholder takes full width
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.menu_book, size: 48, color: Colors.grey),
      ),
    );
  }
}