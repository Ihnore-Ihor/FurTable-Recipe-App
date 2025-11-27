import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/feedback/bloc/feedback_bloc.dart'; // Створи цей файл!

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedbackBloc(),
      child: const FeedbackView(),
    );
  }
}

class FeedbackView extends StatefulWidget {
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
            const SnackBar(content: Text('Thank you for your feedback!')),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: const Text('Send Feedback'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about your experience...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Text Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      hintText:
                          'Share your thoughts, suggestions, or report any issues...',
                      hintStyle: TextStyle(color: AppTheme.mediumGray),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                      counterText: '', // Ховаємо стандартний лічильник
                    ),
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
                'Your email address ($email) will be included with this feedback.',
                style: const TextStyle(
                  color: AppTheme.mediumGray,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              // Button
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
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: state is FeedbackLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Send Feedback',
                              style: TextStyle(fontSize: 16),
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
