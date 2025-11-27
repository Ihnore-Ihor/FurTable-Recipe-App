import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';

/// Screen displaying Frequently Asked Questions.
class FAQScreen extends StatelessWidget {
  /// Creates an [FAQScreen].
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('FAQ'), // Title matches menu item.
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'FAQ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppTheme.darkCharcoal,
            ),
          ),
          SizedBox(height: 16),

          FAQItem(
            question: "How do I create a recipe?",
            answer:
                "Go to the 'My Recipes' tab (book icon) and tap the '+' icon in the top right corner.",
          ),
          FAQItem(
            question: "Can I make my recipes private?",
            answer:
                "Yes! When creating or editing a recipe, toggle the 'Make this recipe public' switch off.",
          ),
          FAQItem(
            question: "How do I change my password?",
            answer: "Navigate to Profile > Account Settings > Change Password.",
          ),
          FAQItem(
            question: "Is FurTable free?",
            answer: "Yes, FurTable is completely free to use for everyone.",
          ),
          FAQItem(
            question: "How do I delete my account?",
            answer:
                "Go to Profile > Account Settings and select 'Delete Account' at the bottom.",
          ),
        ],
      ),
    );
  }
}

/// A widget representing a single FAQ item with an expandable answer.
class FAQItem extends StatelessWidget {
  /// The question text.
  final String question;

  /// The answer text.
  final String answer;

  /// Creates an [FAQItem].
  const FAQItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ), // Remove divider line when expanded.
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: AppTheme.darkCharcoal,
          collapsedIconColor: AppTheme.mediumGray,
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppTheme.darkCharcoal,
              fontFamily: 'Inter',
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 15,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
