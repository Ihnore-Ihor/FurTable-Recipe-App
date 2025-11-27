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

/// Screen displaying the user's favorite recipes.
class FavoritesScreen extends StatelessWidget {
  /// Creates a [FavoritesScreen].
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesBloc()..add(LoadFavorites()),
      child: const FavoritesView(),
    );
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
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Favorites'),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'My Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
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
                builder: (context) => RecipeDetailsScreen(recipe: recipe),
              ),
            );
          },
          child: RecipeCard(
            id: recipe.id,
            imageUrl: recipe.imageUrl,
            title: recipe.title,
            author: recipe.author,
            likes: recipe.likes,
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
            'No favorites yet',
            style: textTheme.titleLarge?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 8),

          Text(
            'Tap the heart icon on recipes you love',
            style: textTheme.bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
