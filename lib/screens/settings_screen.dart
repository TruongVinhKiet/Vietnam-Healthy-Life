// ignore_for_file: library_private_types_in_public_api

// ignore_for_file: deprecated_member_use, prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
// import theme when needed later
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/widgets/settings_provider.dart';
import 'package:my_diary/widgets/language_provider.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  Map<String, dynamic> _settings = {};
  int _intensityIndex = 1; // 0=low,1=medium,2=high
  int _windDir = 0; // degrees 0..359

  final _cityCtrl = TextEditingController();
  final _bgCtrl = TextEditingController();
  String? _previewPath; // asset path or network url
  bool _bgEnabled = false;
  File? _selectedImageFile; // Selected image from gallery
  final ImagePicker _imagePicker = ImagePicker();

  late final AnimationController _introController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeIn = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
          ),
        );
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await AuthService.getSettings();
    if (data != null) {
      _settings = Map<String, dynamic>.from(data);
      _cityCtrl.text = _settings['weather_city']?.toString() ?? '';
      _bgCtrl.text = _settings['background_image_url']?.toString() ?? '';
      _bgEnabled = _settings['background_image_enabled'] == true;
      final ef = _settings['effect_intensity']?.toString() ?? 'medium';
      _intensityIndex = (ef == 'low') ? 0 : (ef == 'high' ? 2 : 1);
      final wd = _settings['wind_direction'];
      try {
        if (wd != null) {
          if (wd is num) {
            _windDir = wd.round() % 360;
          } else {
            _windDir = int.tryParse(wd.toString()) ?? 0;
          }
        } else {
          _windDir = 0;
        }
      } catch (e) {
        _windDir = 0;
      }
      _updatePreviewFromSettings();
      // update global settings notifier so theme changes take effect app-wide
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final sn = context.maybeSettings();
        if (sn != null) {
          sn.updateFromMap(_settings);
        }
      });
    }
    setState(() => _loading = false);
    // kick off intro animation when content becomes visible
    if (mounted) {
      _introController.forward(from: 0);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final payload = {
      'theme': _settings['theme'],
      'language': _settings['language'],
      'font_size': _settings['font_size'],
      'unit_system': _settings['unit_system'],
      'seasonal_ui_enabled': _settings['seasonal_ui_enabled'] == true,
      'seasonal_mode': _settings['seasonal_mode'],
      'seasonal_custom_bg': _settings['seasonal_custom_bg'],
      'falling_leaves_enabled': _settings['falling_leaves_enabled'] == true,
      'weather_effects_enabled': _settings['weather_effects_enabled'] == true,
      'weather_enabled': _settings['weather_enabled'] == true,
      'weather_city': _cityCtrl.text.trim().isNotEmpty
          ? _cityCtrl.text.trim()
          : null,
      'background_image_url': _bgCtrl.text.trim().isNotEmpty
          ? _bgCtrl.text.trim()
          : null,
      'background_image_enabled': _bgEnabled == true,
      'effect_intensity': _intensityIndex == 0
          ? 'low'
          : (_intensityIndex == 2 ? 'high' : 'medium'),
      'wind_direction': _windDir,
    }..removeWhere((k, v) => v == null);

    // capture messenger before awaiting network calls to avoid use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);
    final resp = await AuthService.updateSettings(payload);
    setState(() => _loading = false);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (resp == null || resp['error'] != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(resp?['error']?.toString() ?? l10n.error)),
      );
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    // Immediately update global settings so UI reacts without waiting for reload
    try {
      final sn = context.maybeSettings();
      if (sn != null) {
        sn.updateFromMap(Map<String, dynamic>.from(resp));
      }
    } catch (e) {
      // ignore
    }
    // update local state and preview immediately as well
    setState(() {
      _settings = Map<String, dynamic>.from(resp);
      _cityCtrl.text = _settings['weather_city']?.toString() ?? '';
      final ef = _settings['effect_intensity']?.toString() ?? 'medium';
      _intensityIndex = (ef == 'low') ? 0 : (ef == 'high' ? 2 : 1);
      final wd2 = _settings['wind_direction'];
      _bgEnabled = _settings['background_image_enabled'] == true;
      try {
        if (wd2 != null) {
          if (wd2 is num) {
            _windDir = wd2.round() % 360;
          } else {
            _windDir = int.tryParse(wd2.toString()) ?? 0;
          }
        }
      } catch (e) {
        // ignore
      }
    });
    _updatePreviewFromSettings();
    // still reload from server to ensure persistence: do a short delayed re-fetch
    Future.delayed(const Duration(milliseconds: 500), () async {
      await _load();
    });
  }

  void _updatePreviewFromSettings() {
    try {
      // Priority: weather asset -> seasonal custom -> seasonal asset -> explicit background url
      if (_settings['weather_enabled'] == true &&
          _settings['weather_last_data'] != null) {
        final w = _settings['weather_last_data'];
        String cond = '';
        try {
          cond = (w['weather'] != null && w['weather'].isNotEmpty)
              ? w['weather'][0]['main'].toString().toLowerCase()
              : '';
        } catch (e) {
          cond = '';
        }
        if (cond.contains('rain') || cond.contains('drizzle')) {
          _previewPath = 'assets/weather/rain.png';
        } else if (cond.contains('snow')) {
          _previewPath = 'assets/weather/snow.png';
        } else if (cond.contains('thunder')) {
          _previewPath = 'assets/weather/thunder.png';
        } else if (cond.contains('clear')) {
          _previewPath = 'assets/weather/clear.png';
        } else if (cond.contains('cloud')) {
          _previewPath = 'assets/weather/clouds.png';
        } else if (cond.contains('mist') ||
            cond.contains('fog') ||
            cond.contains('haze')) {
          _previewPath = 'assets/weather/fog.png';
        }
      } else if (_settings['seasonal_ui_enabled'] == true) {
        final custom = _settings['seasonal_custom_bg']?.toString();
        if (custom != null && custom.isNotEmpty) {
          _previewPath = custom;
        } else {
          final month = DateTime.now().month;
          String asset = 'assets/season/spring.png';
          if (month >= 3 && month <= 5) {
            asset = 'assets/season/spring.png';
          } else if (month >= 6 && month <= 8) {
            asset = 'assets/season/summer.png';
          } else if (month >= 9 && month <= 11) {
            asset = 'assets/season/autumn.png';
          } else {
            asset = 'assets/season/winter.png';
          }
          _previewPath = asset;
        }
      } else if (_bgCtrl.text.trim().isNotEmpty) {
        _previewPath = _bgCtrl.text.trim();
      } else if (_settings['background_image_url'] != null &&
          _settings['background_image_url']?.toString().isNotEmpty == true) {
        _previewPath = _settings['background_image_url']?.toString();
      } else {
        _previewPath = null;
      }
    } catch (e) {
      _previewPath = null;
    }
    setState(() {});
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          // Update preview to show selected image
          _previewPath = pickedFile.path;
        });

        // Upload image to server
        await _uploadBackgroundImage(_selectedImageFile!);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cannotSelectImage(e.toString()))));
      }
    }
  }

  Future<void> _uploadBackgroundImage(File imageFile) async {
    try {
      setState(() => _loading = true);
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context)!;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        setState(() => _loading = false);
        messenger.showSnackBar(SnackBar(content: Text(l10n.notLoggedIn)));
        return;
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/background-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      setState(() => _loading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final imageUrl = data['url'] ?? data['image_url'] ?? data['path'];

        if (imageUrl != null) {
          final full = imageUrl.toString().startsWith('http')
              ? imageUrl.toString()
              : '${ApiConfig.baseUrl}$imageUrl';
          setState(() {
            _bgCtrl.text = full;
            _previewPath = full;
          });

          messenger.showSnackBar(
            SnackBar(content: Text('✅ ${l10n.settingsSaved}')),
          );
        }
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('${l10n.error}: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorSavingData(e.toString()))));
      }
    }
  }

  Future<void> _refreshWeather() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_settings['weather_enabled'] == true)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enableWeatherUpdateFirst)));
      return;
    }
    setState(() => _loading = true);
    // capture messenger before awaiting
    final messenger = ScaffoldMessenger.of(context);
    final resp = await AuthService.refreshWeather(
      city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (resp == null || resp['error'] != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(resp?['error']?.toString() ?? l10n.error),
        ),
      );
      return;
    }
    // update local settings with returned data
    setState(() {
      _settings = Map<String, dynamic>.from(resp);
      _cityCtrl.text = _settings['weather_city']?.toString() ?? '';
    });
    // update global settings notifier immediately
    try {
      final sn = context.maybeSettings();
      if (sn != null) {
        sn.updateFromMap(_settings);
      }
    } catch (e) {
      // ignore
    }
    _updatePreviewFromSettings();
    messenger.showSnackBar(SnackBar(content: Text(l10n.weatherUpdated)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Modern SliverAppBar with gradient
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Row(
                      children: [
                        Hero(
                          tag: 'heroSettings',
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade400,
                                  Colors.cyan.shade400,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.settings_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.settings,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.shade600,
                            Colors.blue.shade600,
                            Colors.teal.shade500,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -50,
                            bottom: -50,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.settings_rounded,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section 0: Language Settings
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                final language = context.language();
                                return _buildSectionCard(
                                  title: l10n.language,
                                  icon: Icons.language,
                                  color: Colors.purple,
                                  children: [
                                    _buildModernDropdownTile(
                                      title: l10n.language,
                                      subtitle: language.isVietnamese
                                          ? l10n.vietnamese
                                          : l10n.english,
                                      icon: Icons.translate,
                                      color: Colors.purple,
                                      value: language.locale.languageCode,
                                      items: [
                                        DropdownMenuItem(
                                          value: 'vi',
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.flag_circle,
                                                color: Colors.redAccent,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(l10n.vietnamese),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'en',
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.public,
                                                color: Colors.blueAccent,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(l10n.english),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) async {
                                        if (v == 'vi') {
                                          await language.setVietnamese();
                                        } else if (v == 'en') {
                                          await language.setEnglish();
                                        }
                                        // LanguageProvider will notify listeners and MaterialApp will rebuild automatically
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Section 1: Theme Settings
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return _buildSectionCard(
                                  title: l10n.interface,
                                  icon: Icons.palette,
                                  color: Colors.blue,
                                  children: [
                                    _buildModernDropdownTile(
                                      title: l10n.interfaceMode,
                                      subtitle: _getThemeModeText(
                                        _settings['theme']?.toString() ??
                                            'auto',
                                        l10n,
                                      ),
                                      icon: Icons.brightness_6,
                                      color: Colors.blue,
                                      value:
                                          _settings['theme']?.toString() ??
                                          'auto',
                                      items: [
                                        DropdownMenuItem(
                                          value: 'auto',
                                          child: Text(l10n.automatic),
                                        ),
                                        DropdownMenuItem(
                                          value: 'light',
                                          child: Text(l10n.light),
                                        ),
                                        DropdownMenuItem(
                                          value: 'dark',
                                          child: Text(l10n.dark),
                                        ),
                                      ],
                                      onChanged: (v) => setState(
                                        () => _settings['theme'] = v,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Section 2: Seasonal UI
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return _buildSectionCard(
                                  title: l10n.seasonalInterface,
                                  icon: Icons.nature,
                                  color: Colors.green,
                                  children: [
                                    _buildModernSwitchTile(
                                      title: l10n.seasonalInterface,
                                      subtitle: l10n.autoChangeByMonth,
                                      icon: Icons.auto_awesome,
                                      color: Colors.green,
                                      value:
                                          _settings['seasonal_ui_enabled'] ==
                                          true,
                                      onChanged: (v) => setState(
                                        () => _settings['seasonal_ui_enabled'] =
                                            v,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernDropdownTile(
                                      title: l10n.seasonMode,
                                      subtitle: _getSeasonModeText(
                                        _settings['seasonal_mode']
                                                ?.toString() ??
                                            'auto',
                                        l10n,
                                      ),
                                      icon: Icons.calendar_month,
                                      color: Colors.green,
                                      value:
                                          _settings['seasonal_mode']
                                              ?.toString() ??
                                          'auto',
                                      items: [
                                        DropdownMenuItem(
                                          value: 'auto',
                                          child: Text(l10n.automaticByMonth),
                                        ),
                                        DropdownMenuItem(
                                          value: 'manual',
                                          child: Text(l10n.manual),
                                        ),
                                        DropdownMenuItem(
                                          value: 'off',
                                          child: Text(l10n.off),
                                        ),
                                      ],
                                      onChanged: (v) => setState(
                                        () => _settings['seasonal_mode'] = v,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernSwitchTile(
                                      title: l10n.fallingLeaves,
                                      subtitle: l10n.fallingLeavesEffect,
                                      icon: Icons.eco,
                                      color: Colors.orange,
                                      value:
                                          _settings['falling_leaves_enabled'] !=
                                          false,
                                      onChanged: (v) => setState(
                                        () =>
                                            _settings['falling_leaves_enabled'] =
                                                v,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Section 3: Weather (disabled when seasonal UI is ON)
                            Opacity(
                              opacity: _settings['seasonal_ui_enabled'] == true
                                  ? 0.4
                                  : 1,
                              child: AbsorbPointer(
                                absorbing:
                                    _settings['seasonal_ui_enabled'] == true,
                                child: _buildSectionCard(
                                  title: l10n.weather,
                                  icon: Icons.wb_cloudy,
                                  color: Colors.lightBlue,
                                  children: [
                                    _buildModernSwitchTile(
                                      title: l10n.updateAccordingToWeather,
                                      subtitle: l10n.changeInterfaceByCity,
                                      icon: Icons.cloud,
                                      color: Colors.lightBlue,
                                      value:
                                          _settings['weather_enabled'] == true,
                                      onChanged: (v) => setState(
                                        () => _settings['weather_enabled'] = v,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernSwitchTile(
                                      title: l10n.weatherEffects,
                                      subtitle: l10n.rainSnowFog,
                                      icon: Icons.water_drop,
                                      color: Colors.cyan,
                                      value:
                                          _settings['weather_effects_enabled'] !=
                                          false,
                                      onChanged: (v) => setState(
                                        () =>
                                            _settings['weather_effects_enabled'] =
                                                v,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildModernTextField(
                                      controller: _cityCtrl,
                                      label: l10n.weatherCity,
                                      hint: l10n.weatherCityHint,
                                      icon: Icons.location_city,
                                      color: Colors.lightBlue,
                                      enabled:
                                          _settings['weather_enabled'] == true,
                                    ),
                                    if (_settings['weather_last_data'] !=
                                        null) ...[
                                      const SizedBox(height: 12),
                                      _buildWeatherInfo(),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Section 4: Effects Intensity
                            _buildSectionCard(
                              title: l10n.effectIntensity,
                              icon: Icons.tune,
                              color: Colors.deepPurple,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.shade50,
                                        Colors.purple.shade50,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.deepPurple.shade200,
                                    ),
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
                                                  Colors.deepPurple.shade400,
                                                  Colors.purple.shade600,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.auto_fix_high,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            l10n.effectIntensityTitle,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple.shade900,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    Colors.deepPurple.shade300,
                                              ),
                                            ),
                                            child: Text(
                                              _intensityIndex == 0
                                                  ? l10n.low
                                                  : (_intensityIndex == 2
                                                        ? l10n.high
                                                        : l10n.medium),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Colors.deepPurple.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor:
                                              Colors.deepPurple.shade400,
                                          inactiveTrackColor:
                                              Colors.deepPurple.shade100,
                                          thumbColor:
                                              Colors.deepPurple.shade600,
                                          overlayColor:
                                              Colors.deepPurple.shade100,
                                          valueIndicatorColor:
                                              Colors.deepPurple.shade600,
                                        ),
                                        child: Slider(
                                          value: _intensityIndex.toDouble(),
                                          min: 0,
                                          max: 2,
                                          divisions: 2,
                                          label: _intensityIndex == 0
                                              ? l10n.low
                                              : (_intensityIndex == 2
                                                    ? l10n.high
                                                    : l10n.medium),
                                          onChanged: (v) => setState(
                                            () => _intensityIndex = v.round(),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildIntensityButton(l10n.low, 0),
                                          _buildIntensityButton(l10n.medium, 1),
                                          _buildIntensityButton(l10n.high, 2),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Section 5: Wind Direction
                            _buildSectionCard(
                              title: l10n.windDirectionTitle,
                              icon: Icons.air,
                              color: Colors.teal,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.teal.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.shade400,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Transform.rotate(
                                              angle: _windDir * 3.14159 / 180,
                                              child: const Icon(
                                                Icons.navigation,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.weatherAngle(_windDir),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal.shade900,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.teal.shade300,
                                              ),
                                            ),
                                            child: Text(
                                              _getWindDirection(_windDir),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor:
                                              Colors.teal.shade400,
                                          inactiveTrackColor:
                                              Colors.teal.shade100,
                                          thumbColor: Colors.teal.shade600,
                                          overlayColor: Colors.teal.shade100,
                                          valueIndicatorColor:
                                              Colors.teal.shade600,
                                        ),
                                        child: Slider(
                                          value: _windDir.toDouble(),
                                          min: 0,
                                          max: 360,
                                          divisions: 36,
                                          label: l10n.weatherAngle(_windDir),
                                          onChanged: (v) => setState(
                                            () => _windDir = v.round(),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildWindButton('N', 0),
                                          _buildWindButton('E', 90),
                                          _buildWindButton('S', 180),
                                          _buildWindButton('W', 270),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Section 6: Background Image (disabled when seasonal UI is ON)
                            Opacity(
                              opacity: _settings['seasonal_ui_enabled'] == true
                                  ? 0.4
                                  : 1,
                              child: AbsorbPointer(
                                absorbing:
                                    _settings['seasonal_ui_enabled'] == true,
                                child: _buildSectionCard(
                                  title: l10n.useCustomBackgroundImage,
                                  icon: Icons.wallpaper,
                                  color: Colors.pink,
                                  children: [
                                    // Button to pick image from gallery
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ElevatedButton.icon(
                                        onPressed: _pickImageFromGallery,
                                        icon: const Icon(
                                          Icons.photo_library,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          l10n.pickFromGallery,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pink.shade600,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    _buildModernTextField(
                                      controller: _bgCtrl,
                                      label: l10n.backgroundImageUrl,
                                      hint: 'https://...',
                                      icon: Icons.link,
                                      color: Colors.pink,
                                      keyboardType: TextInputType.url,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildModernSwitchTile(
                                      title: l10n.useCustomBackgroundImage,
                                      subtitle:
                                          l10n.applyBackgroundImageSubtitle,
                                      icon: Icons.image,
                                      color: Colors.pink,
                                      value: _bgEnabled,
                                      onChanged: (v) =>
                                          setState(() => _bgEnabled = v),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPreviewSection(context),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade500,
                                          Colors.purple.shade500,
                                          Colors.purple.shade600,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade400
                                              .withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.purple.shade300
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Decorative corner element
                                        Positioned(
                                          right: -10,
                                          top: -10,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                  Colors.white.withValues(
                                                    alpha: 0.05,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _save,
                                          icon: const Icon(
                                            Icons.save_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          label: Text(
                                            l10n.save,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.teal.shade500,
                                          Colors.green.shade500,
                                          Colors.green.shade600,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.shade400
                                              .withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.green.shade300
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Decorative corner element
                                        Positioned(
                                          left: -10,
                                          bottom: -10,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                  Colors.white.withValues(
                                                    alpha: 0.05,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _refreshWeather,
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          label: Text(
                                            l10n.weatherUpdated,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper methods for modern UI
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.shade400, color.shade600, color.shade700],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.shade50,
            Colors.white,
            color.shade50.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? color.shade300 : color.shade100,
          width: 2,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: value
                        ? [color.shade400, color.shade600]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (value ? color : Colors.grey).withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              if (value)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: value ? color.shade900 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: value ? color.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: value ? color.shade200 : Colors.grey.shade300,
              ),
            ),
            child: Transform.scale(
              scale: 1.1,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: color.shade600,
                activeTrackColor: color.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: color.shade600, size: 20),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.shade800,
            ),
            isDense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required MaterialColor color,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: enabled
              ? [Colors.white, color.shade50.withValues(alpha: 0.3)]
              : [Colors.grey.shade100, Colors.grey.shade200],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled ? color.withValues(alpha: 0.4) : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Decorative element
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.05), Colors.transparent],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(60),
                ),
              ),
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(
              fontSize: 15,
              color: enabled ? Colors.black87 : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: TextStyle(
                color: color.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: enabled
                        ? [color.shade400, color.shade600]
                        : [Colors.grey.shade400, Colors.grey.shade500],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (enabled ? color : Colors.grey).withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              suffixIcon: enabled
                  ? Icon(Icons.edit_outlined, color: color.shade400, size: 20)
                  : Icon(
                      Icons.lock_outline,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityButton(String label, int index) {
    final isSelected = _intensityIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _intensityIndex = index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.purple.shade600,
                      Colors.purple.shade700,
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.deepPurple.shade700
                  : Colors.deepPurple.shade200,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.deepPurple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewPlaceholder(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade100, Colors.grey.shade200],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noImage,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewNetwork(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (c, u) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.pink.shade100],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          ),
        ),
      ),
      errorWidget: (c, u, e) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade200],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(
                    l10n.error,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  Widget _buildWindButton(String label, int degrees) {
    final isSelected = (_windDir - degrees).abs() < 5;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _windDir = degrees),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal.shade400 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.teal.shade700 : Colors.teal.shade200,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.teal.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeModeText(String mode, AppLocalizations l10n) {
    switch (mode) {
      case 'auto':
        return l10n.automatic;
      case 'light':
        return l10n.light;
      case 'dark':
        return l10n.dark;
      default:
        return l10n.automatic;
    }
  }

  String _getSeasonModeText(String mode, AppLocalizations l10n) {
    switch (mode) {
      case 'auto':
        return l10n.automaticByMonth;
      case 'manual':
        return l10n.manual;
      case 'off':
        return l10n.off;
      default:
        return l10n.automaticByMonth;
    }
  }

  String _getWindDirection(int degrees) {
    final l10n = AppLocalizations.of(context)!;
    if (degrees >= 337.5 || degrees < 22.5) return l10n.windNorth;
    if (degrees >= 22.5 && degrees < 67.5) return l10n.windNorthEast;
    if (degrees >= 67.5 && degrees < 112.5) return l10n.windEast;
    if (degrees >= 112.5 && degrees < 157.5) return l10n.windSouthEast;
    if (degrees >= 157.5 && degrees < 202.5) return l10n.windSouth;
    if (degrees >= 202.5 && degrees < 247.5) return l10n.windSouthWest;
    if (degrees >= 247.5 && degrees < 292.5) return l10n.windWest;
    if (degrees >= 292.5 && degrees < 337.5) return l10n.windNorthWest;
    return 'N/A';
  }

  Widget _buildWeatherInfo() {
    final weather = _settings['weather_last_data'];
    if (weather == null) return const SizedBox();

    String condition = '—';
    String temp = '—';
    IconData weatherIcon = Icons.wb_sunny;
    MaterialColor weatherColor = Colors.orange;

    try {
      if (weather['weather'] != null && weather['weather'].isNotEmpty) {
        condition = weather['weather'][0]['description']?.toString() ?? '—';
        final main =
            weather['weather'][0]['main']?.toString().toLowerCase() ?? '';

        if (main.contains('rain') || main.contains('drizzle')) {
          weatherIcon = Icons.water_drop;
          weatherColor = Colors.blue;
        } else if (main.contains('snow')) {
          weatherIcon = Icons.ac_unit;
          weatherColor = Colors.lightBlue;
        } else if (main.contains('thunder')) {
          weatherIcon = Icons.flash_on;
          weatherColor = Colors.amber;
        } else if (main.contains('cloud')) {
          weatherIcon = Icons.cloud;
          weatherColor = Colors.grey;
        } else if (main.contains('clear')) {
          weatherIcon = Icons.wb_sunny;
          weatherColor = Colors.orange;
        }
      }
      if (weather['main'] != null) {
        temp = '${weather['main']['temp']}°C';
      }
    } catch (e) {
      // ignore
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [weatherColor.shade50, weatherColor.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: weatherColor.shade300, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [weatherColor.shade400, weatherColor.shade600],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(weatherIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: weatherColor.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  temp,
                  style: TextStyle(fontSize: 14, color: weatherColor.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade400, Colors.pink.shade600],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.visibility,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.previewBackground,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade900,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink.shade100, Colors.pink.shade50],
            ),
            border: Border.all(color: Colors.pink.shade300, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.shade200.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.pink.shade100.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Builder(
                  builder: (_) {
                    if (_previewPath == null || _previewPath!.isEmpty) {
                      return _buildPreviewPlaceholder(l10n);
                    }

                    final p = _previewPath!;
                    if (p.startsWith('http')) {
                      return _buildPreviewNetwork(p);
                    }
                    if (p.startsWith('/uploads')) {
                      final full = '${ApiConfig.baseUrl}$p';
                      return _buildPreviewNetwork(full);
                    }
                    if (p.startsWith('file://') || p.startsWith('/')) {
                      return Image.file(
                        File(p),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    }
                    return Image.asset(
                      p,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  },
                ),
              ),
              // Decorative overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.preview,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Preview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _cityCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }
}
