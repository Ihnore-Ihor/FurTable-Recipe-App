import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Screen displaying Frequently Asked Questions.
class FAQScreen extends StatelessWidget {
  /// Creates an [FAQScreen].
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.faq), // Title matches menu item.
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppLocalizations.of(context)!.faq,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppTheme.darkCharcoal,
            ),
          ),
          SizedBox(height: 16),

          FAQItem(
            question: AppLocalizations.of(context)!.faqQ1,
            answer: AppLocalizations.of(context)!.faqA1,
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.faqQ2,
            answer: AppLocalizations.of(context)!.faqA2,
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.faqQ3,
            answer: AppLocalizations.of(context)!.faqA3,
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.faqQ4,
            answer: AppLocalizations.of(context)!.faqA4,
          ),
          FAQItem(
            question: AppLocalizations.of(context)!.faqQ5,
            answer: AppLocalizations.of(context)!.faqA5,
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
