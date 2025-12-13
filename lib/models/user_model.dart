class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // user | admin
  final double rating;
  final int favors;
  final String bio;
  final String profilePicture;
  final int ratingSum;
  final int ratingCount;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.rating,
    required this.favors,
    required this.bio,
    required this.profilePicture,
    required this.ratingSum,
    required this.ratingCount,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      rating: (data['rating'] ?? 0).toDouble(),
      favors: data['favors'] ?? 0,
      bio: data['bio'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      ratingSum: data['ratingSum'] ?? 0,
      ratingCount: data['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'rating': rating,
      'favors': favors,
      'bio': bio,
      'profilePicture': profilePicture,
      'ratingSum': ratingSum,
      'ratingCount': ratingCount,
    };
  }
}
