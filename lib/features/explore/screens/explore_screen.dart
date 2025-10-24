import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recipes = [
      {
        'image': 'assets/images/salmon.png',
        'title': 'Grilled Salmon Teriyaki',
        'author': 'ChefMaria',
        'likes': '2.4k',
      },
      {
        'image': 'assets/images/pasta.png',
        'title':
            'Creamy Mushroom Pasta with a very long name that might wrap to two lines',
        'author': 'ItalianNonna',
        'likes': '1.8k',
      },
      {
        'image': 'assets/images/sushi.png',
        'title': 'Dragon Roll Sushi',
        'author': 'SushiMaster',
        'likes': '3.1k',
      },
      {
        'image': 'assets/images/burger.png',
        'title': 'Classic Beef Burger',
        'author': 'GrillKing',
        'likes': '956',
      },
      {
        'image': 'assets/images/cake.png',
        'title': 'Carrot Cake',
        'author': 'SweetTooth',
        'likes': '4.2k',
      },
      {
        'image': 'assets/images/salad.png',
        'title': 'Fresh Garden Salad',
        'author': 'HealthyEats',
        'likes': '1.2k',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Explore'),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.person_outline,
              color: AppTheme.darkCharcoal,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AlignedGridView.count(
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
      ),
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
        currentIndex: 0,
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
}
