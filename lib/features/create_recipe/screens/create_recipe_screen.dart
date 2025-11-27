import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateRecipeBloc(),
      child: const CreateRecipeView(),
    );
  }
}

class CreateRecipeView extends StatefulWidget {
  const CreateRecipeView({super.key});

  @override
  State<CreateRecipeView> createState() => _CreateRecipeViewState();
}

class _CreateRecipeViewState extends State<CreateRecipeView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isPublic = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener слухає зміни стану і реагує (навігація, снекбари)
    return BlocListener<CreateRecipeBloc, CreateRecipeState>(
      listener: (context, state) {
        if (state is CreateRecipeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe created successfully!')),
          );
          Navigator.pop(context); // Закриваємо екран
        } else if (state is CreateRecipeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: const Text('Create Recipe'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<CreateRecipeBloc, CreateRecipeState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is CreateRecipeLoading
                        ? null // Блокуємо кнопку поки вантажить
                        : () {
                            // Відправляємо подію
                            context.read<CreateRecipeBloc>().add(
                              SubmitRecipe(
                                title: _titleController.text,
                                description: _descriptionController.text,
                                isPublic: _isPublic,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkCharcoal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    child: state is CreateRecipeLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Image Upload ---
              const Text(
                'Recipe Image',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.darkCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => print("Pick image"),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.offWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        size: 32,
                        color: AppTheme.mediumGray,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to add photo',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.mediumGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Fields ---
              _buildLabel('Recipe Title *'),
              _buildTextField(
                controller: _titleController,
                hintText: 'Enter recipe title...',
              ),
              const SizedBox(height: 24),

              _buildLabel('Description'),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Describe your recipe...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              _buildLabel('Ingredients *'),
              _buildTextField(
                controller: _ingredientsController,
                hintText: 'Enter each ingredient on a new line...',
                maxLines: 6,
              ),
              const SizedBox(height: 24),

              _buildLabel('Instructions *'),
              _buildTextField(
                controller: _instructionsController,
                hintText: 'Enter each step on a new line...',
                maxLines: 8,
              ),
              const SizedBox(height: 24),

              // --- Switch ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make this recipe public',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.darkCharcoal,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Anyone can see this recipe',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _isPublic,
                    activeColor: AppTheme.darkCharcoal,
                    onChanged: (value) => setState(() => _isPublic = value),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppTheme.darkCharcoal,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 3 : 1,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.mediumGray),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.darkCharcoal,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
