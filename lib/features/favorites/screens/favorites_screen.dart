import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/explore/models/recipe_model.dart'; // Імпорт моделі
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/explore/screens/recipe_details_screen.dart'; // Для кліку
import 'package:furtable/features/loading/screens/loading_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Використовуємо нашу модель Recipe замість Map
    // (В реальному додатку це теж мало б йти через BLoC, але поки статика)
    final List<Recipe> favoriteRecipes = [
      const Recipe(
        id: '1',
        title: 'Grilled Salmon Teriyaki',
        author: 'ChefMaria',
        imageUrl: 'assets/images/salmon.png',
        likes: '2.4k',
        timeMinutes: 45,
        ingredients: ['Salmon', 'Soy Sauce'],
        steps: ['Cook it'],
      ),
      const Recipe(
        id: '3',
        title: 'Dragon Roll Sushi',
        author: 'SushiMaster',
        imageUrl: 'assets/images/sushi.png',
        likes: '3.1k',
        timeMinutes: 60,
        ingredients: ['Rice', 'Fish'],
        steps: ['Roll it'],
      ),
    ];

    // final List<Recipe> favoriteRecipes = []; // Розкоментуй для тесту Empty State

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
                MaterialPageRoute(builder: (context) => const LoadingScreen()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: favoriteRecipes.isEmpty
          ? _buildEmptyState(context)
          : _buildFavoritesGrid(favoriteRecipes),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.darkCharcoal,
        unselectedItemColor: AppTheme.mediumGray,
        currentIndex: 2, // Активна вкладка Favorites
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

        // Додаємо GestureDetector, щоб можна було відкрити деталі і з улюблених
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
            'assets/images/gohin_empty.png', // Твій ассет
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
