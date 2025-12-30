// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FurTable';

  @override
  String get login => 'Log In';

  @override
  String get signUp => 'Create Account';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get fillInfo => 'Fill out the information below...';

  @override
  String get letsGetStarted => 'Let\'s get started...';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get nickname => 'Nickname';

  @override
  String get signIn => 'Sign In';

  @override
  String get getStarted => 'Get Started';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get accountCreatedCheckEmail =>
      'Account created! Please check your email to verify.';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get minPassword => 'Minimum 8 characters required';

  @override
  String get mustContainNumber => 'Must contain at least one number';

  @override
  String get requiredField => 'Please fill in this field';

  @override
  String get explore => 'Explore';

  @override
  String get myRecipes => 'My Recipes';

  @override
  String get favorites => 'Favorites';

  @override
  String get search => 'Search';

  @override
  String get cookTime => 'Cooking Time';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get description => 'Description';

  @override
  String byAuthor(String name) {
    return 'by $name';
  }

  @override
  String get noDescription => 'No description provided.';

  @override
  String get noIngredients => 'No ingredients listed.';

  @override
  String get noInstructions => 'No instructions listed.';

  @override
  String step(int number) {
    return 'Step $number';
  }

  @override
  String get createRecipe => 'Create Recipe';

  @override
  String get editRecipe => 'Edit Recipe';

  @override
  String get recipeImage => 'Recipe Image';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get recipeTitle => 'Recipe Title';

  @override
  String get enterTitle => 'Enter recipe title...';

  @override
  String get describeRecipe => 'Describe your recipe...';

  @override
  String get enterIngredientHint =>
      'Example:\n2 Eggs\n200g Flour\n(Each on a new line)';

  @override
  String get enterInstructionHint =>
      'Example:\nMix eggs.\nBake at 180C.\n(Each step on a new line)';

  @override
  String get makePublic => 'Make this recipe public';

  @override
  String get anyoneCanSee => 'Anyone can see this recipe';

  @override
  String get selectTime => 'Select time';

  @override
  String get compressingImage => 'Compressing image...';

  @override
  String get recipeCreated => 'Recipe created successfully!';

  @override
  String get recipeUpdated => 'Recipe updated!';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get days => 'Days';

  @override
  String get hours => 'Hours';

  @override
  String get mins => 'Mins';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get discard => 'Discard';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get chooseAvatar => 'Choose an Avatar';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get faq => 'FAQ';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get logOut => 'Log Out';

  @override
  String get emailNotVerified => 'Email not verified';

  @override
  String get resendVerification => 'Resend Verification Email';

  @override
  String waitToResend(int seconds) {
    return 'Wait ${seconds}s to resend';
  }

  @override
  String get verificationSent => 'Verification email sent! Check your inbox.';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get nicknameEmpty => 'Nickname cannot be empty';

  @override
  String get faqQ1 => 'How do I create a recipe?';

  @override
  String get faqA1 =>
      'Go to the \'My Recipes\' tab (book icon) and tap the \'+\' icon in the top right corner.';

  @override
  String get faqQ2 => 'Can I make my recipes private?';

  @override
  String get faqA2 =>
      'Yes! When creating or editing a recipe, toggle the \'Make this recipe public\' switch off.';

  @override
  String get faqQ3 => 'How do I change my password?';

  @override
  String get faqA3 =>
      'Navigate to Profile > Account Settings > Change Password.';

  @override
  String get faqQ4 => 'Is FurTable free?';

  @override
  String get faqA4 => 'Yes, FurTable is completely free to use for everyone.';

  @override
  String get faqQ5 => 'How do I delete my account?';

  @override
  String get faqA5 =>
      'Go to Profile > Account Settings and select \'Delete Account\' at the bottom.';

  @override
  String get feedbackThanks => 'Thank you for your feedback!';

  @override
  String feedbackError(String error) {
    return 'Error sending feedback: $error';
  }

  @override
  String get tellUsExperience => 'Tell us about your experience...';

  @override
  String get feedbackHint =>
      'Share your thoughts, suggestions, or report any issues...';

  @override
  String emailIncluded(String email) {
    return 'Your email address ($email) will be included with this feedback.';
  }

  @override
  String get inProgress => 'In progress...';

  @override
  String get reachedEnd => 'You\'ve reached the end';

  @override
  String get changePasswordSubtitle =>
      'Update your password for enhanced security.';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get confirmYourPassword => 'Confirm your new password';

  @override
  String get passwordRequirement =>
      'Minimum 8 characters, including one number';

  @override
  String get clearCacheDialogTitle => 'Clear Cache?';

  @override
  String get clearCacheDialogDesc =>
      'This will remove all downloaded images. They will be re-downloaded when needed.';

  @override
  String get clearCacheSuccess => 'Image cache cleared successfully';

  @override
  String get errorClearingCache => 'Error clearing cache';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordUpdated => 'Password updated!';

  @override
  String get storageCache => 'Storage & Cache';

  @override
  String get enableCaching => 'Enable Image Caching';

  @override
  String get saveImagesLocally => 'Save images locally for faster loading';

  @override
  String get autoClear => 'Auto-clear on Startup';

  @override
  String get clearCacheStart => 'Clear cache every time app starts';

  @override
  String get clearCacheNow => 'Clear Image Cache Now';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm => 'Delete Account?';

  @override
  String get deleteAccountDesc =>
      'Are you sure you want to permanently delete this account? This action cannot be undone.';

  @override
  String get language => 'Language';

  @override
  String get typeToSearch => 'Type to search...';

  @override
  String get noRecipesFound => 'No recipes found.';

  @override
  String get tryDifferentSearch => 'Try searching for something else.';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clear => 'Clear';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get deleteRecipeTitle => 'Delete Recipe?';

  @override
  String get deleteRecipeContent =>
      'Are you sure you want to permanently delete this recipe? This action cannot be undone.';

  @override
  String get recipeDeleted => 'Recipe deleted';

  @override
  String get searchHint => 'Recipe or Author';

  @override
  String get public => 'Public';

  @override
  String get private => 'Private';

  @override
  String get noRecipesYet => 'No recipes yet';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get tapHeart => 'Tap the heart icon on recipes you love';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faqQ_create => 'How do I create a new recipe?';

  @override
  String get faqA_create =>
      'Go to the \'My Recipes\' tab (book icon) and tap the \'+\' button in the top right corner. Fill in the details, add a photo, and hit Save.';

  @override
  String get faqQ_private => 'Can I keep my recipes secret?';

  @override
  String get faqA_private =>
      'Yes! When creating or editing a recipe, simply toggle the \'Make this recipe public\' switch off. Only you will see it.';

  @override
  String get faqQ_editDelete => 'How do I edit or delete a recipe?';

  @override
  String get faqA_editDelete =>
      'In the \'My Recipes\' tab, tap the three dots icon on any of your recipe cards. You will see options to Edit or Delete.';

  @override
  String get faqQ_favorites => 'How do Favorites work?';

  @override
  String get faqA_favorites =>
      'Tap the heart icon on any recipe to save it to your collection. You can find all your saved dishes in the \'Favorites\' tab.';

  @override
  String get faqQ_search => 'How does search work?';

  @override
  String get faqA_search =>
      'You can search by recipe title or author name. Just type in the search bar and press Enter (or the search button on keyboard).';

  @override
  String get faqQ_profile => 'Can I change my avatar?';

  @override
  String get faqA_profile =>
      'Yes, go to Profile > Edit Profile and tap on your current avatar to choose a new character.';

  @override
  String get faqQ_legoshi => 'Why is a wolf staring at me when loading?';

  @override
  String get faqA_legoshi =>
      'That\'s Legoshi. He ensures your data is loaded correctly... and he\'s also looking for egg sandwiches.';

  @override
  String get faqQ_egg => 'Is this app safe for herbivores?';

  @override
  String get faqA_egg =>
      'Absolutely. FurTable supports all diets, from salads for Haru to burgers for the rest. No animals were harmed in the coding of this app.';

  @override
  String get joinTitle => 'Join FurTable';

  @override
  String get loginOrSignup => 'Log In / Sign Up';

  @override
  String get guestMyRecipesTitle => 'Start Cooking!';

  @override
  String get guestMyRecipesMessage =>
      'Create an account to save your own recipes and share them with the world.';

  @override
  String get guestFavoritesTitle => 'Save Your Favorites';

  @override
  String get guestFavoritesMessage =>
      'Log in to create your personal collection of delicious recipes.';

  @override
  String get authRequiredLike => 'Log in to add this recipe to your favorites.';

  @override
  String get authRequiredAction => 'Log in to perform this action.';
}
