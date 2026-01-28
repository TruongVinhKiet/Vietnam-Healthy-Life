// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'My Diary';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get at => 'at';

  @override
  String get suggestionLoadError => 'Failed to load suggestions';

  @override
  String suggestionGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String get suggestionGenerateSuccess => 'Suggestions created!';

  @override
  String get suggestionGenerateError => 'Failed to create suggestions';

  @override
  String get suggestionAcceptSuccess => 'Suggestion accepted!';

  @override
  String get suggestionAcceptError => 'Failed to accept suggestion';

  @override
  String get suggestionSwapSuccess => 'New suggestion swapped!';

  @override
  String get suggestionSwapError => 'Failed to swap suggestion';

  @override
  String get suggestionGenerating => 'Generating...';

  @override
  String get suggestionCreateNew => 'Create new suggestion';

  @override
  String get suggestionEmptyTitle => 'No suggestions yet';

  @override
  String get suggestionEmptyMessage =>
      'Tap \"Create new suggestion\" to generate meals for this day';

  @override
  String get suggestionEmptyAction => 'Create suggestion';

  @override
  String suggestionCountLabel(int count) {
    return '$count items';
  }

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get swapSuggestion => 'Swap suggestion';

  @override
  String get processing => 'Processing...';

  @override
  String get accept => 'Accept';

  @override
  String get acceptedNote => 'Accepted - please add this to your diary!';

  @override
  String portionSize(String count) {
    return '$count servings';
  }

  @override
  String get mealLabel => 'Dish';

  @override
  String get drinkLabel => 'Drink';

  @override
  String get chooseMealCountsTitle => 'Select meal counts';

  @override
  String get chooseMealCountsSubtitle =>
      'Choose number of dishes and drinks per meal (Max 2 dishes/meal)';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get mealField => 'Dish';

  @override
  String get drinkField => 'Drink';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get analyzingImage => 'Analyzing image...';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get recognizeDish => 'Dish recognition';

  @override
  String saveDataError(String error) {
    return 'Failed to save data: $error';
  }

  @override
  String get defaultDishName => 'Dish';

  @override
  String accuracy(int percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String get nutritionComposition => 'Nutrition composition';

  @override
  String get nutrient => 'Nutrient';

  @override
  String get amount => 'Amount';

  @override
  String get reject => 'Reject';

  @override
  String get saving => 'Saving...';

  @override
  String get medicationStats => 'Medication statistics';

  @override
  String get days7 => '7 days';

  @override
  String get days14 => '14 days';

  @override
  String get days30 => '30 days';

  @override
  String get noData => 'No data';

  @override
  String get totalDose => 'Total doses';

  @override
  String get taken => 'Taken';

  @override
  String get onTime => 'On time (±1 hour)';

  @override
  String get late => 'Late';

  @override
  String get missed => 'Missed';

  @override
  String get adherence => 'Adherence';

  @override
  String get onTimeShort => 'On time';

  @override
  String loadNotificationsError(String error) {
    return 'Failed to load notifications: $error';
  }

  @override
  String get noNotificationsShort => 'No notifications';

  @override
  String errorSaveData(String error) {
    return 'Save failed: $error';
  }

  @override
  String get healthWarning => 'Health warning';

  @override
  String notSuitableForHealth(String item) {
    return '$item is not suitable for your health condition. You should not eat this.';
  }

  @override
  String get dishContainsRestrictedFood =>
      'This dish contains foods you should avoid based on your health condition';

  @override
  String get usuallyEaten => 'Commonly eaten';

  @override
  String nutrientForWeight(num weight) {
    return 'Nutrition for ${weight}g';
  }

  @override
  String get minerals => 'Minerals';

  @override
  String get other => 'Other';

  @override
  String get drugInteractionWarning => 'Drug interaction warning';

  @override
  String get recentlyTookDrug =>
      'You just took medication and this food may interact:';

  @override
  String get drugNameFallback => 'Medication';

  @override
  String interactionWithNutrient(String nutrient) {
    return 'Interacts with $nutrient';
  }

  @override
  String nutrientName(String name) {
    return 'Nutrient: $name';
  }

  @override
  String get areYouSure => 'Are you sure you want to continue?';

  @override
  String get continueAnyway => 'Continue anyway';

  @override
  String get cancelAction => 'Cancel';

  @override
  String fieldTooLong(String field) {
    return '$field is too long, truncated to limit';
  }

  @override
  String fieldInvalidChars(String field) {
    return '$field contains invalid characters';
  }

  @override
  String fieldInvalid(String field) {
    return '$field is invalid';
  }

  @override
  String fieldMaxInteger(String field, int max) {
    return '$field max $max integer digits';
  }

  @override
  String fieldMaxFraction(String field, int max) {
    return '$field max $max fractional digits';
  }

  @override
  String fieldMustBeNumber(Object field) {
    return '$field must be a number';
  }

  @override
  String fieldMinValue(String field, num min) {
    return '$field must be >= $min';
  }

  @override
  String fieldMaxValue(String field, num max) {
    return '$field must be <= $max';
  }

  @override
  String get editPersonalInfo => 'Edit personal info';

  @override
  String get basicInfo => 'Basic information';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get fullName => 'Full Name';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get ageLabel => 'Age';

  @override
  String get ageMustBeNumber => 'Age must be a number';

  @override
  String get ageRange => 'Age: 5-120';

  @override
  String get genderLabel => 'Gender';

  @override
  String get female => 'Female';

  @override
  String get otherGender => 'Other';

  @override
  String get heightLabel => 'Height (cm)';

  @override
  String get heightLabelShort => 'Height';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get weightLabelShort => 'Weight';

  @override
  String get lifestylePreferences => 'Lifestyle & Preferences';

  @override
  String get activityLevelLabel => 'Activity level';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activityLight => 'Lightly active';

  @override
  String get activityModerate => 'Moderately active';

  @override
  String get activityActive => 'Active';

  @override
  String get activityVeryActive => 'Very active';

  @override
  String get dietTypeLabel => 'Diet type';

  @override
  String get dietMediterranean => 'Mediterranean';

  @override
  String get dietCustom => 'Custom';

  @override
  String get foodAllergy => 'Food allergy';

  @override
  String get healthGoal => 'Health Goal';

  @override
  String get loseWeight => 'Lose Weight';

  @override
  String get maintainWeight => 'Maintain Weight';

  @override
  String get gainWeight => 'Gain Weight';

  @override
  String get interface => 'Interface';

  @override
  String get interfaceMode => 'Interface Mode';

  @override
  String get automatic => 'Automatic';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get seasonalInterface => 'Seasonal Interface';

  @override
  String get autoChangeByMonth => 'Automatically change by month';

  @override
  String get seasonMode => 'Season Mode';

  @override
  String get automaticByMonth => 'Automatic (by month)';

  @override
  String get manual => 'Manual';

  @override
  String get off => 'Off';

  @override
  String get fallingLeaves => 'Falling Leaves';

  @override
  String get fallingLeavesEffect => 'Falling leaves autumn effect';

  @override
  String get weather => 'Weather';

  @override
  String get weatherCity => 'Weather City';

  @override
  String get windDirection => 'Wind Direction';

  @override
  String get windNorth => 'North (N)';

  @override
  String get windNorthEast => 'North East (NE)';

  @override
  String get windEast => 'East (E)';

  @override
  String get windSouthEast => 'South East (SE)';

  @override
  String get windSouth => 'South (S)';

  @override
  String get windSouthWest => 'South West (SW)';

  @override
  String get windWest => 'West (W)';

  @override
  String get windNorthWest => 'North West (NW)';

  @override
  String weatherAngle(int degree) {
    return 'Angle: $degree°';
  }

  @override
  String get background => 'Background';

  @override
  String get backgroundImage => 'Background Image';

  @override
  String get enableBackgroundImage => 'Enable Background Image';

  @override
  String get backgroundImageUrl => 'Background Image URL';

  @override
  String get applyBackgroundImageSubtitle =>
      'Apply the background image URL you enter';

  @override
  String get weatherCityHint => 'e.g., Ho Chi Minh City, Ca Mau...';

  @override
  String get effectIntensity => 'Effect Intensity';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get save => 'Save';

  @override
  String get home => 'Home';

  @override
  String get health => 'Health';

  @override
  String get statistics => 'Statistics';

  @override
  String get account => 'Account';

  @override
  String get dietaryFiber => 'Dietary Fiber';

  @override
  String get fat => 'Fat';

  @override
  String get totalFiber => 'Total Fiber';

  @override
  String ofDailyGoal(String goal) {
    return 'of daily goal $goal';
  }

  @override
  String get done => 'Done';

  @override
  String get goalNotSet => 'Goal not set';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get today => 'Today!';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get name => 'Name';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String activityLevel(String level) {
    return 'Activity Level: $level';
  }

  @override
  String get goal => 'Goal';

  @override
  String get vitamins => 'Vitamins';

  @override
  String get aminoAcids => 'Amino Acids';

  @override
  String get fibers => 'Fibers';

  @override
  String get fats => 'Fats';

  @override
  String get information => 'Information';

  @override
  String get code => 'Code';

  @override
  String get group => 'Group';

  @override
  String get unit => 'Unit';

  @override
  String get rda => 'RDA';

  @override
  String get nutritionOverview => 'Nutrition Overview';

  @override
  String get personalRecommendation => 'Personal Recommendation';

  @override
  String get benefits => 'Benefits';

  @override
  String get description => 'Description:';

  @override
  String get foods => 'Foods';

  @override
  String get contraindications => 'Contraindications';

  @override
  String get recommended => 'Recommended';

  @override
  String get consumed => 'Consumed';

  @override
  String get remaining => 'Remaining';

  @override
  String get left => 'left';

  @override
  String get g => 'g';

  @override
  String get mg => 'mg';

  @override
  String get microgram => 'μg';

  @override
  String get ml => 'ml';

  @override
  String get l => 'L';

  @override
  String get kg => 'kg';

  @override
  String get cm => 'cm';

  @override
  String get m => 'm';

  @override
  String get customizeMealDistribution => 'Customize meal distribution';

  @override
  String get percentagesMustSumTo100 => 'Percentages must sum to 100';

  @override
  String get timeFormatMustBeHHmm => 'Time format must be HH:mm (e.g., 07:00)';

  @override
  String get percentage => 'Percentage';

  @override
  String get timeUtc7 => 'Time (UTC+7)';

  @override
  String get record => 'Record';

  @override
  String get deleteDrink => 'Delete Drink';

  @override
  String get confirmDeleteDrink =>
      'Are you sure you want to delete this drink from your library?';

  @override
  String get delete => 'Delete';

  @override
  String get cannotDeleteDrink => 'Cannot delete drink';

  @override
  String get drinkDetail => 'Drink Detail';

  @override
  String get drinkNotFound => 'Drink not found';

  @override
  String get noIngredientInfo => 'No ingredient information';

  @override
  String get quickEntry => 'Quick Entry (ml or L)';

  @override
  String get example250Or03L => 'Example: 250 or 0.3L';

  @override
  String get pleaseEnterValidWaterAmount => 'Please enter a valid water amount';

  @override
  String get recordButton => 'Record';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get enableWeatherUpdateFirst => 'Enable weather update first';

  @override
  String get drinkDeleted => 'Drink deleted';

  @override
  String get addDrink => 'Add Drink';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get showToAllUsers => 'Show to all users';

  @override
  String get noSugar => 'No Sugar';

  @override
  String get selectIngredient => 'Select Ingredient';

  @override
  String get enterKeywordToSearchFood => 'Enter keyword to search for food';

  @override
  String get createDrink => 'Create Drink';

  @override
  String get hydration => 'Hydration';

  @override
  String get noIngredientsYet => 'No ingredients yet';

  @override
  String get saveDrink => 'Save Drink';

  @override
  String get manageDrinks => 'Manage Drinks';

  @override
  String get confirmDeleteDrinkQuestion =>
      'Are you sure you want to delete this drink?';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get manageFoods => 'Manage Foods';

  @override
  String get addFood => 'Add Food';

  @override
  String get page => 'Page';

  @override
  String get noNutritionInfo => 'No nutrition information';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteFood(String foodName) {
    return 'Are you sure you want to delete food \"$foodName\"?';
  }

  @override
  String get foodDeletedSuccessfully => 'Food deleted successfully';

  @override
  String get cannotConnectToServer => 'Cannot connect to server';

  @override
  String errorLoadingList(String error) {
    return 'Error loading list: $error';
  }

  @override
  String get noDrinkRecipes => 'No drink recipes';

  @override
  String get pleaseSelectDrink => 'Please select a drink to continue.';

  @override
  String get drinksNotFound => 'No drinks found';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Please add at least one ingredient';

  @override
  String get recipes => 'Recipes';

  @override
  String get mealTemplates => 'Meal Templates';

  @override
  String get cannotLoadStatistics => 'Cannot load statistics';

  @override
  String get manageHealthConditions => 'Manage Health Conditions';

  @override
  String get noDiseasesInSystem => 'No diseases in system';

  @override
  String get errorLoadingListColon => 'Error loading list';

  @override
  String get updateAccordingToWeather => 'Update according to weather';

  @override
  String get changeInterfaceByCity => 'Change interface by city';

  @override
  String get weatherEffects => 'Weather effects';

  @override
  String get rainSnowFog => 'Rain, snow, fog...';

  @override
  String get effectIntensityTitle => 'Effect Intensity';

  @override
  String get windDirectionTitle => 'Wind Direction';

  @override
  String get useCustomBackgroundImage => 'Use custom background image';

  @override
  String get previewBackground => 'Preview background';

  @override
  String get noImage => 'No image';

  @override
  String get drinkCreated => 'Drink created';

  @override
  String get failed => 'Failed';

  @override
  String get ingredient => 'Ingredient';

  @override
  String get errorColon => 'Error';

  @override
  String get addDisease => 'Add Disease';

  @override
  String confirmDeleteDisease(String diseaseName) {
    return 'Are you sure you want to delete disease \"$diseaseName\"?';
  }

  @override
  String get diseaseDeletedSuccessfully => 'Disease deleted successfully';

  @override
  String get noAdjustments => 'No adjustments';

  @override
  String get noAvoidList => 'No avoid list';

  @override
  String get diseaseUpdatedSuccessfully => 'Disease updated successfully';

  @override
  String get diseaseAddedSuccessfully => 'Disease added successfully';

  @override
  String get weatherUpdated => 'Weather updated';

  @override
  String get medicationMarked => 'Medication marked';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get recipeDeleted => 'Recipe deleted';

  @override
  String get recipeDeleteError => 'Error deleting recipe';

  @override
  String get recipeAddedToMeal => 'Recipe added to meal';

  @override
  String get recipeAddToMealError => 'Error adding to meal';

  @override
  String get recipeLoadError => 'Error loading recipes';

  @override
  String get recipeLoadDetailError => 'Error loading details';

  @override
  String get createFirstRecipe => 'Create first recipe';

  @override
  String get addToMeal => 'Add to Meal';

  @override
  String get deleteRecipe => 'Delete Recipe';

  @override
  String get confirmDeleteRecipe =>
      'Are you sure you want to delete this recipe?';

  @override
  String get pleaseLoginToUseChat => 'Please login to use chat feature';

  @override
  String errorLoadingMessages(String error) {
    return 'Error loading messages: $error';
  }

  @override
  String get errorSendingMessage => 'Error sending message';

  @override
  String get errorAnalyzingImage => 'Error analyzing image. Please try again.';

  @override
  String get errorSendingImage => 'Error sending image';

  @override
  String get errorProcessing => 'Error processing';

  @override
  String get bodyMeasurement => 'Body Measurement';

  @override
  String get mediterraneanDiet => 'Mediterranean Diet';

  @override
  String get mealsToday => 'Meals Today';

  @override
  String get water => 'Water';

  @override
  String get details => 'Details';

  @override
  String get customize => 'Customize';

  @override
  String hydrationPercent(String percent) {
    return 'Hydration $percent%';
  }

  @override
  String get vitaminC => 'Vitamin C';

  @override
  String get calcium => 'Calcium';

  @override
  String get fiber => 'Fiber';

  @override
  String get omega3 => 'Omega-3';

  @override
  String get cameraNutritionScanner => 'Camera Nutrition Scanner';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get failedToSave => 'Failed to save';

  @override
  String get network => 'Network';

  @override
  String get aquaSmartBottle => 'Aqua SmartBottle';

  @override
  String get lastDrink => 'Last drink';

  @override
  String get noRecentDrink => 'No recent drink';

  @override
  String get bmi => 'BMI';

  @override
  String get lbs => 'lbs';

  @override
  String get eaten => 'Eaten';

  @override
  String get burned => 'Burned';

  @override
  String get kcalLeft => 'Kcal left';

  @override
  String get topMinerals => 'Top minerals';

  @override
  String get topVitamins => 'Top vitamins';

  @override
  String get tapDetailsToSeeFullMineralsTable =>
      'Tap Details to see full minerals table and recommended daily amounts.';

  @override
  String get tapDetailsToSeeFullVitaminTable =>
      'Tap Details to see full vitamin table and recommended daily amounts.';

  @override
  String get tapDetailsToSeeFullAminoAcidTable =>
      'Tap Details to see full amino acid table and recommended amounts.';

  @override
  String get cookingRecipes => 'Cooking Recipes';

  @override
  String get exploreVietnameseDishes => 'Explore Vietnamese dishes';

  @override
  String get viewAll => 'View all';

  @override
  String get drinkRecipes => 'Drink Recipes';

  @override
  String get customizeVolume => 'Self-made, customizable volume';

  @override
  String get exploreNow => 'Explore now';

  @override
  String get discover => 'Discover';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get activityFactor => 'Activity Factor (e.g. 1.2)';

  @override
  String get dietType => 'Diet Type';

  @override
  String get allergies => 'Allergies (select):';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get noResponseFromServer => 'No response from server';

  @override
  String get recordWaterIntake => 'Record Water Intake';

  @override
  String get selectDrinkToRecord => 'Select a drink to record';

  @override
  String get noDrinkRecipesYet => 'No drink recipes yet';

  @override
  String get pleaseSelectDrinkToContinue =>
      'Please select a drink to continue.';

  @override
  String get reset => 'Reset';

  @override
  String get logout => 'Logout';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get recommendedNutritionalNeeds => 'Recommended Nutritional Needs';

  @override
  String get security => 'Security';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get user => 'User';

  @override
  String get invalidData => 'Invalid data';

  @override
  String get dishDetail => 'Dish Detail';

  @override
  String get dishNotFound => 'Dish not found';

  @override
  String get createDish => 'Create Dish';

  @override
  String get pleaseEnterDishName => 'Please enter dish name';

  @override
  String get dishCreatedSuccessfully => 'Dish created successfully!';

  @override
  String get continueTreatment => 'Continue Treatment';

  @override
  String get recovered => 'Recovered';

  @override
  String confirmContinueTreatment(String conditionName) {
    return 'Do you want to continue treatment for \"$conditionName\"?';
  }

  @override
  String get treatmentExtended => 'Treatment extended';

  @override
  String confirmRecovered(String conditionName) {
    return 'Have you recovered from \"$conditionName\"?';
  }

  @override
  String get congratulationsRecovered => 'Congratulations on your recovery! 🎉';

  @override
  String get cannotIdentifyConversation => 'Cannot identify this conversation';

  @override
  String get noMessagesInConversation => 'No messages in this conversation';

  @override
  String errorLoadingNotifications(String error) {
    return 'Error loading notifications: $error';
  }

  @override
  String get allMarkedAsRead => 'All marked as read';

  @override
  String cannotTakePhoto(String error) {
    return 'Cannot take photo: $error';
  }

  @override
  String cannotSelectImage(String error) {
    return 'Cannot select image: $error';
  }

  @override
  String get cannotRecognizeFood =>
      'Cannot recognize food in image. Please try again with a clearer food image.';

  @override
  String errorConnectingToAI(String error) {
    return 'Error connecting to AI: $error';
  }

  @override
  String savedNutritionInfo(String foodName) {
    return '✓ Saved nutrition info for $foodName';
  }

  @override
  String errorSavingData(String error) {
    return 'Error saving data: $error';
  }

  @override
  String get cannotLoadFoodInfo => 'Cannot load food information';

  @override
  String get pleaseSelectFoodOrDish => 'Please select food or dish';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get addedToMealSuccessfully => 'Added to meal successfully';

  @override
  String errorLoadingDiseaseList(String error) {
    return 'Error loading disease list: $error';
  }

  @override
  String alreadyHaveDisease(String diseaseName) {
    return 'You already have \"$diseaseName\", cannot add again';
  }

  @override
  String get pleaseSelectStartDate => 'Please select treatment start date';

  @override
  String get pleaseSelectAtLeastOneMedicationTime =>
      'Please select at least one medication time';

  @override
  String diseaseAdded(String diseaseName) {
    return 'Added \"$diseaseName\"';
  }

  @override
  String get notDetermined => 'Not determined';

  @override
  String get noMeasurements => 'No measurements';

  @override
  String get increaseResistance => 'Increase resistance';

  @override
  String get strongBones => 'Strong bones';

  @override
  String get goodDigestion => 'Good digestion';

  @override
  String get cardiovascularHealth => 'Cardiovascular health';

  @override
  String get noMealData => 'No meal data';

  @override
  String get searchDish => 'Search dish (e.g.: Pho, Rice)...';

  @override
  String get searchIngredient =>
      'Search ingredient (e.g.: Beef, Vegetables)...';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get featureComingSoon => 'Feature coming soon!';

  @override
  String get dish => 'Dish';

  @override
  String unreadCount(String count) {
    return '$count unread';
  }

  @override
  String get notificationDetail => 'Notification Detail';

  @override
  String get selectHealthCondition => 'Select Health Condition';

  @override
  String get normal => 'Normal';

  @override
  String get underweight => 'Underweight';

  @override
  String get overweight => 'Overweight';

  @override
  String get obese => 'Obese';

  @override
  String get severelyUnderweight => 'Severely Underweight';

  @override
  String get slightlyOverweight => 'Slightly Overweight';

  @override
  String get perfect => 'Perfect';

  @override
  String get good => 'Good';

  @override
  String get needAttention => 'Need Attention';

  @override
  String get needImprovement => 'Need Improvement';

  @override
  String foodRestrictedByHealthCondition(String foodName) {
    return '$foodName cannot be added due to your health condition';
  }

  @override
  String get deleteDish => 'Delete Dish';

  @override
  String confirmDeleteDish(String dishName) {
    return 'Are you sure you want to delete \"$dishName\"?';
  }

  @override
  String dishDeleted(String dishName) {
    return 'Deleted \"$dishName\"';
  }

  @override
  String cannotDeleteDish(String errorMsg) {
    return 'Cannot delete dish ($errorMsg)';
  }

  @override
  String get weightG => 'Weight (g)';

  @override
  String get notes => 'Notes';

  @override
  String get close => 'Close';

  @override
  String get enterFoodName => 'Enter food name...';

  @override
  String get enterKeywordToSearch => 'Enter keyword to search for food';

  @override
  String get nameEnglish => 'Name (English)';

  @override
  String get nameVietnamese => 'Vietnamese Name';

  @override
  String get category => 'Category';

  @override
  String get baseLiquidNotes => 'Base liquid / notes';

  @override
  String get defaultVolumeMl => 'Default volume (ml)';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get noIngredients => 'No ingredients';

  @override
  String get searchAndAddIngredientsBelow => 'Search and add ingredients below';

  @override
  String get yourHealthCondition => 'Your Health Condition';

  @override
  String get inTreatment => 'In Treatment';

  @override
  String get completed => 'Completed';

  @override
  String get medicationSchedule => 'Medication Schedule';

  @override
  String todayDate(String day, String month, String year) {
    return 'Today, $day/$month/$year';
  }

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get medication => 'Medication';

  @override
  String get nextAppointment => 'Next Appointment';

  @override
  String get past => 'Past';

  @override
  String daysLeft(String days) {
    return '$days days left';
  }

  @override
  String get selectNewEndDate => 'Select new end date';

  @override
  String get addNewAppointment => 'Add New Appointment';

  @override
  String get title => 'Title';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get required => 'Required';

  @override
  String get invalidAge => 'Invalid age';

  @override
  String get selectGender => 'Select gender';

  @override
  String get invalid => 'Invalid';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get currentlyHaveThisCondition => 'Currently have this condition';

  @override
  String get treatmentInfo => 'Treatment Info';

  @override
  String get treatmentStartDate => 'Treatment Start Date *';

  @override
  String get treatmentEndDateOptional => 'Treatment End Date (Optional)';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get confirmAdd => 'Confirm Add';

  @override
  String get nutritionalNotifications => 'Nutritional Notifications';

  @override
  String get markAllAsRead => 'Mark All as Read';

  @override
  String get refresh => 'Refresh';

  @override
  String get notification => 'Notification';

  @override
  String get todayProgress => 'Today Progress';

  @override
  String get current => 'Current';

  @override
  String get target => 'Target';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(String minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(String hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(String days) {
    return '$days days ago';
  }

  @override
  String get searchDisease => 'Search disease...';

  @override
  String get causes => 'Causes:';

  @override
  String get cannotAddDisease => 'Cannot add disease';

  @override
  String get notLoggedInNoToken => 'Not logged in - token not found';

  @override
  String get waterIntakeStatisticsByHour => 'Water intake statistics by hour';

  @override
  String get noWaterIntakeRecordedForToday =>
      'No water intake recorded for today.';

  @override
  String get noDataForToday => 'No data for today';

  @override
  String get pleaseRecordYourMealsToSeeDetailedStatistics =>
      'Please record your meals to see detailed statistics.';

  @override
  String get noDetailedRecordsForToday => 'No detailed records for today.';

  @override
  String get noDataForThisDate => 'No data for this date';

  @override
  String get mealHistoryForToday => 'Meal history for today';

  @override
  String get topNutrients => 'Top nutrients';

  @override
  String get dishesEaten => 'Dishes eaten';

  @override
  String moreDishes(String count) {
    return '+$count more dishes';
  }

  @override
  String get timeUnknown => 'Time unknown';

  @override
  String get foodUnknown => 'Unknown food';

  @override
  String get viewOverview => 'View overview';

  @override
  String get viewDetailsByDate => 'View details by date';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get sunday => 'Sun';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String dishesToday(String count) {
    return '$count dishes today';
  }

  @override
  String get noMealRecorded => 'No meal recorded yet';

  @override
  String get breakfastShort => 'Breakfast';

  @override
  String get lunchShort => 'Lunch';

  @override
  String get snackShort => 'Snack';

  @override
  String get dinnerShort => 'Dinner';
}
