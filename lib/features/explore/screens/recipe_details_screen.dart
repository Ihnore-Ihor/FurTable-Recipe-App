import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/auth_helper.dart';
import 'package:furtable/core/utils/avatar_helper.dart';
import 'package:furtable/core/utils/duration_helper.dart';
import 'package:furtable/core/widgets/app_image.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Screen displaying the detailed view of a recipe with interactive checklists.
class RecipeDetailsScreen extends StatefulWidget {
  final Recipe initialRecipe;

  const RecipeDetailsScreen({super.key, required this.initialRecipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  // Store indices/values of completed items locally
  final Set<String> _completedIngredients = {};
  final Set<int> _completedSteps = {};

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          backgroundColor: AppTheme.offWhite,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFavorite = false;
                if (state is FavoritesLoaded) {
                  isFavorite = state.recipes.any(
                    (r) => r.id == widget.initialRecipe.id,
                  );
                }
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppTheme.darkCharcoal,
                  ),
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      AuthHelper.showAuthRequiredDialog(
                        context,
                        AppLocalizations.of(context)!.authRequiredLike,
                        icon: Icons.favorite_border,
                      );
                      return;
                    }
                    context.read<FavoritesBloc>().add(
                      ToggleFavorite(widget.initialRecipe),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('recipes')
              .doc(widget.initialRecipe.id)
              .snapshots(),
          builder: (context, snapshot) {
            Recipe recipe;
            if (snapshot.hasData && snapshot.data!.exists) {
              recipe = Recipe.fromFirestore(snapshot.data!);
            } else {
              recipe = widget.initialRecipe;
            }

            return SizedBox.expand(
              child: SingleChildScrollView(
                // Increased bottom padding to 80 for comfortable scrolling to the end
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  width:
                      double.infinity, // Ensure the entire width is scrollable.
                  alignment:
                      Alignment.topCenter, // Center the content horizontally.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipe Image
                        AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Hero(
                            tag: 'recipe_image_${recipe.id}',
                            child: AppImage(
                              imagePath: recipe.imageUrl,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Recipe Title
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkCharcoal,
                            height: 1.2,
                          ),
                        ),
                        const CopyableNewline(),
                        const SizedBox(height: 16),

                        // Author Info
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.darkCharcoal,
                                  width: 1.5,
                                ),
                              ),
                              // Increased radius from 16 to 24 (48px diameter).
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white,
                                backgroundImage: AvatarHelper.getAvatarProvider(
                                  recipe.authorAvatarUrl,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.byAuthor(recipe.authorName),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkCharcoal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const CopyableNewline(),

                        const SizedBox(height: 16),

                        // Cooking Time Info
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_filled,
                              color: AppTheme.darkCharcoal,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DurationHelper.format(context, recipe.timeMinutes),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                  color: AppTheme.darkCharcoal),
                            ),
                          ],
                        ),
                        const CopyableNewline(),
                        const CopyableNewline(),

                        const SizedBox(height: 32),

                        // Description Section
                        Text(
                          AppLocalizations.of(context)!.description,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkCharcoal,
                          ),
                        ),
                        const CopyableNewline(),

                        const SizedBox(height: 12),

                        Text(
                          recipe.description.isNotEmpty
                              ? recipe.description
                              : AppLocalizations.of(context)!.noDescription,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            height: 1.6,
                            color: AppTheme.darkCharcoal,
                          ),
                        ),
                        const CopyableNewline(),
                        const CopyableNewline(),

                        const SizedBox(height: 32),

                        // Ingredients Checklist
                        Text(
                          AppLocalizations.of(context)!.ingredients,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkCharcoal,
                          ),
                        ),
                        const CopyableNewline(),

                        const SizedBox(height: 16),
                        if (recipe.ingredients.isEmpty)
                          Text(
                            AppLocalizations.of(context)!.noIngredients,
                            style: const TextStyle(color: AppTheme.mediumGray),
                          ),

                        ...recipe.ingredients.map((ingredient) {
                          final isDone = _completedIngredients.contains(
                            ingredient,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isDone) {
                                            _completedIngredients.remove(
                                              ingredient,
                                            );
                                          } else {
                                            _completedIngredients.add(
                                              ingredient,
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                          top: 2.0,
                                          bottom: 2.0,
                                        ),
                                        child: _ThinCheckbox(isDone: isDone),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        opacity: isDone ? 0.5 : 1.0,
                                        child: Text(
                                          ingredient,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 17,
                                            height: 1.5,
                                            color: AppTheme.darkCharcoal,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const CopyableNewline(),
                            ],
                          );
                        }),

                        const CopyableNewline(),

                        const SizedBox(height: 32),

                        // Instructions Checklist
                        Text(
                          AppLocalizations.of(context)!.instructions,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkCharcoal,
                          ),
                        ),
                        const CopyableNewline(),
                        const SizedBox(height: 16),
                        if (recipe.steps.isEmpty)
                          Text(
                            AppLocalizations.of(context)!.noInstructions,
                            style: const TextStyle(color: AppTheme.mediumGray),
                          ),

                        ...recipe.steps.asMap().entries.map((entry) {
                          int idx = entry.key;
                          String step = entry.value;
                          final isDone = _completedSteps.contains(idx);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isDone) {
                                            _completedSteps.remove(idx);
                                          } else {
                                            _completedSteps.add(idx);
                                          }
                                        });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                          top: 2.0,
                                          bottom: 2.0,
                                        ),
                                        child: _ThinCheckbox(isDone: isDone),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        opacity: isDone ? 0.5 : 1.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.step(idx + 1),
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.mediumGray,
                                              ),
                                            ),
                                            const CopyableNewline(),
                                            const SizedBox(height: 4),
                                            Text(
                                              step,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 17,
                                                height: 1.6,
                                                color: AppTheme.darkCharcoal
                                                    .withValues(alpha: 0.9),
                                                decoration: isDone
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const CopyableNewline(),
                              const CopyableNewline(),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A custom thin checkbox for recipe checklists.
class _ThinCheckbox extends StatelessWidget {
  final bool isDone;

  const _ThinCheckbox({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20, // Reduced from 24.0 for a more compact look.
      height: 20,
      decoration: BoxDecoration(
        color: isDone ? AppTheme.darkCharcoal : Colors.transparent,
        borderRadius: BorderRadius.circular(
          5,
        ), // Slightly reduced radius from 6.
        border: Border.all(
          color: AppTheme.darkCharcoal,
          width: 1.0, // Thin border line.
        ),
      ),
      child: isDone
          // Reduced size from 16 to 14 to fit the smaller container.
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

/// A widget that is invisible to the eye but adds a newline character when text is copied via SelectionArea.
class CopyableNewline extends StatelessWidget {
  const CopyableNewline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '\n',
      style: TextStyle(
        fontSize: 1, // Minimum size for Flutter to render it.
        height: 0,   // Zero height to avoid breaking the UI layout.
        color: Colors.transparent, // Invisible.
      ),
    );
  }
}
