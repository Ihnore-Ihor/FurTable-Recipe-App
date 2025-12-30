import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/widgets/app_image.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use AspectRatio 1/1 for guaranteed square
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill( // Fills the entire 1:1 square
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Hero(
                    tag: 'recipe_image_${widget.id}',
                    child: AppImage(
                      imagePath: widget.imageUrl,
                      // AspectRatio will define the height, we remove it from here
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Like button
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: widget.onFavoriteToggle,
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
                          color: AppTheme.darkCharcoal.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: AppTheme.darkCharcoal, // Dark color for both
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.likes,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        Text(widget.author, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
