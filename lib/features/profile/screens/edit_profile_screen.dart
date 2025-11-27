import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/features/profile/bloc/profile_bloc.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';

/// Screen for editing the user's profile information.
class EditProfileScreen extends StatelessWidget {
  /// Creates an [EditProfileScreen].
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: const EditProfileView(),
    );
  }
}

/// The view implementation for [EditProfileScreen].
class EditProfileView extends StatefulWidget {
  /// Creates an [EditProfileView].
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();

  // Variables to track changes.
  late String _initialNickname;
  bool _isImageChanged = false; // Flag for photo change.
  bool _hasChanges = false; // Overall change status.

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _initialNickname = user?.displayName ?? 'Legoshi Fan1';

    _nicknameController.text = _initialNickname;
    _emailController.text = user?.email ?? 'legoshi.fan1@email.com';

    // Listen for changes in the nickname field.
    _nicknameController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final nicknameChanged = _nicknameController.text.trim() != _initialNickname;
    final hasChanges = nicknameChanged || _isImageChanged;

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  // Simulate photo change (since we don't have a real Image Picker).
  void _changePhoto() {
    setState(() {
      _isImageChanged = true;
      _checkForChanges();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo selected (simulated)')));
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        UpdateProfileInfo(_nicknameController.text),
      );
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  // Determine if the button is active.
                  // Active if: (has changes) AND (not loading).
                  final isButtonEnabled =
                      _hasChanges && state is! ProfileLoading;

                  return ElevatedButton(
                    onPressed: isButtonEnabled ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      // Color depends on activity.
                      backgroundColor: isButtonEnabled
                          ? AppTheme.darkCharcoal // Active (black)
                          : Colors.grey.shade400, // Inactive (grey)
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 36),
                      // Ensure grey color when disabled, not default transparent.
                      disabledBackgroundColor: Colors.grey.shade400,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: state is ProfileLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _changePhoto, // Clicking photo activates changes.
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  // Highlight border if photo changed.
                                  color: _isImageChanged
                                      ? AppTheme.darkCharcoal
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                  'assets/images/legoshi_eating_auth.png',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.offWhite,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 20,
                                  color: AppTheme.darkCharcoal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _changePhoto,
                        child: const Text(
                          'Tap to change photo',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppTheme.mediumGray,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Nickname',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nicknameController,
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Nickname cannot be empty' : null,
                  style: const TextStyle(color: AppTheme.darkCharcoal),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  style: const TextStyle(
                    color: AppTheme.mediumGray,
                  ), // Grey text for disabled field.
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
