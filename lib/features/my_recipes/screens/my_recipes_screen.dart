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
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';
import 'package:furtable/features/profile/screens/profile_screen.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Screen displaying the recipes created by the current user.
///
/// Provides tabs for Public and Private recipes and allows editing or deleting them.
class MyRecipesScreen extends StatelessWidget {
  /// Creates a [MyRecipesScreen].
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC here to load data when entering the screen.
    return BlocProvider(
      create: (context) => MyRecipesBloc()..add(LoadMyRecipes()),
      child: const MyRecipesView(),
    );
  }
}

/// The view implementation for [MyRecipesScreen].
class MyRecipesView extends StatelessWidget {
  /// Creates a [MyRecipesView].
  const MyRecipesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(AppLocalizations.of(context)!.myRecipes),
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
              icon: const Icon(Icons.person_outline, color: AppTheme.darkCharcoal),
            ),
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
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.public),
                  Tab(text: AppLocalizations.of(context)!.private),
                ],
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
        ),

        // Listen to the state here.
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
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              label: AppLocalizations.of(context)!.explore,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book),
              label: AppLocalizations.of(context)!.myRecipes,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              label: AppLocalizations.of(context)!.favorites,
            ),
            BottomNavigationBarItem(icon: const Icon(Icons.search), label: AppLocalizations.of(context)!.search),
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
          AppLocalizations.of(context)!.noRecipesYet,
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
                builder: (context) => RecipeDetailsScreen(initialRecipe: recipe),
              ),
            );
          },
          child: Stack(
            children: [
              BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, favState) {
                  bool isFav = false;
                  if (favState is FavoritesLoaded) {
                    isFav = favState.recipes.any((r) => r.id == recipe.id);
                  }
                  return RecipeCard(
                    id: recipe.id,
                    imageUrl: recipe.imageUrl,
                    title: recipe.title,
                    author: recipe.authorName,
                    likes: recipe.likes,
                    isFavorite: isFav,
                    onFavoriteToggle: () {
                      context.read<FavoritesBloc>().add(ToggleFavorite(recipe));
                    },
                  );
                },
              ),

              // --- Menu Button (3 dots) ---
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
                    onSelected: (value) async {
                      if (value == 'edit') {
                        // 1. Navigate to edit screen.
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateRecipeScreen(recipeToEdit: recipe),
                          ),
                        );
                        // If returned true (successful save), refresh the list.
                        if (result == true && context.mounted) {
                          context.read<MyRecipesBloc>().add(LoadMyRecipes());
                        }
                      } else if (value == 'delete') {
                        // 2. Show delete dialog.
                        _showDeleteDialog(context, recipe);
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

              // Lock icon for private recipes.
              if (isPrivate)
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

  /// Shows a confirmation dialog for deleting a recipe.
  void _showDeleteDialog(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.deleteRecipeTitle,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteRecipeContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppTheme.mediumGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkCharcoal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Delete via BLoC.
              context.read<MyRecipesBloc>().add(DeleteRecipeEvent(recipe.id));
              Navigator.pop(ctx); // Close dialog.

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.recipeDeleted),
                  backgroundColor: AppTheme.darkCharcoal,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}
