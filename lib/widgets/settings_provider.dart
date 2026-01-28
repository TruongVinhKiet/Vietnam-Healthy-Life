import 'package:flutter/material.dart';

class SettingsNotifier extends ChangeNotifier {
  String _theme = 'light';
  bool _seasonalUiEnabled = false;
  String _seasonalMode = 'auto';
  String? _seasonalCustomBg;
  bool _fallingLeavesEnabled = false; // disabled by default; user must enable with seasonal UI
  bool _weatherEnabled = false;
  bool _weatherEffectsEnabled = true;
  String? _weatherCity;
  Map<String, dynamic>? _weatherLastData;
  String? _backgroundImageUrl;
  bool _backgroundImageEnabled = false;
  String _effectIntensity = 'medium'; // 'low' | 'medium' | 'high'
  double _windDirection = 0.0; // degrees 0..360, 0 = North

  String get theme => _theme;

  bool get isDark => _theme == 'dark';

  bool get seasonalUiEnabled => _seasonalUiEnabled;
  String get seasonalMode => _seasonalMode;
  String? get seasonalCustomBg => _seasonalCustomBg;
  bool get fallingLeavesEnabled => _fallingLeavesEnabled;
  bool get weatherEnabled => _weatherEnabled;
  String? get weatherCity => _weatherCity;
  Map<String, dynamic>? get weatherLastData => _weatherLastData;
  String? get backgroundImageUrl => _backgroundImageUrl;
  bool get weatherEffectsEnabled => _weatherEffectsEnabled;
  String get effectIntensity => _effectIntensity;
  bool get backgroundImageEnabled => _backgroundImageEnabled;
  double get windDirection => _windDirection;

  void setTheme(String t) {
    if (t == _theme) return;
    _theme = t;
    notifyListeners();
  }

  void setSeasonalUiEnabled(bool v) {
    if (v == _seasonalUiEnabled) return;
    _seasonalUiEnabled = v;
    notifyListeners();
  }

  void setSeasonalMode(String v) {
    if (v == _seasonalMode) return;
    _seasonalMode = v;
    notifyListeners();
  }

  void setSeasonalCustomBg(String? v) {
    if (v == _seasonalCustomBg) return;
    _seasonalCustomBg = v;
    notifyListeners();
  }

  void setFallingLeavesEnabled(bool v) {
    if (v == _fallingLeavesEnabled) return;
    _fallingLeavesEnabled = v;
    notifyListeners();
  }

  void setWeatherEnabled(bool v) {
    if (v == _weatherEnabled) return;
    _weatherEnabled = v;
    notifyListeners();
  }

  void setWeatherCity(String? v) {
    if (v == _weatherCity) return;
    _weatherCity = v;
    notifyListeners();
  }

  void setWeatherLastData(Map<String, dynamic>? v) {
    _weatherLastData = v;
    notifyListeners();
  }

  void setWeatherEffectsEnabled(bool v) {
    if (v == _weatherEffectsEnabled) return;
    _weatherEffectsEnabled = v;
    notifyListeners();
  }

  void setEffectIntensity(String v) {
    if (v == _effectIntensity) return;
    if (v != 'low' && v != 'medium' && v != 'high') return;
    _effectIntensity = v;
    notifyListeners();
  }

  void setWindDirection(double v) {
    // normalize to 0..360
    var nv = v % 360.0;
    if (nv < 0) nv += 360.0;
    if ((nv - _windDirection).abs() < 0.0001) return;
    _windDirection = nv;
    notifyListeners();
  }

  void setBackgroundImageUrl(String? v) {
    if (v == _backgroundImageUrl) return;
    _backgroundImageUrl = v;
    notifyListeners();
  }

  void setBackgroundImageEnabled(bool v) {
    if (v == _backgroundImageEnabled) return;
    _backgroundImageEnabled = v;
    notifyListeners();
  }

  void updateFromMap(Map<String, dynamic>? map) {
    if (map == null) return;
    final t = map['theme']?.toString();
    if (t != null) {
      setTheme(t);
    }
    if (map.containsKey('seasonal_ui_enabled')) {
      setSeasonalUiEnabled(map['seasonal_ui_enabled'] == true);
    }
    if (map.containsKey('seasonal_mode') && map['seasonal_mode'] != null) {
      setSeasonalMode(map['seasonal_mode'].toString());
    }
    if (map.containsKey('seasonal_custom_bg')) {
      setSeasonalCustomBg(map['seasonal_custom_bg']?.toString());
    }
    if (map.containsKey('falling_leaves_enabled')) {
      setFallingLeavesEnabled(map['falling_leaves_enabled'] != false);
    }
    if (map.containsKey('weather_enabled')) {
      setWeatherEnabled(map['weather_enabled'] == true);
    }
    if (map.containsKey('weather_city')) {
      setWeatherCity(map['weather_city']?.toString());
    }
    if (map.containsKey('weather_last_data') &&
        map['weather_last_data'] != null) {
      setWeatherLastData(Map<String, dynamic>.from(map['weather_last_data']));
    }
    if (map.containsKey('background_image_url')) {
      setBackgroundImageUrl(map['background_image_url']?.toString());
    }
    if (map.containsKey('background_image_enabled')) {
      setBackgroundImageEnabled(map['background_image_enabled'] == true);
    }
    if (map.containsKey('weather_effects_enabled')) {
      setWeatherEffectsEnabled(map['weather_effects_enabled'] == true);
    }
    if (map.containsKey('effect_intensity') && map['effect_intensity'] != null) {
      setEffectIntensity(map['effect_intensity'].toString());
    }
    if (map.containsKey('wind_direction') && map['wind_direction'] != null) {
      final raw = map['wind_direction'];
      double? v;
      try {
        if (raw is num) {
          v = raw.toDouble();
        } else {
          v = double.tryParse(raw.toString());
        }
      } catch (e) {
        v = null;
      }
      if (v != null) setWindDirection(v);
    }
  }
}

class SettingsProvider extends StatefulWidget {
  final Widget child;

  const SettingsProvider({super.key, required this.child});

  @override
  State<SettingsProvider> createState() => _SettingsProviderState();
}

class _SettingsProviderState extends State<SettingsProvider> {
  final SettingsNotifier notifier = SettingsNotifier();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedSettings(notifier: notifier, child: widget.child);
  }
}

class _InheritedSettings extends InheritedNotifier<SettingsNotifier> {
  const _InheritedSettings({
    required SettingsNotifier super.notifier,
    required super.child,
  });
}

extension SettingsOf on BuildContext {
  SettingsNotifier settings() {
    final inh = dependOnInheritedWidgetOfExactType<_InheritedSettings>();
    return inh!.notifier as SettingsNotifier;
  }

  SettingsNotifier? maybeSettings() {
    final inh = dependOnInheritedWidgetOfExactType<_InheritedSettings>();
    return inh?.notifier;
  }
}
