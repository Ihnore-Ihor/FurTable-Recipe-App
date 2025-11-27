import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';

/// A card widget displaying a recipe summary.
class RecipeCard extends StatefulWidget {
  /// The unique identifier of the recipe.
  final String id;

  /// The URL or path to the recipe image.
  final String imageUrl;

  /// The title of the recipe.
  final String title;

  /// The author of the recipe.
  final String author;

  /// The number of likes formatted as a string.
  final String likes;

  /// Creates a [RecipeCard].
  const RecipeCard({
    super.key,
    required this.id,
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
    // Calculate card width to avoid layout errors.
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                // Ensure the tag is unique using the ID.
                tag: 'recipe_image_${widget.id}',
                child: Image.asset(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity, // Fill column width.
                  height: cardWidth, // Make it square.
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
