// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'my_diary_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/account_screen_fixed.dart';
import 'screens/ai_image_analysis_screen.dart';
import 'widgets/season_effect_provider.dart';
import 'widgets/settings_provider.dart';
import 'widgets/profile_provider.dart';
import 'widgets/season_effect.dart';
import 'services/daily_meal_suggestion_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'widgets/language_provider.dart';
import 'services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await initializeDateFormatting('en', null);
  
  // Initialize local notifications
  await LocalNotificationService().initialize();
  
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: !kIsWeb && Platform.isAndroid
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return LanguageProvider(
      child: SettingsProvider(
        child: ProfileProvider(
          child: SeasonEffectProvider(
            child: Builder(
              builder: (context) {
                final settings = context.maybeSettings();
                final language = context.language();
                ThemeMode themeMode = ThemeMode.system;
                final sTheme = settings?.theme;
                if (sTheme == 'dark') {
                  themeMode = ThemeMode.dark;
                } else if (sTheme == 'light') {
                  themeMode = ThemeMode.light;
                } else {
                  themeMode = ThemeMode.system;
                }
                // Use ListenableBuilder to rebuild when language changes
                return ListenableBuilder(
                  listenable: language,
                  builder: (context, _) {
                    return MaterialApp(
                      title: 'VietNam Healthy Life',
                      debugShowCheckedModeBanner: false,
                      locale: language.locale,
                      localizationsDelegates: [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: const [
                        Locale('vi', ''), // Vietnamese
                        Locale('en', ''), // English
                      ],
                      theme: ThemeData(
                        brightness: Brightness.light,
                        primarySwatch: Colors.blue,
                        platform: TargetPlatform.iOS,
                        dividerTheme: const DividerThemeData(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      darkTheme: ThemeData(
                        brightness: Brightness.dark,
                        primarySwatch: Colors.blue,
                      ),
                      themeMode: themeMode,
                      home:
                          MyDiaryApp(), // Temporarily bypassed AuthWrapper for testing
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MyDiaryApp extends StatefulWidget {
  const MyDiaryApp({super.key});

  @override
  _MyDiaryAppState createState() => _MyDiaryAppState();
}

class _MyDiaryAppState extends State<MyDiaryApp> with TickerProviderStateMixin {
  AnimationController? animationController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    // Cleanup passed meal suggestions on app launch
    _cleanupPassedMealSuggestions();
  }

  Future<void> _cleanupPassedMealSuggestions() async {
    try {
      final result = await DailyMealSuggestionService.cleanupPassedMeals();
      if (result['success'] == true) {
        debugPrint('✅ Cleaned up passed meal suggestions');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up passed meal suggestions: $e');
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Nút AI Phân tích ở giữa - mở màn hình AI Analysis
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AiImageAnalysisScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return MyDiaryScreen(animationController: animationController);
      case 1:
        return const ScheduleScreen();
      case 3:
        return const StatisticsScreen();
      case 4:
        return const AccountScreen();
      default:
        return MyDiaryScreen(animationController: animationController);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF111218) : Colors.white;

    return Scaffold(
      body: Builder(
        builder: (ctx) {
          // Wrap the selected screen with SeasonEffect so background + effects are shown behind all pages
          final settings = context.maybeSettings();
          final enabled =
              (settings?.seasonalUiEnabled == true) ||
              (settings?.weatherEnabled == true);
          return SeasonEffect(
            currentDate: DateTime.now(),
            enabled: enabled,
            child: _getSelectedScreen(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: navBg,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, l10n.home, 0),
                  _buildNavItem(Icons.favorite, l10n.health, 1),
                  const SizedBox(width: 60), // Khoảng trống cho nút QR
                  _buildNavItem(Icons.bar_chart, l10n.statistics, 3),
                  _buildNavItem(Icons.person, l10n.account, 4),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 4.0,
        child: const Icon(Icons.auto_awesome, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Điều chỉnh index để phù hợp với _selectedIndex
    bool isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.blue;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : inactiveColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
