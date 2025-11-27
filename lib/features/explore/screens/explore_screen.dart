import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/navigation_helper.dart';
import 'package:furtable/features/explore/bloc/explore_bloc.dart';
import 'package:furtable/features/explore/bloc/explore_event.dart';
import 'package:furtable/features/explore/bloc/explore_state.dart';
import 'package:furtable/features/explore/screens/recipe_details_screen.dart';
import 'package:furtable/features/explore/widgets/recipe_card.dart';
import 'package:furtable/features/profile/screens/profile_screen.dart';

/// The main screen for exploring recipes.
///
/// This widget provides the [ExploreBloc] to the widget tree.
class ExploreScreen extends StatelessWidget {
  /// Whether to show a verification message upon loading.
  final bool showVerificationMessage;

  /// Creates an [ExploreScreen].
  const ExploreScreen({
    super.key,
    this.showVerificationMessage = false, // Default is false
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreBloc()..add(LoadRecipesEvent()),
      child: ExploreView(
        showVerificationMessage: showVerificationMessage,
      ),
    );
  }
}

/// The view implementation for the explore screen.
///
/// Contains the UI and scroll logic, and has access to the [ExploreBloc].
class ExploreView extends StatefulWidget {
  /// Whether to show a verification message.
  final bool showVerificationMessage;

  /// Creates an [ExploreView].
  const ExploreView({super.key, required this.showVerificationMessage});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logScreenView(screenName: 'ExploreScreen');
    _scrollController.addListener(_onScroll);

    // Logic to show verification message if needed.
    if (widget.showVerificationMessage) {
      // Wait for the frame to render before showing the SnackBar.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created! Please check your email to verify.',
            ),
            backgroundColor: AppTheme.darkCharcoal,
            duration: Duration(seconds: 6),
            behavior:
                SnackBarBehavior.floating, // Floating behavior for better UI.
            margin: EdgeInsets.all(16),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      // Load more recipes when the bottom is reached.
      context.read<ExploreBloc>().add(LoadRecipesEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1920) return 6;
    if (screenWidth > 1200) return 5;
    if (screenWidth > 1024) return 4;
    if (screenWidth > 767) return 3;
    if (screenWidth > 480) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);

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
      body: BlocBuilder<ExploreBloc, ExploreState>(
        builder: (context, state) {
          if (state.status == ExploreStatus.initial ||
              (state.status == ExploreStatus.loading &&
                  state.recipes.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.darkCharcoal),
            );
          }

          if (state.status == ExploreStatus.failure && state.recipes.isEmpty) {
            return Center(
              child: Text('Error loading recipes: ${state.errorMessage}'),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverAlignedGrid.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  itemCount: state.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = state.recipes[index];

                    // Handle recipe tap.
                    return GestureDetector(
                      onTap: () {
                        // Navigate to recipe details screen.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailsScreen(recipe: recipe),
                          ),
                        );
                      },
                      child: RecipeCard(
                        // Pass ID for Hero animation tag.
                        id: recipe.id,
                        imageUrl: recipe.imageUrl,
                        title: recipe.title,
                        author: recipe.author,
                        likes: recipe.likes,
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: state.hasReachedMax
                        ? Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppTheme.mediumGray.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "You've reached the end",
                                style: TextStyle(
                                  color: AppTheme.mediumGray.withOpacity(0.5),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.darkCharcoal,
                          ),
                  ),
                ),
              ),
            ],
          );
        },
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
        onTap: (index) => NavigationHelper.onItemTapped(context, index, 0),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'My Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
