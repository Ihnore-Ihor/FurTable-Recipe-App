import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/image_helper.dart';
import 'package:furtable/core/widgets/app_image.dart';
import 'package:furtable/core/widgets/scrollable_form_body.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/core/services/local_storage_service.dart';
import 'package:furtable/core/utils/duration_helper.dart';
import 'package:furtable/l10n/app_localizations.dart';

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
  final _timeController = TextEditingController();

  bool _isPublic = true;
  Uint8List? _selectedImageBytes;
  final _storage = LocalStorageService();
  bool _isPopBlocked = false; // To prevent concurrent dialogs
  bool _canPopNow = false; // To allow programmatic pop when canPop is false

  // Variables for initial state
  late String _initTitle;
  late String _initDesc;
  late String _initIngr;
  late String _initInstr;
  late String _initTime;
  late bool _initPublic;

  @override
  void initState() {
    super.initState();

    // Initialize default values
    _initTitle = '';
    _initDesc = '';
    _initIngr = '';
    _initInstr = '';
    _initTime = '30';
    _initPublic = true;

    if (widget.recipeToEdit != null) {
      final r = widget.recipeToEdit!;
      _titleController.text = r.title;
      _descriptionController.text = r.description;
      _ingredientsController.text = r.ingredients.join('\n');
      _instructionsController.text = r.steps.join('\n');
      _timeController.text = r.timeMinutes.toString();
      _isPublic = r.isPublic;

      // Cache initial state for comparison
      _initTitle = r.title;
      _initDesc = r.description;
      _initIngr = r.ingredients.join('\n');
      _initInstr = r.steps.join('\n');
      _initTime = r.timeMinutes.toString();
      _initPublic = r.isPublic;
    } else {
      // NEW: Load draft if not editing an existing recipe
      _loadDraft();
      // Update init state after draft load in _loadDraft if needed, 
      // but let's do it after _loadDraft call here for simplicity.
      _initTitle = _titleController.text;
      _initDesc = _descriptionController.text;
      _initIngr = _ingredientsController.text;
      _initInstr = _instructionsController.text;
      _initTime = _timeController.text;
      _initPublic = _isPublic;
    }

    // NEW: Listen for changes to auto-save draft
    _titleController.addListener(_saveDraft);
    _descriptionController.addListener(_saveDraft);
    _ingredientsController.addListener(_saveDraft);
    _instructionsController.addListener(_saveDraft);
  }

  bool _hasChanges() {
    // 1. If a new image is selected - definitely changed
    if (_selectedImageBytes != null) return true;

    // 2. Compare text fields
    if (_titleController.text != _initTitle) return true;
    if (_descriptionController.text != _initDesc) return true;
    if (_ingredientsController.text != _initIngr) return true;
    if (_instructionsController.text != _initInstr) return true;
    if (_timeController.text != _initTime) return true;
    if (_isPublic != _initPublic) return true;

    return false;
  }

  Future<void> _handleExit() async {
    // If we are already in the exit process or showing a dialog, ignore
    if (_isPopBlocked) return;

    // If no changes -> exit directly
    if (!_hasChanges()) {
      setState(() => _canPopNow = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    _isPopBlocked = true;
    // If there ARE changes -> show dialog
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.discardChanges,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(AppLocalizations.of(context)!.unsavedChangesMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppTheme.mediumGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkCharcoal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true), // Discard
            child: Text(AppLocalizations.of(context)!.discard),
          ),
        ],
      ),
    );

    _isPopBlocked = false;

    if (shouldDiscard == true && mounted) {
      if (widget.recipeToEdit == null) {
        _storage.clearDraft();
        _storage.clearDraftImage();
      }
      
      // Update state to allow the pop to proceed
      setState(() => _canPopNow = true);
      
      // Use PostFrameCallback to ensure the state update is processed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _loadDraft() {
    final draft = _storage.getDraft();
    if (draft != null && draft.length >= 5) {
      setState(() {
        _titleController.text = draft[0];
        _descriptionController.text = draft[1];
        _ingredientsController.text = draft[2];
        _instructionsController.text = draft[3];
        _timeController.text = draft[4];
        if (draft.length > 5) {
          _isPublic = draft[5] == 'true';
        }

        // Show a brief hint only if title was restored
        if (_titleController.text.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.draftRestored),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppTheme.darkCharcoal,
                ),
              );
            }
          });
        }
      });
    }

    final savedImage = _storage.getDraftImage();
    if (savedImage != null) {
      setState(() => _selectedImageBytes = savedImage);
    }
  }

  void _saveDraft() {
    // Only save if we are creating a NEW recipe (not editing)
    if (widget.recipeToEdit == null) {
      _storage.saveDraft([
        _titleController.text,
        _descriptionController.text,
        _ingredientsController.text,
        _instructionsController.text,
        _timeController.text,
        _isPublic.toString(),
      ]);
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

  /// Validates the form and submits the recipe data to the BLoC.
  void _submitForm() {
    debugPrint("Submit button pressed");
    FocusScope.of(context).unfocus();

    // Verify form validity and ensure a cooking time has been selected.
    final isValid = _formKey.currentState?.validate() ?? false;
    final timeEmpty =
        _timeController.text.isEmpty || _timeController.text == '0';

    if (!isValid || timeEmpty) {
      debugPrint("Validation failed");
      if (_autovalidateMode == AutovalidateMode.disabled) {
        setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      }

      if (timeEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectCookingTime),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final ingredients = _ingredientsController.text.trim();
    final instructions = _instructionsController.text.trim();
    final time = int.tryParse(_timeController.text) ?? 30;

    debugPrint("Sending event to BLoC...");

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
          likesCount: widget.recipeToEdit!.likesCount,
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

  /// Picks an image from the gallery, compresses it, and saves it to the draft.
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (!mounted) return;

      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.compressingImage),
            duration: const Duration(seconds: 1),
            backgroundColor: AppTheme.darkCharcoal,
          ),
        );

        final rawBytes = await image.readAsBytes();
        if (!mounted) return;

        // 1. COMPRESS FIRST
        final compressedBytes = await ImageHelper.compressImage(rawBytes);
        if (!mounted) return;

        // 2. CHECK SIZE (Optional but safe)
        if (compressedBytes.lengthInBytes > 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.imageTooLarge),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _selectedImageBytes = compressedBytes;
        });
        // 3. SAVE COMPRESSED IMAGE TO DRAFT
        _storage.saveDraftImage(compressedBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Builds a column with a property name and a [CupertinoPicker] for selection.
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
              children: List<Widget>.generate(
                count,
                (int index) => Center(child: Text(index.toString())),
              ),
            ),
          ),
        ],
      ),
    );
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
                isEditing
                    ? AppLocalizations.of(context)!.recipeUpdated
                    : AppLocalizations.of(context)!.recipeCreated,
              ),
              backgroundColor: AppTheme.darkCharcoal,
            ),
          );

          // NEW: Clear draft after successful creation
          if (!isEditing) {
            _storage.clearDraft();
            _storage.clearDraftImage();
          }

          Navigator.pop(context, true);
        } else if (state is CreateRecipeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: PopScope(
        canPop: _canPopNow,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleExit();
        },
        child: Scaffold(
          backgroundColor: AppTheme.offWhite,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              isEditing
                  ? AppLocalizations.of(context)!.editRecipe
                  : AppLocalizations.of(context)!.createRecipe,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: _handleExit,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 36),
                      disabledBackgroundColor: AppTheme.darkCharcoal.withValues(
                        alpha: 0.7,
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
        body: ScrollableFormBody(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
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
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedImageBytes = null);
                                    _storage.clearDraftImage();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : (isEditing &&
                              widget.recipeToEdit!.imageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppImage(
                              imagePath: widget.recipeToEdit!.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.file_upload_outlined,
                                size: 32,
                                color: AppTheme.mediumGray,
                              ),
                              const SizedBox(height: 8),
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
                  validator: (v) => v!.isEmpty
                      ? AppLocalizations.of(context)!.requiredField
                      : null,
                  keyboardType: TextInputType.multiline,
                  autofillHints: null,
                  maxLength: 256,
                  maxLines: null,
                ),

                const SizedBox(height: 24),
                _buildLabel(AppLocalizations.of(context)!.description),
                _buildTextFormField(
                  controller: _descriptionController,
                  hintText: AppLocalizations.of(context)!.describeRecipe,
                  maxLines: 4,
                ),

                const SizedBox(height: 24),
                _buildLabel('${AppLocalizations.of(context)!.cookTime} *'),
                GestureDetector(
                  onTap: () {
                    int initialMinutes =
                        int.tryParse(_timeController.text) ?? 30;
                    Duration tempDuration = Duration(minutes: initialMinutes);

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
                                        setState(
                                          () => _timeController.text =
                                              tempDuration.inMinutes.toString(),
                                        );
                                        _saveDraft();
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
                                child: Row(
                                  children: [
                                    _buildPickerColumn(
                                      title: AppLocalizations.of(context)!.days,
                                      count: 32,
                                      initialItem: tempDuration.inDays,
                                      onChanged: (val) =>
                                          tempDuration = Duration(
                                            days: val,
                                            hours: tempDuration.inHours % 24,
                                            minutes:
                                                tempDuration.inMinutes % 60,
                                          ),
                                    ),
                                    _buildPickerColumn(
                                      title: AppLocalizations.of(
                                        context,
                                      )!.hours,
                                      count: 24,
                                      initialItem: tempDuration.inHours % 24,
                                      onChanged: (val) =>
                                          tempDuration = Duration(
                                            days: tempDuration.inDays,
                                            hours: val,
                                            minutes:
                                                tempDuration.inMinutes % 60,
                                          ),
                                    ),
                                    _buildPickerColumn(
                                      title: AppLocalizations.of(context)!.mins,
                                      count: 60,
                                      initialItem: tempDuration.inMinutes % 60,
                                      onChanged: (val) =>
                                          tempDuration = Duration(
                                            days: tempDuration.inDays,
                                            hours: tempDuration.inHours % 24,
                                            minutes: val,
                                          ),
                                    ),
                                  ],
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
                          _timeController.text.isEmpty ||
                                  _timeController.text == '0'
                              ? AppLocalizations.of(context)!.selectTime
                              : DurationHelper.format(
                                  context,
                                  int.tryParse(_timeController.text) ?? 0,
                                ),
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                (_timeController.text.isEmpty ||
                                    _timeController.text == '0')
                                ? AppTheme.mediumGray
                                : AppTheme.darkCharcoal,
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
                  validator: (v) => v!.isEmpty
                      ? AppLocalizations.of(context)!.requiredField
                      : null,
                ),

                const SizedBox(height: 24),
                _buildLabel('${AppLocalizations.of(context)!.instructions} *'),
                _buildTextFormField(
                  controller: _instructionsController,
                  hintText: AppLocalizations.of(context)!.enterInstructionHint,
                  maxLines: 8,
                  validator: (v) => v!.isEmpty
                      ? AppLocalizations.of(context)!.requiredField
                      : null,
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.makePublic,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.anyoneCanSee,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _isPublic,
                      activeTrackColor: AppTheme.darkCharcoal,
                      onChanged: (v) {
                        setState(() => _isPublic = v);
                        _saveDraft();
                      },
                    ),
                  ],
                ),
              ],
            ),
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
    int? maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      minLines: (maxLines ?? 1) > 1 ? 3 : 1,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      style: const TextStyle(color: AppTheme.darkCharcoal),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.mediumGray.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
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
