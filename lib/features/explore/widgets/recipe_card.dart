import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';

/// A card widget displaying a brief summary of a recipe.
class RecipeCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String author;
  final String likes;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  /// Creates a [RecipeCard].
  const RecipeCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: 'recipe_image_${widget.id}',
                child: widget.imageUrl.startsWith('http')
                    ? Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: cardWidth,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: cardWidth,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: cardWidth,
                        errorBuilder: (context, error, stackTrace) => Container(
                           width: double.infinity,
                           height: cardWidth,
                           color: Colors.grey[200],
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: widget.onFavoriteToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: AppTheme.darkCharcoal, // Dark color for both
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(widget.likes, style: Theme.of(context).textTheme.labelSmall),
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
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Just author text, no avatar
        Text(
          widget.author,
          style: Theme.of(context).textTheme.bodyMedium
        ),
      ],
    );
  }
}
