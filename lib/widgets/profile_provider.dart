import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNotifier extends ChangeNotifier {
  Map<String, dynamic>? _raw;

  double? get weightKg => _getDouble('weight_kg');
  double? get goalWeight => _getDouble('goal_weight');
  double? get heightCm => _getDouble('height_cm');
  double? get bmr => _getDouble('bmr');
  double? get tdee => _getDouble('tdee');
  double? get dailyCalorieTarget => _getDouble('daily_calorie_target');
  double? get dailyProteinTarget => _getDouble('daily_protein_target');
  double? get dailyFatTarget => _getDouble('daily_fat_target');
  double? get dailyCarbTarget => _getDouble('daily_carb_target');

  Map<String, dynamic>? get raw => _raw;

  double? _getDouble(String key) {
    if (_raw == null || !_raw!.containsKey(key)) return null;
    final v = _raw![key];
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Future<void> loadProfile() async {
    try {
      final u = await AuthService.me();
      if (u != null) {
        final nowUtc = DateTime.now().toUtc();
        final vietnamTime = nowUtc.add(const Duration(hours: 7));
        final today = vietnamTime.toIso8601String().split('T')[0];
        final prefs = await SharedPreferences.getInstance();
        final persistedDate = prefs.getString('mediterranean_last_date');

        // CHỈ reset SharedPreferences khi ngày THỰC SỰ thay đổi (sau 00:00 UTC+7)
        final isNewDay = persistedDate == null || persistedDate != today;
        if (isNewDay) {
          await prefs.remove('mediterranean_today_calories');
          await prefs.remove('mediterranean_today_protein');
          await prefs.remove('mediterranean_today_fat');
          await prefs.remove('mediterranean_today_carbs');
          await prefs.setString('mediterranean_last_date', today);
        }

        _raw = Map<String, dynamic>.from(u);

        // Lấy giá trị từ backend
        final backendCalories = _toIntSafe(u['today_calories']);
        final backendProtein = _toIntSafe(u['today_protein']);
        final backendFat = _toIntSafe(u['today_fat']);
        final backendCarbs = _toIntSafe(u['today_carbs']);
        final backendWater = _toIntSafe(u['today_water']);

        // Logic: Chỉ reset về 0 khi ngày THỰC SỰ thay đổi (sau 00:00 UTC+7)
        // Nếu vẫn trong cùng ngày, giữ giá trị hiện tại (từ backend hoặc SharedPreferences)
        
        if (isNewDay) {
          // Ngày mới: Dùng giá trị từ backend (có thể là 0 nếu backend đã reset)
          if (backendCalories != null) {
            _raw!['today_calories'] = backendCalories;
            if (backendCalories > 0) {
              await prefs.setInt('mediterranean_today_calories', backendCalories);
            }
          } else {
            _raw!['today_calories'] = 0;
          }

          if (backendProtein != null) {
            _raw!['today_protein'] = backendProtein;
            if (backendProtein > 0) {
              await prefs.setInt('mediterranean_today_protein', backendProtein);
            }
          } else {
            _raw!['today_protein'] = 0;
          }

          if (backendFat != null) {
            _raw!['today_fat'] = backendFat;
            if (backendFat > 0) {
              await prefs.setInt('mediterranean_today_fat', backendFat);
            }
          } else {
            _raw!['today_fat'] = 0;
          }

          if (backendCarbs != null) {
            _raw!['today_carbs'] = backendCarbs;
            if (backendCarbs > 0) {
              await prefs.setInt('mediterranean_today_carbs', backendCarbs);
            }
          } else {
            _raw!['today_carbs'] = 0;
          }

          // Nước: ngày mới thì dùng giá trị backend (thường = 0 nếu backend reset)
          if (backendWater != null) {
            _raw!['today_water'] = backendWater;
            _raw!['today_water_ml'] = backendWater;
          } else {
            _raw!['today_water'] = 0;
            _raw!['today_water_ml'] = 0;
          }
        } else {
          // Cùng ngày: Ưu tiên backend, nếu backend = 0 hoặc null thì dùng SharedPreferences
          if (backendCalories != null && backendCalories > 0) {
            // Backend có giá trị > 0: dùng backend
            _raw!['today_calories'] = backendCalories;
            await prefs.setInt('mediterranean_today_calories', backendCalories);
          } else {
            // Backend = 0 hoặc null: dùng SharedPreferences (giữ giá trị cũ)
            final persistedCalories = prefs.getInt('mediterranean_today_calories');
            _raw!['today_calories'] = persistedCalories ?? backendCalories ?? 0;
          }

          if (backendProtein != null && backendProtein > 0) {
            _raw!['today_protein'] = backendProtein;
            await prefs.setInt('mediterranean_today_protein', backendProtein);
          } else {
            final persistedProtein = prefs.getInt('mediterranean_today_protein');
            _raw!['today_protein'] = persistedProtein ?? backendProtein ?? 0;
          }

          if (backendFat != null && backendFat > 0) {
            _raw!['today_fat'] = backendFat;
            await prefs.setInt('mediterranean_today_fat', backendFat);
          } else {
            final persistedFat = prefs.getInt('mediterranean_today_fat');
            _raw!['today_fat'] = persistedFat ?? backendFat ?? 0;
          }

          if (backendCarbs != null && backendCarbs > 0) {
            _raw!['today_carbs'] = backendCarbs;
            await prefs.setInt('mediterranean_today_carbs', backendCarbs);
          } else {
            final persistedCarbs = prefs.getInt('mediterranean_today_carbs');
            _raw!['today_carbs'] = persistedCarbs ?? backendCarbs ?? 0;
          }

          // Nước: cùng ngày thì luôn ưu tiên backend nếu >0, nếu backend = 0/null thì giữ giá trị cũ (không tự reset)
          if (backendWater != null && backendWater > 0) {
            _raw!['today_water'] = backendWater;
            _raw!['today_water_ml'] = backendWater;
          } else if (_raw!.containsKey('today_water')) {
            final existing = _toIntSafe(_raw!['today_water']) ?? 0;
            _raw!['today_water'] = existing;
            _raw!['today_water_ml'] = existing;
          }
        }

        debugPrint(
          '[ProfileProvider] Loaded profile for user ID: ${u['user_id']}, email: ${u['email']}, '
          'today_calories: ${_raw!['today_calories']}, today_water: ${_raw!['today_water']}, '
          'today_water_ml: ${_raw!['today_water_ml']}, date: $today, isNewDay: $isNewDay',
        );
        notifyListeners();
      } else {
        debugPrint('[ProfileProvider] Failed to load profile - user is null');
      }
    } catch (e) {
      debugPrint('[ProfileProvider] Error loading profile: $e');
    }
  }

  /// Merge today's totals returned by meal creation into the provider state.
  void applyTodayTotals(Map<String, dynamic>? today) async {
    if (today == null) return;
    _raw ??= <String, dynamic>{};
    // expected keys: calories/protein/fat/carbs or today.*
    int? calories, protein, fat, carbs;

    if (today.containsKey('calories')) {
      calories = _toIntSafe(today['calories']);
      _raw!['today_calories'] = calories;
    }
    if (today.containsKey('protein')) {
      protein = _toIntSafe(today['protein']);
      _raw!['today_protein'] = protein;
    }
    if (today.containsKey('fat')) {
      fat = _toIntSafe(today['fat']);
      _raw!['today_fat'] = fat;
    }
    if (today.containsKey('carbs')) {
      carbs = _toIntSafe(today['carbs']);
      _raw!['today_carbs'] = carbs;
    }
    // also accept prefixed keys
    if (today.containsKey('today_calories')) {
      calories = _toIntSafe(today['today_calories']);
      _raw!['today_calories'] = calories;
    }
    if (today.containsKey('today_protein')) {
      protein = _toIntSafe(today['today_protein']);
      _raw!['today_protein'] = protein;
    }
    if (today.containsKey('today_fat')) {
      fat = _toIntSafe(today['today_fat']);
      _raw!['today_fat'] = fat;
    }
    if (today.containsKey('today_carbs')) {
      carbs = _toIntSafe(today['today_carbs']);
      _raw!['today_carbs'] = carbs;
    }

    // Persist Mediterranean diet data to SharedPreferences
    if (calories != null || protein != null || fat != null || carbs != null) {
      final prefs = await SharedPreferences.getInstance();
      if (calories != null)
        await prefs.setInt('mediterranean_today_calories', calories);
      if (protein != null)
        await prefs.setInt('mediterranean_today_protein', protein);
      if (fat != null) await prefs.setInt('mediterranean_today_fat', fat);
      if (carbs != null) await prefs.setInt('mediterranean_today_carbs', carbs);
    }

    // fiber: accept today's fiber totals returned by meal creation or other endpoints
    if (today.containsKey('total_fiber')) {
      _raw!['today_fiber'] = today['total_fiber'];
    }
    if (today.containsKey('today_fiber')) {
      _raw!['today_fiber'] = today['today_fiber'];
    }
    // fatty acids total (if returned)
    if (today.containsKey('total_fatty')) {
      _raw!['today_fatty'] = today['total_fatty'];
    }
    // support water key names - convert to number for consistency
    if (today.containsKey('today_water')) {
      final waterVal = today['today_water'];
      final parsed =
          waterVal is num ? waterVal.toDouble() : (double.tryParse(waterVal.toString()) ?? 0.0);
      _raw!['today_water'] = parsed;
      _raw!['today_water_ml'] = parsed; // keep legacy key in sync for WaterView
    }
    if (today.containsKey('total_water')) {
      final waterVal = today['total_water'];
      final parsed =
          waterVal is num ? waterVal.toDouble() : (double.tryParse(waterVal.toString()) ?? 0.0);
      _raw!['today_water'] = parsed;
      _raw!['today_water_ml'] = parsed;
    }
    if (today.containsKey('today_water_ml')) {
      final waterVal = today['today_water_ml'];
      final parsed =
          waterVal is num ? waterVal.toDouble() : (double.tryParse(waterVal.toString()) ?? 0.0);
      _raw!['today_water'] = parsed;
      _raw!['today_water_ml'] = parsed;
    }
    // accept last drink timestamp if provided (ISO string)
    if (today.containsKey('last_drink_at')) {
      _raw!['today_last_drink'] = today['last_drink_at'];
    }
    if (today.containsKey('today_last_drink')) {
      _raw!['today_last_drink'] = today['today_last_drink'];
    }
    if (today.containsKey('last_drink')) {
      _raw!['today_last_drink'] = today['last_drink'];
    }
    notifyListeners();
  }

  int? _toIntSafe(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  void updateFromMap(Map<String, dynamic>? m) {
    if (m == null) return;
    _raw = Map<String, dynamic>.from(m);
    notifyListeners();
  }

  /// Set last drink timestamp (ISO string) returned from server.
  void setTodayLastDrink(String? iso) {
    if (iso == null) return;
    _raw ??= <String, dynamic>{};
    _raw!['today_last_drink'] = iso;
    notifyListeners();
  }

  /// Clear all profile data and persistent storage (for logout/user switch)
  Future<void> clearProfile() async {
    _raw = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mediterranean_today_calories');
    await prefs.remove('mediterranean_today_protein');
    await prefs.remove('mediterranean_today_fat');
    await prefs.remove('mediterranean_today_carbs');
    await prefs.remove('mediterranean_last_date');
    debugPrint('[ProfileProvider] Cleared all profile data');
    notifyListeners();
  }
}

class ProfileProvider extends StatefulWidget {
  final Widget child;

  const ProfileProvider({super.key, required this.child});

  @override
  State<ProfileProvider> createState() => _ProfileProviderState();
}

class _ProfileProviderState extends State<ProfileProvider> {
  final ProfileNotifier notifier = ProfileNotifier();

  @override
  void initState() {
    super.initState();
    // eager load profile once
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await notifier.loadProfile();
    });
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProfile(notifier: notifier, child: widget.child);
  }
}

class _InheritedProfile extends InheritedNotifier<ProfileNotifier> {
  const _InheritedProfile({
    required ProfileNotifier super.notifier,
    required super.child,
  });
}

extension ProfileOf on BuildContext {
  ProfileNotifier profile() {
    final inh = dependOnInheritedWidgetOfExactType<_InheritedProfile>();
    return inh!.notifier as ProfileNotifier;
  }

  ProfileNotifier? maybeProfile() {
    final inh = dependOnInheritedWidgetOfExactType<_InheritedProfile>();
    return inh?.notifier;
  }
}
