import 'package:flutter/material.dart';
import 'package:furtable/core/widgets/app_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/search/bloc/search_bloc.dart';
import 'package:furtable/features/search/bloc/search_event.dart';
import 'package:furtable/features/search/bloc/search_state.dart';
import 'package:furtable/features/explore/widgets/responsive_recipe_grid.dart'; // <--- Import
import 'package:furtable/features/profile/screens/profile_screen.dart';
import 'package:furtable/l10n/app_localizations.dart';

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
  // Common widget for displaying placeholder images.
  Widget _buildPlaceholderImage(String assetPath) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On desktop height should be larger so it doesn't look like a strip
        double height = constraints.maxWidth > 600 ? 400 : 250;

        return Opacity(
          opacity: 0.75,
          child: AppImage(
            imagePath: assetPath,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            // alignment: Alignment.topCenter is already built-in for Haru in AppImage/placeholder logic if needed,
            // or we can rely on fit: BoxFit.cover to do a decent job.
            // If explicit alignment is needed, wrapping AppImage in another widget or modifying AppImage might be needed,
            // but for now we follow the request to use AppImage.
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(AppLocalizations.of(context)!.search),
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
                hintText: AppLocalizations.of(context)!.searchHint,
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
                            Text(
                              AppLocalizations.of(context)!.recentSearches,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkCharcoal,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.read<SearchBloc>().add(
                                ClearSearchHistory(),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.clear,
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
                        Text(
                          AppLocalizations.of(context)!.typeToSearch,
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
                        Text(
                          AppLocalizations.of(context)!.noRecipesFound,
                          style: TextStyle(
                            color: AppTheme.darkCharcoal,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.tryDifferentSearch,
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
                  // INSTEAD OF AlignedGridView.count...
                  return StandardRecipeGrid(recipes: state.recipes);
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
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: AppLocalizations.of(context)!.search),
        ],
      ),
    );
  }
}
