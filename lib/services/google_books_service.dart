import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBookResult {
  final String id;
  final String title;
  final List<String> authors;
  final String? thumbnail;
  final String? description;
  final List<String> categories;

  GoogleBookResult({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnail,
    this.description,
    required this.categories,
  });
}

class GoogleBooksService {
  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<GoogleBookResult>> search(String query) async {
    if (query.length < 3) return [];

    final uri = Uri.parse('$_baseUrl?q=$query&maxResults=10');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return [];
    }

    final data = json.decode(response.body);
    final items = data['items'] as List<dynamic>?;

    if (items == null) return [];

    return items.map((item) {
      final volume = item['volumeInfo'];
      String? thumbnail;
      final imageLinks = volume['imageLinks'];
      if (imageLinks != null) {
        thumbnail =
            imageLinks['thumbnail'] ??
            imageLinks['smallThumbnail'] ??
            imageLinks['medium'] ??
            imageLinks['large'];
      }

      if (thumbnail != null && thumbnail.startsWith('http://')) {
        thumbnail = thumbnail.replaceFirst('http://', 'https://');
      }
      return GoogleBookResult(
        id: item['id'],
        title: volume['title'] ?? '',
        authors: List<String>.from(volume['authors'] ?? []),
        description: volume['description'],
        categories: List<String>.from(volume['categories'] ?? []),
        thumbnail: thumbnail,
      );
    }).toList();
  }
}
