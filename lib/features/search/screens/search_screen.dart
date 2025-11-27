import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/explore/screens/recipe_details_screen.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/search/bloc/search_bloc.dart';
import 'package:furtable/features/search/bloc/search_event.dart';
import 'package:furtable/features/search/bloc/search_state.dart';
import 'package:furtable/features/profile/screens/profile_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchQueryChanged(''));
    FocusScope.of(context).unfocus();
  }

  // Спільний віджет для відображення картинок (Legom )
  Widget _buildPlaceholderImage(String assetPath) {
    return Opacity(
      opacity: 0.75, // 75% непрозорості
      child: Container(
        width: double.infinity, // На всю ширину
        height: 250, // Фіксована висота
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover, // Розтягуємо по ширині
            alignment: Alignment.topCenter, // Показуємо тільки верхні 40%
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Search'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<SearchBloc>().add(SearchQueryChanged(value));
              },
              decoration: InputDecoration(
                hintText: 'Recipe or Author',
                hintStyle: const TextStyle(color: AppTheme.mediumGray),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.mediumGray,
                ),
                suffixIcon: _showClearButton
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppTheme.mediumGray,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                // 1. СТАН: ПОЧАТОК (Legom)
                if (state is SearchInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Вертикально по центру
                      children: [
                        _buildPlaceholderImage(
                          'assets/images/legom_posing.png',
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Type to search...',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 2. СТАН: ЗАВАНТАЖЕННЯ
                if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.darkCharcoal,
                    ),
                  );
                }

                // 3. СТАН: НЕ ЗНАЙДЕНО (Legom) - Той самий стиль
                if (state is SearchEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Вертикально по центру
                      children: [
                        _buildPlaceholderImage(
                          'assets/images/legom_posing.png',
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No recipes found.',
                          style: TextStyle(
                            color: AppTheme.darkCharcoal,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try searching for something else.',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 4. СТАН: УСПІХ
                if (state is SearchSuccess) {
                  return AlignedGridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    itemCount: state.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = state.recipes[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailsScreen(recipe: recipe),
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

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),

      // Навігація (виклик спільної функції, яку ми напишемо нижче)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.darkCharcoal,
        unselectedItemColor: AppTheme.mediumGray,
        currentIndex: 3,
        onTap: (index) => NavigationHelper.onItemTapped(context, index, 3),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'My Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
