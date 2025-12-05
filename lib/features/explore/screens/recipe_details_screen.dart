import 'package:cloud_firestore/cloud_firestore.dart'; // <--- НОВЕ
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/favorites/bloc/favorites_bloc.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe initialRecipe; // Перейменували для ясності

  // Приймаємо початкові дані, щоб показати їх поки грузиться оновлення
  const RecipeDetailsScreen({super.key, required this.initialRecipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      // AppBar залишаємо тут, щоб кнопка "Назад" працювала завжди
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Лайк виносимо сюди, він працює окремо через BLoC
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              bool isFavorite = false;
              if (state is FavoritesLoaded) {
                isFavorite = state.recipes.any((r) => r.id == initialRecipe.id);
              }
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppTheme.darkCharcoal,
                ),
                onPressed: () {
                  context.read<FavoritesBloc>().add(ToggleFavorite(initialRecipe));
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // --- ГОЛОВНА ЗМІНА: StreamBuilder ---
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .doc(initialRecipe.id)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Визначаємо, які дані показувати
          Recipe recipe;

          if (snapshot.hasData && snapshot.data!.exists) {
            // Якщо прийшли свіжі дані з бази - беремо їх
            recipe = Recipe.fromFirestore(snapshot.data!);
          } else {
            // Поки вантажиться (або помилка) - показуємо ті, що передали при вході
            recipe = initialRecipe;
          }

          // 2. Малюємо UI (той самий код, що й раніше, але використовуємо змінну recipe)
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Картинка
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
                            errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey),
                          )
                        : Image.asset(
                            recipe.imageUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                             errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Заголовок
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppTheme.darkCharcoal, height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Автор + Аватар
                Row(
                  children: [
                    // --- ВІДНОВЛЕНА АВАТАРКА ---
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.darkCharcoal, 
                          width: 1.5 // Трохи товстіша рамка для стилю
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 16, // Розмір аватара
                        backgroundColor: Colors.white,
                        // Використовуємо шлях з моделі або дефолтний
                        backgroundImage: AssetImage(
                          (recipe.authorAvatarUrl.isNotEmpty)
                              ? recipe.authorAvatarUrl
                              : 'assets/images/legoshi_eating_auth.png'
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ---------------------------

                    Text(
                      'by ${recipe.authorName}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600, // Трохи жирніше для акценту
                        color: AppTheme.darkCharcoal, // Темний колір (раніше був сірий)
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // ... Решта полів (Опис, Інгредієнти, Кроки) без змін ...
                const Text('Description', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkCharcoal)),
                const SizedBox(height: 8),
                Text(recipe.description.isNotEmpty ? recipe.description : 'No description.', style: const TextStyle(fontFamily: 'Inter', fontSize: 15, height: 1.5, color: AppTheme.mediumGray)),
                
                const SizedBox(height: 24),
                const Text('Ingredients', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkCharcoal)),
                const SizedBox(height: 12),
                ...recipe.ingredients.map((i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text("• $i", style: const TextStyle(fontSize: 15, color: AppTheme.darkCharcoal)))),
                
                const SizedBox(height: 24),
                const Text('Instructions', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkCharcoal)),
                const SizedBox(height: 12),
                ...recipe.steps.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(s, style: const TextStyle(fontSize: 15, color: AppTheme.darkCharcoal)))),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
