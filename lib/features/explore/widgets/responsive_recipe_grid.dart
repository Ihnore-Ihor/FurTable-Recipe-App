import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/auth_helper.dart'; // <--- Import
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/screens/recipe_details_screen.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';
import 'package:furtable/l10n/app_localizations.dart';

// --- VARIANT 1: FOR CUSTOM SCROLL VIEW (Explore, Favorites) ---
class SliverRecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;

  const SliverRecipeGrid({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = NavigationHelper.getResponsiveCrossAxisCount(width);

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverAlignedGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        itemCount: recipes.length,
        itemBuilder: (context, index) => _buildItem(context, recipes[index]),
      ),
    );
  }
}

// --- VARIANT 2: FOR STANDARD SCREENS (Search, MyRecipes) ---
class StandardRecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final bool showLockIcon; // Specific to My Recipes
  final Function(Recipe)? onEdit;
  final Function(Recipe)? onDelete;

  const StandardRecipeGrid({
    super.key,
    required this.recipes,
    this.showLockIcon = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = NavigationHelper.getResponsiveCrossAxisCount(width);

    return AlignedGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 24,
      crossAxisSpacing: 16,
      itemCount: recipes.length,
      itemBuilder: (context, index) => _buildItem(
        context,
        recipes[index],
        showLockIcon,
        onEdit,
        onDelete,
      ),
    );
  }
}

// --- COMMON ITEM BUILDER LOGIC ---
Widget _buildItem(
  BuildContext context,
  Recipe recipe, [
  bool showLock = false,
  Function(Recipe)? onEdit,
  Function(Recipe)? onDelete,
]) {
  return BlocBuilder<FavoritesBloc, FavoritesState>(
    builder: (context, favState) {
      bool isFavorite = false;
      if (favState is FavoritesLoaded) {
        isFavorite = favState.recipes.any((r) => r.id == recipe.id);
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsScreen(initialRecipe: recipe),
            ),
          );
        },
        child: Stack(
          children: [
            RecipeCard(
              id: recipe.id,
              imageUrl: recipe.imageUrl,
              title: recipe.title,
              author: recipe.authorName,
              likes: recipe.likes,
              cookingTime: recipe.timeMinutes, // NEW: Localized duration
              isFavorite: isFavorite,
              onFavoriteToggle: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  AuthHelper.showAuthRequiredDialog(
                    context,
                    AppLocalizations.of(context)!.authRequiredLike,
                    icon: Icons.favorite_border,
                  );
                  return;
                }
                context.read<FavoritesBloc>().add(ToggleFavorite(recipe));
              },
            ),

            // Menu Button (3 dots) - showing only if callbacks are provided
            if (onEdit != null && onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 18,
                      color: AppTheme.darkCharcoal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(recipe);
                      } else if (value == 'delete') {
                        onDelete(recipe);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Lock icon for private recipes
            if (showLock)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
