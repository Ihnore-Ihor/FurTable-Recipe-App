import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';

/// Screen displaying the detailed view of a recipe.
class RecipeDetailsScreen extends StatelessWidget {
  /// The initial recipe data.
  final Recipe initialRecipe; // Renamed for clarity

  /// Creates a [RecipeDetailsScreen] with initial data.
  ///
  /// Initial data is shown while fetching updates.
  const RecipeDetailsScreen({super.key, required this.initialRecipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      // AppBar remains here so the Back button always works
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Like button handled via BLoC
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              bool isFavorite = false;
              if (state is FavoritesLoaded) {
                isFavorite = state.recipes.any((r) => r.id == initialRecipe.id);
              }
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppTheme.darkCharcoal,
                ),
                onPressed: () {
                  context.read<FavoritesBloc>().add(ToggleFavorite(initialRecipe));
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- MAIN CHANGE: StreamBuilder ---
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .doc(initialRecipe.id)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Determine which data to show
          Recipe recipe;

          if (snapshot.hasData && snapshot.data!.exists) {
            // If fresh data from DB, use it
            recipe = Recipe.fromFirestore(snapshot.data!);
          } else {
            // While loading (or error), show initial data
            recipe = initialRecipe;
          }

          // 2. Draw UI (same code as before, but using the recipe variable)
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Hero(
                  tag: 'recipe_image_${recipe.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: recipe.imageUrl.startsWith('http')
                        ? Image.network(
                            recipe.imageUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey),
                          )
                        : Image.asset(
                            recipe.imageUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppTheme.darkCharcoal, height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Author + Avatar
                Row(
                  children: [
                    // --- RESTORED AVATAR ---
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.darkCharcoal,
                          width: 1.5 // Slightly thicker border for style
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 16, // Avatar size
                        backgroundColor: Colors.white,
                        // Use path from model or default
                        backgroundImage: AssetImage(
                          (recipe.authorAvatarUrl.isNotEmpty)
                              ? recipe.authorAvatarUrl
                              : 'assets/images/legoshi_eating_auth.png'
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ---------------------------

                    Text(
                      'by ${recipe.authorName}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600, // Slightly bolder for accent
                        color: AppTheme.darkCharcoal, // Dark color
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // ... Rest of fields (Description, Ingredients, Steps) unchanged ...
                const Text('Description', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkCharcoal)),
                const SizedBox(height: 8),
                Text(recipe.description.isNotEmpty ? recipe.description : 'No description.', style: const TextStyle(fontFamily: 'Inter', fontSize: 15, height: 1.5, color: AppTheme.mediumGray)),

                const SizedBox(height: 24),
                const Text('Ingredients', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkCharcoal)),
                const SizedBox(height: 12),
                ...recipe.ingredients.map((i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text("• $i", style: const TextStyle(fontSize: 15, color: AppTheme.darkCharcoal)))),

                const SizedBox(height: 24),
                const Text('Instructions', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkCharcoal)),
                const SizedBox(height: 12),
                ...recipe.steps.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(s, style: const TextStyle(fontSize: 15, color: AppTheme.darkCharcoal)))),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
