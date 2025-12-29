// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'FurTable';

  @override
  String get login => 'Вхід';

  @override
  String get signUp => 'Реєстрація';

  @override
  String get welcomeBack => 'З поверненням';

  @override
  String get fillInfo => 'Заповніть інформацію нижче...';

  @override
  String get letsGetStarted => 'Почнімо...';

  @override
  String get email => 'Ел. пошта';

  @override
  String get password => 'Пароль';

  @override
  String get nickname => 'Нікнейм';

  @override
  String get signIn => 'Увійти';

  @override
  String get getStarted => 'Почати';

  @override
  String get or => 'АБО';

  @override
  String get continueWithGoogle => 'Увійти через Google';

  @override
  String get accountCreatedCheckEmail =>
      'Акаунт створено! Перевірте пошту для підтвердження.';

  @override
  String get invalidEmail => 'Введіть коректну електронну пошту';

  @override
  String get minPassword => 'Мінімум 8 символів';

  @override
  String get mustContainNumber => 'Має містити хоча б одну цифру';

  @override
  String get requiredField => 'Це поле обов\'язкове';

  @override
  String get explore => 'Головна';

  @override
  String get myRecipes => 'Мої рецепти';

  @override
  String get favorites => 'Улюблене';

  @override
  String get search => 'Пошук';

  @override
  String get cookTime => 'Час готування';

  @override
  String get ingredients => 'Інгредієнти';

  @override
  String get instructions => 'Інструкції';

  @override
  String get description => 'Опис';

  @override
  String byAuthor(String name) {
    return 'від $name';
  }

  @override
  String get noDescription => 'Опис відсутній.';

  @override
  String get noIngredients => 'Інгредієнти не вказані.';

  @override
  String get noInstructions => 'Інструкції не вказані.';

  @override
  String step(int number) {
    return 'Крок $number';
  }

  @override
  String get createRecipe => 'Створити рецепт';

  @override
  String get editRecipe => 'Редагувати рецепт';

  @override
  String get recipeImage => 'Фото рецепту';

  @override
  String get tapToAddPhoto => 'Натисніть, щоб додати фото';

  @override
  String get recipeTitle => 'Назва рецепту';

  @override
  String get enterTitle => 'Введіть назву...';

  @override
  String get describeRecipe => 'Опишіть ваш рецепт...';

  @override
  String get enterIngredientHint =>
      'Приклад:\n2 Яйця\n200г Борошна\n(Кожен з нового рядка)';

  @override
  String get enterInstructionHint =>
      'Приклад:\nЗбити яйця.\nЗапікати при 180C.\n(Кожен крок з нового рядка)';

  @override
  String get makePublic => 'Зробити публічним';

  @override
  String get anyoneCanSee => 'Будь-хто зможе бачити цей рецепт';

  @override
  String get selectTime => 'Оберіть час';

  @override
  String get compressingImage => 'Стиснення зображення...';

  @override
  String get recipeCreated => 'Рецепт успішно створено!';

  @override
  String get recipeUpdated => 'Рецепт оновлено!';

  @override
  String get save => 'Зберегти';

  @override
  String get done => 'Готово';

  @override
  String get days => 'Дн';

  @override
  String get hours => 'Год';

  @override
  String get mins => 'Хв';

  @override
  String get profile => 'Профіль';

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get tapToChangePhoto => 'Натисніть для зміни фото';

  @override
  String get chooseAvatar => 'Оберіть аватар';

  @override
  String get accountSettings => 'Налаштування акаунту';

  @override
  String get faq => 'Часті питання';

  @override
  String get helpSupport => 'Допомога';

  @override
  String get sendFeedback => 'Надіслати відгук';

  @override
  String get logOut => 'Вийти';

  @override
  String get emailNotVerified => 'Пошта не підтверджена';

  @override
  String get resendVerification => 'Надіслати лист повторно';

  @override
  String waitToResend(int seconds) {
    return 'Зачекайте $secondsс';
  }

  @override
  String get verificationSent => 'Лист надіслано! Перевірте вхідні.';

  @override
  String get profileUpdated => 'Профіль оновлено!';

  @override
  String get nicknameEmpty => 'Нікнейм не може бути пустим';

  @override
  String get faqQ1 => 'Як створити рецепт?';

  @override
  String get faqA1 =>
      'Перейдіть на вкладку \'Мої рецепти\' (іконка книги) та натисніть \'+\' у верхньому куті.';

  @override
  String get faqQ2 => 'Чи можу я приховати рецепти?';

  @override
  String get faqA2 =>
      'Так! При створенні або редагуванні вимкніть перемикач \'Зробити публічним\'.';

  @override
  String get faqQ3 => 'Як змінити пароль?';

  @override
  String get faqA3 => 'Профіль > Налаштування акаунту > Змінити пароль.';

  @override
  String get faqQ4 => 'FurTable безкоштовний?';

  @override
  String get faqA4 => 'Так, FurTable повністю безкоштовний для всіх.';

  @override
  String get faqQ5 => 'Як видалити акаунт?';

  @override
  String get faqA5 => 'Профіль > Налаштування акаунту > Видалити акаунт.';

  @override
  String get feedbackThanks => 'Дякуємо за ваш відгук!';

  @override
  String feedbackError(String error) {
    return 'Помилка: $error';
  }

  @override
  String get tellUsExperience => 'Розкажіть про ваші враження...';

  @override
  String get feedbackHint =>
      'Поділіться думками, ідеями або повідомте про проблему...';

  @override
  String emailIncluded(String email) {
    return 'Вашу пошту ($email) буде додано до відгуку.';
  }

  @override
  String get inProgress => 'В процесі...';

  @override
  String get reachedEnd => 'Ви дійшли до кінця';

  @override
  String get changePasswordSubtitle => 'Оновіть пароль для підвищення безпеки.';

  @override
  String get enterCurrentPassword => 'Введіть поточний пароль';

  @override
  String get enterNewPassword => 'Введіть новий пароль';

  @override
  String get confirmYourPassword => 'Підтвердіть новий пароль';

  @override
  String get passwordRequirement => 'Мінімум 8 символів, включаючи одну цифру';

  @override
  String get clearCacheDialogTitle => 'Очистити кеш?';

  @override
  String get clearCacheDialogDesc =>
      'Це видалить усі завантажені зображення. Вони будуть завантажені знову за потреби.';

  @override
  String get clearCacheSuccess => 'Кеш зображень успішно очищено';

  @override
  String get errorClearingCache => 'Помилка очищення кешу';

  @override
  String get changePassword => 'Змінити пароль';

  @override
  String get currentPassword => 'Поточний пароль';

  @override
  String get newPassword => 'Новий пароль';

  @override
  String get confirmNewPassword => 'Підтвердити пароль';

  @override
  String get passwordsDoNotMatch => 'Паролі не співпадають';

  @override
  String get passwordUpdated => 'Пароль оновлено!';

  @override
  String get storageCache => 'Сховище та Кеш';

  @override
  String get enableCaching => 'Увімкнути кешування';

  @override
  String get saveImagesLocally => 'Зберігати фото локально для швидкості';

  @override
  String get autoClear => 'Авто-очищення при старті';

  @override
  String get clearCacheStart => 'Очищати кеш при кожному запуску';

  @override
  String get clearCacheNow => 'Очистити кеш зараз';

  @override
  String get deleteAccount => 'Видалити акаунт';

  @override
  String get deleteAccountConfirm => 'Видалити акаунт?';

  @override
  String get deleteAccountDesc => 'Ви впевнені? Цю дію неможливо скасувати.';

  @override
  String get language => 'Мова';

  @override
  String get typeToSearch => 'Введіть для пошуку...';

  @override
  String get noRecipesFound => 'Рецептів не знайдено.';

  @override
  String get tryDifferentSearch => 'Спробуйте інший запит.';

  @override
  String get recentSearches => 'Історія пошуку';

  @override
  String get clear => 'Очистити';

  @override
  String get error => 'Помилка';

  @override
  String get success => 'Успішно';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get edit => 'Редагувати';

  @override
  String get update => 'Оновити';

  @override
  String get deleteRecipeTitle => 'Видалити рецепт?';

  @override
  String get deleteRecipeContent =>
      'Ви впевнені, що хочете безповоротно видалити цей рецепт? Цю дію неможливо скасувати.';

  @override
  String get recipeDeleted => 'Рецепт видалено';

  @override
  String get searchHint => 'Рецепт або Автор';

  @override
  String get public => 'Публічні';

  @override
  String get private => 'Приватні';

  @override
  String get noRecipesYet => 'Ще немає рецептів';

  @override
  String get noFavorites => 'У вибраному пусто';

  @override
  String get tapHeart => 'Тисніть на серце, щоб зберегти рецепт';

  @override
  String get joinTitle => 'Приєднуйтесь до FurTable';

  @override
  String get loginOrSignup => 'Вхід / Реєстрація';

  @override
  String get guestMyRecipesTitle => 'Почніть готувати!';

  @override
  String get guestMyRecipesMessage =>
      'Створіть акаунт, щоб зберігати власні рецепти та ділитися ними зі світом.';

  @override
  String get guestFavoritesTitle => 'Зберігайте улюблене';

  @override
  String get guestFavoritesMessage =>
      'Увійдіть, щоб створити власну колекцію смачних рецептів.';

  @override
  String get authRequiredLike =>
      'Увійдіть, щоб додати цей рецепт до улюблених.';

  @override
  String get authRequiredAction => 'Увійдіть, щоб виконати цю дію.';
}
