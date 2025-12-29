import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoTimerPicker
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/widgets/app_image.dart'; // <--- Import
import 'package:furtable/core/utils/image_helper.dart';
import 'package:furtable/l10n/app_localizations.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Screen for creating or editing a recipe.
class CreateRecipeScreen extends StatelessWidget {
  /// The recipe to edit, if in edit mode.
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

/// The view implementation for [CreateRecipeScreen].
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
  final _timeController = TextEditingController();

  bool _isPublic = true;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      final r = widget.recipeToEdit!;
      _titleController.text = r.title;
      _descriptionController.text = r.description;
      _ingredientsController.text = r.ingredients.join('\n');
      _instructionsController.text = r.steps.join('\n');
      _timeController.text = r.timeMinutes.toString();
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // 1. Quick extension check
        final extension = image.name.split('.').last.toLowerCase();
        if (['pdf', 'doc', 'docx', 'exe', 'zip'].contains(extension)) {
          _showError('Invalid file format. Please select an image (JPG, PNG).');
          return;
        }

        final bytes = await image.readAsBytes();

        // 2. Deep byte check (using our helper)
        if (!ImageHelper.isImage(bytes)) {
          _showError('The selected file is not a valid image.');
          return;
        }

        // 3. Compression (to ~100 KB)
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.compressingImage),
            duration: const Duration(milliseconds: 500),
            backgroundColor: AppTheme.darkCharcoal,
          ),
        );

        final compressedBytes = await ImageHelper.compressImage(bytes);

        // For debugging
        // print("Original size...");
        // print("Compressed size...");

        setState(() {
          _selectedImageBytes = compressedBytes;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatDuration(int minutes) {
    final duration = Duration(minutes: minutes);
    final d = duration.inDays;
    final h = duration.inHours % 24;
    final m = duration.inMinutes % 60;

    String result = '';
    if (d > 0) result += '$d${AppLocalizations.of(context)!.days} ';
    if (h > 0) result += '$h${AppLocalizations.of(context)!.hours} ';
    result += '$m${AppLocalizations.of(context)!.mins}';
    return result;
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      if (_autovalidateMode == AutovalidateMode.disabled) {
        setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      }
      return;
    }

    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final ingredients = _ingredientsController.text.trim();
    final instructions = _instructionsController.text.trim();
    final time = int.tryParse(_timeController.text) ?? 30;

    if (widget.recipeToEdit != null) {
      context.read<CreateRecipeBloc>().add(
        UpdateRecipe(
          id: widget.recipeToEdit!.id,
          title: title,
          description: desc,
          ingredients: ingredients,
          instructions: instructions,
          timeMinutes: time,
          isPublic: _isPublic,
          currentImageUrl: widget.recipeToEdit!.imageUrl,
          newImageBytes: _selectedImageBytes,
        ),
      );
    } else {
      context.read<CreateRecipeBloc>().add(
        SubmitRecipe(
          title: title,
          description: desc,
          ingredients: ingredients,
          instructions: instructions,
          timeMinutes: time,
          isPublic: _isPublic,
          imageBytes: _selectedImageBytes,
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
            SnackBar(
              content: Text(isEditing ? AppLocalizations.of(context)!.recipeUpdated : AppLocalizations.of(context)!.recipeCreated),
              backgroundColor: AppTheme.darkCharcoal,
            ),
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
          title: Text(isEditing ? AppLocalizations.of(context)!.editRecipe : AppLocalizations.of(context)!.createRecipe),
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
                        : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkCharcoal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state is CreateRecipeLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.save,
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                Text(
                  AppLocalizations.of(context)!.recipeImage,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
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
                            child: Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (isEditing &&
                              widget.recipeToEdit!.imageUrl.isNotEmpty)
                        ? AppImage(
                            imagePath: widget.recipeToEdit!.imageUrl,
                            width: double.infinity,
                            height: 200,
                            borderRadius: BorderRadius.circular(12),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_upload_outlined,
                                size: 32,
                                color: AppTheme.mediumGray,
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.tapToAddPhoto,
                                style: const TextStyle(
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
                _buildLabel('${AppLocalizations.of(context)!.recipeTitle} *'),
                _buildTextFormField(
                  controller: _titleController,
                  hintText: AppLocalizations.of(context)!.enterTitle,
                  validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.requiredField : null,
                ),

                const SizedBox(height: 24),
                _buildLabel(AppLocalizations.of(context)!.description),
                _buildTextFormField(
                  controller: _descriptionController,
                  hintText: AppLocalizations.of(context)!.describeRecipe,
                  maxLines: 3,
                ),

                const SizedBox(height: 24),
                _buildLabel('${AppLocalizations.of(context)!.cookTime} *'),
                GestureDetector(
                  onTap: () {
                    // 1. Initial value (or 30 if empty)
                    int currentMinutes =
                        int.tryParse(_timeController.text) ?? 30;
                    // 2. Temporary variable for scrolling
                    Duration tempDuration = Duration(minutes: currentMinutes);

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      builder: (BuildContext builder) {
                        return Container(
                          height: 300,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.grey[100],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // 3. On 'Done', save the tempDuration
                                        setState(() {
                                          _timeController.text = tempDuration
                                              .inMinutes
                                              .toString();
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.done,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.darkCharcoal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Row(
                                      children: [
                                        // Days
                                        _buildPickerColumn(
                                          title: AppLocalizations.of(context)!.days,
                                          count: 32, // 0..31
                                          initialItem: tempDuration.inDays,
                                          onChanged: (val) {
                                            setState(() {
                                              tempDuration = Duration(
                                                days: val,
                                                hours:
                                                    tempDuration.inHours % 24,
                                                minutes:
                                                    tempDuration.inMinutes % 60,
                                              );
                                            });
                                          },
                                        ),
                                        // Hours
                                        _buildPickerColumn(
                                          title: AppLocalizations.of(context)!.hours,
                                          count: 24,
                                          initialItem:
                                              tempDuration.inHours % 24,
                                          onChanged: (val) {
                                            setState(() {
                                              tempDuration = Duration(
                                                days: tempDuration.inDays,
                                                hours: val,
                                                minutes:
                                                    tempDuration.inMinutes % 60,
                                              );
                                            });
                                          },
                                        ),
                                        // Minutes
                                        _buildPickerColumn(
                                          title: AppLocalizations.of(context)!.mins,
                                          count: 60,
                                          initialItem:
                                              tempDuration.inMinutes % 60,
                                          onChanged: (val) {
                                            setState(() {
                                              tempDuration = Duration(
                                                days: tempDuration.inDays,
                                                hours:
                                                    tempDuration.inHours % 24,
                                                minutes: val,
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _timeController.text.isEmpty
                              ? AppLocalizations.of(context)!.selectTime
                              : _formatDuration(
                                  int.tryParse(_timeController.text) ?? 0,
                                ),
                        ),
                        const Icon(
                          Icons.access_time,
                          color: AppTheme.mediumGray,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _buildLabel('${AppLocalizations.of(context)!.ingredients} *'),
                _buildTextFormField(
                  controller: _ingredientsController,
                  hintText: AppLocalizations.of(context)!.enterIngredientHint,
                  maxLines: 6,
                  validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.requiredField : null,
                ),

                const SizedBox(height: 24),
                _buildLabel('${AppLocalizations.of(context)!.instructions} *'),
                _buildTextFormField(
                  controller: _instructionsController,
                  hintText: AppLocalizations.of(context)!.enterInstructionHint,
                  maxLines: 8,
                  validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.requiredField : null,
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.makePublic,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Switch.adaptive(
                      value: _isPublic,
                      activeColor: AppTheme.darkCharcoal,
                      onChanged: (v) => setState(() => _isPublic = v),
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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: AppTheme.darkCharcoal,
      ),
    ),
  );

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
      style: const TextStyle(color: AppTheme.darkCharcoal),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.mediumGray.withOpacity(0.5),
          fontSize: 14,
        ),
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
            width: 1.5,
          ),
        ),
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

  Widget _buildPickerColumn({
    required String title,
    required int count,
    required int initialItem,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: initialItem,
              ),
              itemExtent: 32,
              onSelectedItemChanged: onChanged,
              children: List<Widget>.generate(count, (int index) {
                return Center(child: Text(index.toString()));
              }),
            ),
          ),
        ],
      ),
    );
  }
}
