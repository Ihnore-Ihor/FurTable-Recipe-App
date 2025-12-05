import 'dart:typed_data'; // Для роботи з байтами картинки
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для фільтрації вводу цифр
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // Для вибору фото
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

class CreateRecipeScreen extends StatelessWidget {
  final Recipe? recipeToEdit;

  const CreateRecipeScreen({super.key, this.recipeToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateRecipeBloc(),
      child: CreateRecipeView(recipeToEdit: recipeToEdit),
    );
  }
}

class CreateRecipeView extends StatefulWidget {
  final Recipe? recipeToEdit;
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
  final _timeController = TextEditingController(); // <--- НОВЕ: ЧАС
  
  bool _isPublic = true; // За замовчуванням публічний
  Uint8List? _selectedImageBytes; // <--- НОВЕ: Зберігаємо фото

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      final r = widget.recipeToEdit!;
      _titleController.text = r.title;
      _descriptionController.text = r.description;
      _ingredientsController.text = r.ingredients.join('\n');
      _instructionsController.text = r.steps.join('\n');
      _timeController.text = r.timeMinutes.toString(); // Заповнюємо час
      _isPublic = r.isPublic;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // --- ФУНКЦІЯ ВИБОРУ ФОТО ---
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      if (_autovalidateMode == AutovalidateMode.disabled) {
        setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      }
      return;
    }

    // Парсимо час (якщо пусто або 0, ставимо дефолт)
    int time = int.tryParse(_timeController.text) ?? 30;

    if (widget.recipeToEdit != null) {
        // Логіка оновлення (UpdateRecipe)...
        context.read<CreateRecipeBloc>().add(
          UpdateRecipe(
            id: widget.recipeToEdit!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            ingredients: _ingredientsController.text.trim(),
            instructions: _instructionsController.text.trim(),
            isPublic: _isPublic,
            currentImageUrl: widget.recipeToEdit!.imageUrl,
            newImageBytes: _selectedImageBytes,
          ),
        );
    } else {
      context.read<CreateRecipeBloc>().add(
            SubmitRecipe(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              ingredients: _ingredientsController.text.trim(),
              instructions: _instructionsController.text.trim(),
              timeMinutes: time, // <--- Передаємо час
              isPublic: _isPublic,
              imageBytes: _selectedImageBytes, // <--- Передаємо фото
            ),
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
            const SnackBar(content: Text('Success!'), backgroundColor: AppTheme.darkCharcoal),
          );
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
                    onPressed: state is CreateRecipeLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkCharcoal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: state is CreateRecipeLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
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
                const Text('Recipe Image', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.darkCharcoal)),
                const SizedBox(height: 12),
                
                // --- ЗОНА ВИБОРУ ФОТО ---
                GestureDetector(
                  onTap: _pickImage, // <--- ТУТ ПІДКЛЮЧЕНО ФУНКЦІЮ
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.offWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: _selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                          )
                        : (isEditing &&
                                widget.recipeToEdit!.imageUrl.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: widget.recipeToEdit!.imageUrl
                                        .startsWith('http')
                                    ? Image.network(
                                        widget.recipeToEdit!.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.error),
                                      )
                                    : Image.asset(
                                        widget.recipeToEdit!.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.error),
                                      ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.file_upload_outlined, size: 32, color: AppTheme.mediumGray),
                                  SizedBox(height: 8),
                                  Text('Tap to add photo', style: TextStyle(fontFamily: 'Inter', color: AppTheme.mediumGray, fontSize: 14)),
                                ],
                              ),
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildLabel('Recipe Title *'),
                _buildTextFormField(controller: _titleController, hintText: 'Enter title...', validator: (v) => v!.isEmpty ? 'Required' : null),
                
                const SizedBox(height: 24),
                _buildLabel('Description'),
                _buildTextFormField(controller: _descriptionController, hintText: 'Describe it...', maxLines: 3),

                // --- ПОЛЕ ЧАСУ ---
                const SizedBox(height: 24),
                _buildLabel('Cooking Time (minutes) *'),
                _buildTextFormField(
                  controller: _timeController,
                  hintText: 'e.g. 45',
                  // Дозволяємо вводити тільки цифри
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 24),
                _buildLabel('Ingredients *'),
                _buildTextFormField(controller: _ingredientsController, hintText: 'One per line...', maxLines: 6, validator: (v) => v!.isEmpty ? 'Required' : null),
                
                const SizedBox(height: 24),
                _buildLabel('Instructions *'),
                _buildTextFormField(controller: _instructionsController, hintText: 'One per line...', maxLines: 8, validator: (v) => v!.isEmpty ? 'Required' : null),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Make Public', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
                    Switch.adaptive(value: _isPublic, activeColor: AppTheme.darkCharcoal, onChanged: (v) => setState(() => _isPublic = v)),
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

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 3 : 1,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
