import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/favorites/screens/favorites_screen.dart';
import 'package:furtable/features/loading/screens/loading_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    print("ANALYTICS: Logging ExploreScreen view...");
    FirebaseAnalytics.instance.logScreenView(screenName: 'ExploreScreen');
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1920) {
      return 6;
    } else if (screenWidth > 1200) {
      return 5;
    } else if (screenWidth > 1024) {
      return 4;
    } else if (screenWidth > 767) {
      return 3;
    } else if (screenWidth > 480) {
      return 2;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = _getCrossAxisCount(screenWidth);

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoadingScreen()),
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
      body: Column(
        children: [
          Expanded(
            child: AlignedGridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: crossAxisCount,
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
          ),
        ],
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
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const FavoritesScreen(),
              ),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'My Recipes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
