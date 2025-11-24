import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';

class RecipeCard extends StatefulWidget {
  final String id; // <--- НОВЕ ПОЛЕ
  final String imageUrl;
  final String title;
  final String author;
  final String likes;

  const RecipeCard({
    super.key,
    required this.id, // <--- ВИМАГАЄМО ID
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Розрахунок ширини картки, щоб уникнути помилок layout
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                // ВИПРАВЛЕНО: Тепер тег унікальний завдяки ID
                tag: 'recipe_image_${widget.id}',
                child: Image.asset(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity, // Заповнюємо ширину колонки
                  height: cardWidth, // Робимо квадратним
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkCharcoal.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: AppTheme.darkCharcoal,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(widget.likes, style: textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.title,
          style: textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(widget.author, style: textTheme.bodyMedium),
      ],
    );
  }
}
