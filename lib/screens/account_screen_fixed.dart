// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/login_screen.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/screens/register_screen.dart';
import 'package:my_diary/screens/personal_info_screen.dart';
import 'package:my_diary/screens/help_screen.dart';
import 'package:my_diary/screens/about_screen.dart';
import 'package:my_diary/screens/rda_recommendations_screen.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/screens/settings_screen.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';
import 'package:my_diary/screens/notifications_screen.dart';
import 'package:my_diary/screens/security_screen.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:my_diary/widgets/draggable_lightbulb_button.dart';
import 'package:my_diary/widgets/draggable_chat_button.dart';
import 'package:my_diary/widgets/draggable_timeline_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _currentUser;
  bool _hasUnseenNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await AuthService.me();
    if (mounted) setState(() => _currentUser = user);
    // Also refresh notification badge when account screen opens or user changes
    _refreshUnseenNotifications();
  }

  Future<void> _refreshUnseenNotifications() async {
    try {
      final items = await AuthService.getNotifications();
      if (items == null) {
        if (mounted) setState(() => _hasUnseenNotifications = false);
        return;
      }
      final lastSeen = await AuthService.getNotificationsLastSeen();
      final unseen = AuthService.hasUnseenNotificationsLocal(items, lastSeen);
      if (mounted) setState(() => _hasUnseenNotifications = unseen);
    } catch (_) {
      if (mounted) setState(() => _hasUnseenNotifications = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seasonNotifier = SeasonEffectNotifier.maybeOf(context);

    return SeasonEffect(
      currentDate: seasonNotifier?.selectedDate ?? DateTime.now(),
      enabled: seasonNotifier?.enabled ?? true,
      child: Container(
        color: (seasonNotifier?.hasBackground ?? false)
            ? Colors.transparent
            : FitnessAppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  _appBar(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _profileCard(),
                        const SizedBox(height: 24),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Column(
                              children: [
                                _menuItem(
                                  Icons.person_outline,
                                  l10n.personalInformation,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PersonalInfoScreen(
                                          user: _currentUser,
                                        ),
                                      ),
                                    );
                                  },
                                  heroTag: 'heroPersonalInfo',
                                ),
                                _menuItem(
                                  Icons.restaurant_menu,
                                  l10n.recommendedNutritionalNeeds,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RDARecommendationsScreen(),
                                      ),
                                    );
                                  },
                                  heroTag: 'heroRDA',
                                ),
                                _menuItem(
                                  Icons.settings_outlined,
                                  l10n.settings,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                  heroTag: 'heroSettings',
                                ),
                                _menuItem(
                                  Icons.notifications_outlined,
                                  l10n.notifications,
                                  () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationsScreen(),
                                      ),
                                    );
                                    // After returning, refresh to clear badge
                                    await _refreshUnseenNotifications();
                                  },
                                  heroTag: 'heroNotifications',
                                  showBadge: _hasUnseenNotifications,
                                ),
                                _menuItem(
                                  Icons.lock_outline,
                                  l10n.security,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SecurityScreen(),
                                      ),
                                    );
                                  },
                                  heroTag: 'heroSecurity',
                                ),
                                _menuItem(
                                  Icons.help_outline,
                                  l10n.help,
                                  () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HelpScreen(),
                                      ),
                                    );
                                  },
                                  heroTag: 'heroHelp',
                                ),
                                _menuItem(
                                  Icons.info_outline,
                                  l10n.about,
                                  () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AboutScreen(),
                                      ),
                                    );
                                  },
                                  heroTag: 'aboutHeroIcon',
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // show login/register when not logged in, otherwise show logout
                        _currentUser == null
                            ? _notLoggedActions()
                            : _logoutButton(),
                      ],
                    ),
                  ),
                ],
              ),
              // Draggable chat button
              const DraggableChatButton(),
              // Draggable lightbulb button for smart suggestions
              const DraggableLightbulbButton(),
              const DraggableTimelineButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.account,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    letterSpacing: 1.2,
                    color: FitnessAppTheme.darkerText,
                  ),
                );
              },
            ),
          ),
          Icon(Icons.person, color: FitnessAppTheme.grey, size: 24),
        ],
      ),
    );
  }

  String? _resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${AuthService.baseUrl}$url';
  }

  Widget _profileCard() {
    final avatarUrl = _resolveAvatarUrl(
      _currentUser?['avatar_url']?.toString(),
    );

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
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: avatarUrl == null
                    ? Colors.blue.withAlpha((0.12 * 255).round())
                    : null,
                borderRadius: BorderRadius.circular(40),
              ),
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              _currentUser != null &&
                                      (_currentUser!['full_name'] ?? '')
                                          .isNotEmpty
                                  ? _initials(_currentUser!['full_name'])
                                  : 'U',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[700],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        _currentUser != null &&
                                (_currentUser!['full_name'] ?? '').isNotEmpty
                            ? _initials(_currentUser!['full_name'])
                            : 'U',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              _currentUser != null
                                  ? (_currentUser!['full_name'] ?? l10n.user)
                                  : l10n.user,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: FitnessAppTheme.darkerText,
                              ),
                            );
                          },
                        ),
                      ),
                      if (_currentUser != null)
                        InkWell(
                          onTap: _openEditDialog,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.edit,
                              color: FitnessAppTheme.grey,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        _currentUser != null
                            ? (_currentUser!['email'] ?? l10n.notLoggedIn)
                            : l10n.notLoggedIn,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: FitnessAppTheme.grey,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (_currentUser != null && _currentUser!['age'] != null)
                        _infoChip('${_currentUser!['age']} tuổi'),
                      if (_currentUser != null &&
                          _currentUser!['height_cm'] != null)
                        _infoChip('${_currentUser!['height_cm']} cm'),
                      if (_currentUser != null &&
                          _currentUser!['weight_kg'] != null)
                        _infoChip('${_currentUser!['weight_kg']} kg'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp('\\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FitnessAppTheme.grey.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: FitnessAppTheme.darkerText),
      ),
    );
  }

  void _openEditDialog() {
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

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
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
                              l10n.editProfile,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Full Name
                        _buildModernTextField(
                          controller: fnController,
                          label: 'Họ và tên',
                          icon: Icons.person_outline,
                          iconColor: Colors.blue,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildModernTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          iconColor: Colors.purple,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Age
                        _buildModernTextField(
                          controller: ageController,
                          label: 'Tuổi',
                          icon: Icons.cake_outlined,
                          iconColor: Colors.orange,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // Height
                        _buildModernTextField(
                          controller: heightController,
                          label: 'Chiều cao (cm)',
                          icon: Icons.height_rounded,
                          iconColor: Colors.green,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Weight
                        _buildModernTextField(
                          controller: weightController,
                          label: 'Cân nặng (kg)',
                          icon: Icons.monitor_weight_outlined,
                          iconColor: Colors.red,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.cancel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade800,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              // call server endpoint to update profile
                              final fullName = fnController.text.trim();
                              final email = emailController.text.trim();
                              final ageVal = int.tryParse(ageController.text);
                              final heightVal = double.tryParse(
                                heightController.text,
                              );
                              final weightVal = double.tryParse(
                                weightController.text,
                              );

                              // Capture messenger before any await to avoid using BuildContext after await
                              final messenger = ScaffoldMessenger.of(context);

                              final resp = await AuthService.updateProfile(
                                fullName: fullName.isNotEmpty ? fullName : null,
                                email: email.isNotEmpty ? email : null,
                                age: ageVal,
                                heightCm: heightVal,
                                weightKg: weightVal,
                              );

                              if (!mounted) return;
                              if (resp == null) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!.noResponseFromServer,
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (resp['error'] != null) {
                                final l10n = AppLocalizations.of(context)!;
                                final msg = resp['error']?.toString() ?? l10n.error;
                                messenger.showSnackBar(
                                  SnackBar(content: Text(msg)),
                                );
                                return;
                              }

                              // server returns { user: { ... } }
                              if (resp['user'] != null) {
                                setState(
                                  () =>
                                      _currentUser = Map<String, dynamic>.from(
                                        resp['user'] as Map,
                                      ),
                                );
                                if (context.mounted) {
                                  final l10n = AppLocalizations.of(context)!;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.profileUpdateSuccess),
                                    ),
                                  );
                                }
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                                return;
                              }

                              if (context.mounted) {
                                final l10n = AppLocalizations.of(context)!;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.error),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return Text(
                                  l10n.save,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                );
                              },
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
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: 0.2),
                  iconColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: iconColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? heroTag,
    bool showBadge = false,
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
              _buildIconWithBadge(icon, heroTag: heroTag, showBadge: showBadge),
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
                ),
              ),
              Icon(Icons.chevron_right, color: FitnessAppTheme.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(
    IconData icon, {
    String? heroTag,
    bool showBadge = false,
  }) {
    final baseIcon = Icon(icon, color: FitnessAppTheme.grey, size: 24);
    final iconChild = heroTag != null
        ? Hero(
            tag: heroTag,
            flightShuttleBuilder: (ctx, anim, direction, fromCtx, toCtx) {
              final child = Icon(icon, color: Colors.white, size: 28);
              return AnimatedBuilder(
                animation: anim,
                builder: (_, __) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.cyan.shade300],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: child),
                ),
              );
            },
            child: baseIcon,
          )
        : baseIcon;

    if (!showBadge) return iconChild;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconChild,
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
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
          if (!mounted) return;
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
              Builder(
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
                  );
                },
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
                final loggedIn = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (!mounted) return;
                if (loggedIn == true) {
                  _loadUser();
                  try {
                    final prov = context.maybeProfile();
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
                if (!mounted) return;
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
}
