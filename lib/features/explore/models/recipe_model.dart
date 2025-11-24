import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String likes;
  final int timeMinutes;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.likes,
    required this.timeMinutes,
    required this.ingredients,
    required this.steps,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    imageUrl,
    likes,
    timeMinutes,
    ingredients,
    steps,
  ];
}
