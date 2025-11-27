import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  // Контролери для текстових полів
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Стан перемикача Public/Private
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
    return Scaffold(
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
            child: ElevatedButton(
              onPressed: () {
                // Тут буде логіка збереження
                Navigator.pop(context);
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
                minimumSize: const Size(0, 36), // Висота кнопки
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Image Upload Section ---
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
              onTap: () {
                // Тут буде логіка вибору фото
                print("Pick image");
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.offWhite, // Або Colors.white, як в дизайні
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.file_upload_outlined,
                      size: 32,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(height: 8),
                    const Text(
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

            // --- 2. Recipe Title ---
            _buildLabel('Recipe Title *'),
            _buildTextField(
              controller: _titleController,
              hintText: 'Enter recipe title...',
            ),

            const SizedBox(height: 24),

            // --- 3. Description ---
            _buildLabel('Description'),
            _buildTextField(
              controller: _descriptionController,
              hintText: 'Describe your recipe...',
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // --- 4. Ingredients ---
            _buildLabel('Ingredients *'),
            _buildTextField(
              controller: _ingredientsController,
              hintText: 'Enter each ingredient on a new line...',
              maxLines: 6,
            ),

            const SizedBox(height: 24),

            // --- 5. Instructions ---
            _buildLabel('Instructions *'),
            _buildTextField(
              controller: _instructionsController,
              hintText: 'Enter each step on a new line...',
              maxLines: 8,
            ),

            const SizedBox(height: 24),

            // --- 6. Public Switch ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
              ],
            ),

            // Додатковий відступ знизу для скролу
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Допоміжний віджет для заголовків полів
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

  // Допоміжний віджет для полів вводу (щоб не дублювати стиль)
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
        minLines: maxLines > 1 ? 3 : 1, // Мінімальна висота для великих полів
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.mediumGray),
          filled: true,
          fillColor: Colors.white, // Білий фон поля
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide.none, // Прибираємо рамку (або робимо дуже світлу)
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
