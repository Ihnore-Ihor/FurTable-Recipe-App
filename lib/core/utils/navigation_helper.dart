import 'package:flutter/material.dart';
import 'package:furtable/features/explore/screens/explore_screen.dart';
import 'package:furtable/features/my_recipes/screens/my_recipes_screen.dart';
import 'package:furtable/features/favorites/screens/favorites_screen.dart';
import 'package:furtable/features/search/screens/search_screen.dart';

class NavigationHelper {
  static void onItemTapped(BuildContext context, int index, int currentIndex) {
    // Якщо натиснули на ту саму вкладку — нічого не робимо
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const ExploreScreen();
        break;
      case 1:
        page = const MyRecipesScreen();
        break;
      case 2:
        page = const FavoritesScreen();
        break;
      case 3:
        page = const SearchScreen();
        break;
      default:
        return;
    }

    // Виконуємо перехід з Fade анімацією для підтримки Hero
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
