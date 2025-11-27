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
  // Ключ для форми
  final _formKey = GlobalKey<FormState>();

  // Режим валідації (спочатку вимкнений, вмикається після натискання Save)
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

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

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      // Якщо є помилки, вмикаємо живий режим валідації
      if (_autovalidateMode == AutovalidateMode.disabled) {
        setState(() {
          _autovalidateMode = AutovalidateMode.onUserInteraction;
        });
      }
      return;
    }

    // Якщо все ок, відправляємо подію в BLoC
    context.read<CreateRecipeBloc>().add(
      SubmitRecipe(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateRecipeBloc, CreateRecipeState>(
      listener: (context, state) {
        if (state is CreateRecipeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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
                        ? null
                        : _submitForm, // Викликаємо нашу функцію валідації
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
                      disabledBackgroundColor: AppTheme.darkCharcoal
                          .withOpacity(0.7),
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
        // Обгортаємо все в Form
        body: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
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
                _buildTextFormField(
                  controller: _titleController,
                  hintText: 'Enter recipe title...',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildLabel('Description'),
                _buildTextFormField(
                  controller: _descriptionController,
                  hintText: 'Describe your recipe...',
                  maxLines: 4,
                  // Опис не обов'язковий, тому validator не потрібен
                ),
                const SizedBox(height: 24),

                _buildLabel('Ingredients *'),
                _buildTextFormField(
                  controller: _ingredientsController,
                  hintText: 'Enter each ingredient on a new line...',
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please list at least one ingredient';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildLabel('Instructions *'),
                _buildTextFormField(
                  controller: _instructionsController,
                  hintText: 'Enter each step on a new line...',
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide cooking instructions';
                    }
                    return null;
                  },
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

  // Оновлений віджет для полів вводу (TextFormField)
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 3 : 1,
      validator: validator,
      style: const TextStyle(color: AppTheme.darkCharcoal),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.mediumGray),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),

        // Стиль помилки (червоний текст знизу)
        errorStyle: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),

        // Звичайна рамка (світло-сіра або прозора)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        // Рамка при фокусі (чорна або темно-сіра)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.darkCharcoal,
            width: 1.5,
          ),
        ),

        // Рамка при помилці (червона)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
      ),
    );
  }
}
