import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/screens/recipe_details_screen.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';
import 'package:furtable/features/profile/screens/profile_screen.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Screen displaying the user's favorite recipes.
class FavoritesScreen extends StatelessWidget {
  /// Creates a [FavoritesScreen].
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FavoritesView();
  }
}

/// The view implementation for [FavoritesScreen].
class FavoritesView extends StatelessWidget {
  /// Creates a [FavoritesView].
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(AppLocalizations.of(context)!.favorites),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              color: AppTheme.darkCharcoal,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Connect BLoC Builder.
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          // Only show spinner on first loading.
          if (state is FavoritesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.darkCharcoal),
            );
          }

          if (state is FavoritesError) {
            return Center(child: Text(state.message));
          }

          if (state is FavoritesLoaded) {
            if (state.recipes.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildFavoritesGrid(state.recipes);
          }

          return const SizedBox.shrink();
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.darkCharcoal,
        unselectedItemColor: AppTheme.mediumGray,
        currentIndex: 2,
        onTap: (index) => NavigationHelper.onItemTapped(context, index, 2),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: AppLocalizations.of(context)!.explore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            activeIcon: const Icon(Icons.book),
            label: AppLocalizations.of(context)!.myRecipes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: AppLocalizations.of(context)!.favorites,
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: AppLocalizations.of(context)!.search),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(List<Recipe> recipes) {
    return AlignedGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 24,
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsScreen(initialRecipe: recipe),
              ),
            );
          },
          child: RecipeCard(
            id: recipe.id,
            imageUrl: recipe.imageUrl,
            title: recipe.title,
            author: recipe.authorName,
            likes: recipe.likes,
            isFavorite: true, // Always true in Favorites screen
            onFavoriteToggle: () {
              context.read<FavoritesBloc>().add(ToggleFavorite(recipe));
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/gohin_empty.png',
            height: 200,
            color: AppTheme.mediumGray.withOpacity(0.5),
          ),
          const SizedBox(height: 24),

          Text(
            AppLocalizations.of(context)!.noFavorites,
            style: textTheme.titleLarge?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 8),

          Text(
            AppLocalizations.of(context)!.tapHeart,
            style: textTheme.bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
