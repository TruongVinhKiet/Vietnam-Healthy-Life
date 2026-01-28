import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/login_screen.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/screens/register_screen.dart';
import 'package:my_diary/screens/help_screen.dart';
import 'package:my_diary/screens/about_screen.dart';
import 'package:my_diary/screens/rda_recommendations_screen.dart';
// ignore_for_file: library_private_types_in_public_api

import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';
import 'package:my_diary/screens/settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _currentUser;
  ProfileNotifier? _profileNotifier;
  late AnimationController _animationController;

  // Expandable state for each section
  final Map<String, bool> _expandedSections = {
    'basic_info': true,
    'lifestyle': true,
  };

  static const List<String> dietOptions = [
    'Ăn chay',
    'Keto',
    'Clean',
    'Low-carb',
    'Địa trung hải',
    'Tự chọn',
  ];

  static const List<String> allergyOptions = [
    'Sữa bò',
    'Trứng',
    'Đậu phộng',
    'Tôm',
    'Cua',
    'Sò',
    'Ốc',
    'Lúa mì',
    'Đậu nành',
  ];

  static const List<String> healthGoalOptions = ['Tăng', 'Giảm', 'Duy trì'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = context.maybeProfile();
    if (_profileNotifier == notifier) return;
    _profileNotifier?.removeListener(_handleProfileUpdated);
    _profileNotifier = notifier;
    _profileNotifier?.addListener(_handleProfileUpdated);
    final data = notifier?.raw;
    if (data != null && mounted) {
      setState(() {
        _currentUser = Map<String, dynamic>.from(data);
      });
    }
  }

  @override
  void dispose() {
    _profileNotifier?.removeListener(_handleProfileUpdated);
    _animationController.dispose();
    super.dispose();
  }

  void _handleProfileUpdated() {
    if (!mounted) return;
    final data = _profileNotifier?.raw;
    if (data == null) return;
    setState(() {
      _currentUser = Map<String, dynamic>.from(data);
    });
  }

  void _loadUser() async {
    final user = await AuthService.me();
    if (!mounted) return;
    setState(() => _currentUser = user);
    _profileNotifier?.updateFromMap(user);
    _animationController.forward();
  }

  // map numeric activity factor to Vietnamese label
  String _activityLabelFromFactor(double f) {
    if (f < 1.3) return 'ít vận động';
    if (f < 1.45) return 'vận động nhẹ';
    if (f < 1.65) return 'vừa phải';
    if (f < 1.85) return 'rất năng động';
    return 'cực kỳ năng động';
  }

  Future<void> _openEditDialog() async {
    final fullName = _currentUser?['full_name'] ?? '';
    final email = _currentUser?['email'] ?? '';
    final age = _currentUser?['age']?.toString() ?? '';
    final height = _currentUser?['height_cm']?.toString() ?? '';
    final weight = _currentUser?['weight_kg']?.toString() ?? '';

    final fnController = TextEditingController(text: fullName);
    final emailController = TextEditingController(text: email);
    final ageController = TextEditingController(text: age);
    final heightController = TextEditingController(text: height);
    final weightController = TextEditingController(text: weight);

    final activityFactorController = TextEditingController(
      text: _currentUser?['activity_factor']?.toString() ?? '',
    );
    String computedActivityLabel = '';
    if (activityFactorController.text.trim().isNotEmpty) {
      final v = double.tryParse(
        activityFactorController.text.replaceAll(',', '.'),
      );
      if (v != null) computedActivityLabel = _activityLabelFromFactor(v);
    }

    String? selectedDiet = _currentUser?['diet_type']?.toString();
    final selectedAllergies = <String>{};
    if (_currentUser?['allergies'] != null) {
      final raw = _currentUser!['allergies'];
      if (raw is String) {
        for (final a
            in raw
                .split(RegExp(r'[,;]'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)) {
          selectedAllergies.add(a);
        }
      }
    }
    String? selectedHealthGoal = _currentUser?['health_goals']?.toString();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateDialog) {
            void onActivityFactorChanged(String text) {
              final v = double.tryParse(text.replaceAll(',', '.'));
              setStateDialog(() {
                if (v != null) {
                  computedActivityLabel = _activityLabelFromFactor(v);
                } else {
                  computedActivityLabel = '';
                }
              });
            }

            return AlertDialog(
              title: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(l10n.editProfile);
                },
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Column(
                          children: [
                            TextField(
                              controller: fnController,
                              decoration: InputDecoration(
                                labelText: l10n.fullName,
                              ),
                            ),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                              ),
                            ),
                            TextField(
                              controller: ageController,
                              decoration: InputDecoration(
                                labelText: l10n.ageLabel,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: heightController,
                              decoration: InputDecoration(
                                labelText: l10n.heightCm,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                            TextField(
                              controller: weightController,
                              decoration: InputDecoration(
                                labelText: l10n.weightKg,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            // Activity factor numeric input; activity label computed automatically
                            TextField(
                              controller: activityFactorController,
                              decoration: InputDecoration(
                                labelText: l10n.activityFactor,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9\.]'),
                                ),
                              ],
                              onChanged: onActivityFactorChanged,
                            ),
                            if (computedActivityLabel.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Builder(
                                    builder: (context) {
                                      final l10n = AppLocalizations.of(
                                        context,
                                      )!;
                                      return Text(
                                        l10n.activityLevel(
                                          computedActivityLabel,
                                        ),
                                        style: const TextStyle(fontSize: 13),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            // diet type dropdown
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return DropdownButtonFormField<String>(
                                  initialValue:
                                      (selectedDiet?.isNotEmpty ?? false)
                                      ? selectedDiet
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: l10n.dietType,
                                  ),
                                  items: dietOptions
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setStateDialog(() => selectedDiet = v),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            // allergies multi-select using FilterChips
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l10n.allergies,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: allergyOptions.map((a) {
                                final selected = selectedAllergies.contains(a);
                                return FilterChip(
                                  label: Text(a),
                                  selected: selected,
                                  onSelected: (sel) => setStateDialog(() {
                                    if (sel) {
                                      selectedAllergies.add(a);
                                    } else {
                                      selectedAllergies.remove(a);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            // health goal
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return DropdownButtonFormField<String>(
                                  initialValue:
                                      (selectedHealthGoal?.isNotEmpty ?? false)
                                      ? selectedHealthGoal
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: l10n.healthGoal,
                                  ),
                                  items: healthGoalOptions
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setStateDialog(
                                    () => selectedHealthGoal = v,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(l10n.cancel),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return ElevatedButton(
                      onPressed: () async {
                        // build payload
                        final payload = <String, dynamic>{
                          'fullName': fnController.text.trim().isNotEmpty
                              ? fnController.text.trim()
                              : null,
                          'email': emailController.text.trim().isNotEmpty
                              ? emailController.text.trim()
                              : null,
                          'age': int.tryParse(ageController.text.trim()),
                          'heightCm': double.tryParse(
                            heightController.text.trim().replaceAll(',', '.'),
                          ),
                          'weightKg': double.tryParse(
                            weightController.text.trim().replaceAll(',', '.'),
                          ),
                          'activityFactor': double.tryParse(
                            activityFactorController.text.trim().replaceAll(
                              ',',
                              '.',
                            ),
                          ),
                          'activityLevel': computedActivityLabel.isNotEmpty
                              ? computedActivityLabel
                              : null,
                          'dietType': selectedDiet,
                          'allergies': selectedAllergies.isNotEmpty
                              ? selectedAllergies.join(', ')
                              : null,
                          'healthGoals': selectedHealthGoal,
                        };

                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(ctx).pop();

                        if (!mounted) return;
                        final resp = await AuthService.updateProfile(
                          fullName: payload['fullName'],
                          email: payload['email'],
                          age: payload['age'],
                          heightCm: payload['heightCm'],
                          weightKg: payload['weightKg'],
                          activityLevel: payload['activityLevel'],
                          activityFactor: payload['activityFactor'],
                          dietType: payload['dietType'],
                          allergies: payload['allergies'],
                          healthGoals: payload['healthGoals'],
                        );
                        if (!mounted) return;

                        if (resp == null) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.noResponseFromServer)),
                          );
                          return;
                        }
                        if (resp['error'] != null) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(resp['error'].toString())),
                          );
                          return;
                        }
                        // refresh local user data from server response or re-fetch
                        if (resp['user'] != null) {
                          if (mounted) {
                            setState(
                              () => _currentUser = Map<String, dynamic>.from(
                                resp['user'],
                              ),
                            );
                          }
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.profileUpdateSuccess)),
                          );
                        } else {
                          _loadUser();
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.profileUpdateSuccess)),
                          );
                        }
                      },
                      child: Text(l10n.save),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? heroTag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FitnessAppTheme.grey.withAlpha((0.1 * 255).round()),
            offset: const Offset(1.1, 1.1),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              heroTag != null
                  ? Hero(
                      tag: heroTag,
                      flightShuttleBuilder:
                          (ctx, anim, direction, fromCtx, toCtx) {
                            final child = Icon(
                              icon,
                              color: Colors.white,
                              size: 28,
                            );
                            return AnimatedBuilder(
                              animation: anim,
                              builder: (_, __) => Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.cyan.shade300,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: child),
                              ),
                            );
                          },
                      child: Icon(icon, color: FitnessAppTheme.grey, size: 24),
                    )
                  : Icon(icon, color: FitnessAppTheme.grey, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: FitnessAppTheme.darkerText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, color: FitnessAppTheme.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          // Clear profile data before logout
          final prov = context.maybeProfile();
          if (prov != null) {
            await prov.clearProfile();
          }
          await AuthService.logout();
          setState(() => _currentUser = null);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.logout,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notLoggedActions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: FitnessAppTheme.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                final prov = context.maybeProfile();
                final loggedIn = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (loggedIn == true) {
                  // refresh local user and global profile provider so home uses server-stored values
                  _loadUser();
                  try {
                    if (prov != null) await prov.loadProfile();
                  } catch (_) {}
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.login,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha((0.06 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
                if (created == true) _loadUser();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.register,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final seasonNotifier = SeasonEffectNotifier.maybeOf(context);

    return SeasonEffect(
      currentDate: seasonNotifier?.selectedDate ?? DateTime.now(),
      enabled: seasonNotifier?.enabled ?? true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: FadeTransition(
                opacity: _animationController,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      key: 'basic_info',
                      title: 'Thông tin cá nhân',
                      emoji: '👤',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildLifestyleSection(
                      key: 'lifestyle',
                      title: 'Lối sống',
                      emoji: '🏃',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    _buildMenuSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        boxShadow: [
          BoxShadow(
            color: FitnessAppTheme.grey.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          l10n.account,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: FitnessAppTheme.nearlyBlack,
                          ),
                        );
                      },
                    ),
                    if (_currentUser != null)
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(
                            _currentUser!['email'] ?? l10n.notLoggedIn,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 12,
                              color: FitnessAppTheme.grey,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FitnessAppTheme.nearlyBlue,
            FitnessAppTheme.nearlyBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      _currentUser?['full_name'] ?? l10n.user,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      _currentUser?['email'] ?? l10n.notLoggedIn,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
          if (_currentUser != null)
            InkWell(
              onTap: _openEditDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String key,
    required String title,
    required String emoji,
    required Color color,
  }) {
    final isExpanded = _expandedSections[key] ?? true;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedSections[key] = !isExpanded;
                });
              },
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: FitnessAppTheme.nearlyBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded && _currentUser != null)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    if (_currentUser!['age'] != null)
                      _buildInfoItem(
                        icon: '🎂',
                        label: 'Tuổi',
                        value: '${_currentUser!['age']}',
                        color: Colors.orange,
                      ),
                    if (_currentUser!['gender'] != null)
                      _buildInfoItem(
                        icon: _currentUser!['gender'] == 'Nam' ? '♂️' : '♀️',
                        label: 'Giới tính',
                        value: '${_currentUser!['gender']}',
                        color: Colors.pink,
                      ),
                    if (_currentUser!['height_cm'] != null)
                      _buildInfoItem(
                        icon: '📏',
                        label: 'Chiều cao',
                        value: '${_currentUser!['height_cm']} cm',
                        color: Colors.purple,
                      ),
                    if (_currentUser!['weight_kg'] != null)
                      _buildInfoItem(
                        icon: '⚖️',
                        label: 'Cân nặng',
                        value: '${_currentUser!['weight_kg']} kg',
                        color: Colors.green,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleSection({
    required String key,
    required String title,
    required String emoji,
    required Color color,
  }) {
    final isExpanded = _expandedSections[key] ?? true;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedSections[key] = !isExpanded;
                });
              },
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: FitnessAppTheme.nearlyBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded && _currentUser != null)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    if (_currentUser!['activity_level'] != null)
                      _buildInfoItem(
                        icon: '🏃',
                        label: 'Mức độ vận động',
                        value: '${_currentUser!['activity_level']}',
                        color: Colors.cyan,
                      ),
                    if (_currentUser!['diet_type'] != null)
                      _buildInfoItem(
                        icon: '🍽️',
                        label: 'Kiểu ăn',
                        value: '${_currentUser!['diet_type']}',
                        color: Colors.amber,
                      ),
                    if (_currentUser!['health_goals'] != null)
                      _buildInfoItem(
                        icon: '🎯',
                        label: 'Mục tiêu sức khỏe',
                        value: '${_currentUser!['health_goals']}',
                        color: Colors.teal,
                      ),
                    if (_currentUser!['allergies'] != null &&
                        _currentUser!['allergies'].toString().isNotEmpty)
                      _buildInfoItem(
                        icon: '⚠️',
                        label: 'Dị ứng',
                        value: '${_currentUser!['allergies']}',
                        color: Colors.red,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: FitnessAppTheme.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
                color: FitnessAppTheme.nearlyBlack,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FitnessAppTheme.grey.withAlpha((0.2 * 255).round()),
            offset: const Offset(1.1, 1.1),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    _menuItem(
                      Icons.person_outline,
                      l10n.personalInformation,
                      () {},
                    ),
                    _menuItem(
                      Icons.restaurant_menu,
                      l10n.recommendedNutritionalNeeds,
                      () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RDARecommendationsScreen(),
                          ),
                        );
                      },
                      heroTag: 'rdaHeroIcon',
                    ),
                    _menuItem(Icons.settings_outlined, l10n.settings, () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    }),
                    _menuItem(
                      Icons.notifications_outlined,
                      l10n.notifications,
                      () {},
                    ),
                    _menuItem(Icons.lock_outline, l10n.security, () {}),
                    _menuItem(Icons.help_outline, l10n.help, () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      );
                    }),
                    _menuItem(Icons.info_outline, l10n.about, () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    }, heroTag: 'aboutHeroIcon'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _currentUser == null ? _notLoggedActions() : _logoutButton(),
          ],
        ),
      ),
    );
  }
}
