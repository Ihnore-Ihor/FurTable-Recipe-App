import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/create_recipe/screens/create_recipe_screen.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/screens/recipe_details_screen.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_bloc.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_event.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_state.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Провайдер тут, щоб завантажити дані при вході на екран
    return BlocProvider(
      create: (context) => MyRecipesBloc()..add(LoadMyRecipes()),
      child: const MyRecipesView(),
    );
  }
}

class MyRecipesView extends StatelessWidget {
  const MyRecipesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('My Recipes'),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppTheme.offWhite,
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
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
        ),

        // Тут слухаємо стан
        body: BlocBuilder<MyRecipesBloc, MyRecipesState>(
          builder: (context, state) {
            if (state is MyRecipesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.darkCharcoal),
              );
            }

            if (state is MyRecipesError) {
              return Center(child: Text(state.message));
            }

            if (state is MyRecipesLoaded) {
              return TabBarView(
                children: [
                  _buildRecipeGrid(context, state.publicRecipes),
                  _buildRecipeGrid(
                    context,
                    state.privateRecipes,
                    isPrivate: true,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.darkCharcoal,
          unselectedItemColor: AppTheme.mediumGray,
          currentIndex: 1,
          onTap: (index) => NavigationHelper.onItemTapped(context, index, 1),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'My Recipes',
            ),
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
