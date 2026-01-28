import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../fitness_app_theme.dart';
import '../services/ai_analysis_service.dart';
import '../services/local_notification_service.dart';
import '../widgets/nutrition_result_table.dart';
import '../widgets/profile_provider.dart';

/// Screen để phân tích hình ảnh thức ăn/đồ uống bằng AI
class AiImageAnalysisScreen extends StatefulWidget {
  const AiImageAnalysisScreen({super.key});

  @override
  State<AiImageAnalysisScreen> createState() => _AiImageAnalysisScreenState();
}

class _AiImageAnalysisScreenState extends State<AiImageAnalysisScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _originalFilename;
  List<Map<String, dynamic>> _analyzedItems = [];
  bool _isAnalyzing = false;
  String? _errorMessage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // Store original filename from XFile.name
        _originalFilename = image.name;
        setState(() {
          _selectedImage = File(image.path);
          _analyzedItems = [];
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn ảnh: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn ảnh trước';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final items = await AiAnalysisService.analyzeImage(
        _selectedImage!,
        originalFilename: _originalFilename,
      );

      setState(() {
        _analyzedItems = items;
        _isAnalyzing = false;
      });

      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Lỗi phân tích: $e';
      });
    }
  }

  Future<void> _acceptItem(int itemId) async {
    try {
      final todayTotals = await AiAnalysisService.acceptAnalysis(itemId);

      // Update ProfileProvider with new totals
      if (todayTotals != null && mounted) {
        context.profile().applyTodayTotals(todayTotals);
      }

      if (mounted) {
        // Show local notification
        final item = _analyzedItems.firstWhere(
          (item) => item['id'] == itemId,
          orElse: () => {'item_name': 'Món ăn'},
        );
        final foodName = item['item_name'] ?? 'Món ăn';
        await LocalNotificationService().notifyNutritionAcceptedFromAI(
          foodName,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chấp nhận và lưu vào hệ thống!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Remove accepted item from list
        setState(() {
          _analyzedItems.removeWhere((item) => item['id'] == itemId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectItem(int itemId) async {
    try {
      await AiAnalysisService.rejectAnalysis(itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã từ chối'),
            duration: Duration(seconds: 1),
          ),
        );

        setState(() {
          _analyzedItems.removeWhere((item) => item['id'] == itemId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        title: const Text('Phân tích hình ảnh AI'),
        backgroundColor: FitnessAppTheme.nearlyWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image picker section
            _buildImagePickerSection(),
            const SizedBox(height: 20),

            // Analyze button
            if (_selectedImage != null) _buildAnalyzeButton(),

            const SizedBox(height: 20),

            // Loading indicator
            if (_isAnalyzing) _buildLoadingIndicator(),

            // Error message
            if (_errorMessage != null) _buildErrorMessage(),

            // Analysis results
            if (_analyzedItems.isNotEmpty) _buildResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedImage == null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  label: const Text(
                    'Chụp ảnh',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 1,
                    side: BorderSide(color: FitnessAppTheme.nearlyDarkBlue),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, color: Colors.black),
                  label: const Text(
                    'Thư viện',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 1,
                    side: BorderSide(color: FitnessAppTheme.nearlyDarkBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton.icon(
      onPressed: _isAnalyzing ? null : _analyzeImage,
      icon: const Icon(Icons.analytics, size: 28),
      label: const Text(
        'Phân tích ngay',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang phân tích hình ảnh...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kết quả phân tích:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(_analyzedItems.length, (index) {
          final item = _analyzedItems[index];
          return FadeTransition(
            opacity: _animationController,
            child: _buildItemCard(item, index),
          );
        }),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final nutrients = item['nutrients'] as Map<String, dynamic>? ?? {};
    final nutrientsList = nutrients.entries
        .where((e) => e.value != null && e.value > 0)
        .map(
          (e) => {
            'nutrient_code': e.key.toUpperCase(),
            'nutrient_name': _getNutrientName(e.key),
            'amount': e.value,
            'unit': _getNutrientUnit(e.key),
          },
        )
        .toList();

    return NutritionResultTable(
      foodName: item['item_name'] ?? 'Món ăn',
      confidence: (item['confidence_score'] ?? 0.0).toDouble(),
      nutrients: nutrientsList,
      onApprove: () => _acceptItem(item['id'] as int),
      onReject: () => _rejectItem(item['id'] as int),
      isLoading: false,
    );
  }

  /// Get user-friendly nutrient name
  String _getNutrientName(String code) {
    final names = {
      // Macros
      'enerc_kcal': 'Calories',
      'procnt': 'Protein',
      'chocdf': 'Total Carbohydrate',
      'fat': 'Total Fat',
      'water': 'Water',

      // All Vitamins (13)
      'vita': 'Vitamin A',
      'vitd': 'Vitamin D',
      'vite': 'Vitamin E',
      'vitk': 'Vitamin K',
      'vitc': 'Vitamin C',
      'vitb1': 'Vitamin B1 (Thiamine)',
      'vitb2': 'Vitamin B2 (Riboflavin)',
      'vitb3': 'Vitamin B3 (Niacin)',
      'vitb5': 'Vitamin B5 (Pantothenic Acid)',
      'vitb6': 'Vitamin B6 (Pyridoxine)',
      'vitb7': 'Vitamin B7 (Biotin)',
      'vitb9': 'Vitamin B9 (Folate)',
      'vitb12': 'Vitamin B12 (Cobalamin)',

      // All Minerals (14)
      'ca': 'Calcium',
      'p': 'Phosphorus',
      'mg': 'Magnesium',
      'k': 'Potassium',
      'na': 'Sodium',
      'fe': 'Iron',
      'zn': 'Zinc',
      'cu': 'Copper',
      'mn': 'Manganese',
      'i': 'Iodine',
      'se': 'Selenium',
      'cr': 'Chromium',
      'mo': 'Molybdenum',
      'f': 'Fluoride',

      // All Amino Acids (9)
      'amino_his': 'Histidine',
      'amino_ile': 'Isoleucine',
      'amino_leu': 'Leucine',
      'amino_lys': 'Lysine',
      'amino_met': 'Methionine',
      'amino_phe': 'Phenylalanine',
      'amino_thr': 'Threonine',
      'amino_trp': 'Tryptophan',
      'amino_val': 'Valine',

      // Fiber (5)
      'fibtg': 'Dietary Fiber',
      'total_fiber': 'Total Dietary Fiber',
      'fib_sol': 'Soluble Fiber',
      'fib_insol': 'Insoluble Fiber',
      'fib_rs': 'Resistant Starch',
      'fib_bglu': 'Beta-Glucan',

      // Fatty Acids (10)
      'total_fat': 'Total Fat',
      'fams': 'Monounsaturated Fat (MUFA)',
      'fapu': 'Polyunsaturated Fat (PUFA)',
      'fasat': 'Saturated Fat (SFA)',
      'fatrn': 'Trans Fat',
      'faepa': 'EPA',
      'fadha': 'DHA',
      'faepa_dha': 'EPA + DHA',
      'epa_dha': 'EPA + DHA',
      'fa18_2n6c': 'Linoleic Acid (LA)',
      'fa18_3n3': 'Alpha-Linolenic Acid (ALA)',
      'ala': 'Alpha-Linolenic Acid (ALA)',
      'la': 'Linoleic Acid (LA)',
      'cholesterol': 'Cholesterol',
    };
    return names[code.toLowerCase()] ?? code.toUpperCase();
  }

  /// Get nutrient unit
  String _getNutrientUnit(String code) {
    final lowerCode = code.toLowerCase();
    if (lowerCode == 'enerc_kcal') return 'kcal';
    if (lowerCode == 'water') return 'ml';
    if (lowerCode.startsWith('vit')) {
      if (lowerCode == 'vitd') return 'IU';
      if (lowerCode == 'vitb12') return 'µg';
      return lowerCode == 'vita' ? 'µg' : 'mg';
    }
    if (lowerCode.startsWith('min_')) return 'mg';
    return 'g'; // default for macros and fiber
  }
}
