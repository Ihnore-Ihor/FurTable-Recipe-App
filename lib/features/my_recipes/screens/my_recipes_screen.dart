import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/core/widgets/guest_view.dart';
import 'package:furtable/features/create_recipe/screens/create_recipe_screen.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_bloc.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_event.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_state.dart';
import 'package:furtable/features/explore/widgets/responsive_recipe_grid.dart'; // <--- Import
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(AppLocalizations.of(context)!.myRecipes),
          ),
          automaticallyImplyLeading: false,
        ),
        body: GuestView(
          title: AppLocalizations.of(context)!.guestMyRecipesTitle,
          message: AppLocalizations.of(context)!.guestMyRecipesMessage,
          imagePath: 'assets/images/jack_writing.png',
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
      );
    }

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

    // INSTEAD OF manual AlignedGridView (lines 182-312)...
    return StandardRecipeGrid(
      recipes: recipes,
      showLockIcon: isPrivate,
      onEdit: (recipe) async {
        // 1. Navigate to edit screen.
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateRecipeScreen(recipeToEdit: recipe),
          ),
        );
        // If returned true (successful save), refresh the list.
        if (result == true && context.mounted) {
          context.read<MyRecipesBloc>().add(LoadMyRecipes());
        }
      },
      onDelete: (recipe) {
        // 2. Show delete dialog.
        _showDeleteDialog(context, recipe);
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
