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

/// Screen for searching recipes by title or author.
class SearchScreen extends StatelessWidget {
  /// Creates a [SearchScreen].
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc()..add(LoadSearchHistory()),
      child: const SearchView(),
    );
  }
}

/// The view implementation for [SearchScreen].
class SearchView extends StatefulWidget {
  /// Creates a [SearchView].
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

  // Common widget for displaying placeholder images.
  Widget _buildPlaceholderImage(String assetPath) {
    return Opacity(
      opacity: 0.75, // 75% opacity.
      child: Container(
        width: double.infinity, // Full width.
        height: 250, // Fixed height.
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover, // Stretch to width.
            alignment: Alignment.topCenter, // Show only top 40%.
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
              // History Save (saves only when Enter/Search is pressed).
              onSubmitted: (value) {
                context.read<SearchBloc>().add(SearchQuerySubmitted(value));
              },
              // Keyboard action setting.
              textInputAction: TextInputAction.search,

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
                // History State.
                if (state is SearchHistoryLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Searches',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkCharcoal,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.read<SearchBloc>().add(
                                ClearSearchHistory(),
                              ),
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: AppTheme.mediumGray),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.history.length,
                          itemBuilder: (context, index) {
                            final item = state.history[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.history,
                                color: AppTheme.mediumGray,
                              ),
                              title: Text(
                                item,
                                style: const TextStyle(
                                  color: AppTheme.darkCharcoal,
                                ),
                              ),
                              onTap: () {
                                // 1. Set text.
                                _searchController.text = item;
                                // 2. IMPORTANT: Trigger Submitted to start search.
                                context.read<SearchBloc>().add(
                                  SearchQuerySubmitted(item),
                                );
                                // 3. Unfocus to hide keyboard.
                                FocusScope.of(context).unfocus();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                // 1. STATE: INITIAL
                if (state is SearchInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Vertically centered.
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

                // 2. STATE: LOADING
                if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.darkCharcoal,
                    ),
                  );
                }

                // 3. STATE: EMPTY
                if (state is SearchEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Vertically centered.
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

                // 4. STATE: SUCCESS
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

      // Navigation bar.
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
