import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/screens/recipe_details_screen.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/create_recipe/screens/create_recipe_screen.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Фейкові дані для прикладу
    final myPublicRecipes = [
      const Recipe(
        id: 'mp_1',
        title: 'Homemade Pizza',
        author: 'You',
        imageUrl: 'assets/images/pizza.png',
        likes: '124',
        timeMinutes: 40,
        ingredients: [],
        steps: [],
      ),
      const Recipe(
        id: 'mp_2',
        title: 'Banana Bread',
        author: 'You',
        imageUrl: 'assets/images/banana_bread.png',
        likes: '67',
        timeMinutes: 60,
        ingredients: [],
        steps: [],
      ),
    ];

    final myPrivateRecipes = [
      const Recipe(
        id: 'mpr_1',
        title: 'Secret Family Soup',
        author: 'You',
        imageUrl: 'assets/images/family_soup.png',
        likes: '0',
        timeMinutes: 120,
        ingredients: [],
        steps: [],
      ),
    ];

    return DefaultTabController(
      length: 2, // Дві вкладки: Public, Private
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('My Recipes'),
          ),
          automaticallyImplyLeading: false,
          actions: [
            // Кнопка "Додати" (+)
            IconButton(
              onPressed: () {
                // Перехід на екран створення
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateRecipeScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
                color: AppTheme.darkCharcoal,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  12,
                ), // Округлий контейнер для табів
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppTheme.offWhite, // Колір активної вкладки
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: AppTheme.darkCharcoal,
                unselectedLabelColor: AppTheme.mediumGray,
                labelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Public'),
                  Tab(text: 'Private'),
                ],
                dividerColor: Colors.transparent, // Прибираємо лінію знизу
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _buildRecipeGrid(context, myPublicRecipes),
            _buildRecipeGrid(context, myPrivateRecipes, isPrivate: true),
          ],
        ),

        // Навігація
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.darkCharcoal,
          unselectedItemColor: AppTheme.mediumGray,
          currentIndex: 1, // Індекс "My Recipes"
          onTap: (index) => NavigationHelper.onItemTapped(context, index, 1),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'My Recipes',
            ), // Icon changed to filled book
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(
    BuildContext context,
    List<Recipe> recipes, {
    bool isPrivate = false,
  }) {
    if (recipes.isEmpty) {
      return Center(
        child: Text(
          'No recipes yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

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
          child: Stack(
            children: [
              RecipeCard(
                id: recipe.id,
                imageUrl: recipe.imageUrl,
                title: recipe.title,
                author: recipe.author,
                likes: recipe.likes,
              ),
              // Якщо приватний - додаємо замочок
              if (isPrivate)
                Positioned(
                  top: 8,
                  right: 8,
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
}
