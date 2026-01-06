import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FurTable'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUp;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @fillInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill out the information below...'**
  String get fillInfo;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started...'**
  String get letsGetStarted;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @accountCreatedCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please check your email to verify.'**
  String get accountCreatedCheckEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @minPassword.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters required'**
  String get minPassword;

  /// No description provided for @mustContainNumber.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least one number'**
  String get mustContainNumber;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Please fill in this field'**
  String get requiredField;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking Time'**
  String get cookTime;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String byAuthor(String name);

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescription;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients listed.'**
  String get noIngredients;

  /// No description provided for @noInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions listed.'**
  String get noInstructions;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String step(int number);

  /// No description provided for @createRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create Recipe'**
  String get createRecipe;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editRecipe;

  /// No description provided for @recipeImage.
  ///
  /// In en, this message translates to:
  /// **'Recipe Image'**
  String get recipeImage;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Title'**
  String get recipeTitle;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter recipe title...'**
  String get enterTitle;

  /// No description provided for @describeRecipe.
  ///
  /// In en, this message translates to:
  /// **'Describe your recipe...'**
  String get describeRecipe;

  /// No description provided for @enterIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'Example:\n2 Eggs\n200g Flour\n(Each on a new line)'**
  String get enterIngredientHint;

  /// No description provided for @enterInstructionHint.
  ///
  /// In en, this message translates to:
  /// **'Example:\nMix eggs.\nBake at 180C.\n(Each step on a new line)'**
  String get enterInstructionHint;

  /// No description provided for @makePublic.
  ///
  /// In en, this message translates to:
  /// **'Make this recipe public'**
  String get makePublic;

  /// No description provided for @anyoneCanSee.
  ///
  /// In en, this message translates to:
  /// **'Anyone can see this recipe'**
  String get anyoneCanSee;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @compressingImage.
  ///
  /// In en, this message translates to:
  /// **'Compressing image...'**
  String get compressingImage;

  /// No description provided for @draftRestored.
  ///
  /// In en, this message translates to:
  /// **'Draft restored from last session'**
  String get draftRestored;

  /// No description provided for @recipeCreated.
  ///
  /// In en, this message translates to:
  /// **'Recipe created successfully!'**
  String get recipeCreated;

  /// No description provided for @recipeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recipe updated!'**
  String get recipeUpdated;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'Mins'**
  String get mins;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// No description provided for @unsavedChangesMsg.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get unsavedChangesMsg;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large (>1MB)'**
  String get imageTooLarge;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @selectCookingTime.
  ///
  /// In en, this message translates to:
  /// **'Please select cooking time'**
  String get selectCookingTime;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose an Avatar'**
  String get chooseAvatar;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerification;

  /// No description provided for @waitToResend.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds}s to resend'**
  String waitToResend(int seconds);

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox.'**
  String get verificationSent;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @nicknameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nickname cannot be empty'**
  String get nicknameEmpty;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I create a recipe?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Go to the \'My Recipes\' tab (book icon) and tap the \'+\' icon in the top right corner.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'Can I make my recipes private?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Yes! When creating or editing a recipe, toggle the \'Make this recipe public\' switch off.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I change my password?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Profile > Account Settings > Change Password.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'Is FurTable free?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Yes, FurTable is completely free to use for everyone.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Account Settings and select \'Delete Account\' at the bottom.'**
  String get faqA5;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThanks;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Error sending feedback: {error}'**
  String feedbackError(String error);

  /// No description provided for @tellUsExperience.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience...'**
  String get tellUsExperience;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts, suggestions, or report any issues...'**
  String get feedbackHint;

  /// No description provided for @emailIncluded.
  ///
  /// In en, this message translates to:
  /// **'Your email address ({email}) will be included with this feedback.'**
  String emailIncluded(String email);

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress...'**
  String get inProgress;

  /// No description provided for @reachedEnd.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the end'**
  String get reachedEnd;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your password for enhanced security.'**
  String get changePasswordSubtitle;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmYourPassword;

  /// No description provided for @passwordRequirement.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters, including one number'**
  String get passwordRequirement;

  /// No description provided for @clearCacheDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache?'**
  String get clearCacheDialogTitle;

  /// No description provided for @clearCacheDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'This will remove all downloaded images. They will be re-downloaded when needed.'**
  String get clearCacheDialogDesc;

  /// No description provided for @clearCacheSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image cache cleared successfully'**
  String get clearCacheSuccess;

  /// No description provided for @errorClearingCache.
  ///
  /// In en, this message translates to:
  /// **'Error clearing cache'**
  String get errorClearingCache;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated!'**
  String get passwordUpdated;

  /// No description provided for @storageCache.
  ///
  /// In en, this message translates to:
  /// **'Storage & Cache'**
  String get storageCache;

  /// No description provided for @enableCaching.
  ///
  /// In en, this message translates to:
  /// **'Enable Image Caching'**
  String get enableCaching;

  /// No description provided for @saveImagesLocally.
  ///
  /// In en, this message translates to:
  /// **'Save images locally for faster loading'**
  String get saveImagesLocally;

  /// No description provided for @autoClear.
  ///
  /// In en, this message translates to:
  /// **'Auto-clear on Startup'**
  String get autoClear;

  /// No description provided for @clearCacheStart.
  ///
  /// In en, this message translates to:
  /// **'Clear cache every time app starts'**
  String get clearCacheStart;

  /// No description provided for @clearCacheNow.
  ///
  /// In en, this message translates to:
  /// **'Clear Image Cache Now'**
  String get clearCacheNow;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this account? This action cannot be undone.'**
  String get deleteAccountDesc;

  /// No description provided for @deleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this account? This action cannot be undone.'**
  String get deleteAccountContent;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search...'**
  String get typeToSearch;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found.'**
  String get noRecipesFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else.'**
  String get tryDifferentSearch;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String copied(String label);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @deleteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe?'**
  String get deleteRecipeTitle;

  /// No description provided for @deleteRecipeContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this recipe? This action cannot be undone.'**
  String get deleteRecipeContent;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get recipeDeleted;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Recipe or Author'**
  String get searchHint;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @tapHeart.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on recipes you love'**
  String get tapHeart;

  /// No description provided for @shareMasterpieces.
  ///
  /// In en, this message translates to:
  /// **'Share your culinary masterpieces!'**
  String get shareMasterpieces;

  /// No description provided for @createPrivateHint.
  ///
  /// In en, this message translates to:
  /// **'Create a private recipe to see it here.'**
  String get createPrivateHint;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqQ_create.
  ///
  /// In en, this message translates to:
  /// **'How do I create a new recipe?'**
  String get faqQ_create;

  /// No description provided for @faqA_create.
  ///
  /// In en, this message translates to:
  /// **'Go to the \'My Recipes\' tab (book icon) and tap the \'+\' button in the top right corner. Fill in the details, add a photo, and hit Save.'**
  String get faqA_create;

  /// No description provided for @faqQ_private.
  ///
  /// In en, this message translates to:
  /// **'Can I keep my recipes secret?'**
  String get faqQ_private;

  /// No description provided for @faqA_private.
  ///
  /// In en, this message translates to:
  /// **'Yes! When creating or editing a recipe, simply toggle the \'Make this recipe public\' switch off. Only you will see it.'**
  String get faqA_private;

  /// No description provided for @faqQ_editDelete.
  ///
  /// In en, this message translates to:
  /// **'How do I edit or delete a recipe?'**
  String get faqQ_editDelete;

  /// No description provided for @faqA_editDelete.
  ///
  /// In en, this message translates to:
  /// **'In the \'My Recipes\' tab, tap the three dots icon on any of your recipe cards. You will see options to Edit or Delete.'**
  String get faqA_editDelete;

  /// No description provided for @faqQ_favorites.
  ///
  /// In en, this message translates to:
  /// **'How do Favorites work?'**
  String get faqQ_favorites;

  /// No description provided for @faqA_favorites.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any recipe to save it to your collection. You can find all your saved dishes in the \'Favorites\' tab.'**
  String get faqA_favorites;

  /// No description provided for @faqQ_search.
  ///
  /// In en, this message translates to:
  /// **'How does search work?'**
  String get faqQ_search;

  /// No description provided for @faqA_search.
  ///
  /// In en, this message translates to:
  /// **'You can search by recipe title or author name. Just type in the search bar and press Enter (or the search button on keyboard).'**
  String get faqA_search;

  /// No description provided for @faqQ_profile.
  ///
  /// In en, this message translates to:
  /// **'Can I change my avatar?'**
  String get faqQ_profile;

  /// No description provided for @faqA_profile.
  ///
  /// In en, this message translates to:
  /// **'Yes, go to Profile > Edit Profile and tap on your current avatar to choose a new character.'**
  String get faqA_profile;

  /// No description provided for @faqQ_legoshi.
  ///
  /// In en, this message translates to:
  /// **'Why is a wolf staring at me when loading?'**
  String get faqQ_legoshi;

  /// No description provided for @faqA_legoshi.
  ///
  /// In en, this message translates to:
  /// **'That\'s Legoshi. He ensures your data is loaded correctly... and he\'s also looking for egg sandwiches.'**
  String get faqA_legoshi;

  /// No description provided for @faqQ_egg.
  ///
  /// In en, this message translates to:
  /// **'Is this app safe for herbivores?'**
  String get faqQ_egg;

  /// No description provided for @faqA_egg.
  ///
  /// In en, this message translates to:
  /// **'Absolutely. FurTable supports all diets, from salads for Haru to burgers for the rest. No animals were harmed in the coding of this app.'**
  String get faqA_egg;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join FurTable'**
  String get joinTitle;

  /// No description provided for @loginOrSignup.
  ///
  /// In en, this message translates to:
  /// **'Log In / Sign Up'**
  String get loginOrSignup;

  /// No description provided for @guestMyRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking!'**
  String get guestMyRecipesTitle;

  /// No description provided for @guestMyRecipesMessage.
  ///
  /// In en, this message translates to:
  /// **'Create an account to save your own recipes and share them with the world.'**
  String get guestMyRecipesMessage;

  /// No description provided for @guestFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Your Favorites'**
  String get guestFavoritesTitle;

  /// No description provided for @guestFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Log in to create your personal collection of delicious recipes.'**
  String get guestFavoritesMessage;

  /// No description provided for @authRequiredLike.
  ///
  /// In en, this message translates to:
  /// **'Log in to add this recipe to your favorites.'**
  String get authRequiredLike;

  /// No description provided for @authRequiredAction.
  ///
  /// In en, this message translates to:
  /// **'Log in to perform this action.'**
  String get authRequiredAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
