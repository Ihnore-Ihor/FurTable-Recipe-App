import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/widgets/scrollable_form_body.dart';
import 'package:furtable/features/feedback/bloc/feedback_bloc.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Screen for users to submit feedback.
class FeedbackScreen extends StatelessWidget {
  /// Creates a [FeedbackScreen].
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedbackBloc(),
      child: const FeedbackView(),
    );
  }
}

/// The view implementation for [FeedbackScreen].
class FeedbackView extends StatefulWidget {
  /// Creates a [FeedbackView].
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final _controller = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _charCount = _controller.text.length);
    });
  }

  void _send() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<FeedbackBloc>().add(SubmitFeedback(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.feedbackThanks),
              backgroundColor: AppTheme.darkCharcoal,
            ),
          );
          Navigator.pop(context);
        } else if (state is FeedbackFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.feedbackError(state.error),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.sendFeedback),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ScrollableFormBody(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.tellUsExperience,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.darkCharcoal,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                height:
                    200, // Fixed height provides consistent layout during keyboard interaction.
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: 1000,
                  style: const TextStyle(color: AppTheme.darkCharcoal),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.feedbackHint,
                    hintStyle: TextStyle(color: AppTheme.mediumGray),
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                '$_charCount/1000 characters',
                style: const TextStyle(color: AppTheme.mediumGray),
              ),

              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.emailIncluded(email),
                style: const TextStyle(
                  color: AppTheme.mediumGray,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: BlocBuilder<FeedbackBloc, FeedbackState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is FeedbackLoading || _charCount == 0
                          ? null
                          : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkCharcoal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade400,
                        disabledForegroundColor: Colors.white,
                      ),
                      child: state is FeedbackLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.sendFeedback,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
