import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final String imageUrl;
  final int likesCount;
  final int timeMinutes;
  final List<String> ingredients;
  final List<String> steps;
  final bool isPublic;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.authorId,
    required this.authorName,
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

  // Перетворення з Firestore (читання)
  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
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

  // Перетворення в Firestore (запис)
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'timeMinutes': timeMinutes,
      'ingredients': ingredients,
      'steps': steps,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      // Ключові слова для пошуку
      'searchKeywords': _generateKeywords(title),
    };
  }

  List<String> _generateKeywords(String title) {
    List<String> keywords = [];
    String temp = "";
    for (int i = 0; i < title.length; i++) {
      temp = temp + title[i].toLowerCase();
      keywords.add(temp);
    }
    return keywords;
  }

  // Цей геттер потрібен, щоб старий код міг звертатися до recipe.likes
  String get likes {
    if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}k';
    }
    return likesCount.toString();
  }

  // Цей геттер потрібен, щоб старий код міг звертатися до recipe.author
  // (бо в новій моделі поле називається authorName)
  String get author => authorName;

  @override
  List<Object?> get props => [id, authorId, title, imageUrl, likesCount, isPublic];
}
