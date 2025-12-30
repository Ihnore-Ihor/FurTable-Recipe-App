import 'package:flutter/material.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/l10n/app_localizations.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Формуємо список питань динамічно, щоб мати доступ до контексту локалізації
    final l10n = AppLocalizations.of(context)!;
    
    final List<Map<String, String>> faqItems = [
      {'q': l10n.faqQ_create, 'a': l10n.faqA_create},
      {'q': l10n.faqQ_editDelete, 'a': l10n.faqA_editDelete},
      {'q': l10n.faqQ_private, 'a': l10n.faqA_private},
      {'q': l10n.faqQ_favorites, 'a': l10n.faqA_favorites},
      {'q': l10n.faqQ_search, 'a': l10n.faqA_search},
      {'q': l10n.faqQ_profile, 'a': l10n.faqA_profile},
      // Жартівливі
      {'q': l10n.faqQ_legoshi, 'a': l10n.faqA_legoshi},
      {'q': l10n.faqQ_egg, 'a': l10n.faqA_egg},
    ];

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(l10n.faq),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: faqItems.length + 1, // +1 для заголовка
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                l10n.faqTitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: AppTheme.darkCharcoal,
                ),
              ),
            );
          }

          final item = faqItems[index - 1];
          return _FAQItem(
            question: item['q']!,
            answer: item['a']!,
          );
        },
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Легка тінь для об'єму
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        // Прибираємо стандартні лінії ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: AppTheme.darkCharcoal,
          collapsedIconColor: AppTheme.mediumGray,
          expandedAlignment: Alignment.centerLeft, // Вирівнювання відповіді
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
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
