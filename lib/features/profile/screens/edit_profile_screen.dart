import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/app_theme.dart';
import 'package:furtable/core/utils/avatar_helper.dart';
import 'package:furtable/core/widgets/scrollable_form_body.dart';
import 'package:furtable/features/profile/bloc/profile_bloc.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';
import 'package:furtable/l10n/app_localizations.dart';

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

  // Stores the path to the selected avatar.
  String _selectedAvatarPath = AvatarHelper.defaultAvatar;
  bool _hasChanges = false;
  late String _initialNickname;
  late String _initialAvatar;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    _initialNickname = user?.displayName ?? 'Legoshi Fan1';
    // Use user's current photo URL or default avatar.
    _initialAvatar = user?.photoURL ?? AvatarHelper.defaultAvatar;

    _nicknameController.text = _initialNickname;
    _emailController.text = user?.email ?? 'legoshi.fan1@email.com';
    _selectedAvatarPath = _initialAvatar;

    _nicknameController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final nicknameChanged = _nicknameController.text.trim() != _initialNickname;
    final avatarChanged = _selectedAvatarPath != _initialAvatar;

    final hasChanges = nicknameChanged || avatarChanged;

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  // --- AVATAR PICKER SHEET ---
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows stretching the bottom sheet to full screen height.
      useSafeArea: true, // Accounts for device notch and status bar.
      backgroundColor: AppTheme.offWhite,
      builder: (context) {
        return Scaffold(
          backgroundColor: AppTheme.offWhite,
          // Adding AppBar for easy closing
          appBar: AppBar(
            backgroundColor: AppTheme.offWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppTheme.darkCharcoal),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.of(context)!.chooseAvatar,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: AppTheme.darkCharcoal,
              ),
            ),
            centerTitle: true,
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1, // Square items
            ),
            itemCount: AvatarHelper.avatars.length,
            itemBuilder: (context, index) {
              final path = AvatarHelper.avatars[index];
              final isSelected = path == _selectedAvatarPath;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatarPath = path;
                    _checkForChanges();
                  });
                  Navigator.pop(context); // Close on selection
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Highlight selected with a thick border
                    border: isSelected
                        ? Border.all(color: AppTheme.darkCharcoal, width: 4)
                        : Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(path),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Send both nickname and new avatar path.
      context.read<ProfileBloc>().add(
        UpdateProfileInfo(
          nickname: _nicknameController.text,
          avatarPath: _selectedAvatarPath, // Update event with new avatar
        ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profileUpdated),
            ),
          );
          // Return true to notify previous screen to refresh.
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        resizeToAvoidBottomInset: false, 
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.editProfile),
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
                          ? AppTheme
                                .darkCharcoal // Active (black)
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
                        : Text(
                            AppLocalizations.of(context)!.save,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
        body: ScrollableFormBody(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showAvatarPicker, // Open avatar picker
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _selectedAvatarPath != _initialAvatar
                                      ? AppTheme.darkCharcoal
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage:
                                      AvatarHelper.getAvatarProvider(
                                        _selectedAvatarPath,
                                      ), // Show selected
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
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
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
                        onTap: _showAvatarPicker,
                        child: Text(
                          AppLocalizations.of(context)!.tapToChangePhoto,
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

                Text(
                  AppLocalizations.of(context)!.nickname,
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
                  validator: (val) => val!.trim().isEmpty
                      ? AppLocalizations.of(context)!.nicknameEmpty
                      : null,
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
                Text(
                  AppLocalizations.of(context)!.email,
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
