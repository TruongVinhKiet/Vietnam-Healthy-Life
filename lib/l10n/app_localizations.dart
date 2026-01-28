import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'My Diary'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @suggestionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions'**
  String get suggestionLoadError;

  /// No description provided for @suggestionGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String suggestionGenericError(String error);

  /// No description provided for @suggestionGenerateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Suggestions created!'**
  String get suggestionGenerateSuccess;

  /// No description provided for @suggestionGenerateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create suggestions'**
  String get suggestionGenerateError;

  /// No description provided for @suggestionAcceptSuccess.
  ///
  /// In en, this message translates to:
  /// **'Suggestion accepted!'**
  String get suggestionAcceptSuccess;

  /// No description provided for @suggestionAcceptError.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept suggestion'**
  String get suggestionAcceptError;

  /// No description provided for @suggestionSwapSuccess.
  ///
  /// In en, this message translates to:
  /// **'New suggestion swapped!'**
  String get suggestionSwapSuccess;

  /// No description provided for @suggestionSwapError.
  ///
  /// In en, this message translates to:
  /// **'Failed to swap suggestion'**
  String get suggestionSwapError;

  /// No description provided for @suggestionGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get suggestionGenerating;

  /// No description provided for @suggestionCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new suggestion'**
  String get suggestionCreateNew;

  /// No description provided for @suggestionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No suggestions yet'**
  String get suggestionEmptyTitle;

  /// No description provided for @suggestionEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Create new suggestion\" to generate meals for this day'**
  String get suggestionEmptyMessage;

  /// No description provided for @suggestionEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Create suggestion'**
  String get suggestionEmptyAction;

  /// No description provided for @suggestionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String suggestionCountLabel(int count);

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @swapSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Swap suggestion'**
  String get swapSuggestion;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @acceptedNote.
  ///
  /// In en, this message translates to:
  /// **'Accepted - please add this to your diary!'**
  String get acceptedNote;

  /// No description provided for @portionSize.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String portionSize(String count);

  /// No description provided for @mealLabel.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get mealLabel;

  /// No description provided for @drinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drinkLabel;

  /// No description provided for @chooseMealCountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select meal counts'**
  String get chooseMealCountsTitle;

  /// No description provided for @chooseMealCountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose number of dishes and drinks per meal (Max 2 dishes/meal)'**
  String get chooseMealCountsSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @mealField.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get mealField;

  /// No description provided for @drinkField.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drinkField;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @analyzingImage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image...'**
  String get analyzingImage;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retakePhoto;

  /// No description provided for @recognizeDish.
  ///
  /// In en, this message translates to:
  /// **'Dish recognition'**
  String get recognizeDish;

  /// No description provided for @saveDataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save data: {error}'**
  String saveDataError(String error);

  /// No description provided for @defaultDishName.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get defaultDishName;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {percent}%'**
  String accuracy(int percent);

  /// No description provided for @nutritionComposition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition composition'**
  String get nutritionComposition;

  /// No description provided for @nutrient.
  ///
  /// In en, this message translates to:
  /// **'Nutrient'**
  String get nutrient;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @medicationStats.
  ///
  /// In en, this message translates to:
  /// **'Medication statistics'**
  String get medicationStats;

  /// No description provided for @days7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get days7;

  /// No description provided for @days14.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get days14;

  /// No description provided for @days30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get days30;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @totalDose.
  ///
  /// In en, this message translates to:
  /// **'Total doses'**
  String get totalDose;

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time (±1 hour)'**
  String get onTime;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// No description provided for @onTimeShort.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTimeShort;

  /// No description provided for @loadNotificationsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications: {error}'**
  String loadNotificationsError(String error);

  /// No description provided for @noNotificationsShort.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotificationsShort;

  /// No description provided for @errorSaveData.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String errorSaveData(String error);

  /// No description provided for @healthWarning.
  ///
  /// In en, this message translates to:
  /// **'Health warning'**
  String get healthWarning;

  /// No description provided for @notSuitableForHealth.
  ///
  /// In en, this message translates to:
  /// **'{item} is not suitable for your health condition. You should not eat this.'**
  String notSuitableForHealth(String item);

  /// No description provided for @dishContainsRestrictedFood.
  ///
  /// In en, this message translates to:
  /// **'This dish contains foods you should avoid based on your health condition'**
  String get dishContainsRestrictedFood;

  /// No description provided for @usuallyEaten.
  ///
  /// In en, this message translates to:
  /// **'Commonly eaten'**
  String get usuallyEaten;

  /// No description provided for @nutrientForWeight.
  ///
  /// In en, this message translates to:
  /// **'Nutrition for {weight}g'**
  String nutrientForWeight(num weight);

  /// No description provided for @minerals.
  ///
  /// In en, this message translates to:
  /// **'Minerals'**
  String get minerals;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @drugInteractionWarning.
  ///
  /// In en, this message translates to:
  /// **'Drug interaction warning'**
  String get drugInteractionWarning;

  /// No description provided for @recentlyTookDrug.
  ///
  /// In en, this message translates to:
  /// **'You just took medication and this food may interact:'**
  String get recentlyTookDrug;

  /// No description provided for @drugNameFallback.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get drugNameFallback;

  /// No description provided for @interactionWithNutrient.
  ///
  /// In en, this message translates to:
  /// **'Interacts with {nutrient}'**
  String interactionWithNutrient(String nutrient);

  /// No description provided for @nutrientName.
  ///
  /// In en, this message translates to:
  /// **'Nutrient: {name}'**
  String nutrientName(String name);

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to continue?'**
  String get areYouSure;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @fieldTooLong.
  ///
  /// In en, this message translates to:
  /// **'{field} is too long, truncated to limit'**
  String fieldTooLong(String field);

  /// No description provided for @fieldInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'{field} contains invalid characters'**
  String fieldInvalidChars(String field);

  /// No description provided for @fieldInvalid.
  ///
  /// In en, this message translates to:
  /// **'{field} is invalid'**
  String fieldInvalid(String field);

  /// No description provided for @fieldMaxInteger.
  ///
  /// In en, this message translates to:
  /// **'{field} max {max} integer digits'**
  String fieldMaxInteger(String field, int max);

  /// No description provided for @fieldMaxFraction.
  ///
  /// In en, this message translates to:
  /// **'{field} max {max} fractional digits'**
  String fieldMaxFraction(String field, int max);

  /// No description provided for @fieldMustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'{field} must be a number'**
  String fieldMustBeNumber(Object field);

  /// No description provided for @fieldMinValue.
  ///
  /// In en, this message translates to:
  /// **'{field} must be >= {min}'**
  String fieldMinValue(String field, num min);

  /// No description provided for @fieldMaxValue.
  ///
  /// In en, this message translates to:
  /// **'{field} must be <= {max}'**
  String fieldMaxValue(String field, num max);

  /// No description provided for @editPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit personal info'**
  String get editPersonalInfo;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInfo;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get changeAvatar;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @ageMustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Age must be a number'**
  String get ageMustBeNumber;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age: 5-120'**
  String get ageRange;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @otherGender.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherGender;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightLabel;

  /// No description provided for @heightLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabelShort;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @weightLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabelShort;

  /// No description provided for @lifestylePreferences.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & Preferences'**
  String get lifestylePreferences;

  /// No description provided for @activityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevelLabel;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get activityLight;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get activityModerate;

  /// No description provided for @activityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activityActive;

  /// No description provided for @activityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get activityVeryActive;

  /// No description provided for @dietTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Diet type'**
  String get dietTypeLabel;

  /// No description provided for @dietMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get dietMediterranean;

  /// No description provided for @dietCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get dietCustom;

  /// No description provided for @foodAllergy.
  ///
  /// In en, this message translates to:
  /// **'Food allergy'**
  String get foodAllergy;

  /// No description provided for @healthGoal.
  ///
  /// In en, this message translates to:
  /// **'Health Goal'**
  String get healthGoal;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// No description provided for @maintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// No description provided for @gainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get gainWeight;

  /// No description provided for @interface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @interfaceMode.
  ///
  /// In en, this message translates to:
  /// **'Interface Mode'**
  String get interfaceMode;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @seasonalInterface.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Interface'**
  String get seasonalInterface;

  /// No description provided for @autoChangeByMonth.
  ///
  /// In en, this message translates to:
  /// **'Automatically change by month'**
  String get autoChangeByMonth;

  /// No description provided for @seasonMode.
  ///
  /// In en, this message translates to:
  /// **'Season Mode'**
  String get seasonMode;

  /// No description provided for @automaticByMonth.
  ///
  /// In en, this message translates to:
  /// **'Automatic (by month)'**
  String get automaticByMonth;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @fallingLeaves.
  ///
  /// In en, this message translates to:
  /// **'Falling Leaves'**
  String get fallingLeaves;

  /// No description provided for @fallingLeavesEffect.
  ///
  /// In en, this message translates to:
  /// **'Falling leaves autumn effect'**
  String get fallingLeavesEffect;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @weatherCity.
  ///
  /// In en, this message translates to:
  /// **'Weather City'**
  String get weatherCity;

  /// No description provided for @windDirection.
  ///
  /// In en, this message translates to:
  /// **'Wind Direction'**
  String get windDirection;

  /// No description provided for @windNorth.
  ///
  /// In en, this message translates to:
  /// **'North (N)'**
  String get windNorth;

  /// No description provided for @windNorthEast.
  ///
  /// In en, this message translates to:
  /// **'North East (NE)'**
  String get windNorthEast;

  /// No description provided for @windEast.
  ///
  /// In en, this message translates to:
  /// **'East (E)'**
  String get windEast;

  /// No description provided for @windSouthEast.
  ///
  /// In en, this message translates to:
  /// **'South East (SE)'**
  String get windSouthEast;

  /// No description provided for @windSouth.
  ///
  /// In en, this message translates to:
  /// **'South (S)'**
  String get windSouth;

  /// No description provided for @windSouthWest.
  ///
  /// In en, this message translates to:
  /// **'South West (SW)'**
  String get windSouthWest;

  /// No description provided for @windWest.
  ///
  /// In en, this message translates to:
  /// **'West (W)'**
  String get windWest;

  /// No description provided for @windNorthWest.
  ///
  /// In en, this message translates to:
  /// **'North West (NW)'**
  String get windNorthWest;

  /// No description provided for @weatherAngle.
  ///
  /// In en, this message translates to:
  /// **'Angle: {degree}°'**
  String weatherAngle(int degree);

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @backgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Background Image'**
  String get backgroundImage;

  /// No description provided for @enableBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Enable Background Image'**
  String get enableBackgroundImage;

  /// No description provided for @backgroundImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Background Image URL'**
  String get backgroundImageUrl;

  /// No description provided for @applyBackgroundImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply the background image URL you enter'**
  String get applyBackgroundImageSubtitle;

  /// No description provided for @weatherCityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Ho Chi Minh City, Ca Mau...'**
  String get weatherCityHint;

  /// No description provided for @effectIntensity.
  ///
  /// In en, this message translates to:
  /// **'Effect Intensity'**
  String get effectIntensity;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @dietaryFiber.
  ///
  /// In en, this message translates to:
  /// **'Dietary Fiber'**
  String get dietaryFiber;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @totalFiber.
  ///
  /// In en, this message translates to:
  /// **'Total Fiber'**
  String get totalFiber;

  /// No description provided for @ofDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'of daily goal {goal}'**
  String ofDailyGoal(String goal);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @goalNotSet.
  ///
  /// In en, this message translates to:
  /// **'Goal not set'**
  String get goalNotSet;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today!'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

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

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level: {level}'**
  String activityLevel(String level);

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @vitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get vitamins;

  /// No description provided for @aminoAcids.
  ///
  /// In en, this message translates to:
  /// **'Amino Acids'**
  String get aminoAcids;

  /// No description provided for @fibers.
  ///
  /// In en, this message translates to:
  /// **'Fibers'**
  String get fibers;

  /// No description provided for @fats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fats;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @rda.
  ///
  /// In en, this message translates to:
  /// **'RDA'**
  String get rda;

  /// No description provided for @nutritionOverview.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Overview'**
  String get nutritionOverview;

  /// No description provided for @personalRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Personal Recommendation'**
  String get personalRecommendation;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get description;

  /// No description provided for @foods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get foods;

  /// No description provided for @contraindications.
  ///
  /// In en, this message translates to:
  /// **'Contraindications'**
  String get contraindications;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get left;

  /// No description provided for @g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get g;

  /// No description provided for @mg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get mg;

  /// No description provided for @microgram.
  ///
  /// In en, this message translates to:
  /// **'μg'**
  String get microgram;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @l.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get l;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @m.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get m;

  /// No description provided for @customizeMealDistribution.
  ///
  /// In en, this message translates to:
  /// **'Customize meal distribution'**
  String get customizeMealDistribution;

  /// No description provided for @percentagesMustSumTo100.
  ///
  /// In en, this message translates to:
  /// **'Percentages must sum to 100'**
  String get percentagesMustSumTo100;

  /// No description provided for @timeFormatMustBeHHmm.
  ///
  /// In en, this message translates to:
  /// **'Time format must be HH:mm (e.g., 07:00)'**
  String get timeFormatMustBeHHmm;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @timeUtc7.
  ///
  /// In en, this message translates to:
  /// **'Time (UTC+7)'**
  String get timeUtc7;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @deleteDrink.
  ///
  /// In en, this message translates to:
  /// **'Delete Drink'**
  String get deleteDrink;

  /// No description provided for @confirmDeleteDrink.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this drink from your library?'**
  String get confirmDeleteDrink;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cannotDeleteDrink.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete drink'**
  String get cannotDeleteDrink;

  /// No description provided for @drinkDetail.
  ///
  /// In en, this message translates to:
  /// **'Drink Detail'**
  String get drinkDetail;

  /// No description provided for @drinkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Drink not found'**
  String get drinkNotFound;

  /// No description provided for @noIngredientInfo.
  ///
  /// In en, this message translates to:
  /// **'No ingredient information'**
  String get noIngredientInfo;

  /// No description provided for @quickEntry.
  ///
  /// In en, this message translates to:
  /// **'Quick Entry (ml or L)'**
  String get quickEntry;

  /// No description provided for @example250Or03L.
  ///
  /// In en, this message translates to:
  /// **'Example: 250 or 0.3L'**
  String get example250Or03L;

  /// No description provided for @pleaseEnterValidWaterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid water amount'**
  String get pleaseEnterValidWaterAmount;

  /// No description provided for @recordButton.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordButton;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @enableWeatherUpdateFirst.
  ///
  /// In en, this message translates to:
  /// **'Enable weather update first'**
  String get enableWeatherUpdateFirst;

  /// No description provided for @drinkDeleted.
  ///
  /// In en, this message translates to:
  /// **'Drink deleted'**
  String get drinkDeleted;

  /// No description provided for @addDrink.
  ///
  /// In en, this message translates to:
  /// **'Add Drink'**
  String get addDrink;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @showToAllUsers.
  ///
  /// In en, this message translates to:
  /// **'Show to all users'**
  String get showToAllUsers;

  /// No description provided for @noSugar.
  ///
  /// In en, this message translates to:
  /// **'No Sugar'**
  String get noSugar;

  /// No description provided for @selectIngredient.
  ///
  /// In en, this message translates to:
  /// **'Select Ingredient'**
  String get selectIngredient;

  /// No description provided for @enterKeywordToSearchFood.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword to search for food'**
  String get enterKeywordToSearchFood;

  /// No description provided for @createDrink.
  ///
  /// In en, this message translates to:
  /// **'Create Drink'**
  String get createDrink;

  /// No description provided for @hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydration;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet'**
  String get noIngredientsYet;

  /// No description provided for @saveDrink.
  ///
  /// In en, this message translates to:
  /// **'Save Drink'**
  String get saveDrink;

  /// No description provided for @manageDrinks.
  ///
  /// In en, this message translates to:
  /// **'Manage Drinks'**
  String get manageDrinks;

  /// No description provided for @confirmDeleteDrinkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this drink?'**
  String get confirmDeleteDrinkQuestion;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @manageFoods.
  ///
  /// In en, this message translates to:
  /// **'Manage Foods'**
  String get manageFoods;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @noNutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'No nutrition information'**
  String get noNutritionInfo;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteFood.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete food \"{foodName}\"?'**
  String confirmDeleteFood(String foodName);

  /// No description provided for @foodDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Food deleted successfully'**
  String get foodDeletedSuccessfully;

  /// No description provided for @cannotConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server'**
  String get cannotConnectToServer;

  /// No description provided for @errorLoadingList.
  ///
  /// In en, this message translates to:
  /// **'Error loading list: {error}'**
  String errorLoadingList(String error);

  /// No description provided for @noDrinkRecipes.
  ///
  /// In en, this message translates to:
  /// **'No drink recipes'**
  String get noDrinkRecipes;

  /// No description provided for @pleaseSelectDrink.
  ///
  /// In en, this message translates to:
  /// **'Please select a drink to continue.'**
  String get pleaseSelectDrink;

  /// No description provided for @drinksNotFound.
  ///
  /// In en, this message translates to:
  /// **'No drinks found'**
  String get drinksNotFound;

  /// No description provided for @pleaseAddAtLeastOneIngredient.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one ingredient'**
  String get pleaseAddAtLeastOneIngredient;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @mealTemplates.
  ///
  /// In en, this message translates to:
  /// **'Meal Templates'**
  String get mealTemplates;

  /// No description provided for @cannotLoadStatistics.
  ///
  /// In en, this message translates to:
  /// **'Cannot load statistics'**
  String get cannotLoadStatistics;

  /// No description provided for @manageHealthConditions.
  ///
  /// In en, this message translates to:
  /// **'Manage Health Conditions'**
  String get manageHealthConditions;

  /// No description provided for @noDiseasesInSystem.
  ///
  /// In en, this message translates to:
  /// **'No diseases in system'**
  String get noDiseasesInSystem;

  /// No description provided for @errorLoadingListColon.
  ///
  /// In en, this message translates to:
  /// **'Error loading list'**
  String get errorLoadingListColon;

  /// No description provided for @updateAccordingToWeather.
  ///
  /// In en, this message translates to:
  /// **'Update according to weather'**
  String get updateAccordingToWeather;

  /// No description provided for @changeInterfaceByCity.
  ///
  /// In en, this message translates to:
  /// **'Change interface by city'**
  String get changeInterfaceByCity;

  /// No description provided for @weatherEffects.
  ///
  /// In en, this message translates to:
  /// **'Weather effects'**
  String get weatherEffects;

  /// No description provided for @rainSnowFog.
  ///
  /// In en, this message translates to:
  /// **'Rain, snow, fog...'**
  String get rainSnowFog;

  /// No description provided for @effectIntensityTitle.
  ///
  /// In en, this message translates to:
  /// **'Effect Intensity'**
  String get effectIntensityTitle;

  /// No description provided for @windDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Wind Direction'**
  String get windDirectionTitle;

  /// No description provided for @useCustomBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Use custom background image'**
  String get useCustomBackgroundImage;

  /// No description provided for @previewBackground.
  ///
  /// In en, this message translates to:
  /// **'Preview background'**
  String get previewBackground;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImage;

  /// No description provided for @drinkCreated.
  ///
  /// In en, this message translates to:
  /// **'Drink created'**
  String get drinkCreated;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @ingredient.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredient;

  /// No description provided for @errorColon.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorColon;

  /// No description provided for @addDisease.
  ///
  /// In en, this message translates to:
  /// **'Add Disease'**
  String get addDisease;

  /// No description provided for @confirmDeleteDisease.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete disease \"{diseaseName}\"?'**
  String confirmDeleteDisease(String diseaseName);

  /// No description provided for @diseaseDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Disease deleted successfully'**
  String get diseaseDeletedSuccessfully;

  /// No description provided for @noAdjustments.
  ///
  /// In en, this message translates to:
  /// **'No adjustments'**
  String get noAdjustments;

  /// No description provided for @noAvoidList.
  ///
  /// In en, this message translates to:
  /// **'No avoid list'**
  String get noAvoidList;

  /// No description provided for @diseaseUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Disease updated successfully'**
  String get diseaseUpdatedSuccessfully;

  /// No description provided for @diseaseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Disease added successfully'**
  String get diseaseAddedSuccessfully;

  /// No description provided for @weatherUpdated.
  ///
  /// In en, this message translates to:
  /// **'Weather updated'**
  String get weatherUpdated;

  /// No description provided for @medicationMarked.
  ///
  /// In en, this message translates to:
  /// **'Medication marked'**
  String get medicationMarked;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get recipeDeleted;

  /// No description provided for @recipeDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting recipe'**
  String get recipeDeleteError;

  /// No description provided for @recipeAddedToMeal.
  ///
  /// In en, this message translates to:
  /// **'Recipe added to meal'**
  String get recipeAddedToMeal;

  /// No description provided for @recipeAddToMealError.
  ///
  /// In en, this message translates to:
  /// **'Error adding to meal'**
  String get recipeAddToMealError;

  /// No description provided for @recipeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading recipes'**
  String get recipeLoadError;

  /// No description provided for @recipeLoadDetailError.
  ///
  /// In en, this message translates to:
  /// **'Error loading details'**
  String get recipeLoadDetailError;

  /// No description provided for @createFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create first recipe'**
  String get createFirstRecipe;

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get addToMeal;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteRecipe;

  /// No description provided for @confirmDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe?'**
  String get confirmDeleteRecipe;

  /// No description provided for @pleaseLoginToUseChat.
  ///
  /// In en, this message translates to:
  /// **'Please login to use chat feature'**
  String get pleaseLoginToUseChat;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {error}'**
  String errorLoadingMessages(String error);

  /// No description provided for @errorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending message'**
  String get errorSendingMessage;

  /// No description provided for @errorAnalyzingImage.
  ///
  /// In en, this message translates to:
  /// **'Error analyzing image. Please try again.'**
  String get errorAnalyzingImage;

  /// No description provided for @errorSendingImage.
  ///
  /// In en, this message translates to:
  /// **'Error sending image'**
  String get errorSendingImage;

  /// No description provided for @errorProcessing.
  ///
  /// In en, this message translates to:
  /// **'Error processing'**
  String get errorProcessing;

  /// No description provided for @bodyMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Body Measurement'**
  String get bodyMeasurement;

  /// No description provided for @mediterraneanDiet.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean Diet'**
  String get mediterraneanDiet;

  /// No description provided for @mealsToday.
  ///
  /// In en, this message translates to:
  /// **'Meals Today'**
  String get mealsToday;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @hydrationPercent.
  ///
  /// In en, this message translates to:
  /// **'Hydration {percent}%'**
  String hydrationPercent(String percent);

  /// No description provided for @vitaminC.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C'**
  String get vitaminC;

  /// No description provided for @calcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get calcium;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @omega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3'**
  String get omega3;

  /// No description provided for @cameraNutritionScanner.
  ///
  /// In en, this message translates to:
  /// **'Camera Nutrition Scanner'**
  String get cameraNutritionScanner;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @aquaSmartBottle.
  ///
  /// In en, this message translates to:
  /// **'Aqua SmartBottle'**
  String get aquaSmartBottle;

  /// No description provided for @lastDrink.
  ///
  /// In en, this message translates to:
  /// **'Last drink'**
  String get lastDrink;

  /// No description provided for @noRecentDrink.
  ///
  /// In en, this message translates to:
  /// **'No recent drink'**
  String get noRecentDrink;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @lbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// No description provided for @eaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get eaten;

  /// No description provided for @burned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get burned;

  /// No description provided for @kcalLeft.
  ///
  /// In en, this message translates to:
  /// **'Kcal left'**
  String get kcalLeft;

  /// No description provided for @topMinerals.
  ///
  /// In en, this message translates to:
  /// **'Top minerals'**
  String get topMinerals;

  /// No description provided for @topVitamins.
  ///
  /// In en, this message translates to:
  /// **'Top vitamins'**
  String get topVitamins;

  /// No description provided for @tapDetailsToSeeFullMineralsTable.
  ///
  /// In en, this message translates to:
  /// **'Tap Details to see full minerals table and recommended daily amounts.'**
  String get tapDetailsToSeeFullMineralsTable;

  /// No description provided for @tapDetailsToSeeFullVitaminTable.
  ///
  /// In en, this message translates to:
  /// **'Tap Details to see full vitamin table and recommended daily amounts.'**
  String get tapDetailsToSeeFullVitaminTable;

  /// No description provided for @tapDetailsToSeeFullAminoAcidTable.
  ///
  /// In en, this message translates to:
  /// **'Tap Details to see full amino acid table and recommended amounts.'**
  String get tapDetailsToSeeFullAminoAcidTable;

  /// No description provided for @cookingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Cooking Recipes'**
  String get cookingRecipes;

  /// No description provided for @exploreVietnameseDishes.
  ///
  /// In en, this message translates to:
  /// **'Explore Vietnamese dishes'**
  String get exploreVietnameseDishes;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @drinkRecipes.
  ///
  /// In en, this message translates to:
  /// **'Drink Recipes'**
  String get drinkRecipes;

  /// No description provided for @customizeVolume.
  ///
  /// In en, this message translates to:
  /// **'Self-made, customizable volume'**
  String get customizeVolume;

  /// No description provided for @exploreNow.
  ///
  /// In en, this message translates to:
  /// **'Explore now'**
  String get exploreNow;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @activityFactor.
  ///
  /// In en, this message translates to:
  /// **'Activity Factor (e.g. 1.2)'**
  String get activityFactor;

  /// No description provided for @dietType.
  ///
  /// In en, this message translates to:
  /// **'Diet Type'**
  String get dietType;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies (select):'**
  String get allergies;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// No description provided for @noResponseFromServer.
  ///
  /// In en, this message translates to:
  /// **'No response from server'**
  String get noResponseFromServer;

  /// No description provided for @recordWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Record Water Intake'**
  String get recordWaterIntake;

  /// No description provided for @selectDrinkToRecord.
  ///
  /// In en, this message translates to:
  /// **'Select a drink to record'**
  String get selectDrinkToRecord;

  /// No description provided for @noDrinkRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No drink recipes yet'**
  String get noDrinkRecipesYet;

  /// No description provided for @pleaseSelectDrinkToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please select a drink to continue.'**
  String get pleaseSelectDrinkToContinue;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @recommendedNutritionalNeeds.
  ///
  /// In en, this message translates to:
  /// **'Recommended Nutritional Needs'**
  String get recommendedNutritionalNeeds;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @invalidData.
  ///
  /// In en, this message translates to:
  /// **'Invalid data'**
  String get invalidData;

  /// No description provided for @dishDetail.
  ///
  /// In en, this message translates to:
  /// **'Dish Detail'**
  String get dishDetail;

  /// No description provided for @dishNotFound.
  ///
  /// In en, this message translates to:
  /// **'Dish not found'**
  String get dishNotFound;

  /// No description provided for @createDish.
  ///
  /// In en, this message translates to:
  /// **'Create Dish'**
  String get createDish;

  /// No description provided for @pleaseEnterDishName.
  ///
  /// In en, this message translates to:
  /// **'Please enter dish name'**
  String get pleaseEnterDishName;

  /// No description provided for @dishCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Dish created successfully!'**
  String get dishCreatedSuccessfully;

  /// No description provided for @continueTreatment.
  ///
  /// In en, this message translates to:
  /// **'Continue Treatment'**
  String get continueTreatment;

  /// No description provided for @recovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get recovered;

  /// No description provided for @confirmContinueTreatment.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue treatment for \"{conditionName}\"?'**
  String confirmContinueTreatment(String conditionName);

  /// No description provided for @treatmentExtended.
  ///
  /// In en, this message translates to:
  /// **'Treatment extended'**
  String get treatmentExtended;

  /// No description provided for @confirmRecovered.
  ///
  /// In en, this message translates to:
  /// **'Have you recovered from \"{conditionName}\"?'**
  String confirmRecovered(String conditionName);

  /// No description provided for @congratulationsRecovered.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on your recovery! 🎉'**
  String get congratulationsRecovered;

  /// No description provided for @cannotIdentifyConversation.
  ///
  /// In en, this message translates to:
  /// **'Cannot identify this conversation'**
  String get cannotIdentifyConversation;

  /// No description provided for @noMessagesInConversation.
  ///
  /// In en, this message translates to:
  /// **'No messages in this conversation'**
  String get noMessagesInConversation;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications: {error}'**
  String errorLoadingNotifications(String error);

  /// No description provided for @allMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All marked as read'**
  String get allMarkedAsRead;

  /// No description provided for @cannotTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Cannot take photo: {error}'**
  String cannotTakePhoto(String error);

  /// No description provided for @cannotSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Cannot select image: {error}'**
  String cannotSelectImage(String error);

  /// No description provided for @cannotRecognizeFood.
  ///
  /// In en, this message translates to:
  /// **'Cannot recognize food in image. Please try again with a clearer food image.'**
  String get cannotRecognizeFood;

  /// No description provided for @errorConnectingToAI.
  ///
  /// In en, this message translates to:
  /// **'Error connecting to AI: {error}'**
  String errorConnectingToAI(String error);

  /// No description provided for @savedNutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'✓ Saved nutrition info for {foodName}'**
  String savedNutritionInfo(String foodName);

  /// No description provided for @errorSavingData.
  ///
  /// In en, this message translates to:
  /// **'Error saving data: {error}'**
  String errorSavingData(String error);

  /// No description provided for @cannotLoadFoodInfo.
  ///
  /// In en, this message translates to:
  /// **'Cannot load food information'**
  String get cannotLoadFoodInfo;

  /// No description provided for @pleaseSelectFoodOrDish.
  ///
  /// In en, this message translates to:
  /// **'Please select food or dish'**
  String get pleaseSelectFoodOrDish;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @addedToMealSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Added to meal successfully'**
  String get addedToMealSuccessfully;

  /// No description provided for @errorLoadingDiseaseList.
  ///
  /// In en, this message translates to:
  /// **'Error loading disease list: {error}'**
  String errorLoadingDiseaseList(String error);

  /// No description provided for @alreadyHaveDisease.
  ///
  /// In en, this message translates to:
  /// **'You already have \"{diseaseName}\", cannot add again'**
  String alreadyHaveDisease(String diseaseName);

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select treatment start date'**
  String get pleaseSelectStartDate;

  /// No description provided for @pleaseSelectAtLeastOneMedicationTime.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one medication time'**
  String get pleaseSelectAtLeastOneMedicationTime;

  /// No description provided for @diseaseAdded.
  ///
  /// In en, this message translates to:
  /// **'Added \"{diseaseName}\"'**
  String diseaseAdded(String diseaseName);

  /// No description provided for @notDetermined.
  ///
  /// In en, this message translates to:
  /// **'Not determined'**
  String get notDetermined;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements'**
  String get noMeasurements;

  /// No description provided for @increaseResistance.
  ///
  /// In en, this message translates to:
  /// **'Increase resistance'**
  String get increaseResistance;

  /// No description provided for @strongBones.
  ///
  /// In en, this message translates to:
  /// **'Strong bones'**
  String get strongBones;

  /// No description provided for @goodDigestion.
  ///
  /// In en, this message translates to:
  /// **'Good digestion'**
  String get goodDigestion;

  /// No description provided for @cardiovascularHealth.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular health'**
  String get cardiovascularHealth;

  /// No description provided for @noMealData.
  ///
  /// In en, this message translates to:
  /// **'No meal data'**
  String get noMealData;

  /// No description provided for @searchDish.
  ///
  /// In en, this message translates to:
  /// **'Search dish (e.g.: Pho, Rice)...'**
  String get searchDish;

  /// No description provided for @searchIngredient.
  ///
  /// In en, this message translates to:
  /// **'Search ingredient (e.g.: Beef, Vegetables)...'**
  String get searchIngredient;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon!'**
  String get featureComingSoon;

  /// No description provided for @dish.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get dish;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadCount(String count);

  /// No description provided for @notificationDetail.
  ///
  /// In en, this message translates to:
  /// **'Notification Detail'**
  String get notificationDetail;

  /// No description provided for @selectHealthCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Health Condition'**
  String get selectHealthCondition;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// No description provided for @overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// No description provided for @obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// No description provided for @severelyUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Severely Underweight'**
  String get severelyUnderweight;

  /// No description provided for @slightlyOverweight.
  ///
  /// In en, this message translates to:
  /// **'Slightly Overweight'**
  String get slightlyOverweight;

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get perfect;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @needAttention.
  ///
  /// In en, this message translates to:
  /// **'Need Attention'**
  String get needAttention;

  /// No description provided for @needImprovement.
  ///
  /// In en, this message translates to:
  /// **'Need Improvement'**
  String get needImprovement;

  /// No description provided for @foodRestrictedByHealthCondition.
  ///
  /// In en, this message translates to:
  /// **'{foodName} cannot be added due to your health condition'**
  String foodRestrictedByHealthCondition(String foodName);

  /// No description provided for @deleteDish.
  ///
  /// In en, this message translates to:
  /// **'Delete Dish'**
  String get deleteDish;

  /// No description provided for @confirmDeleteDish.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{dishName}\"?'**
  String confirmDeleteDish(String dishName);

  /// No description provided for @dishDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{dishName}\"'**
  String dishDeleted(String dishName);

  /// No description provided for @cannotDeleteDish.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete dish ({errorMsg})'**
  String cannotDeleteDish(String errorMsg);

  /// No description provided for @weightG.
  ///
  /// In en, this message translates to:
  /// **'Weight (g)'**
  String get weightG;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @enterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Enter food name...'**
  String get enterFoodName;

  /// No description provided for @enterKeywordToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword to search for food'**
  String get enterKeywordToSearch;

  /// No description provided for @nameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get nameEnglish;

  /// No description provided for @nameVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Name'**
  String get nameVietnamese;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @baseLiquidNotes.
  ///
  /// In en, this message translates to:
  /// **'Base liquid / notes'**
  String get baseLiquidNotes;

  /// No description provided for @defaultVolumeMl.
  ///
  /// In en, this message translates to:
  /// **'Default volume (ml)'**
  String get defaultVolumeMl;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients'**
  String get noIngredients;

  /// No description provided for @searchAndAddIngredientsBelow.
  ///
  /// In en, this message translates to:
  /// **'Search and add ingredients below'**
  String get searchAndAddIngredientsBelow;

  /// No description provided for @yourHealthCondition.
  ///
  /// In en, this message translates to:
  /// **'Your Health Condition'**
  String get yourHealthCondition;

  /// No description provided for @inTreatment.
  ///
  /// In en, this message translates to:
  /// **'In Treatment'**
  String get inTreatment;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @medicationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Medication Schedule'**
  String get medicationSchedule;

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today, {day}/{month}/{year}'**
  String todayDate(String day, String month, String year);

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @nextAppointment.
  ///
  /// In en, this message translates to:
  /// **'Next Appointment'**
  String get nextAppointment;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(String days);

  /// No description provided for @selectNewEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select new end date'**
  String get selectNewEndDate;

  /// No description provided for @addNewAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add New Appointment'**
  String get addNewAppointment;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Invalid age'**
  String get invalidAge;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @currentlyHaveThisCondition.
  ///
  /// In en, this message translates to:
  /// **'Currently have this condition'**
  String get currentlyHaveThisCondition;

  /// No description provided for @treatmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Treatment Info'**
  String get treatmentInfo;

  /// No description provided for @treatmentStartDate.
  ///
  /// In en, this message translates to:
  /// **'Treatment Start Date *'**
  String get treatmentStartDate;

  /// No description provided for @treatmentEndDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Treatment End Date (Optional)'**
  String get treatmentEndDateOptional;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @confirmAdd.
  ///
  /// In en, this message translates to:
  /// **'Confirm Add'**
  String get confirmAdd;

  /// No description provided for @nutritionalNotifications.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Notifications'**
  String get nutritionalNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @todayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today Progress'**
  String get todayProgress;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(String minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(String hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(String days);

  /// No description provided for @searchDisease.
  ///
  /// In en, this message translates to:
  /// **'Search disease...'**
  String get searchDisease;

  /// No description provided for @causes.
  ///
  /// In en, this message translates to:
  /// **'Causes:'**
  String get causes;

  /// No description provided for @cannotAddDisease.
  ///
  /// In en, this message translates to:
  /// **'Cannot add disease'**
  String get cannotAddDisease;

  /// No description provided for @notLoggedInNoToken.
  ///
  /// In en, this message translates to:
  /// **'Not logged in - token not found'**
  String get notLoggedInNoToken;

  /// No description provided for @waterIntakeStatisticsByHour.
  ///
  /// In en, this message translates to:
  /// **'Water intake statistics by hour'**
  String get waterIntakeStatisticsByHour;

  /// No description provided for @noWaterIntakeRecordedForToday.
  ///
  /// In en, this message translates to:
  /// **'No water intake recorded for today.'**
  String get noWaterIntakeRecordedForToday;

  /// No description provided for @noDataForToday.
  ///
  /// In en, this message translates to:
  /// **'No data for today'**
  String get noDataForToday;

  /// No description provided for @pleaseRecordYourMealsToSeeDetailedStatistics.
  ///
  /// In en, this message translates to:
  /// **'Please record your meals to see detailed statistics.'**
  String get pleaseRecordYourMealsToSeeDetailedStatistics;

  /// No description provided for @noDetailedRecordsForToday.
  ///
  /// In en, this message translates to:
  /// **'No detailed records for today.'**
  String get noDetailedRecordsForToday;

  /// No description provided for @noDataForThisDate.
  ///
  /// In en, this message translates to:
  /// **'No data for this date'**
  String get noDataForThisDate;

  /// No description provided for @mealHistoryForToday.
  ///
  /// In en, this message translates to:
  /// **'Meal history for today'**
  String get mealHistoryForToday;

  /// No description provided for @topNutrients.
  ///
  /// In en, this message translates to:
  /// **'Top nutrients'**
  String get topNutrients;

  /// No description provided for @dishesEaten.
  ///
  /// In en, this message translates to:
  /// **'Dishes eaten'**
  String get dishesEaten;

  /// No description provided for @moreDishes.
  ///
  /// In en, this message translates to:
  /// **'+{count} more dishes'**
  String moreDishes(String count);

  /// No description provided for @timeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Time unknown'**
  String get timeUnknown;

  /// No description provided for @foodUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown food'**
  String get foodUnknown;

  /// No description provided for @viewOverview.
  ///
  /// In en, this message translates to:
  /// **'View overview'**
  String get viewOverview;

  /// No description provided for @viewDetailsByDate.
  ///
  /// In en, this message translates to:
  /// **'View details by date'**
  String get viewDetailsByDate;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @dishesToday.
  ///
  /// In en, this message translates to:
  /// **'{count} dishes today'**
  String dishesToday(String count);

  /// No description provided for @noMealRecorded.
  ///
  /// In en, this message translates to:
  /// **'No meal recorded yet'**
  String get noMealRecorded;

  /// No description provided for @breakfastShort.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfastShort;

  /// No description provided for @lunchShort.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunchShort;

  /// No description provided for @snackShort.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snackShort;

  /// No description provided for @dinnerShort.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinnerShort;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
