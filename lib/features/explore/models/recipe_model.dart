import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a recipe in the application.
class Recipe extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl; // New field
  final String title;
  final String description;
  final String imageUrl;
  final int likesCount;
  final int timeMinutes;
  final List<String> ingredients;
  final List<String> steps;
  final bool isPublic;
  final DateTime createdAt;

  /// Creates a [Recipe] instance.
  const Recipe({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl = 'assets/images/legoshi_eating_auth.png', // Default
    required this.title,
    required this.description,
    required this.imageUrl,
    this.likesCount = 0,
    required this.timeMinutes,
    required this.ingredients,
    required this.steps,
    this.isPublic = true,
    required this.createdAt,
  });

  /// Creates a [Recipe] from a Firestore document.
  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorAvatarUrl: data['authorAvatarUrl'] ??
          'assets/images/legoshi_eating_auth.png', // Read from DB
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      likesCount: data['likesCount'] ?? 0,
      timeMinutes: data['timeMinutes'] ?? 0,
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      isPublic: data['isPublic'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the recipe to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl, // Write to DB
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'timeMinutes': timeMinutes,
      'ingredients': ingredients,
      'steps': steps,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'searchKeywords': generateKeywords(title, authorName),
    };
  }

  /// Smart keyword generation: splits text into words and generates prefixes for each.
  static List<String> generateKeywords(String title, String authorName) {
    Set<String> keywords = {};

    // 1. Add words from title
    final titleWords = title.toLowerCase().split(' ');
    for (var word in titleWords) {
      if (word.trim().isEmpty) continue;

      // Generate prefixes for EACH word
      // E.g. "Seafood Pasta" ->
      // "s", "se", "sea" ... "seafood"
      // "p", "pa", "pas" ... "pasta"
      String temp = "";
      for (int i = 0; i < word.length; i++) {
        temp = temp + word[i];
        keywords.add(temp);
      }
    }

    // 2. Add words from author name (similarly)
    final authorWords = authorName.toLowerCase().split(' ');
    for (var word in authorWords) {
      if (word.trim().isEmpty) continue;
      String temp = "";
      for (int i = 0; i < word.length; i++) {
        temp = temp + word[i];
        keywords.add(temp);
      }
    }

    return keywords.toList();
  }

  // --- GETTERS COMPATIBILITY ---
  // Fixes "undefined getter" errors
  String get author => authorName;

  String get likes {
    if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}k';
    }
    return likesCount.toString();
  }

  @override
  List<Object?> get props => [id, authorId, title, imageUrl, likesCount];
}
