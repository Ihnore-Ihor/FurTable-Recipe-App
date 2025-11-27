import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Screen displaying the details of a specific recipe.
class RecipeDetailsScreen extends StatelessWidget {
  /// The recipe to display.
  final Recipe recipe;

  /// Creates a [RecipeDetailsScreen].
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      // Transparent or white AppBar with navigation buttons.
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: AppTheme.darkCharcoal),
            onPressed: () {
              // Like logic to be implemented later.
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Hero(
              tag: 'recipe_image_${recipe.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  recipe.imageUrl,
                  width: double.infinity,
                  height: 250, // Fixed height as per design.
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              recipe.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkCharcoal,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Author (Avatar + Name)
            Row(
              children: [
                // Placeholder avatar (can be replaced with author image from model).
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    'assets/images/legoshi_eating_auth.png',
                  ),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 12),
                Text(
                  recipe.author,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A perfectly grilled salmon glazed with homemade teriyaki sauce. This dish combines the richness of fresh salmon with the sweet and savory flavors.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                height: 1.5,
                color: AppTheme.mediumGray,
              ),
            ),

            const SizedBox(height: 24),

            // Ingredients
            const Text(
              'Ingredients',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 12),
            ...recipe.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bullet point
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: AppTheme.darkCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            const Text(
              'Instructions',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            ...recipe.steps.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              String step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numbered circle
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.darkCharcoal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$idx',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          height: 1.5,
                          color: AppTheme.darkCharcoal.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
