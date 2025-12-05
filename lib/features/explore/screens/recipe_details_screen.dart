import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // --- ЛОГІКА ЛАЙКА ---
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              bool isFavorite = false;
              
              // Перевіряємо, чи є поточний рецепт у списку завантажених улюблених
              if (state is FavoritesLoaded) {
                isFavorite = state.recipes.any((r) => r.id == recipe.id);
              }

              return IconButton(
                // Змінюємо іконку та колір залежно від стану
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppTheme.darkCharcoal : AppTheme.darkCharcoal,
                ),
                onPressed: () {
                  // Відправляємо подію в глобальний блок
                  context.read<FavoritesBloc>().add(ToggleFavorite(recipe));
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Картинка рецепту
            Hero(
              tag: 'recipe_image_${recipe.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: recipe.imageUrl.startsWith('http')
                    ? Image.network(
                        recipe.imageUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        recipe.imageUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 250,
                          color: Colors.grey[300],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Заголовок
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
            const SizedBox(height: 8),

            // 3. Автор (БЕЗ АВАТАРА, ТІЛЬКИ ТЕКСТ)
            Text(
              'by ${recipe.authorName}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.mediumGray, // Сірий колір для автора
              ),
            ),

            const SizedBox(height: 24),

            // 4. Опис
            const Text(
              'Description',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.description.isNotEmpty 
                  ? recipe.description 
                  : 'No description provided.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                height: 1.5,
                color: AppTheme.mediumGray,
              ),
            ),

            const SizedBox(height: 24),

            // 5. Інгредієнти
            const Text(
              'Ingredients',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 12),
            if (recipe.ingredients.isEmpty)
              const Text('No ingredients listed.', style: TextStyle(color: AppTheme.mediumGray)),
            
            ...recipe.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9CA3AF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppTheme.darkCharcoal,
                      ),
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 24),

            // 6. Інструкції
            const Text(
              'Instructions',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            if (recipe.steps.isEmpty)
              const Text('No instructions listed.', style: TextStyle(color: AppTheme.mediumGray)),

            ...recipe.steps.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              String step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.darkCharcoal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$idx',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          height: 1.5,
                          color: AppTheme.darkCharcoal.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
