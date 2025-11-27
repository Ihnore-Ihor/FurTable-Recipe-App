import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// A screen that allows users to create a new recipe or edit an existing one.
///
/// If [recipeToEdit] is provided, the screen pre-fills the fields with the recipe's data.
class CreateRecipeScreen extends StatelessWidget {
  /// The recipe to edit, if any.
  final Recipe? recipeToEdit;

  /// Creates a [CreateRecipeScreen].
  const CreateRecipeScreen({super.key, this.recipeToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateRecipeBloc(),
      child: CreateRecipeView(recipeToEdit: recipeToEdit),
    );
  }
}

/// The view implementation for creating or editing a recipe.
class CreateRecipeView extends StatefulWidget {
  /// The recipe to edit, if any.
  final Recipe? recipeToEdit;

  /// Creates a [CreateRecipeView].
  const CreateRecipeView({super.key, this.recipeToEdit});

  @override
  State<CreateRecipeView> createState() => _CreateRecipeViewState();
}

class _CreateRecipeViewState extends State<CreateRecipeView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill fields with existing recipe data.
    if (widget.recipeToEdit != null) {
      final r = widget.recipeToEdit!;
      _titleController.text = r.title;
      // Convert lists to newline-separated strings.
      _ingredientsController.text = r.ingredients.join('\n');
      _instructionsController.text = r.steps.join('\n');
      // Simulate description as it's not in the model.
      _descriptionController.text = "Delicious recipe by ${r.author}";
      // _isPublic = r.isPublic; // Uncomment if isPublic is added to the model.
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  /// Validates the form and dispatches the appropriate event (Submit or Update).
  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    // 1. Validation.
    if (!isValid) {
      if (_autovalidateMode == AutovalidateMode.disabled) {
        setState(() {
          _autovalidateMode = AutovalidateMode.onUserInteraction;
        });
      }
      return;
    }

    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();

    // 2. Dispatch event based on mode (Create vs Update).
    if (widget.recipeToEdit != null) {
      context.read<CreateRecipeBloc>().add(
        UpdateRecipe(
          id: widget.recipeToEdit!.id,
          title: title,
          description: desc,
          isPublic: _isPublic,
        ),
      );
    } else {
      context.read<CreateRecipeBloc>().add(
        SubmitRecipe(title: title, description: desc, isPublic: _isPublic),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipeToEdit != null;

    return BlocListener<CreateRecipeBloc, CreateRecipeState>(
      listener: (context, state) {
        if (state is CreateRecipeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? 'Recipe updated!' : 'Recipe created successfully!',
              ),
              backgroundColor: AppTheme.darkCharcoal,
            ),
          );
          // Return true to indicate success and trigger a refresh on the previous screen.
          Navigator.pop(context, true);
        } else if (state is CreateRecipeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Recipe' : 'Create Recipe'),
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
                        : _submitForm, // Triggers validation and submission.
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
        body: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Image Upload Section ---
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
                    // Logic for image display: Show photo if editing, otherwise show upload icon.
                    child: isEditing
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.recipeToEdit!.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
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

                // --- Form Fields with Validation ---
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

                // --- Visibility Switch ---
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

        // Error styling.
        errorStyle: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),

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
            width: 1.5,
          ),
        ),

        // Red border on error.
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
