import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_diary/widgets/nutrition_result_table.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class PhotoRecognitionDialog extends StatefulWidget {
  final String mealType;

  const PhotoRecognitionDialog({super.key, required this.mealType});

  @override
  State<PhotoRecognitionDialog> createState() => _PhotoRecognitionDialogState();
}

class _PhotoRecognitionDialogState extends State<PhotoRecognitionDialog> {
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _nutritionResult;

  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (!mounted) return;

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (!mounted) return;
        setState(() {
          _image = photo;
          _imageBytes = bytes;
        });
        await _analyzePhoto();
      }
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context)!.cannotTakePhoto(e.toString()));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return;

      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _image = image;
          _imageBytes = bytes;
        });
        await _analyzePhoto();
      }
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context)!.cannotSelectImage(e.toString()));
    }
  }

  Future<void> _analyzePhoto() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
      _nutritionResult = null;
    });

    try {
      // Read image and convert to base64
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (!mounted) return;

      // Call Python AI API directly
      final response = await http.post(
        Uri.parse('http://localhost:8000/analyze-nutrition'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image': base64Image}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['is_food'] == true) {
          setState(() {
            _nutritionResult = {
              'food_name': result['food_name'],
              'confidence': result['confidence'],
              'nutrients': result['nutrients'],
            };
            _isAnalyzing = false;
          });
        } else {
          setState(() => _isAnalyzing = false);
          if (!mounted) return;
          _showError(AppLocalizations.of(context)!.cannotRecognizeFood);
        }
      } else {
        setState(() => _isAnalyzing = false);
        if (!mounted) return;
        _showError(AppLocalizations.of(context)!.errorAnalyzingImage);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      _showError(
        AppLocalizations.of(context)!.errorConnectingToAI(e.toString()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildNutritionResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(_imageBytes!, height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          NutritionResultTable(
            foodName:
                _nutritionResult!['food_name'] ??
                AppLocalizations.of(context)!.defaultDishName,
            confidence: (_nutritionResult!['confidence'] ?? 0.0).toDouble(),
            nutrients: List<Map<String, dynamic>>.from(
              _nutritionResult!['nutrients'] ?? [],
            ),
            onApprove: () async {
              // Save to database via API
              try {
                final messenger = ScaffoldMessenger.of(context);
                final l10n = AppLocalizations.of(context)!;
                final prefs = await SharedPreferences.getInstance();
                final token =
                    prefs.getString('auth_token') ?? prefs.getString('token');

                if (!mounted) return;

                if (token != null) {
                  final response = await http.post(
                    Uri.parse('${ApiConfig.baseUrl}/nutrients/approve-scan'),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'food_name': _nutritionResult!['food_name'],
                      'nutrients': _nutritionResult!['nutrients'],
                    }),
                  );

                  if (!mounted) return;

                  final data = response.body.isNotEmpty
                      ? json.decode(response.body)
                      : null;

                  if (response.statusCode == 200 && data?['success'] == true) {
                    final today = data['today'];
                    if (today is Map<String, dynamic>) {
                      final profile = context.maybeProfile();
                      profile?.applyTodayTotals({
                        'today_calories':
                            today['total_calories'] ?? today['today_calories'],
                        'today_protein':
                            today['total_protein'] ?? today['today_protein'],
                        'today_fat': today['total_fat'] ?? today['today_fat'],
                        'today_carbs':
                            today['total_carbs'] ?? today['today_carbs'],
                      });
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.savedNutritionInfo(
                                  _nutritionResult!['food_name'] ??
                                      l10n.defaultDishName.toLowerCase(),
                                ),
                              );
                            },
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else if (mounted) {
                    final detail = data?['message'] ?? l10n.errorSavingData('');
                    messenger.showSnackBar(
                      SnackBar(content: Text(detail.toString())),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  final l10n = AppLocalizations.of(context)!;
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.saveDataError('$e'))),
                  );
                }
              }
            },
            onReject: () {
              setState(() {
                _image = null;
                _imageBytes = null;
                _nutritionResult = null;
              });
            },
            isLoading: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: FitnessAppTheme.background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FitnessAppTheme.nearlyBlue,
                    FitnessAppTheme.nearlyBlue.withValues(alpha: 0.8),
                  ],
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
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.recognizeDish,
                      style: const TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _image == null
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Camera options
                          _buildActionButton(
                            icon: Icons.camera_alt,
                            label: l10n.takePhoto,
                            color: FitnessAppTheme.nearlyBlue,
                            onTap: _takePhoto,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.photo_library,
                            label: l10n.pickFromGallery,
                            color: Colors.green,
                            onTap: _pickFromGallery,
                          ),
                        ],
                      ),
                    )
                  : _nutritionResult != null
                  ? _buildNutritionResult()
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Show selected image
                          if (_imageBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _imageBytes!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 16),

                          if (_isAnalyzing) ...[
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              l10n.analyzingImage,
                              style: const TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontSize: 14,
                                color: FitnessAppTheme.grey,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _image = null;
                                _imageBytes = null;
                                _nutritionResult = null;
                              });
                            },
                            child: Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return Text(l10n.retakePhoto);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
