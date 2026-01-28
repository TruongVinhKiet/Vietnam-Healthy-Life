// ignore_for_file: deprecated_member_use, prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_diary/services/social_service.dart';
import 'package:my_diary/fitness_app_theme.dart';

// Note: numeric & decimal input formatters are provided below. Daily numeric targets are system-calculated and not user-editable.

// Decimal formatter: allow one decimal point, limit integer and fraction lengths.
class DecimalLimitFormatter extends TextInputFormatter {
  final int maxInteger;
  final int maxFraction;
  final void Function()? onTruncate;

  DecimalLimitFormatter({
    this.maxInteger = 8,
    this.maxFraction = 2,
    this.onTruncate,
  }) : assert(maxInteger > 0),
       assert(maxFraction >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var txt = newValue.text;
    // remove invalid characters (allow digits and dot)
    txt = txt.replaceAll(RegExp(r'[^0-9\.]'), '');
    // if more than one dot, keep only the first
    final parts = txt.split('.');
    if (parts.length > 2) {
      txt = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    final idx = txt.indexOf('.');
    String intPart = idx >= 0 ? txt.substring(0, idx) : txt;
    String fracPart = idx >= 0 ? txt.substring(idx + 1) : '';

    var truncated = false;
    if (intPart.length > maxInteger) {
      intPart = intPart.substring(0, maxInteger);
      truncated = true;
    }
    if (fracPart.length > maxFraction) {
      fracPart = fracPart.substring(0, maxFraction);
      truncated = true;
    }

    final result = fracPart.isNotEmpty ? '$intPart.$fracPart' : intPart;
    if (truncated && onTruncate != null) {
      try {
        onTruncate!.call();
      } catch (_) {}
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class PersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const PersonalInfoScreen({super.key, required this.user});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late Map<String, dynamic> _user;
  bool _loading = false;
  // previews removed: server will compute BMR/TDEE on save

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _genderValue;
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();
  // extended fields
  final _activityLevelCtrl = TextEditingController();
  final _dietTypeCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _healthGoalsCtrl = TextEditingController();
  final _goalTypeCtrl = TextEditingController();
  final _goalWeightCtrl = TextEditingController();
  final _activityFactorCtrl = TextEditingController();
  final _bmrCtrl = TextEditingController();
  final _tdeeCtrl = TextEditingController();
  final _dailyCalorieCtrl = TextEditingController();
  final _dailyProteinCtrl = TextEditingController();
  final _dailyFatCtrl = TextEditingController();
  final _dailyCarbCtrl = TextEditingController();
  final _dailyWaterCtrl = TextEditingController();
  // Controls for macro-percentages and calorie multiplier (percent values, e.g. 25 for 25%)
  final _calorieMultiplierCtrl = TextEditingController();
  final _proteinPctCtrl = TextEditingController();
  final _fatPctCtrl = TextEditingController();
  final _carbPctCtrl = TextEditingController();

  // Avatar
  String? _avatarUrl;
  Uint8List? _avatarBytes;
  String? _avatarMimeType;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.user ?? {});
    _fillControllers();
    // format height/weight on focus loss for better UX
    _heightFocus.addListener(() {
      if (!_heightFocus.hasFocus) {
        _heightCtrl.text = _formatTwoDecimals(_heightCtrl.text);
      }
    });
    _weightFocus.addListener(() {
      if (!_weightFocus.hasFocus) {
        _weightCtrl.text = _formatTwoDecimals(_weightCtrl.text);
      }
    });
    // no client-side BMR/TDEE preview: server will compute on save
  }

  // Listen to global profile provider so this screen updates when /me is reloaded
  ProfileNotifier? _prov;
  void _onProfileChanged() {
    try {
      final raw = _prov?.raw;
      if (raw != null && mounted) {
        setState(() {
          _user = Map<String, dynamic>.from(raw);
          _fillControllers();
        });
      }
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final prov = context.maybeProfile();
      if (prov != _prov) {
        // detach old
        try {
          _prov?.removeListener(_onProfileChanged);
        } catch (_) {}
        _prov = prov;
        _prov?.addListener(_onProfileChanged);
        // ensure latest profile is loaded from server
        _prov?.loadProfile();
      }
    } catch (_) {}
  }

  void _onTruncateDetected(String fieldLabel) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.fieldTooLong(fieldLabel))));
  }

  String? _decimalValidator(
    String? v,
    String fieldName, {
    int maxInteger = 8,
    int maxFraction = 2,
    double? min,
    double? max,
  }) {
    if (v == null || v.trim().isEmpty) return null;
    final s = v.trim();
    // must be a valid number with optional single dot
    if (RegExp(r'[^0-9.]').hasMatch(s)) {
      return AppLocalizations.of(context)!.fieldInvalidChars(fieldName);
    }
    if ('.'.allMatches(s).length > 1) {
      return AppLocalizations.of(context)!.fieldInvalid(fieldName);
    }
    final parts = s.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : '';
    if (intPart.length > maxInteger) {
      return AppLocalizations.of(
        context,
      )!.fieldMaxInteger(fieldName, maxInteger);
    }
    if (fracPart.length > maxFraction) {
      return AppLocalizations.of(
        context,
      )!.fieldMaxFraction(fieldName, maxFraction);
    }
    final val = double.tryParse(s.replaceAll(',', '.'));
    if (val == null) {
      return AppLocalizations.of(context)!.fieldMustBeNumber(fieldName);
    }
    if (min != null && val < min) {
      return AppLocalizations.of(context)!.fieldMinValue(fieldName, min);
    }
    if (max != null && val > max) {
      return AppLocalizations.of(context)!.fieldMaxValue(fieldName, max);
    }
    return null;
  }

  // Client-side BMR/TDEE preview removed - rely on server computation after save.

  // Normalize user-facing free-text into standardized Vietnamese labels
  String _normalizeActivityLevel(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return '';
    // common Vietnamese variants
    if (s.contains('ít') ||
        s.contains('không vận') ||
        s.contains('sedentary')) {
      return 'Ít vận động';
    }
    if (s.contains('vận động nhẹ') ||
        s.contains('vận động ít') ||
        s.contains('light')) {
      return 'Vận động nhẹ';
    }
    if (s.contains('vừa') || s.contains('vừa phải') || s.contains('moderate')) {
      return 'Vừa phải';
    }
    if (s.contains('rất năng động') ||
        s.contains('năng động') ||
        s.contains('active')) {
      return 'Rất năng động';
    }
    if (s.contains('cực') || s.contains('extra') || s.contains('very')) {
      return 'Cực kỳ năng động';
    }
    // if user entered a numeric factor, return as-is
    final numVal = double.tryParse(s.replaceAll(',', '.'));
    if (numVal != null && numVal > 0) return numVal.toString();
    // default
    return s;
  }

  String? _resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${AuthService.baseUrl}$url';
  }

  String _normalizeDietType(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return '';
    // map to Vietnamese canonical diet labels
    if (s.contains('địa trung hải') || s.contains('mediterranean')) {
      return 'Địa Trung Hải';
    }
    if (s.contains('kiêng') ||
        s.contains('no-carb') ||
        s.contains('low carb')) {
      return 'Ít tinh bột';
    }
    if (s.contains('veget') || s.contains('chay')) return 'Chay';
    if (s.contains('keto')) return 'Keto';
    return s; // fallback: send normalized raw string
  }

  String _formatTwoDecimals(String raw) {
    if (raw.trim().isEmpty) return '';
    final n = double.tryParse(raw.replaceAll(',', '.'));
    if (n == null) return raw;
    return n.toStringAsFixed(2);
  }

  void _fillControllers() {
    _avatarUrl = _user['avatar_url']?.toString();
    _avatarBytes = null;
    _avatarMimeType = null;
    _fullNameCtrl.text = _user['full_name']?.toString() ?? '';
    _emailCtrl.text = _user['email']?.toString() ?? '';
    _ageCtrl.text = _user['age']?.toString() ?? '';
    final g = _user['gender']?.toString();
    // normalize stored gender values to internal values: 'male'/'female'/'other'
    if (g == null || g.isEmpty) {
      _genderValue = null;
    } else if (g.toLowerCase().startsWith('m')) {
      _genderValue = 'male';
    } else if (g.toLowerCase().startsWith('f')) {
      _genderValue = 'female';
    } else {
      _genderValue = 'other';
    }
    final hVal = _user['height_cm']?.toString() ?? '';
    final wVal = _user['weight_kg']?.toString() ?? '';
    _heightCtrl.text = hVal.isNotEmpty ? _formatTwoDecimals(hVal) : '';
    _weightCtrl.text = wVal.isNotEmpty ? _formatTwoDecimals(wVal) : '';
    _activityLevelCtrl.text = _user['activity_level']?.toString() ?? '';
    _dietTypeCtrl.text = _user['diet_type']?.toString() ?? '';
    _allergiesCtrl.text = _user['allergies']?.toString() ?? '';
    _healthGoalsCtrl.text = _user['health_goals']?.toString() ?? '';
    _goalTypeCtrl.text = _user['goal_type']?.toString() ?? '';
    _goalWeightCtrl.text = _user['goal_weight']?.toString() ?? '';
    _activityFactorCtrl.text = _user['activity_factor']?.toString() ?? '';
    _bmrCtrl.text = _user['bmr']?.toString() ?? '';
    _tdeeCtrl.text = _user['tdee']?.toString() ?? '';
    _dailyCalorieCtrl.text = _user['daily_calorie_target']?.toString() ?? '';
    _dailyProteinCtrl.text = _user['daily_protein_target']?.toString() ?? '';
    _dailyFatCtrl.text = _user['daily_fat_target']?.toString() ?? '';
    _dailyCarbCtrl.text = _user['daily_carb_target']?.toString() ?? '';
    _dailyWaterCtrl.text = _user['daily_water_target']?.toString() ?? '';
    // load saved macro percentage and multiplier if available
    _calorieMultiplierCtrl.text = _user['calorie_multiplier']?.toString() ?? '';
    _proteinPctCtrl.text = _user['macro_protein_pct']?.toString() ?? '';
    _fatPctCtrl.text = _user['macro_fat_pct']?.toString() ?? '';
    _carbPctCtrl.text = _user['macro_carb_pct']?.toString() ?? '';

    // If server hasn't provided computed daily targets, compute them locally for display
    try {
      final hasDaily =
          (_dailyCalorieCtrl.text.isNotEmpty ||
          _dailyProteinCtrl.text.isNotEmpty ||
          _dailyFatCtrl.text.isNotEmpty ||
          _dailyCarbCtrl.text.isNotEmpty);
      if (!hasDaily) {
        // attempt to compute using available fields
        final double? bmr = double.tryParse(
          (_user['bmr']?.toString() ?? '').replaceAll(',', '.'),
        );
        double? tdee = double.tryParse(
          (_user['tdee']?.toString() ?? '').replaceAll(',', '.'),
        );
        final double? activityFactor = double.tryParse(
          (_user['activity_factor']?.toString() ?? '').replaceAll(',', '.'),
        );
        // If tdee missing, try compute from bmr and activityFactor
        if (tdee == null &&
            bmr != null &&
            (activityFactor != null && activityFactor > 0)) {
          tdee = double.parse((bmr * activityFactor).toStringAsFixed(2));
        }
        // If still missing, try compute BMR from user values
        double? finalBmr = bmr;
        if (finalBmr == null) {
          final weight = double.tryParse(
            (_user['weight_kg']?.toString() ?? '').replaceAll(',', '.'),
          );
          final height = double.tryParse(
            (_user['height_cm']?.toString() ?? '').replaceAll(',', '.'),
          );
          final age = int.tryParse((_user['age']?.toString() ?? ''));
          final gender = _user['gender']?.toString();
          final maybe = _computeBMR(weight, height, age, gender);
          if (maybe != null) finalBmr = double.parse(maybe.toStringAsFixed(2));
        }
        if (tdee == null && finalBmr != null) {
          final af =
              activityFactor ??
              double.tryParse(_activityFactorCtrl.text.replaceAll(',', '.')) ??
              1.2;
          tdee = double.parse((finalBmr * af).toStringAsFixed(2));
        }

        if (tdee != null) {
          // determine multiplier (use saved multiplier or default by goal)
          double multiplier =
              double.tryParse(
                (_user['calorie_multiplier']?.toString() ?? '').replaceAll(
                  ',',
                  '.',
                ),
              ) ??
              0.0;
          if (multiplier <= 0) {
            final healthGoal = _user['health_goals']?.toString() ?? '';
            if (healthGoal == 'Giảm') {
              multiplier = 0.85;
            } else if (healthGoal == 'Tăng') {
              multiplier = 1.15;
            } else {
              multiplier = 1.0;
            }
          }
          final calcDailyCal = double.parse(
            (tdee * multiplier).toStringAsFixed(0),
          );

          // determine macro percentages
          double pProtein =
              double.tryParse(
                (_user['macro_protein_pct']?.toString() ?? '').replaceAll(
                  ',',
                  '.',
                ),
              ) ??
              0.0;
          double pFat =
              double.tryParse(
                (_user['macro_fat_pct']?.toString() ?? '').replaceAll(',', '.'),
              ) ??
              0.0;
          double pCarb =
              double.tryParse(
                (_user['macro_carb_pct']?.toString() ?? '').replaceAll(
                  ',',
                  '.',
                ),
              ) ??
              0.0;
          if (pProtein + pFat + pCarb == 0) {
            // default splits depending on goal
            final healthGoal = _user['health_goals']?.toString() ?? '';
            if (healthGoal == 'Giảm') {
              pProtein = 30;
              pFat = 25;
              pCarb = 45;
            } else if (healthGoal == 'Tăng') {
              pProtein = 32.5;
              pFat = 25;
              pCarb = 42.5;
            } else {
              pProtein = 25;
              pFat = 25;
              pCarb = 50;
            }
          }

          final calcProteinG = double.parse(
            (calcDailyCal * (pProtein / 100.0) / 4.0).toStringAsFixed(0),
          );
          final calcFatG = double.parse(
            (calcDailyCal * (pFat / 100.0) / 9.0).toStringAsFixed(0),
          );
          final calcCarbG = double.parse(
            (calcDailyCal * (pCarb / 100.0) / 4.0).toStringAsFixed(0),
          );

          _dailyCalorieCtrl.text = calcDailyCal.toStringAsFixed(0);
          _dailyProteinCtrl.text = calcProteinG.toStringAsFixed(0);
          _dailyFatCtrl.text = calcFatG.toStringAsFixed(0);
          _dailyCarbCtrl.text = calcCarbG.toStringAsFixed(0);
        }
      }
    } catch (_) {}
  }

  /// Compute BMR using Mifflin-St Jeor formula. Returns null if insufficient data.
  double? _computeBMR(
    double? weightKg,
    double? heightCm,
    int? age,
    String? gender,
  ) {
    if (weightKg == null || heightCm == null || age == null || gender == null) {
      return null;
    }
    final w = weightKg;
    final h = heightCm;
    final a = age;
    double bmr;
    final g = gender.toString().toLowerCase();
    if (g.startsWith('m')) {
      bmr = 10.0 * w + 6.25 * h - 5.0 * a + 5.0;
    } else if (g.startsWith('f')) {
      bmr = 10.0 * w + 6.25 * h - 5.0 * a - 161.0;
    } else {
      // default to average of male/female
      final m = 10.0 * w + 6.25 * h - 5.0 * a + 5.0;
      final f = 10.0 * w + 6.25 * h - 5.0 * a - 161.0;
      bmr = (m + f) / 2.0;
    }
    return bmr;
  }

  @override
  void dispose() {
    try {
      _prov?.removeListener(_onProfileChanged);
    } catch (_) {}
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    // gender uses dropdown (_genderValue) - no controller to dispose
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    _activityLevelCtrl.dispose();
    _dietTypeCtrl.dispose();
    _allergiesCtrl.dispose();
    _healthGoalsCtrl.dispose();
    _goalTypeCtrl.dispose();
    _goalWeightCtrl.dispose();
    _activityFactorCtrl.dispose();
    _bmrCtrl.dispose();
    _tdeeCtrl.dispose();
    _dailyCalorieCtrl.dispose();
    _dailyProteinCtrl.dispose();
    _dailyFatCtrl.dispose();
    _dailyCarbCtrl.dispose();
    _calorieMultiplierCtrl.dispose();
    _proteinPctCtrl.dispose();
    _fatPctCtrl.dispose();
    _carbPctCtrl.dispose();
    super.dispose();
  }

  Widget _row(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
    );
  }

  Future<void> _openEditDialog() async {
    final formKey = GlobalKey<FormState>();
    // prepare dialog-local state so we can copy selections back to the main controllers on Save
    String activityLabelLocal = _activityLevelCtrl.text.trim();
    String? selectedDietLocal = _dietTypeCtrl.text.isNotEmpty
        ? _dietTypeCtrl.text
        : null;
    final selectedAllergiesLocal = <String>{};
    if (_allergiesCtrl.text.isNotEmpty) {
      for (final a
          in _allergiesCtrl.text
              .split(RegExp(r'[,;]'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)) {
        selectedAllergiesLocal.add(a);
      }
    }
    String? selectedHealthGoalLocal = _healthGoalsCtrl.text.isNotEmpty
        ? _healthGoalsCtrl.text
        : null;
    // dialog-local controller for goal weight so we can set it readonly when needed
    final goalWeightLocal = TextEditingController(text: _goalWeightCtrl.text);
    bool goalWeightReadOnlyLocal = (selectedHealthGoalLocal == 'Duy trì');
    // dialog-local multiplier and macro % controllers
    double calorieMultiplierLocal =
        double.tryParse(_calorieMultiplierCtrl.text.replaceAll(',', '.')) ??
        (selectedHealthGoalLocal == 'Tăng'
            ? 1.15
            : (selectedHealthGoalLocal == 'Giảm' ? 0.85 : 1.0));
    int proteinPctLocal =
        int.tryParse(_proteinPctCtrl.text) ??
        (selectedHealthGoalLocal == 'Giảm'
            ? 30
            : (selectedHealthGoalLocal == 'Tăng' ? 33 : 25));
    int fatPctLocal = int.tryParse(_fatPctCtrl.text) ?? 25;
    int carbPctLocal =
        int.tryParse(_carbPctCtrl.text) ??
        (selectedHealthGoalLocal == 'Giảm'
            ? 45
            : (selectedHealthGoalLocal == 'Tăng' ? 42 : 50));
    // step size for +/- controls (1 or 5)
    int macroStepLocal = 1;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 16,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.purple.shade600],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              l10n.editPersonalInfo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Basic Information
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return _buildEditSectionTitle(
                                l10n.basicInfo,
                                Icons.person_outline,
                                Colors.blue,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Center(
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage: _avatarBytes != null
                                              ? MemoryImage(_avatarBytes!)
                                              : (_resolveAvatarUrl(
                                                          _avatarUrl,
                                                        ) !=
                                                        null
                                                    ? NetworkImage(
                                                        _resolveAvatarUrl(
                                                          _avatarUrl,
                                                        )!,
                                                      )
                                                    : null),
                                          backgroundColor: Colors.grey[300],
                                          child:
                                              (_avatarBytes == null &&
                                                  (_avatarUrl == null ||
                                                      _avatarUrl!.isEmpty))
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                )
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: const Color(
                                              0xFF667EEA,
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: _pickAvatar,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _pickAvatar,
                                      child: Text(l10n.changeAvatar),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return _buildModernTextField(
                                controller: _fullNameCtrl,
                                label: l10n.fullName,
                                icon: Icons.badge_outlined,
                                color: Colors.blue,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return _buildModernTextField(
                                controller: _emailCtrl,
                                label: l10n.email,
                                icon: Icons.email_outlined,
                                color: Colors.blue,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return null;
                                  final simpleRe = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  );
                                  if (!simpleRe.hasMatch(v.trim())) {
                                    return l10n.invalidEmail;
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildModernTextField(
                                      controller: _ageCtrl,
                                      label: l10n.ageLabel,
                                      icon: Icons.cake_outlined,
                                      color: Colors.blue,
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return null;
                                        }
                                        final n = int.tryParse(v.trim());
                                        if (n == null)
                                          return l10n.ageMustBeNumber;
                                        if (n < 5 || n > 120)
                                          return l10n.ageRange;
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernDropdown(
                                      value: _genderValue,
                                      label: l10n.genderLabel,
                                      icon: Icons.wc,
                                      color: Colors.blue,
                                      items: [
                                        DropdownMenuItem(
                                          value: 'male',
                                          child: Flexible(
                                            child: Text(
                                              l10n.male,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'female',
                                          child: Flexible(
                                            child: Text(
                                              l10n.female,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'other',
                                          child: Flexible(
                                            child: Text(
                                              l10n.otherGender,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) => _genderValue = v,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildModernTextField(
                                      controller: _heightCtrl,
                                      focusNode: _heightFocus,
                                      label: l10n.heightLabel,
                                      icon: Icons.height,
                                      color: Colors.blue,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9\.]'),
                                        ),
                                        DecimalLimitFormatter(
                                          maxInteger: 8,
                                          maxFraction: 2,
                                          onTruncate: () => _onTruncateDetected(
                                            l10n.heightLabelShort,
                                          ),
                                        ),
                                      ],
                                      validator: (v) => _decimalValidator(
                                        v,
                                        l10n.heightLabelShort,
                                        maxInteger: 8,
                                        maxFraction: 2,
                                        min: 30,
                                        max: 300,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildModernTextField(
                                      controller: _weightCtrl,
                                      focusNode: _weightFocus,
                                      label: l10n.weightLabel,
                                      icon: Icons.monitor_weight_outlined,
                                      color: Colors.blue,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9\.]'),
                                        ),
                                        DecimalLimitFormatter(
                                          maxInteger: 8,
                                          maxFraction: 2,
                                          onTruncate: () => _onTruncateDetected(
                                            l10n.weightLabelShort,
                                          ),
                                        ),
                                      ],
                                      validator: (v) => _decimalValidator(
                                        v,
                                        l10n.weightLabelShort,
                                        maxInteger: 8,
                                        maxFraction: 2,
                                        min: 2,
                                        max: 500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Section 2: Lifestyle & Preferences
                          _buildEditSectionTitle(
                            'Lối sống & Sở thích',
                            Icons.directions_run,
                            Colors.teal,
                          ),
                          const SizedBox(height: 12),

                          // Use StatefulBuilder for interactive controls
                          StatefulBuilder(
                            builder: (dCtx, setDState) {
                              // Update readOnly state when health goal changes
                              if (selectedHealthGoalLocal == 'Duy trì') {
                                goalWeightReadOnlyLocal = true;
                                if (goalWeightLocal.text != _weightCtrl.text) {
                                  goalWeightLocal.text = _weightCtrl.text;
                                }
                              } else {
                                goalWeightReadOnlyLocal = false;
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildModernDropdownStateful(
                                    value:
                                        activityLabelLocal.isNotEmpty &&
                                            [
                                              'Ít vận động',
                                              'Vận động nhẹ',
                                              'Vừa phải',
                                              'Rất năng động',
                                              'Cực kỳ năng động',
                                            ].contains(activityLabelLocal)
                                        ? activityLabelLocal
                                        : null,
                                    label: 'Mức độ vận động',
                                    icon: Icons.directions_run,
                                    color: Colors.teal,
                                    items:
                                        [
                                              'Ít vận động',
                                              'Vận động nhẹ',
                                              'Vừa phải',
                                              'Rất năng động',
                                              'Cực kỳ năng động',
                                            ]
                                            .map(
                                              (d) => DropdownMenuItem(
                                                value: d,
                                                child: Text(d),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (v) => setDState(
                                      () => activityLabelLocal = v ?? '',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildModernDropdownStateful(
                                    value:
                                        selectedDietLocal != null &&
                                            [
                                              'Ăn chay',
                                              'Keto',
                                              'Clean',
                                              'Low-carb',
                                              'Địa trung hải',
                                              'Tự chọn',
                                            ].contains(selectedDietLocal)
                                        ? selectedDietLocal
                                        : null,
                                    label: 'Kiểu ăn',
                                    icon: Icons.restaurant_menu,
                                    color: Colors.teal,
                                    items:
                                        [
                                              'Ăn chay',
                                              'Keto',
                                              'Clean',
                                              'Low-carb',
                                              'Địa trung hải',
                                              'Tự chọn',
                                            ]
                                            .map(
                                              (d) => DropdownMenuItem(
                                                value: d,
                                                child: Text(d),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (v) =>
                                        setDState(() => selectedDietLocal = v),
                                  ),
                                  const SizedBox(height: 20),

                                  // Allergies section
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.shade100
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.teal.shade400,
                                                    Colors.teal.shade600,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.health_and_safety,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Dị ứng thực phẩm',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children:
                                              [
                                                'Sữa bò',
                                                'Trứng',
                                                'Đậu phộng',
                                                'Tôm',
                                                'Cua',
                                                'Sò',
                                                'Cá',
                                                'Lúa mì',
                                                'Đậu nành',
                                              ].map((a) {
                                                final sel =
                                                    selectedAllergiesLocal
                                                        .contains(a);
                                                return InkWell(
                                                  onTap: () => setDState(
                                                    () => sel
                                                        ? selectedAllergiesLocal
                                                              .remove(a)
                                                        : selectedAllergiesLocal
                                                              .add(a),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: sel
                                                          ? LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .teal
                                                                    .shade400,
                                                                Colors
                                                                    .teal
                                                                    .shade600,
                                                              ],
                                                            )
                                                          : null,
                                                      color: sel
                                                          ? null
                                                          : Colors
                                                                .grey
                                                                .shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      border: sel
                                                          ? Border.all(
                                                              color: Colors
                                                                  .teal
                                                                  .shade700,
                                                              width: 2,
                                                            )
                                                          : Border.all(
                                                              color: Colors
                                                                  .grey
                                                                  .shade300,
                                                            ),
                                                      boxShadow: sel
                                                          ? [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .teal
                                                                    .shade200
                                                                    .withValues(
                                                                      alpha:
                                                                          0.5,
                                                                    ),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (sel)
                                                          const Icon(
                                                            Icons.check_circle,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        if (sel)
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                        Text(
                                                          a,
                                                          style: TextStyle(
                                                            color: sel
                                                                ? Colors.white
                                                                : Colors
                                                                      .black87,
                                                            fontWeight: sel
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .normal,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Section 3: Health Goals
                                  _buildEditSectionTitle(
                                    'Mục tiêu sức khỏe',
                                    Icons.flag,
                                    Colors.purple,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildModernDropdownStateful(
                                    value:
                                        selectedHealthGoalLocal != null &&
                                            [
                                              'Tang',
                                              'Giảm',
                                              'Duy trì',
                                            ].contains(selectedHealthGoalLocal)
                                        ? selectedHealthGoalLocal
                                        : null,
                                    label: 'Mục tiêu sức khỏe',
                                    icon: Icons.track_changes,
                                    color: Colors.purple,
                                    items: ['Tăng', 'Giảm', 'Duy trì']
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setDState(() {
                                      selectedHealthGoalLocal = v;
                                      if (selectedHealthGoalLocal ==
                                          'Duy trì') {
                                        goalWeightLocal.text = _weightCtrl.text;
                                        goalWeightReadOnlyLocal = true;
                                      } else {
                                        goalWeightReadOnlyLocal = false;
                                      }
                                      // Update calorie multiplier based on goal
                                      calorieMultiplierLocal =
                                          (selectedHealthGoalLocal == 'Tăng'
                                          ? 1.15
                                          : (selectedHealthGoalLocal == 'Giảm'
                                                ? 0.85
                                                : 1.0));
                                      // Update macro defaults
                                      proteinPctLocal =
                                          (selectedHealthGoalLocal == 'Giảm'
                                          ? 30
                                          : (selectedHealthGoalLocal == 'Tăng'
                                                ? 33
                                                : 25));
                                      carbPctLocal =
                                          (selectedHealthGoalLocal == 'Giảm'
                                          ? 45
                                          : (selectedHealthGoalLocal == 'Tăng'
                                                ? 42
                                                : 50));
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildModernTextField(
                                    controller: goalWeightLocal,
                                    label: 'Cân nặng mục tiêu (kg)',
                                    icon: Icons.emoji_events,
                                    color: Colors.purple,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9\.]'),
                                      ),
                                      DecimalLimitFormatter(
                                        maxInteger: 8,
                                        maxFraction: 2,
                                        onTruncate: () => _onTruncateDetected(
                                          'Cân nặng mục tiêu',
                                        ),
                                      ),
                                    ],
                                    validator: (v) {
                                      final base = _decimalValidator(
                                        v,
                                        'Cân nặng mục tiêu',
                                        maxInteger: 8,
                                        maxFraction: 2,
                                        min: 2,
                                        max: 500,
                                      );
                                      if (base != null) return base;
                                      final goal = double.tryParse(
                                        (v ?? '').replaceAll(',', '.'),
                                      );
                                      final cur = double.tryParse(
                                        _weightCtrl.text.replaceAll(',', '.'),
                                      );
                                      if (selectedHealthGoalLocal ==
                                          'Duy trì') {
                                        return null;
                                      }
                                      if (goal == null || cur == null) {
                                        return null;
                                      }
                                      if (selectedHealthGoalLocal == 'Tang' &&
                                          !(goal > cur)) {
                                        return 'Mục tiêu phải > hiện tại';
                                      }
                                      if (selectedHealthGoalLocal == 'Giảm' &&
                                          !(goal < cur)) {
                                        return 'Mục tiêu phải < hiện tại';
                                      }
                                      return null;
                                    },
                                    readOnly: goalWeightReadOnlyLocal,
                                    enabled: !goalWeightReadOnlyLocal,
                                  ),
                                  const SizedBox(height: 24),

                                  // Section 4: Nutrition Settings
                                  _buildEditSectionTitle(
                                    'Cài đặt dinh dưỡng',
                                    Icons.restaurant,
                                    Colors.amber,
                                  ),
                                  const SizedBox(height: 12),

                                  // Calorie multiplier presets
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.shade100
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Mức độ thay đổi calo',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildCaloriePresetButton(
                                                'Nhẹ',
                                                Icons.air,
                                                selectedHealthGoalLocal ==
                                                        'Gi?m'
                                                    ? 0.9
                                                    : (selectedHealthGoalLocal ==
                                                              'Tang'
                                                          ? 1.1
                                                          : 1.0),
                                                calorieMultiplierLocal,
                                                () => setDState(
                                                  () => calorieMultiplierLocal =
                                                      (selectedHealthGoalLocal ==
                                                          'Gi?m'
                                                      ? 0.9
                                                      : (selectedHealthGoalLocal ==
                                                                'Tang'
                                                            ? 1.1
                                                            : 1.0)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildCaloriePresetButton(
                                                'Vừa',
                                                Icons.fitness_center,
                                                selectedHealthGoalLocal ==
                                                        'Gi?m'
                                                    ? 0.85
                                                    : (selectedHealthGoalLocal ==
                                                              'Tang'
                                                          ? 1.15
                                                          : 1.0),
                                                calorieMultiplierLocal,
                                                () => setDState(
                                                  () => calorieMultiplierLocal =
                                                      (selectedHealthGoalLocal ==
                                                          'Gi?m'
                                                      ? 0.85
                                                      : (selectedHealthGoalLocal ==
                                                                'Tang'
                                                            ? 1.15
                                                            : 1.0)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildCaloriePresetButton(
                                                'Mạnh',
                                                Icons.flash_on,
                                                selectedHealthGoalLocal ==
                                                        'Gi?m'
                                                    ? 0.8
                                                    : (selectedHealthGoalLocal ==
                                                              'Tang'
                                                          ? 1.2
                                                          : 1.0),
                                                calorieMultiplierLocal,
                                                () => setDState(
                                                  () => calorieMultiplierLocal =
                                                      (selectedHealthGoalLocal ==
                                                          'Gi?m'
                                                      ? 0.8
                                                      : (selectedHealthGoalLocal ==
                                                                'Tang'
                                                            ? 1.2
                                                            : 1.0)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.amber.shade50,
                                                Colors.orange.shade50,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.amber.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.amber.shade700,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Hiện tại: ${calorieMultiplierLocal.toStringAsFixed(2)}x',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber.shade900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Macro percentage controls
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.shade100
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tỉ lệ phân bố dinh dưỡng (%)',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Step size selector
                                        Row(
                                          children: [
                                            const Text(
                                              'Bước điều chỉnh:',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            _buildStepButton(
                                              '±1',
                                              macroStepLocal == 1,
                                              () => setDState(
                                                () => macroStepLocal = 1,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildStepButton(
                                              '±5',
                                              macroStepLocal == 5,
                                              () => setDState(
                                                () => macroStepLocal = 5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Protein
                                        _buildMacroControlWithLabel(
                                          'Chất đạm',
                                          Colors.blue,
                                          proteinPctLocal,
                                          () => setDState(
                                            () => proteinPctLocal =
                                                (proteinPctLocal -
                                                        macroStepLocal)
                                                    .clamp(0, 100),
                                          ),
                                          () => setDState(
                                            () => proteinPctLocal =
                                                (proteinPctLocal +
                                                        macroStepLocal)
                                                    .clamp(0, 100),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Fat
                                        _buildMacroControlWithLabel(
                                          'Chất béo',
                                          Colors.orange,
                                          fatPctLocal,
                                          () => setDState(
                                            () => fatPctLocal =
                                                (fatPctLocal - macroStepLocal)
                                                    .clamp(0, 100),
                                          ),
                                          () => setDState(
                                            () => fatPctLocal =
                                                (fatPctLocal + macroStepLocal)
                                                    .clamp(0, 100),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Carb
                                        _buildMacroControlWithLabel(
                                          'Đường',
                                          Colors.green,
                                          carbPctLocal,
                                          () => setDState(
                                            () => carbPctLocal =
                                                (carbPctLocal - macroStepLocal)
                                                    .clamp(0, 100),
                                          ),
                                          () => setDState(
                                            () => carbPctLocal =
                                                (carbPctLocal + macroStepLocal)
                                                    .clamp(0, 100),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Total sum indicator
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green.shade50,
                                                Colors.blue.shade50,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  (proteinPctLocal +
                                                              fatPctLocal +
                                                              carbPctLocal >=
                                                          99 &&
                                                      proteinPctLocal +
                                                              fatPctLocal +
                                                              carbPctLocal <=
                                                          101)
                                                  ? Colors.green.shade300
                                                  : Colors.red.shade300,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                (proteinPctLocal +
                                                                fatPctLocal +
                                                                carbPctLocal >=
                                                            99 &&
                                                        proteinPctLocal +
                                                                fatPctLocal +
                                                                carbPctLocal <=
                                                            101)
                                                    ? Icons.check_circle
                                                    : Icons.warning,
                                                color:
                                                    (proteinPctLocal +
                                                                fatPctLocal +
                                                                carbPctLocal >=
                                                            99 &&
                                                        proteinPctLocal +
                                                                fatPctLocal +
                                                                carbPctLocal <=
                                                            101)
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Tổng: ${proteinPctLocal + fatPctLocal + carbPctLocal}%',
                                                style: TextStyle(
                                                  fontFamily: FitnessAppTheme.fontName,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      (proteinPctLocal +
                                                                  fatPctLocal +
                                                                  carbPctLocal >=
                                                              99 &&
                                                          proteinPctLocal +
                                                                  fatPctLocal +
                                                                  carbPctLocal <=
                                                              101)
                                                      ? Colors.green.shade900
                                                      : Colors.red.shade900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Modern action buttons
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.purple.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade300.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!(formKey.currentState?.validate() ?? true)) {
                                return;
                              }
                              // validate macro percentage sum
                              final prot = proteinPctLocal.toDouble();
                              final fatp = fatPctLocal.toDouble();
                              final carbp = carbPctLocal.toDouble();
                              final s = prot + fatp + carbp;
                              if (s < 99 || s > 101) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Tổng % Chất đạm+Chất béo+Đường nên xấp xỉ 100%',
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                      ),
                                    ),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              // copy dialog-local selections back to main controllers
                              if (activityLabelLocal.isNotEmpty) {
                                _activityLevelCtrl.text = activityLabelLocal;
                              }
                              _dietTypeCtrl.text = selectedDietLocal ?? '';
                              _allergiesCtrl.text =
                                  selectedAllergiesLocal.isNotEmpty
                                  ? selectedAllergiesLocal.join(', ')
                                  : '';
                              _healthGoalsCtrl.text =
                                  selectedHealthGoalLocal ?? '';
                              _goalWeightCtrl.text = goalWeightLocal.text
                                  .trim();
                              _calorieMultiplierCtrl.text =
                                  calorieMultiplierLocal.toStringAsFixed(2);
                              _proteinPctCtrl.text = proteinPctLocal.toString();
                              _fatPctCtrl.text = fatPctLocal.toString();
                              _carbPctCtrl.text = carbPctLocal.toString();
                              Navigator.of(ctx).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      await _saveProfile();
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
          _avatarMimeType = image.mimeType ?? 'image/png';
          _avatarUrl = _avatarUrl; // keep existing url until upload succeeds
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('L?i ch?n ?nh: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim());
    final gender = _genderValue;
    final height = double.tryParse(_heightCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());

    // parse extended numeric fields
    final goalWeight = double.tryParse(_goalWeightCtrl.text.trim());
    double? activityFactor = double.tryParse(_activityFactorCtrl.text.trim());
    double? bmr = double.tryParse(_bmrCtrl.text.trim());
    double? tdee = double.tryParse(_tdeeCtrl.text.trim());
    double? dailyCal = double.tryParse(_dailyCalorieCtrl.text.trim());
    double? dailyProtein = double.tryParse(_dailyProteinCtrl.text.trim());
    double? dailyFat = double.tryParse(_dailyFatCtrl.text.trim());
    double? dailyCarb = double.tryParse(_dailyCarbCtrl.text.trim());

    final mappedActivity = _activityLevelCtrl.text.trim().isNotEmpty
        ? _normalizeActivityLevel(_activityLevelCtrl.text)
        : null;
    final mappedDiet = _dietTypeCtrl.text.trim().isNotEmpty
        ? _normalizeDietType(_dietTypeCtrl.text)
        : null;

    // Compute BMR/TDEE using goal weight when appropriate
    final healthGoal = _healthGoalsCtrl.text.trim();
    double? computedBmr = bmr;
    double? computedTdee = tdee;
    try {
      if (healthGoal.isNotEmpty &&
          healthGoal != 'Duy trì' &&
          goalWeight != null) {
        final useWeight = goalWeight;
        final useHeight =
            height ?? double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
        final useAge = age ?? int.tryParse(_ageCtrl.text.trim());
        final useGender = gender;
        final actFactor =
            activityFactor ??
            double.tryParse(_activityFactorCtrl.text.replaceAll(',', '.')) ??
            1.2;
        final b = _computeBMR(useWeight, useHeight, useAge, useGender);
        if (b != null) {
          computedBmr = double.parse(b.toStringAsFixed(2));
          computedTdee = double.parse(
            (computedBmr * actFactor).toStringAsFixed(2),
          );
        }
      }
    } catch (e) {
      // if computation fails, fall back to provided values
    }

    // --- Auto-calculate daily calorie & macronutrient targets if possible ---
    // Determine final BMR and activity factor to compute TDEE
    double? finalBmr = computedBmr ?? bmr;
    activityFactor =
        activityFactor ??
        double.tryParse(_activityFactorCtrl.text.replaceAll(',', '.')) ??
        1.2;
    // Try to compute BMR from current weight/height/age/gender if still missing
    if (finalBmr == null) {
      final maybeB = _computeBMR(weight, height, age, gender);
      if (maybeB != null) finalBmr = double.parse(maybeB.toStringAsFixed(2));
    }

    double? finalTdee =
        computedTdee ??
        tdee ??
        (finalBmr != null
            ? double.parse((finalBmr * activityFactor).toStringAsFixed(2))
            : null);

    if (finalTdee != null) {
      // choose calorie multiplier based on health goal, but allow user override via _calorieMultiplierCtrl
      double multiplier = 1.0;
      final parsedMultiplier = double.tryParse(
        _calorieMultiplierCtrl.text.replaceAll(',', '.'),
      );
      if (parsedMultiplier != null && parsedMultiplier > 0) {
        multiplier = parsedMultiplier;
      } else {
        if (healthGoal == 'Gi?m') multiplier = 0.85; // between 0.8 and 0.9
        if (healthGoal == 'Tang') multiplier = 1.15; // between 1.1 and 1.2
      }

      final calcDailyCal = double.parse(
        (finalTdee * multiplier).toStringAsFixed(0),
      );

      // macronutrient percentage defaults by goal, can be overridden by user-entered percentages
      double pProtein = 0.25, pFat = 0.25, pCarb = 0.5; // default: giữ cân
      if (healthGoal == 'Gi?m') {
        pProtein = 0.30;
        pFat = 0.25;
        pCarb = 0.45;
      } else if (healthGoal == 'Tang') {
        pProtein = 0.325; // 32.5%
        pFat = 0.25;
        pCarb = 0.425;
      }
      final up = double.tryParse(_proteinPctCtrl.text.replaceAll(',', '.'));
      final uf = double.tryParse(_fatPctCtrl.text.replaceAll(',', '.'));
      final uc = double.tryParse(_carbPctCtrl.text.replaceAll(',', '.'));
      if (up != null && uf != null && uc != null && (up + uf + uc).abs() > 0) {
        // use user-specified percentages (convert to fraction)
        pProtein = up / 100.0;
        pFat = uf / 100.0;
        pCarb = uc / 100.0;
      }

      final calcProteinG = double.parse(
        (calcDailyCal * pProtein / 4.0).toStringAsFixed(0),
      );
      final calcFatG = double.parse(
        (calcDailyCal * pFat / 9.0).toStringAsFixed(0),
      );
      final calcCarbG = double.parse(
        (calcDailyCal * pCarb / 4.0).toStringAsFixed(0),
      );

      // overwrite local target variables and controllers so UI and payload reflect computed values
      dailyCal = calcDailyCal;
      dailyProtein = calcProteinG;
      dailyFat = calcFatG;
      dailyCarb = calcCarbG;

      _dailyCalorieCtrl.text = dailyCal.toStringAsFixed(0);
      _dailyProteinCtrl.text = dailyProtein.toStringAsFixed(0);
      _dailyFatCtrl.text = dailyFat.toStringAsFixed(0);
      _dailyCarbCtrl.text = dailyCarb.toStringAsFixed(0);
    }

    final messenger = ScaffoldMessenger.of(context);
    final prov = context.maybeProfile();

    String? avatarUrl = _avatarUrl;
    if (_avatarBytes != null) {
      try {
        avatarUrl = await SocialService.uploadImage(
          _avatarBytes!,
          folder: 'avatars',
          mimeType: _avatarMimeType,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
        );
        setState(() {
          _avatarUrl = avatarUrl;
          _avatarBytes = null;
          _avatarMimeType = null;
        });
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('L?i t?i ?nh d?i di?n: $e')));
        }
        return;
      }
    }

    final resp = await AuthService.updateProfile(
      fullName: fullName.isNotEmpty ? fullName : null,
      email: email.isNotEmpty ? email : null,
      age: age,
      gender: gender,
      heightCm: height,
      weightKg: weight,
      avatarUrl: _avatarUrl,
      activityLevel: mappedActivity != null && mappedActivity.isNotEmpty
          ? mappedActivity
          : null,
      dietType: mappedDiet != null && mappedDiet.isNotEmpty ? mappedDiet : null,
      allergies: _allergiesCtrl.text.trim().isNotEmpty
          ? _allergiesCtrl.text.trim()
          : null,
      healthGoals: _healthGoalsCtrl.text.trim().isNotEmpty
          ? _healthGoalsCtrl.text.trim()
          : null,
      // removed free-text 'goalType' field; health goal is carried in healthGoals/goalWeight
      goalWeight: goalWeight,
      // system-calculated fields (activity_factor, bmr, tdee, daily targets) are computed server-side and must not be set by client
      dailyWaterTarget: double.tryParse(
        _dailyWaterCtrl.text.replaceAll(',', '.'),
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (resp == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Không nhận được phản hồi từ server')),
      );
      return;
    }

    if (resp['error'] != null) {
      final msg = resp['error']?.toString() ?? 'Lỗi khi lưu';
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    if (resp['user'] != null) {
      if (!mounted) return;
      setState(() {
        _user = Map<String, dynamic>.from(resp['user'] as Map);
        _fillControllers();
      });
      // update global profile provider: re-fetch authoritative profile from server
      try {
        if (prov != null) await prov.loadProfile();
      } catch (_) {}
      // Persist macro/multiplier settings to UserSetting via settings API if provided
      try {
        final settingsPayload = <String, dynamic>{};
        final cm = double.tryParse(
          _calorieMultiplierCtrl.text.replaceAll(',', '.'),
        );
        final pp = int.tryParse(_proteinPctCtrl.text.trim());
        final fp = int.tryParse(_fatPctCtrl.text.trim());
        final cp = int.tryParse(_carbPctCtrl.text.trim());
        if (cm != null) settingsPayload['calorie_multiplier'] = cm;
        if (pp != null) settingsPayload['macro_protein_pct'] = pp;
        if (fp != null) settingsPayload['macro_fat_pct'] = fp;
        if (cp != null) settingsPayload['macro_carb_pct'] = cp;
        if (settingsPayload.isNotEmpty) {
          final sresp = await AuthService.updateSettings(settingsPayload);
          if (sresp == null || sresp['error'] != null) {
            if (!mounted) return;
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Lưu cài đặt dinh dưỡng không thành công'),
              ),
            );
          } else {
            // update settings readback
            // re-fill settings into controllers if provided (we could call AuthService.getSettings too)
          }
        }
      } catch (_) {}
      // Show local notification
      await LocalNotificationService().notifyPersonalInfoChanged();
      
      if (resp['message'] != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(resp['message'].toString())),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
        );
      }
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Không thể cập nhật hồ sơ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final u = _user;
    String fmt(dynamic v) =>
        v == null || (v is String && v.isEmpty) ? '-' : v.toString();
    String genderLabel(dynamic v) {
      if (v == null) return '-';
      final s = v.toString().toLowerCase();
      if (s == 'male' || s.startsWith('m')) return l10n.male;
      if (s == 'female' || s.startsWith('f')) return l10n.female;
      return l10n.otherGender;
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Modern Gradient AppBar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    children: [
                      const Hero(
                        tag: 'heroPersonalInfo',
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              gradient: LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF26C6DA)],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thông tin cá nhân',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Color.fromARGB(100, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                              Colors.blue.shade800,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: -50,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Icons.person_rounded,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _openEditDialog,
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Chỉnh sửa',
                  ),
                  IconButton(
                    tooltip: 'Đặt mục tiêu',
                    icon: const Icon(Icons.calculate_rounded),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final prov = context.maybeProfile();

                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(
                                Icons.calculate_rounded,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 12),
                              const Text('Tính toán'),
                            ],
                          ),
                          content: const Text(
                            'Bạn có muốn tính toán mục tiêu hàng ngày không?',
                            style: TextStyle(fontSize: 15, height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Đồng ý'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;

                      if (!mounted) return;
                      setState(() => _loading = true);
                      try {
                        final resp = await AuthService.recomputeDailyTargets();
                        if (!mounted) return;
                        if (resp == null) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không nhận được phản hồi từ server',
                              ),
                            ),
                          );
                        } else if (resp['error'] != null) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(resp['error'].toString())),
                          );
                        } else {
                          if (resp['user'] != null) {
                            if (!mounted) return;
                            setState(() {
                              _user = Map<String, dynamic>.from(
                                resp['user'] as Map,
                              );
                              _fillControllers();
                            });
                          }
                          try {
                            if (prov != null) await prov.loadProfile();
                          } catch (_) {}
                          if (!mounted) return;
                          final msg =
                              resp['message']?.toString() ??
                              'Mục tiêu hàng ngày đã được đặt lại';
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('L?i: ${e.toString()}')),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Card with Avatar
                      _buildProfileCard(u, genderLabel),
                      const SizedBox(height: 24),

                      // Personal Info Section
                      _buildSectionTitle(
                        'Thông tin cá nhân',
                        Icons.person_rounded,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildModernRow(
                          Icons.cake_rounded,
                          'Tuổi',
                          fmt(u['age']),
                          Colors.orange,
                        ),
                        _buildModernRow(
                          Icons.wc_rounded,
                          'Giới tính',
                          genderLabel(u['gender']),
                          Colors.pink,
                        ),
                        _buildModernRow(
                          Icons.height_rounded,
                          'Chiều cao',
                          '${fmt(u['height_cm'])} cm',
                          Colors.purple,
                        ),
                        _buildModernRow(
                          Icons.fitness_center_rounded,
                          'Cân nặng',
                          '${fmt(u['weight_kg'])} kg',
                          Colors.green,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Lifestyle Section
                      _buildSectionTitle(
                        'Lối sống',
                        Icons.local_activity_rounded,
                        Colors.teal,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildModernRow(
                          Icons.directions_run_rounded,
                          'Mức độ vận động',
                          fmt(u['activity_level']),
                          Colors.teal,
                        ),
                        _buildModernRow(
                          Icons.restaurant_menu_rounded,
                          'Kiểu ăn',
                          fmt(u['diet_type']),
                          Colors.orange,
                        ),
                        _buildModernRow(
                          Icons.warning_amber_rounded,
                          'Dị ứng',
                          fmt(u['allergies']),
                          Colors.red,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Goals Section
                      _buildSectionTitle(
                        'Mục tiêu',
                        Icons.flag_rounded,
                        Colors.deepPurple,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildModernRow(
                          Icons.track_changes_rounded,
                          'Mục tiêu sức khỏe',
                          fmt(u['health_goals']),
                          Colors.deepPurple,
                        ),
                        _buildModernRow(
                          Icons.monitor_weight_rounded,
                          'Cân nặng mục tiêu',
                          '${fmt(u['goal_weight'])} kg',
                          Colors.indigo,
                        ),
                        _buildModernRow(
                          Icons.speed_rounded,
                          'Hệ số vận động',
                          fmt(u['activity_factor']),
                          Colors.cyan,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Metrics Section
                      _buildSectionTitle(
                        'Chỉ số cơ thể',
                        Icons.analytics_rounded,
                        Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricsGrid(u),
                      const SizedBox(height: 24),

                      // Daily Targets Section
                      _buildSectionTitle(
                        'Mục tiêu hàng ngày',
                        Icons.today_rounded,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildDailyTargetsGrid(u),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Loading Overlay
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đang tải...',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _openEditDialog,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Chỉnh sửa'),
              backgroundColor: Colors.blue.shade600,
            ),
    );
  }

  // Helper methods for modern edit dialog
  Widget _buildEditSectionTitle(
    String title,
    IconData icon,
    MaterialColor color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.shade400, color.shade600]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required MaterialColor color,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        readOnly: readOnly,
        enabled: enabled,
        style: TextStyle(
          fontSize: 15,
          color: enabled ? Colors.black87 : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: color.shade700,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade400, color.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required MaterialColor color,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: color.shade700,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade400, color.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernDropdownStateful({
    required String? value,
    required String label,
    required IconData icon,
    required MaterialColor color,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: color.shade700,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade400, color.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriePresetButton(
    String label,
    IconData icon,
    double targetValue,
    double currentValue,
    VoidCallback onTap,
  ) {
    final isSelected = (currentValue - targetValue).abs() < 0.01;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade500],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMacroControl(
    String label,
    MaterialColor color,
    int value,
    VoidCallback onDecrease,
    VoidCallback onIncrease,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.shade50, color.shade100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.pie_chart, color: color.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color.shade900,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade400, color.shade600],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onDecrease,
              icon: const Icon(Icons.remove, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.shade300, width: 2),
            ),
            child: Text(
              '$value%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade400, color.shade600],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onIncrease,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroControlWithLabel(
    String label,
    MaterialColor color,
    int value,
    VoidCallback onDecrease,
    VoidCallback onIncrease,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.pie_chart, color: color.shade700, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.shade900,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.shade50, color.shade100]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.shade400, color.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '$value%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color.shade900,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.shade400, color.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatWater(dynamic mlValue) {
    if (mlValue == null) return '-';
    final num? v = (mlValue is num)
        ? mlValue
        : num.tryParse(mlValue.toString());
    if (v == null) return '-';
    final liters = (v / 1000.0);
    return '${liters.toStringAsFixed(2)} L (${v.toStringAsFixed(0)} ml)';
  }

  // Modern UI Components
  Widget _buildProfileCard(
    Map<String, dynamic> u,
    String Function(dynamic) genderLabel,
  ) {
    final name = u['full_name'] ?? 'Người dùng';
    final email = u['email'] ?? '';
    final gender = genderLabel(u['gender']);
    final age = u['age']?.toString() ?? '-';
    final avatarUrl = _resolveAvatarUrl(u['avatar_url']?.toString());
    final genderLower = (u['gender']?.toString().toLowerCase() ?? '');

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
            Colors.pink.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Enhanced Avatar with glow effect
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade300.withValues(alpha: 0.5),
                          Colors.purple.shade300.withValues(alpha: 0.5),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: avatarUrl == null
                          ? LinearGradient(
                              colors: [Colors.blue.shade400, Colors.purple.shade500],
                            )
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  genderLower == 'male' || gender == 'Nam'
                                      ? Icons.man_rounded
                                      : genderLower == 'female' || gender == 'Nữ'
                                      ? Icons.woman_rounded
                                      : Icons.person_rounded,
                                  size: 48,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        : Icon(
                            genderLower == 'male' || gender == 'Nam'
                                ? Icons.man_rounded
                                : genderLower == 'female' || gender == 'Nữ'
                                ? Icons.woman_rounded
                                : Icons.person_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                  ),
                  // Status badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Info with badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade100,
                            Colors.purple.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cake_rounded,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$age tuổi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Email with icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.email_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    email,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, color.withValues(alpha: 0.03)],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.6),
                  color.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> u) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'BMR',
            u['bmr']?.toString() ?? '-',
            Icons.local_fire_department_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'TDEE',
            u['tdee']?.toString() ?? '-',
            Icons.thermostat_rounded,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDailyTargetsGrid(Map<String, dynamic> u) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTargetCard(
                'Calo',
                u['daily_calorie_target']?.toString() ?? '-',
                'kcal',
                Icons.local_fire_department_rounded,
                Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTargetCard(
                'Chất đạm',
                u['daily_protein_target']?.toString() ?? '-',
                'g',
                Icons.egg_rounded,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTargetCard(
                'Chất béo',
                u['daily_fat_target']?.toString() ?? '-',
                'g',
                Icons.opacity_rounded,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTargetCard(
                'Đường',
                u['daily_carb_target']?.toString() ?? '-',
                'g',
                Icons.grain_rounded,
                Colors.brown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTargetCard(
                'Nước',
                u['daily_water_target']?.toString() ?? '-',
                'ml',
                Icons.water_drop_rounded,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            // Empty space to keep grid balanced
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
