import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/core/widgets/guest_view.dart';
import 'package:furtable/features/explore/widgets/responsive_recipe_grid.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';
import 'package:furtable/l10n/app_localizations.dart'; // Імпорт локалізації

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(AppLocalizations.of(context)!.favorites),
          ),
          automaticallyImplyLeading: false,
        ),
        body: GuestView(
          title: AppLocalizations.of(context)!.guestFavoritesTitle,
          message: AppLocalizations.of(context)!.guestFavoritesMessage,
          imagePath: 'assets/images/gohin_empty.png',
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.darkCharcoal,
          unselectedItemColor: AppTheme.mediumGray,
          currentIndex: 2,
          onTap: (index) => NavigationHelper.onItemTapped(context, index, 2),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              label: AppLocalizations.of(context)!.explore,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book_outlined),
              label: AppLocalizations.of(context)!.myRecipes,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              label: AppLocalizations.of(context)!.favorites,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: AppLocalizations.of(context)!.search,
            ),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (context) => FavoritesBloc()..add(LoadFavorites()),
      child: const FavoritesView(),
    );
  }
}

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(AppLocalizations.of(context)!.favorites),
        ),
        automaticallyImplyLeading: false,
        // Профіль ми викликаємо через NavigationHelper або AppBar Actions
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.darkCharcoal));
          }

          if (state is FavoritesLoaded) {
            if (state.recipes.isEmpty) {
              return _buildEmptyState(context);
            }
            // Використовуємо наш адаптивний грід
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                 SliverRecipeGrid(recipes: state.recipes),
              ],
            );
          }

          if (state is FavoritesError) {
            return Center(child: Text(state.message));
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            label: AppLocalizations.of(context)!.explore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            label: AppLocalizations.of(context)!.myRecipes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            label: AppLocalizations.of(context)!.favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppLocalizations.of(context)!.search,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/gohin_empty.png',
              height: 200,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noFavorites,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapHeart,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
