import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/duration_helper.dart';
import 'package:furtable/core/widgets/app_image.dart';

/// A card widget displaying a brief summary of a recipe.
///
/// Refactored to StatelessWidget to ensure immediate UI updates during state changes (like favoriting).
class RecipeCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String author;
  final String likes;
  final int cookingTime;
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
    required this.cookingTime,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Width calculation for responsiveness if needed, though AspectRatio handles it mostly.
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Square aspect ratio for the image container
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'recipe_image_$id',
                  child: AppImage(
                    imagePath: imageUrl,
                    width: double.infinity,
                    height: cardWidth,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Like button positioned at the bottom right
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          // Use charcoal for both states as requested
                          color: AppTheme.darkCharcoal,
                          size: 16, 
                        ),
                        const SizedBox(width: 4),
                        Text(
                          likes, 
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600
                          )
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
          title,
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                author, 
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time, 
                  size: 14, 
                  color: AppTheme.mediumGray
                ),
                const SizedBox(width: 4),
                Text(
                  DurationHelper.format(context, cookingTime),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
