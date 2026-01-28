import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../fitness_app_theme.dart';
import '../services/drink_service.dart';
import '../services/food_service.dart';
import '../services/local_notification_service.dart';
import '../services/social_service.dart';
import '../l10n/app_localizations.dart';

class CreateDrinkScreen extends StatefulWidget {
  const CreateDrinkScreen({super.key});

  @override
  createState() => _CreateDrinkScreenState();
}

class _CreateDrinkScreenState extends State<CreateDrinkScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vietnameseNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  String _selectedCategory = 'water';
  final List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isSubmitting = false;
  Map<String, Map<String, dynamic>> _estimatedNutrients = {};
  bool _checkingName = false;
  String? _nameError;
  Timer? _nameCheckTimer;

  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedImageMimeType;
  String? _selectedImageFilename;
  bool _uploadingImage = false;

  static const Map<String, Map<String, String>> _drinkCategoryMeta = {
    'water': {'label': 'Nước', 'icon': '💧'},
    'infused_water': {'label': 'Nước ngâm', 'icon': '🍋'},
    'juice': {'label': 'Nước ép', 'icon': '🧃'},
    'tea': {'label': 'Trà', 'icon': '🍵'},
    'herbal_tea': {'label': 'Trà thảo mộc', 'icon': '🌿'},
    'herbal': {'label': 'Thảo mộc', 'icon': '🌿'},
    'coffee': {'label': 'Cà phê', 'icon': '☕'},
    'milk': {'label': 'Sữa', 'icon': '🥛'},
    'smoothie': {'label': 'Sinh tố', 'icon': '🥤'},
    'functional': {'label': 'Chức năng', 'icon': '⚡'},
    'soda': {'label': 'Nước ngọt', 'icon': '🥤'},
    'fermented': {'label': 'Lên men', 'icon': '🫧'},
  };

  List<Map<String, String>> _categories = [
    for (final entry in _drinkCategoryMeta.entries)
      {
        'value': entry.key,
        'label': entry.value['label']!,
        'icon': entry.value['icon']!,
      },
  ];

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Floating animation for icons
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Pulse animation for add button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _loadDrinkCategories();
    _loadInitialFoods();

    // Add listeners for name validation
    _nameController.addListener(_onNameChanged);
    _vietnameseNameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // Debounce name checking
    _nameCheckTimer?.cancel();
    _nameCheckTimer = Timer(
      const Duration(milliseconds: 500),
      _checkNameExists,
    );
  }

  Future<void> _checkNameExists() async {
    final name = _nameController.text.trim();
    final vnName = _vietnameseNameController.text.trim();

    if (name.isEmpty && vnName.isEmpty) {
      setState(() {
        _nameError = null;
        _checkingName = false;
      });
      return;
    }

    setState(() {
      _checkingName = true;
      _nameError = null;
    });

    try {
      final exists = await DrinkService.checkNameExists(
        name: name.isNotEmpty ? name : null,
        vietnameseName: vnName.isNotEmpty ? vnName : null,
      );

      if (!mounted) return;

      setState(() {
        _checkingName = false;
        if (exists) {
          final duplicateName = name.isNotEmpty
              ? (vnName.isNotEmpty ? '$name hoặc $vnName' : name)
              : vnName;
          _nameError = '$duplicateName đã có trong hệ thống';
        } else {
          _nameError = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checkingName = false;
        _nameError = null; // Don't show error on API failure
      });
    }
  }

  @override
  void dispose() {
    _nameCheckTimer?.cancel();
    _nameController.dispose();
    _vietnameseNameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadDrinkCategories() async {
    try {
      final drinks = await DrinkService.fetchCatalog();
      if (!mounted || drinks.isEmpty) return;

      final fromCatalog = drinks
          .map((d) => (d['category'] ?? '').toString())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();

      if (fromCatalog.isEmpty) return;

      final ordered = <String>[..._drinkCategoryMeta.keys];
      final extra =
          fromCatalog
              .where((value) => !_drinkCategoryMeta.containsKey(value))
              .toList()
            ..sort();
      ordered.addAll(extra);

      final mapped = ordered.map((value) {
        final meta = _drinkCategoryMeta[value];
        return <String, String>{
          'value': value,
          'label': meta?['label'] ?? value,
          'icon': meta?['icon'] ?? '🥤',
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _categories = mapped;
        if (_categories.indexWhere((c) => c['value'] == _selectedCategory) ==
            -1) {
          _selectedCategory = _categories.first['value']!;
        }
      });
    } catch (e) {
      debugPrint('Error loading drink categories: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageMimeType = image.mimeType ?? 'image/png';
        _selectedImageFilename = image.name;
      });
    } catch (e) {
      debugPrint('Error picking drink image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadInitialFoods() async {
    setState(() => _isSearching = true);
    try {
      final results = await FoodService.searchFoods('', limit: 100);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error loading foods: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) {
      _loadInitialFoods();
      return;
    }

    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await FoodService.searchFoods(query, limit: 20);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
      }
    }
  }

  void _addIngredient(Map<String, dynamic> food) {
    setState(() {
      _ingredients.add({
        'food_id': food['food_id'],
        'food_name': food['name'],
        'weight_g': 100.0,
      });
      _searchResults = [];
      _searchController.clear();
    });
    _calculateEstimatedNutrients();
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
    _calculateEstimatedNutrients();
  }

  void _updateIngredientWeight(int index, double weight) {
    setState(() {
      _ingredients[index]['weight_g'] = weight;
    });
    _calculateEstimatedNutrients();
  }

  Future<void> _calculateEstimatedNutrients() async {
    if (_ingredients.isEmpty) {
      setState(() {
        _estimatedNutrients = {};
      });
      return;
    }

    final Map<String, Map<String, dynamic>> aggregatedNutrients = {};

    for (final ingredient in _ingredients) {
      final foodId = ingredient['food_id'] as int;
      final weightG = (ingredient['weight_g'] as num).toDouble();

      final foodDetails = await FoodService.getFoodDetails(foodId);
      if (foodDetails == null) continue;

      final nutrients = foodDetails['nutrients'] as List<dynamic>? ?? [];
      final multiplier = weightG / 100.0;

      for (final nutrient in nutrients) {
        final nutrientName = nutrient['nutrient_name'] as String;
        final amountPer100g = ((nutrient['amount_per_100g'] ?? 0) as num)
            .toDouble();
        final unit = nutrient['unit'] as String? ?? '';

        final scaledAmount = amountPer100g * multiplier;

        if (aggregatedNutrients.containsKey(nutrientName)) {
          aggregatedNutrients[nutrientName]!['amount'] += scaledAmount;
        } else {
          aggregatedNutrients[nutrientName] = {
            'amount': scaledAmount,
            'unit': unit,
          };
        }
      }
    }

    setState(() {
      _estimatedNutrients = aggregatedNutrients;
    });
  }

  Future<void> _submitDrink() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final locale = Localizations.localeOf(context);
              return Text(
                locale.languageCode == 'vi'
                    ? 'Vui lòng nhập tên đồ uống'
                    : 'Please enter drink name',
              );
            },
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check name exists one more time before saving
    if (_nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_nameError!), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.pleaseAddAtLeastOneIngredient);
            },
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final totalWeight = _ingredients.fold<double>(
        0,
        (sum, ingredient) => sum + (ingredient['weight_g'] as num).toDouble(),
      );

      String? imageUrl;
      if (_selectedImageBytes != null) {
        setState(() => _uploadingImage = true);
        try {
          imageUrl = await SocialService.uploadImage(
            _selectedImageBytes!,
            folder: 'drinks',
            mimeType: _selectedImageMimeType,
            filename: _selectedImageFilename,
          );
        } catch (e) {
          setState(() => _isSubmitting = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi tải ảnh: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        } finally {
          if (mounted) {
            setState(() => _uploadingImage = false);
          }
        }
      }

      final result = await DrinkService.createCustomDrink({
        'name': _nameController.text.trim(),
        'vietnamese_name': _vietnameseNameController.text.trim().isNotEmpty
            ? _vietnameseNameController.text.trim()
            : null,
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'category': _selectedCategory,
        'default_volume_ml': totalWeight,
        'image_url': imageUrl,
        'ingredients': _ingredients
            .map(
              (ing) => {'food_id': ing['food_id'], 'amount_g': ing['weight_g']},
            )
            .toList(),
      });

      if (result != null && result['error'] != null) {
        throw Exception(result['error']);
      }

      if (mounted) {
        // Show local notification
        final drinkName = _vietnameseNameController.text.trim().isNotEmpty
            ? _vietnameseNameController.text.trim()
            : _nameController.text.trim();
        await LocalNotificationService().notifyDrinkCreated(drinkName);

        if (!mounted) return;

        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.drinkCreated);
              },
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorColon} $e');
              },
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF1F4F8),
              const Color(0xFFE8EFF9),
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(),
                        const SizedBox(height: 24),
                        _buildCategorySection(),
                        const SizedBox(height: 24),
                        _buildIngredientsSection(),
                        const SizedBox(height: 24),
                        _buildNutrientPreview(),
                        if (_estimatedNutrients.isNotEmpty)
                          const SizedBox(height: 24),
                        _buildSearchSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildSubmitButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade400.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_drink,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tạo Món Đồ Uống Mới',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Món của bạn, chỉ bạn mới thấy',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông Tin Đồ Uống',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: FitnessAppTheme.nearlyDarkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên đồ uống (tiếng Anh) *',
              labelStyle: const TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
              ),
              hintText: 'vd: Coconut Water',
              filled: true,
              fillColor: FitnessAppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              errorText: _nameError,
              suffixIcon: _checkingName
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _vietnameseNameController,
            decoration: InputDecoration(
              labelText: 'Tên đồ uống (tiếng Việt)',
              labelStyle: const TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
              ),
              hintText: 'vd: Nước dừa',
              filled: true,
              fillColor: FitnessAppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Mô tả',
              labelStyle: const TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
              ),
              hintText: 'vd: Nước dừa tươi, giàu khoáng...',
              filled: true,
              fillColor: FitnessAppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ảnh đồ uống',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: FitnessAppTheme.nearlyDarkBlue,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: (_isSubmitting || _uploadingImage)
                    ? null
                    : _pickImage,
                icon: Icon(
                  Icons.photo_library,
                  color: (_isSubmitting || _uploadingImage)
                      ? Colors.grey
                      : Colors.blue,
                ),
                label: Text(
                  _selectedImageBytes == null ? 'Chọn ảnh' : 'Đổi ảnh',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    color: (_isSubmitting || _uploadingImage)
                        ? Colors.grey
                        : Colors.blue,
                  ),
                ),
              ),
              if (_selectedImageBytes != null)
                IconButton(
                  onPressed: (_isSubmitting || _uploadingImage)
                      ? null
                      : () {
                          setState(() {
                            _selectedImageBytes = null;
                            _selectedImageMimeType = null;
                            _selectedImageFilename = null;
                          });
                        },
                  icon: Icon(
                    Icons.close,
                    color: (_isSubmitting || _uploadingImage)
                        ? Colors.grey
                        : Colors.red.shade400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _selectedImageBytes != null
                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                  : Container(
                      color: FitnessAppTheme.background,
                      child: const Center(
                        child: Text(
                          'Chưa có ảnh',
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w600,
                            color: FitnessAppTheme.grey,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          if (_uploadingImage) const SizedBox(height: 12),
          if (_uploadingImage)
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: FitnessAppTheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Loại Đồ Uống',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: FitnessAppTheme.nearlyDarkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category['value'];
              return InkWell(
                onTap: () {
                  setState(() => _selectedCategory = category['value']!);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          )
                        : null,
                    color: isSelected ? null : FitnessAppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : FitnessAppTheme.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category['icon']!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category['label']!,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : FitnessAppTheme.nearlyDarkBlue,
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
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.food_bank,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nguyên Liệu',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: FitnessAppTheme.nearlyDarkBlue,
                ),
              ),
              const Spacer(),
              if (_ingredients.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_ingredients.length} nguyên liệu',
                    style: const TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_ingredients.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 64,
                    color: FitnessAppTheme.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        children: [
                          Text(
                            l10n.noIngredients,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 14,
                              color: FitnessAppTheme.grey.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.searchAndAddIngredientsBelow,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 12,
                              color: FitnessAppTheme.grey.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
          else
            Column(
              children: _ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Container(
                  key: ValueKey('ingredient_$index'),
                  child: _buildIngredientItem(index, ingredient),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(int index, Map<String, dynamic> ingredient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FitnessAppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FitnessAppTheme.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.food_bank, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient['food_name'],
                  style: const TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: FitnessAppTheme.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          initialValue: ingredient['weight_g'].toString(),
                          decoration: InputDecoration(
                            hintText: '100',
                            suffixText: 'g',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            suffixStyle: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 12,
                              color: FitnessAppTheme.grey,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          onChanged: (value) {
                            final weight = double.tryParse(value);
                            if (weight != null && weight > 0) {
                              _updateIngredientWeight(index, weight);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _removeIngredient(index),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tìm Nguyên Liệu',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: FitnessAppTheme.nearlyDarkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nguyên liệu (vd: Thịt bò, Rau)...',
              hintStyle: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
                color: FitnessAppTheme.grey.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                  : null,
              filled: true,
              fillColor: FitnessAppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {});
              _searchFoods(value);
            },
          ),
          if (_isSearching) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(
                  color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: FitnessAppTheme.grey.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final food = _searchResults[index];
                  return InkWell(
                    onTap: () => _addIngredient(food),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food['name'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (food['category'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    food['category'],
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontSize: 11,
                                      color: FitnessAppTheme.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSubmitting ? 1.0 : _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isSubmitting
                    ? [Colors.grey, Colors.grey.shade600]
                    : [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                        Colors.blue.shade700,
                      ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: _isSubmitting
                      ? Colors.grey.withValues(alpha: 0.3)
                      : Colors.blue.shade400.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: (_isSubmitting || _nameError != null || _checkingName)
                  ? null
                  : _submitDrink,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 26,
                    ),
              label: Text(
                _isSubmitting ? 'Đang tạo...' : 'Tạo Đồ Uống',
                style: const TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientPreview() {
    if (_estimatedNutrients.isEmpty) {
      return const SizedBox.shrink();
    }

    final macros = <String, Map<String, dynamic>>{};
    final vitamins = <String, Map<String, dynamic>>{};
    final minerals = <String, Map<String, dynamic>>{};
    final aminoAcids = <String, Map<String, dynamic>>{};
    final others = <String, Map<String, dynamic>>{};

    for (final entry in _estimatedNutrients.entries) {
      final name = entry.key.toLowerCase();
      final data = entry.value;

      if (name.contains('energy') ||
          name.contains('calorie') ||
          name.contains('protein') ||
          name.contains('fat') ||
          name.contains('carbohydrate')) {
        macros[entry.key] = data;
      } else if (name.contains('vitamin')) {
        vitamins[entry.key] = data;
      } else if (name.contains('calcium') ||
          name.contains('iron') ||
          name.contains('magnesium') ||
          name.contains('phosphorus') ||
          name.contains('potassium') ||
          name.contains('sodium') ||
          name.contains('zinc') ||
          name.contains('copper') ||
          name.contains('manganese') ||
          name.contains('selenium')) {
        minerals[entry.key] = data;
      } else if (name.contains('leucine') ||
          name.contains('isoleucine') ||
          name.contains('valine') ||
          name.contains('lysine') ||
          name.contains('methionine') ||
          name.contains('phenylalanine') ||
          name.contains('threonine') ||
          name.contains('tryptophan') ||
          name.contains('histidine') ||
          name.contains('alanine') ||
          name.contains('arginine') ||
          name.contains('aspartic') ||
          name.contains('cysteine') ||
          name.contains('glutamic') ||
          name.contains('glycine') ||
          name.contains('proline') ||
          name.contains('serine') ||
          name.contains('tyrosine')) {
        aminoAcids[entry.key] = data;
      } else {
        others[entry.key] = data;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Dinh Dưỡng Ước Tính',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: FitnessAppTheme.nearlyDarkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (macros.isNotEmpty)
            _buildNutrientSection(
              'Đa Lượng',
              macros,
              Colors.orange,
              Icons.local_fire_department,
            ),
          if (vitamins.isNotEmpty)
            _buildNutrientSection(
              'Vitamin',
              vitamins,
              Colors.purple,
              Icons.science,
            ),
          if (minerals.isNotEmpty)
            _buildNutrientSection(
              'Khoáng Chất',
              minerals,
              Colors.cyan,
              Icons.diamond,
            ),
          if (aminoAcids.isNotEmpty)
            _buildNutrientSection(
              'Axit Amin',
              aminoAcids,
              Colors.pink,
              Icons.bubble_chart,
            ),
          if (others.isNotEmpty)
            _buildNutrientSection(
              'Khác',
              others,
              Colors.blue,
              Icons.more_horiz,
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientSection(
    String title,
    Map<String, Map<String, dynamic>> nutrients,
    Color color,
    IconData icon,
  ) {
    const maxDisplay = 10;
    final displayNutrients = nutrients.entries.take(maxDisplay).toList();
    final remainingCount = nutrients.length - maxDisplay;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...displayNutrients.map((entry) {
                  final name = _formatNutrientName(entry.key);
                  final amount = entry.value['amount'] as double;
                  final unit = entry.value['unit'] as String;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '$name: ${amount.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 11,
                        color: FitnessAppTheme.nearlyDarkBlue,
                      ),
                    ),
                  );
                }),
                if (remainingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      '+$remainingCount khác...',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 11,
                        color: FitnessAppTheme.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNutrientName(String name) {
    return name
        .replaceAll('Total ', '')
        .replaceAll(' (total)', '')
        .replaceAll(' total', '')
        .trim();
  }
}
