import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> favoriteRecipes = [
      {
        'image': 'assets/images/salmon.png',
        'title': 'Grilled Salmon Teriyaki',
        'author': 'ChefMaria',
        'likes': '2.4k',
      },
      {
        'image': 'assets/images/sushi.png',
        'title': 'Dragon Roll Sushi',
        'author': 'SushiMaster',
        'likes': '3.1k',
      },
    ];

    //final List<Map<String, String>> favoriteRecipes = [];

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
                MaterialPageRoute(builder: (context) => const Placeholder()),
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
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ExploreScreen(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const Placeholder(),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const Placeholder(),
              ),
            );
          }
        },
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

  Widget _buildFavoritesGrid(List<Map<String, String>> recipes) {
    return AlignedGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 24,
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          imageUrl: recipe['image']!,
          title: recipe['title']!,
          author: recipe['author']!,
          likes: recipe['likes']!,
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
