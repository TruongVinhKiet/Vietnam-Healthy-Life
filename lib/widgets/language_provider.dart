import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = const Locale('vi'); // Default to Vietnamese
  bool _initialized = false;

  Locale get locale => _locale;
  bool get isVietnamese => _locale.languageCode == 'vi';
  bool get isEnglish => _locale.languageCode == 'en';

  Future<void> init() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('app_language');
      
      if (savedLanguage != null) {
        _locale = Locale(savedLanguage);
      } else {
        // Default to Vietnamese
        _locale = const Locale('vi');
      }
      
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[LanguageProvider] Error loading language: $e');
      _locale = const Locale('vi');
      _initialized = true;
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', newLocale.languageCode);
      
      _locale = newLocale;
      notifyListeners();
      
      debugPrint('[LanguageProvider] Language changed to: ${newLocale.languageCode}');
    } catch (e) {
      debugPrint('[LanguageProvider] Error saving language: $e');
    }
  }

  Future<void> setVietnamese() async {
    await setLocale(const Locale('vi'));
  }

  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }
}

class LanguageProvider extends StatefulWidget {
  final Widget child;

  const LanguageProvider({super.key, required this.child});

  @override
  State<LanguageProvider> createState() => _LanguageProviderState();
}

class _LanguageProviderState extends State<LanguageProvider> {
  final LanguageNotifier notifier = LanguageNotifier();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await notifier.init();
    });
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedLanguage(
      notifier: notifier,
      child: widget.child,
    );
  }
}

class _InheritedLanguage extends InheritedNotifier<LanguageNotifier> {
  const _InheritedLanguage({
    required LanguageNotifier super.notifier,
    required super.child,
  });
}

extension LanguageOf on BuildContext {
  LanguageNotifier language() {
    final inh = dependOnInheritedWidgetOfExactType<_InheritedLanguage>();
    return inh!.notifier as LanguageNotifier;
  }

  LanguageNotifier? maybeLanguage() {
    final inh = dependOnInheritedWidgetOfExactType<_InheritedLanguage>();
    return inh?.notifier;
  }
}

