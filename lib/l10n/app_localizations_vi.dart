// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'My Diary';

  @override
  String get settings => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get notifications => 'Thông báo';

  @override
  String get noNotifications => 'Không có thông báo';

  @override
  String get at => 'lúc';

  @override
  String get suggestionLoadError => 'Lỗi tải gợi ý';

  @override
  String suggestionGenericError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get suggestionGenerateSuccess => 'Tạo gợi ý thành công!';

  @override
  String get suggestionGenerateError => 'Lỗi tạo gợi ý';

  @override
  String get suggestionAcceptSuccess => 'Đã chấp nhận gợi ý!';

  @override
  String get suggestionAcceptError => 'Lỗi chấp nhận gợi ý';

  @override
  String get suggestionSwapSuccess => 'Đã đổi gợi ý mới!';

  @override
  String get suggestionSwapError => 'Lỗi đổi gợi ý';

  @override
  String get suggestionGenerating => 'Đang tạo...';

  @override
  String get suggestionCreateNew => 'Tạo gợi ý mới';

  @override
  String get suggestionEmptyTitle => 'Chưa có gợi ý';

  @override
  String get suggestionEmptyMessage =>
      'Nhấn nút \"Tạo gợi ý mới\" để tạo gợi ý bữa ăn cho ngày này';

  @override
  String get suggestionEmptyAction => 'Tạo gợi ý';

  @override
  String suggestionCountLabel(int count) {
    return '$count món';
  }

  @override
  String get tomorrow => 'Ngày mai';

  @override
  String get swapSuggestion => 'Đổi gợi ý';

  @override
  String get processing => 'Đang xử lý...';

  @override
  String get accept => 'Chấp nhận';

  @override
  String get acceptedNote => 'Đã chấp nhận - Hãy thêm món này vào nhật ký!';

  @override
  String portionSize(String count) {
    return '$count phần';
  }

  @override
  String get mealLabel => 'Món ăn';

  @override
  String get drinkLabel => 'Đồ uống';

  @override
  String get chooseMealCountsTitle => 'Chọn số lượng món ăn';

  @override
  String get chooseMealCountsSubtitle =>
      'Chọn số lượng món ăn và đồ uống cho mỗi bữa (Tối đa 2 món/bữa)';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get mealField => 'Món ăn';

  @override
  String get drinkField => 'Đồ uống';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get pickFromGallery => 'Chọn từ thư viện';

  @override
  String get analyzingImage => 'Đang phân tích ảnh...';

  @override
  String get retakePhoto => 'Chụp lại';

  @override
  String get recognizeDish => 'Nhận diện món ăn';

  @override
  String saveDataError(String error) {
    return 'Lỗi lưu dữ liệu: $error';
  }

  @override
  String get defaultDishName => 'Món ăn';

  @override
  String accuracy(int percent) {
    return 'Độ chính xác: $percent%';
  }

  @override
  String get nutritionComposition => 'Thành phần dinh dưỡng';

  @override
  String get nutrient => 'Chất dinh dưỡng';

  @override
  String get amount => 'Lượng';

  @override
  String get reject => 'Từ chối';

  @override
  String get saving => 'Đang lưu...';

  @override
  String get medicationStats => 'Thống kê uống thuốc';

  @override
  String get days7 => '7 ngày';

  @override
  String get days14 => '14 ngày';

  @override
  String get days30 => '30 ngày';

  @override
  String get noData => 'Không có dữ liệu';

  @override
  String get totalDose => 'Tổng số liều';

  @override
  String get taken => 'Đã uống';

  @override
  String get onTime => 'Uống đúng giờ (±1 giờ)';

  @override
  String get late => 'Uống trễ';

  @override
  String get missed => 'Quên uống';

  @override
  String get adherence => 'Tuân thủ';

  @override
  String get onTimeShort => 'Đúng giờ';

  @override
  String loadNotificationsError(String error) {
    return 'Lỗi khi tải thông báo: $error';
  }

  @override
  String get noNotificationsShort => 'Không có thông báo';

  @override
  String errorSaveData(String error) {
    return 'Lỗi lưu dữ liệu: $error';
  }

  @override
  String get healthWarning => 'Cảnh báo sức khỏe';

  @override
  String notSuitableForHealth(String item) {
    return '$item không phù hợp với tình trạng sức khỏe của bạn. Bạn không nên ăn món này.';
  }

  @override
  String get dishContainsRestrictedFood =>
      'Món này chứa thực phẩm cần tránh theo tình trạng sức khỏe của bạn';

  @override
  String get usuallyEaten => 'Món ăn thường dùng';

  @override
  String nutrientForWeight(num weight) {
    return 'Dinh dưỡng cho ${weight}g';
  }

  @override
  String get minerals => 'Khoáng chất';

  @override
  String get other => 'Khác';

  @override
  String get drugInteractionWarning => 'Cảnh báo tương tác thuốc';

  @override
  String get recentlyTookDrug =>
      'Bạn vừa uống thuốc và thực phẩm này có thể tương tác:';

  @override
  String get drugNameFallback => 'Thuốc';

  @override
  String interactionWithNutrient(String nutrient) {
    return 'Có tương tác với $nutrient';
  }

  @override
  String nutrientName(String name) {
    return 'Chất dinh dưỡng: $name';
  }

  @override
  String get areYouSure => 'Bạn có chắc muốn tiếp tục?';

  @override
  String get continueAnyway => 'Vẫn tiếp tục';

  @override
  String get cancelAction => 'Hủy';

  @override
  String fieldTooLong(String field) {
    return '$field quá dài, đã cắt xuống giới hạn';
  }

  @override
  String fieldInvalidChars(String field) {
    return '$field chứa ký tự không hợp lệ';
  }

  @override
  String fieldInvalid(String field) {
    return '$field không hợp lệ';
  }

  @override
  String fieldMaxInteger(String field, int max) {
    return '$field tối đa $max chữ số phần nguyên';
  }

  @override
  String fieldMaxFraction(String field, int max) {
    return '$field tối đa $max chữ số thập phân';
  }

  @override
  String fieldMustBeNumber(Object field) {
    return '$field phải là số';
  }

  @override
  String fieldMinValue(String field, num min) {
    return '$field phải >= $min';
  }

  @override
  String fieldMaxValue(String field, num max) {
    return '$field phải <= $max';
  }

  @override
  String get editPersonalInfo => 'Chỉnh sửa thông tin cá nhân';

  @override
  String get basicInfo => 'Thông tin cơ bản';

  @override
  String get changeAvatar => 'Thay đổi ảnh đại diện';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get invalidEmail => 'Email không hợp lệ';

  @override
  String get ageLabel => 'Tuổi';

  @override
  String get ageMustBeNumber => 'Tuổi phải là số';

  @override
  String get ageRange => 'Tuổi: 5-120';

  @override
  String get genderLabel => 'Giới tính';

  @override
  String get female => 'Nữ';

  @override
  String get otherGender => 'Khác';

  @override
  String get heightLabel => 'Chiều cao (cm)';

  @override
  String get heightLabelShort => 'Chiều cao';

  @override
  String get weightLabel => 'Cân nặng (kg)';

  @override
  String get weightLabelShort => 'Cân nặng';

  @override
  String get lifestylePreferences => 'Lối sống & Sở thích';

  @override
  String get activityLevelLabel => 'Mức độ vận động';

  @override
  String get activitySedentary => 'Ít vận động';

  @override
  String get activityLight => 'Vận động nhẹ';

  @override
  String get activityModerate => 'Vừa phải';

  @override
  String get activityActive => 'Rất năng động';

  @override
  String get activityVeryActive => 'Cực kỳ năng động';

  @override
  String get dietTypeLabel => 'Kiểu ăn';

  @override
  String get dietMediterranean => 'Địa trung hải';

  @override
  String get dietCustom => 'Tự chọn';

  @override
  String get foodAllergy => 'Dị ứng thực phẩm';

  @override
  String get healthGoal => 'Mục tiêu sức khỏe';

  @override
  String get loseWeight => 'Giảm cân';

  @override
  String get maintainWeight => 'Duy trì cân nặng';

  @override
  String get gainWeight => 'Tăng cân';

  @override
  String get interface => 'Giao diện';

  @override
  String get interfaceMode => 'Chế độ giao diện';

  @override
  String get automatic => 'Tự động';

  @override
  String get light => 'Sáng';

  @override
  String get dark => 'Tối';

  @override
  String get seasonalInterface => 'Giao diện theo mùa';

  @override
  String get autoChangeByMonth => 'Tự động thay đổi theo tháng';

  @override
  String get seasonMode => 'Chế độ mùa';

  @override
  String get automaticByMonth => 'Tự động (theo tháng)';

  @override
  String get manual => 'Thủ công';

  @override
  String get off => 'Tắt';

  @override
  String get fallingLeaves => 'Hiệu ứng lá rụng';

  @override
  String get fallingLeavesEffect => 'Hiệu ứng lá rơi mùa thu';

  @override
  String get weather => 'Thời tiết';

  @override
  String get weatherCity => 'Thành phố thời tiết';

  @override
  String get windDirection => 'Hướng gió';

  @override
  String get windNorth => 'Bắc (N)';

  @override
  String get windNorthEast => 'Đông Bắc (NE)';

  @override
  String get windEast => 'Đông (E)';

  @override
  String get windSouthEast => 'Đông Nam (SE)';

  @override
  String get windSouth => 'Nam (S)';

  @override
  String get windSouthWest => 'Tây Nam (SW)';

  @override
  String get windWest => 'Tây (W)';

  @override
  String get windNorthWest => 'Tây Bắc (NW)';

  @override
  String weatherAngle(int degree) {
    return 'Góc: $degree°';
  }

  @override
  String get background => 'Nền';

  @override
  String get backgroundImage => 'Hình nền';

  @override
  String get enableBackgroundImage => 'Bật hình nền';

  @override
  String get backgroundImageUrl => 'URL hình nền';

  @override
  String get applyBackgroundImageSubtitle => 'Áp dụng URL ảnh nền bạn nhập';

  @override
  String get weatherCityHint => 'TP HCM, Cà Mau...';

  @override
  String get effectIntensity => 'Cường độ hiệu ứng';

  @override
  String get low => 'Thấp';

  @override
  String get medium => 'Trung bình';

  @override
  String get high => 'Cao';

  @override
  String get save => 'Lưu';

  @override
  String get home => 'Trang chủ';

  @override
  String get health => 'Sức khỏe';

  @override
  String get statistics => 'Thống kê';

  @override
  String get account => 'Tài khoản';

  @override
  String get dietaryFiber => 'Chất xơ';

  @override
  String get fat => 'Chất béo';

  @override
  String get totalFiber => 'Tổng chất xơ';

  @override
  String ofDailyGoal(String goal) {
    return 'của mục tiêu hàng ngày $goal';
  }

  @override
  String get done => 'Hoàn thành';

  @override
  String get goalNotSet => 'Chưa đặt mục tiêu';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Chất đạm';

  @override
  String get carbs => 'Đường';

  @override
  String get today => 'Hôm nay!';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get thisWeek => 'Tuần này';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get addMeal => 'Thêm bữa ăn';

  @override
  String get breakfast => 'Sáng';

  @override
  String get lunch => 'Trưa';

  @override
  String get dinner => 'Tối';

  @override
  String get snack => 'Xế';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get noResults => 'Không tìm thấy kết quả';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';

  @override
  String get retry => 'Thử lại';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get name => 'Tên';

  @override
  String get age => 'Tuổi';

  @override
  String get gender => 'Giới tính';

  @override
  String get male => 'Nam';

  @override
  String get weight => 'Cân nặng';

  @override
  String get height => 'Chiều cao';

  @override
  String activityLevel(String level) {
    return 'Mức độ: $level';
  }

  @override
  String get goal => 'Mục tiêu';

  @override
  String get vitamins => 'Vitamin';

  @override
  String get aminoAcids => 'Axit amin';

  @override
  String get fibers => 'Chất xơ';

  @override
  String get fats => 'Chất béo';

  @override
  String get information => 'Thông tin';

  @override
  String get code => 'Mã';

  @override
  String get group => 'Nhóm';

  @override
  String get unit => 'Đơn vị';

  @override
  String get rda => 'RDA';

  @override
  String get nutritionOverview => 'Tổng quan dinh dưỡng';

  @override
  String get personalRecommendation => 'Khuyến nghị cá nhân';

  @override
  String get benefits => 'Lợi ích';

  @override
  String get description => 'Mô tả:';

  @override
  String get foods => 'Thực phẩm';

  @override
  String get contraindications => 'Chống chỉ định';

  @override
  String get recommended => 'Khuyến nghị';

  @override
  String get consumed => 'Đã tiêu thụ';

  @override
  String get remaining => 'Còn lại';

  @override
  String get left => 'còn lại';

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
  String get customizeMealDistribution => 'Tùy chỉnh phân bổ bữa ăn';

  @override
  String get percentagesMustSumTo100 => 'Tổng phần trăm phải bằng 100';

  @override
  String get timeFormatMustBeHHmm =>
      'Định dạng thời gian phải là HH:mm (ví dụ: 07:00)';

  @override
  String get percentage => 'Phần trăm';

  @override
  String get timeUtc7 => 'Thời gian (UTC+7)';

  @override
  String get record => 'Ghi nhận';

  @override
  String get deleteDrink => 'Xóa đồ uống';

  @override
  String get confirmDeleteDrink =>
      'Bạn có chắc muốn xóa đồ uống này khỏi thư viện của bạn?';

  @override
  String get delete => 'Xóa';

  @override
  String get cannotDeleteDrink => 'Không thể xóa đồ uống';

  @override
  String get drinkDetail => 'Chi tiết nước uống';

  @override
  String get drinkNotFound => 'Không tìm thấy đồ uống';

  @override
  String get noIngredientInfo => 'Chưa có thông tin nguyên liệu';

  @override
  String get quickEntry => 'Nhập nhanh (ml hoặc L)';

  @override
  String get example250Or03L => 'Ví dụ: 250 hoặc 0.3L';

  @override
  String get pleaseEnterValidWaterAmount => 'Vui lòng nhập lượng nước hợp lệ';

  @override
  String get recordButton => 'Ghi';

  @override
  String get settingsSaved => 'Cài đặt đã được lưu';

  @override
  String get enableWeatherUpdateFirst => 'Bật cập nhật thời tiết trước';

  @override
  String get drinkDeleted => 'Đã xóa đồ uống';

  @override
  String get addDrink => 'Thêm đồ uống';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get add => 'Thêm';

  @override
  String get nameCannotBeEmpty => 'Tên không được để trống';

  @override
  String get showToAllUsers => 'Hiển thị cho tất cả người dùng';

  @override
  String get noSugar => 'Không đường';

  @override
  String get selectIngredient => 'Chọn nguyên liệu';

  @override
  String get enterKeywordToSearchFood => 'Nhập từ khóa để tìm kiếm thực phẩm';

  @override
  String get createDrink => 'Tạo đồ uống';

  @override
  String get hydration => 'Hydration';

  @override
  String get noIngredientsYet => 'Chưa có nguyên liệu';

  @override
  String get saveDrink => 'Lưu đồ uống';

  @override
  String get manageDrinks => 'Quản lý đồ uống';

  @override
  String get confirmDeleteDrinkQuestion => 'Bạn có chắc muốn xóa đồ uống này?';

  @override
  String get deleteFailed => 'Xóa thất bại';

  @override
  String get manageFoods => 'Quản lý thực phẩm';

  @override
  String get addFood => 'Thêm thực phẩm';

  @override
  String get page => 'Trang';

  @override
  String get noNutritionInfo => 'Chưa có thông tin dinh dưỡng';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String confirmDeleteFood(String foodName) {
    return 'Bạn có chắc muốn xóa thực phẩm \"$foodName\"?';
  }

  @override
  String get foodDeletedSuccessfully => 'Xóa thực phẩm thành công';

  @override
  String get cannotConnectToServer => 'Không thể kết nối máy chủ';

  @override
  String errorLoadingList(String error) {
    return 'Lỗi tải danh sách: $error';
  }

  @override
  String get noDrinkRecipes => 'Chưa có công thức nước uống';

  @override
  String get pleaseSelectDrink => 'Hãy chọn một đồ uống để tiếp tục.';

  @override
  String get drinksNotFound => 'Không tìm thấy đồ uống';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Vui lòng thêm ít nhất một nguyên liệu';

  @override
  String get recipes => 'Công thức nấu ăn';

  @override
  String get mealTemplates => 'Mẫu bữa ăn';

  @override
  String get cannotLoadStatistics => 'Không thể tải thống kê';

  @override
  String get manageHealthConditions => 'Quản lý tình trạng sức khỏe';

  @override
  String get noDiseasesInSystem => 'Chưa có bệnh nào trong hệ thống';

  @override
  String get errorLoadingListColon => 'Lỗi khi tải danh sách';

  @override
  String get updateAccordingToWeather => 'Cập nhật theo thời tiết';

  @override
  String get changeInterfaceByCity => 'Thay đổi giao diện theo thành phố';

  @override
  String get weatherEffects => 'Hiệu ứng theo thời tiết';

  @override
  String get rainSnowFog => 'Mưa, tuyết, sương mù...';

  @override
  String get effectIntensityTitle => 'Cường độ hiệu ứng';

  @override
  String get windDirectionTitle => 'Hướng gió';

  @override
  String get useCustomBackgroundImage => 'Sử dụng ảnh nền tùy chỉnh';

  @override
  String get previewBackground => 'Xem trước ảnh nền';

  @override
  String get noImage => 'Không có ảnh';

  @override
  String get drinkCreated => 'Đồ uống đã được tạo';

  @override
  String get failed => 'Thất bại';

  @override
  String get ingredient => 'Nguyên Liệu';

  @override
  String get errorColon => 'Lỗi';

  @override
  String get addDisease => 'Thêm bệnh';

  @override
  String confirmDeleteDisease(String diseaseName) {
    return 'Bạn có chắc muốn xóa bệnh \"$diseaseName\"?';
  }

  @override
  String get diseaseDeletedSuccessfully => 'Đã xóa bệnh thành công';

  @override
  String get noAdjustments => 'Chưa có điều chỉnh';

  @override
  String get noAvoidList => 'Chưa có danh sách cần tránh';

  @override
  String get diseaseUpdatedSuccessfully => 'Đã cập nhật bệnh thành công';

  @override
  String get diseaseAddedSuccessfully => 'Đã thêm bệnh mới thành công';

  @override
  String get weatherUpdated => 'Đã cập nhật thời tiết';

  @override
  String get medicationMarked => 'Đã đánh dấu uống thuốc';

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get recipeDeleted => 'Đã xóa công thức';

  @override
  String get recipeDeleteError => 'Lỗi xóa công thức';

  @override
  String get recipeAddedToMeal => 'Đã thêm công thức vào bữa ăn';

  @override
  String get recipeAddToMealError => 'Lỗi thêm vào bữa ăn';

  @override
  String get recipeLoadError => 'Lỗi tải công thức';

  @override
  String get recipeLoadDetailError => 'Lỗi tải chi tiết';

  @override
  String get createFirstRecipe => 'Tạo công thức đầu tiên';

  @override
  String get addToMeal => 'Thêm vào bữa ăn';

  @override
  String get deleteRecipe => 'Xóa công thức';

  @override
  String get confirmDeleteRecipe => 'Bạn có chắc muốn xóa công thức này?';

  @override
  String get pleaseLoginToUseChat =>
      'Vui lòng đăng nhập để sử dụng tính năng chat';

  @override
  String errorLoadingMessages(String error) {
    return 'Lỗi tải tin nhắn: $error';
  }

  @override
  String get errorSendingMessage => 'Lỗi gửi tin nhắn';

  @override
  String get errorAnalyzingImage => 'Lỗi phân tích ảnh. Vui lòng thử lại.';

  @override
  String get errorSendingImage => 'Lỗi gửi ảnh';

  @override
  String get errorProcessing => 'Lỗi xử lý';

  @override
  String get bodyMeasurement => 'Đo lường cơ thể';

  @override
  String get mediterraneanDiet => 'Chế độ ăn Địa Trung Hải';

  @override
  String get mealsToday => 'Bữa ăn hôm nay';

  @override
  String get water => 'Nước';

  @override
  String get details => 'Chi tiết';

  @override
  String get customize => 'Tùy chỉnh';

  @override
  String hydrationPercent(String percent) {
    return 'Hydration $percent%';
  }

  @override
  String get vitaminC => 'Vitamin C';

  @override
  String get calcium => 'Canxi';

  @override
  String get fiber => 'Chất xơ';

  @override
  String get omega3 => 'Omega-3';

  @override
  String get cameraNutritionScanner => 'Máy quét dinh dưỡng bằng camera';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get failedToSave => 'Lưu thất bại';

  @override
  String get network => 'Mạng';

  @override
  String get aquaSmartBottle => 'Aqua SmartBottle';

  @override
  String get lastDrink => 'Lần uống cuối';

  @override
  String get noRecentDrink => 'Không có nước uống gần đây';

  @override
  String get bmi => 'BMI';

  @override
  String get lbs => 'lbs';

  @override
  String get eaten => 'Đã ăn';

  @override
  String get burned => 'Đã đốt';

  @override
  String get kcalLeft => 'Kcal còn lại';

  @override
  String get topMinerals => 'Khoáng chất hàng đầu';

  @override
  String get topVitamins => 'Vitamin hàng đầu';

  @override
  String get tapDetailsToSeeFullMineralsTable =>
      'Nhấn Chi tiết để xem bảng khoáng chất đầy đủ và lượng khuyến nghị hàng ngày.';

  @override
  String get tapDetailsToSeeFullVitaminTable =>
      'Nhấn Chi tiết để xem bảng vitamin đầy đủ và lượng khuyến nghị hàng ngày.';

  @override
  String get tapDetailsToSeeFullAminoAcidTable =>
      'Nhấn Chi tiết để xem bảng axit amin đầy đủ và lượng khuyến nghị.';

  @override
  String get cookingRecipes => 'Công Thức Nấu Ăn';

  @override
  String get exploreVietnameseDishes => 'Khám phá món ăn Việt Nam';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get drinkRecipes => 'Công Thức Nước Uống';

  @override
  String get customizeVolume => 'Tự pha chế, tùy chỉnh thể tích';

  @override
  String get exploreNow => 'Khám phá ngay';

  @override
  String get discover => 'Khám phá';

  @override
  String get heightCm => 'Chiều cao (cm)';

  @override
  String get weightKg => 'Cân nặng (kg)';

  @override
  String get activityFactor => 'Hệ số vận động (ví dụ 1.2)';

  @override
  String get dietType => 'Kiểu ăn';

  @override
  String get allergies => 'Dị ứng (chọn):';

  @override
  String get profileUpdateSuccess => 'Cập nhật hồ sơ thành công';

  @override
  String get noResponseFromServer => 'Không nhận được phản hồi từ server';

  @override
  String get recordWaterIntake => 'Ghi nhận lượng nước';

  @override
  String get selectDrinkToRecord => 'Chọn đồ uống để ghi nhận';

  @override
  String get noDrinkRecipesYet => 'Chưa có công thức nước uống';

  @override
  String get pleaseSelectDrinkToContinue => 'Hãy chọn một đồ uống để tiếp tục.';

  @override
  String get reset => 'Đặt lại';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get personalInformation => 'Thông tin cá nhân';

  @override
  String get recommendedNutritionalNeeds => 'Nhu cầu dinh dưỡng khuyến nghị';

  @override
  String get security => 'Bảo mật';

  @override
  String get help => 'Trợ giúp';

  @override
  String get about => 'Giới thiệu';

  @override
  String get notLoggedIn => 'Chưa đăng nhập';

  @override
  String get user => 'Người dùng';

  @override
  String get invalidData => 'Dữ liệu không hợp lệ';

  @override
  String get dishDetail => 'Chi tiết món ăn';

  @override
  String get dishNotFound => 'Không tìm thấy món ăn';

  @override
  String get createDish => 'Tạo món ăn';

  @override
  String get pleaseEnterDishName => 'Vui lòng nhập tên món ăn';

  @override
  String get dishCreatedSuccessfully => 'Tạo món ăn thành công!';

  @override
  String get continueTreatment => 'Tiếp tục điều trị';

  @override
  String get recovered => 'Đã khỏi';

  @override
  String confirmContinueTreatment(String conditionName) {
    return 'Bạn muốn tiếp tục điều trị cho \"$conditionName\"?';
  }

  @override
  String get treatmentExtended => 'Đã gia hạn điều trị';

  @override
  String confirmRecovered(String conditionName) {
    return 'Bạn đã khỏi bệnh \"$conditionName\"?';
  }

  @override
  String get congratulationsRecovered => 'Chúc mừng bạn đã khỏi bệnh! 🎉';

  @override
  String get cannotIdentifyConversation =>
      'Không xác định được cuộc hội thoại này';

  @override
  String get noMessagesInConversation =>
      'Chưa có tin nhắn nào trong hội thoại này';

  @override
  String errorLoadingNotifications(String error) {
    return 'Lỗi khi tải thông báo: $error';
  }

  @override
  String get allMarkedAsRead => 'Đã đánh dấu tất cả đã đọc';

  @override
  String cannotTakePhoto(String error) {
    return 'Không thể chụp ảnh: $error';
  }

  @override
  String cannotSelectImage(String error) {
    return 'Không thể chọn ảnh: $error';
  }

  @override
  String get cannotRecognizeFood =>
      'Không nhận diện được thực phẩm trong ảnh. Vui lòng thử lại với ảnh món ăn rõ ràng hơn.';

  @override
  String errorConnectingToAI(String error) {
    return 'Lỗi kết nối đến AI: $error';
  }

  @override
  String savedNutritionInfo(String foodName) {
    return '✓ Đã lưu thông tin dinh dưỡng của $foodName';
  }

  @override
  String errorSavingData(String error) {
    return 'Lỗi lưu dữ liệu: $error';
  }

  @override
  String get cannotLoadFoodInfo => 'Không thể tải thông tin thực phẩm';

  @override
  String get pleaseSelectFoodOrDish => 'Vui lòng chọn thực phẩm hoặc món ăn';

  @override
  String get pleaseEnterValidAmount => 'Vui lòng nhập khối lượng hợp lệ';

  @override
  String get addedToMealSuccessfully => 'Đã thêm vào bữa ăn thành công';

  @override
  String errorLoadingDiseaseList(String error) {
    return 'Lỗi khi tải danh sách bệnh: $error';
  }

  @override
  String alreadyHaveDisease(String diseaseName) {
    return 'Bạn đang mắc bệnh \"$diseaseName\" rồi, không thể thêm lại';
  }

  @override
  String get pleaseSelectStartDate => 'Vui lòng chọn ngày bắt đầu điều trị';

  @override
  String get pleaseSelectAtLeastOneMedicationTime =>
      'Vui lòng chọn ít nhất một giờ uống thuốc';

  @override
  String diseaseAdded(String diseaseName) {
    return 'Đã thêm \"$diseaseName\"';
  }

  @override
  String get notDetermined => 'Chưa xác định';

  @override
  String get noMeasurements => 'Chưa có số đo';

  @override
  String get increaseResistance => 'Tăng sức đề kháng';

  @override
  String get strongBones => 'Xương chắc khỏe';

  @override
  String get goodDigestion => 'Tiêu hóa tốt';

  @override
  String get cardiovascularHealth => 'Sức khỏe tim mạch';

  @override
  String get noMealData => 'Chưa có dữ liệu bữa ăn';

  @override
  String get searchDish => 'Tìm món ăn (vd: Phở, Cơm)...';

  @override
  String get searchIngredient => 'Tìm nguyên liệu (vd: Thịt bò, Rau)...';

  @override
  String get quickAdd => 'Thêm nhanh';

  @override
  String get featureComingSoon => 'Tính năng sẽ được cập nhật sớm!';

  @override
  String get dish => 'Món Ăn';

  @override
  String unreadCount(String count) {
    return '$count chưa đọc';
  }

  @override
  String get notificationDetail => 'Chi tiết thông báo';

  @override
  String get selectHealthCondition => 'Chọn tình trạng sức khỏe';

  @override
  String get normal => 'Bình thường';

  @override
  String get underweight => 'Gầy';

  @override
  String get overweight => 'Thừa cân';

  @override
  String get obese => 'Béo phì';

  @override
  String get severelyUnderweight => 'Thiếu cân nặng';

  @override
  String get slightlyOverweight => 'Hơi thừa';

  @override
  String get perfect => 'Hoàn hảo';

  @override
  String get good => 'Tốt';

  @override
  String get needAttention => 'Cần chú ý';

  @override
  String get needImprovement => 'Cần cải thiện';

  @override
  String foodRestrictedByHealthCondition(String foodName) {
    return '$foodName không được thêm do tình trạng sức khỏe';
  }

  @override
  String get deleteDish => 'Xóa món ăn';

  @override
  String confirmDeleteDish(String dishName) {
    return 'Bạn có chắc muốn xóa \"$dishName\"?';
  }

  @override
  String dishDeleted(String dishName) {
    return 'Đã xóa \"$dishName\"';
  }

  @override
  String cannotDeleteDish(String errorMsg) {
    return 'Không thể xóa món ăn ($errorMsg)';
  }

  @override
  String get weightG => 'Khối lượng (g)';

  @override
  String get notes => 'Ghi chú';

  @override
  String get close => 'Đóng';

  @override
  String get enterFoodName => 'Nhập tên thực phẩm...';

  @override
  String get enterKeywordToSearch => 'Nhập từ khóa để tìm kiếm thực phẩm';

  @override
  String get nameEnglish => 'Tên (English)';

  @override
  String get nameVietnamese => 'Tên tiếng Việt';

  @override
  String get category => 'Danh mục';

  @override
  String get baseLiquidNotes => 'Base liquid / ghi chú';

  @override
  String get defaultVolumeMl => 'Thể tích mặc định (ml)';

  @override
  String get ingredients => 'Nguyên liệu';

  @override
  String get noIngredients => 'Chưa có nguyên liệu nào';

  @override
  String get searchAndAddIngredientsBelow =>
      'Tìm kiếm và thêm nguyên liệu bên dưới';

  @override
  String get yourHealthCondition => 'Tình trạng sức khỏe của bạn';

  @override
  String get inTreatment => 'Đang điều trị';

  @override
  String get completed => 'Hoàn thành';

  @override
  String get medicationSchedule => 'Lịch uống thuốc';

  @override
  String todayDate(String day, String month, String year) {
    return 'Hôm nay, $day/$month/$year';
  }

  @override
  String get morning => 'Buổi sáng';

  @override
  String get afternoon => 'Buổi trưa';

  @override
  String get evening => 'Buổi tối';

  @override
  String get medication => 'Thuốc';

  @override
  String get nextAppointment => 'Ngày tới khám';

  @override
  String get past => 'Đã qua';

  @override
  String daysLeft(String days) {
    return '$days ngày nữa';
  }

  @override
  String get selectNewEndDate => 'Chọn ngày kết thúc mới';

  @override
  String get addNewAppointment => 'Thêm lịch hẹn mới';

  @override
  String get title => 'Tiêu đề';

  @override
  String get start => 'Bắt đầu';

  @override
  String get end => 'Kết thúc';

  @override
  String get passwordMismatch => 'Mật khẩu không khớp';

  @override
  String get registrationFailed => 'Đăng ký thất bại';

  @override
  String get required => 'Bắt buộc';

  @override
  String get invalidAge => 'Tuổi không hợp lệ';

  @override
  String get selectGender => 'Chọn giới tính';

  @override
  String get invalid => 'Không hợp lệ';

  @override
  String get passwordMinLength => 'Mật khẩu >= 6 ký tự';

  @override
  String get currentlyHaveThisCondition => 'Đang mắc bệnh này';

  @override
  String get treatmentInfo => 'Thông tin điều trị';

  @override
  String get treatmentStartDate => 'Ngày bắt đầu điều trị *';

  @override
  String get treatmentEndDateOptional => 'Ngày kết thúc điều trị (Tùy chọn)';

  @override
  String get selectDate => 'Chọn ngày';

  @override
  String get selectTime => 'Chọn giờ';

  @override
  String get confirmAdd => 'Xác nhận thêm';

  @override
  String get nutritionalNotifications => 'Thông báo dinh dưỡng';

  @override
  String get markAllAsRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get refresh => 'Làm mới';

  @override
  String get notification => 'Thông báo';

  @override
  String get todayProgress => 'Tiến độ hôm nay';

  @override
  String get current => 'Hiện tại';

  @override
  String get target => 'Mục tiêu';

  @override
  String get justNow => 'Vừa xong';

  @override
  String minutesAgo(String minutes) {
    return '$minutes phút trước';
  }

  @override
  String hoursAgo(String hours) {
    return '$hours giờ trước';
  }

  @override
  String daysAgo(String days) {
    return '$days ngày trước';
  }

  @override
  String get searchDisease => 'Tìm kiếm bệnh...';

  @override
  String get causes => 'Nguyên nhân:';

  @override
  String get cannotAddDisease => 'Không thể thêm bệnh';

  @override
  String get notLoggedInNoToken => 'Chưa đăng nhập - không tìm thấy token';

  @override
  String get waterIntakeStatisticsByHour => 'Thống kê nước uống theo giờ';

  @override
  String get noWaterIntakeRecordedForToday =>
      'Chưa có nước uống được ghi nhận cho ngày này.';

  @override
  String get noDataForToday => 'Chưa có dữ liệu cho hôm nay';

  @override
  String get pleaseRecordYourMealsToSeeDetailedStatistics =>
      'Hãy ghi lại bữa ăn của bạn để xem thống kê chi tiết.';

  @override
  String get noDetailedRecordsForToday =>
      'Chưa có ghi nhận chi tiết cho ngày này.';

  @override
  String get noDataForThisDate => 'Chưa có dữ liệu cho ngày này';

  @override
  String get mealHistoryForToday => 'Lịch sử bữa ăn trong ngày';

  @override
  String get topNutrients => 'Chất dinh dưỡng nổi bật';

  @override
  String get dishesEaten => 'Các món đã ăn';

  @override
  String moreDishes(String count) {
    return '+$count món khác';
  }

  @override
  String get timeUnknown => 'Chưa rõ giờ';

  @override
  String get foodUnknown => 'Món ăn không rõ';

  @override
  String get viewOverview => 'Xem tổng quan';

  @override
  String get viewDetailsByDate => 'Xem chi tiết theo ngày';

  @override
  String get january => 'Tháng 1';

  @override
  String get february => 'Tháng 2';

  @override
  String get march => 'Tháng 3';

  @override
  String get april => 'Tháng 4';

  @override
  String get may => 'Tháng 5';

  @override
  String get june => 'Tháng 6';

  @override
  String get july => 'Tháng 7';

  @override
  String get august => 'Tháng 8';

  @override
  String get september => 'Tháng 9';

  @override
  String get october => 'Tháng 10';

  @override
  String get november => 'Tháng 11';

  @override
  String get december => 'Tháng 12';

  @override
  String get sunday => 'CN';

  @override
  String get monday => 'T2';

  @override
  String get tuesday => 'T3';

  @override
  String get wednesday => 'T4';

  @override
  String get thursday => 'T5';

  @override
  String get friday => 'T6';

  @override
  String get saturday => 'T7';

  @override
  String dishesToday(String count) {
    return '$count món hôm nay';
  }

  @override
  String get noMealRecorded => 'Chưa ghi nhận món ăn';

  @override
  String get breakfastShort => 'Sáng';

  @override
  String get lunchShort => 'Trưa';

  @override
  String get snackShort => 'Xế';

  @override
  String get dinnerShort => 'Tối';
}
