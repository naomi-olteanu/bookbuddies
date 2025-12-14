enum BookCondition {
  NEW,
  VERY_GOOD,
  GOOD,
  ACCEPTABLE,
  POOR,
}

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final List<String> categories;

  final String? isbn;
  final String? googleBookId;
  final String? googleCoverUrl;

  final String language;
  final String edition;
  final BookCondition condition;

  final List<String> userImages;

  final String ownerId;
  final String ownerName;

  final bool isAvailable;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.categories,
    this.isbn,
    this.googleBookId,
    this.googleCoverUrl,
    required this.language,
    required this.edition,
    required this.condition,
    required this.userImages,
    required this.ownerId,
    required this.ownerName,
    required this.isAvailable,
  });

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'],
      authors: List<String>.from(data['authors'] ?? []),
      description: data['description'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      isbn: data['isbn'],
      googleBookId: data['googleBookId'],
      googleCoverUrl: data['googleCoverUrl'],
      language: data['language'] ?? 'en',
      edition: data['edition'] ?? '',
      condition: BookCondition.values.firstWhere(
        (e) => e.name == data['condition'],
        orElse: () => BookCondition.GOOD,
      ),
      userImages: List<String>.from(data['userImages'] ?? []),
      ownerId: data['ownerId'],
      ownerName: data['ownerName'],
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'authors': authors,
      'description': description,
      'categories': categories,
      'isbn': isbn,
      'googleBookId': googleBookId,
      'googleCoverUrl': googleCoverUrl,
      'language': language,
      'edition': edition,
      'condition': condition.name,
      'userImages': userImages,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'isAvailable': isAvailable,
      'createdAt': DateTime.now(),
    };
  }
}
