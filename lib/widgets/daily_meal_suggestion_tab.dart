import 'package:flutter/material.dart';
import '../models/daily_meal_suggestion.dart';
import '../services/daily_meal_suggestion_service.dart';
import '../services/smart_suggestion_service.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/missing_nutrients_card.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class DailyMealSuggestionTab extends StatefulWidget {
  const DailyMealSuggestionTab({Key? key}) : super(key: key);

  @override
  State<DailyMealSuggestionTab> createState() => _DailyMealSuggestionTabState();
}

class _DailyMealSuggestionTabState extends State<DailyMealSuggestionTab> {
  bool _isLoading = false;
  bool _isGenerating = false;
  DailyMealSuggestions? _suggestions;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _missing;
  bool _isLoadingMissing = false;
  final Set<int> _processingIds = {};
  final Map<String, int> _selectedSuggestionIdByMeal = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().toUtc().add(const Duration(hours: 7));
    _loadSuggestions();
  }

  void _ensureMealSelection(String mealType, List<DailyMealSuggestion> list) {
    if (list.isEmpty) {
      _selectedSuggestionIdByMeal.remove(mealType);
      return;
    }

    final currentId = _selectedSuggestionIdByMeal[mealType];
    if (currentId != null && list.any((s) => s.id == currentId)) {
      return;
    }

    final defaultPick = list.firstWhere(
      (s) => s.isAccepted,
      orElse: () =>
          list.firstWhere((s) => !s.isRejected, orElse: () => list.first),
    );
    _selectedSuggestionIdByMeal[mealType] = defaultPick.id;
  }

  void _syncDefaultSelections() {
    final s = _suggestions;
    if (s == null) return;
    _ensureMealSelection('breakfast', s.breakfast);
    _ensureMealSelection('lunch', s.lunch);
    _ensureMealSelection('dinner', s.dinner);
    _ensureMealSelection('snack', s.snack);
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isLoadingMissing = true;
    });

    try {
      final missingResult = await SmartSuggestionService.getMissingNutrients(
        date: _selectedDate,
      );

      final result = await DailyMealSuggestionService.getSuggestions(
        date: _selectedDate,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _suggestions = result['suggestions'];
          _syncDefaultSelections();
          _isLoading = false;
          _missing = missingResult['error'] == null ? missingResult : null;
          _isLoadingMissing = false;
        });
      } else {
        setState(() {
          _errorMessage =
              result['error'] ??
              AppLocalizations.of(context)!.suggestionLoadError;
          _isLoading = false;
          _missing = missingResult['error'] == null ? missingResult : null;
          _isLoadingMissing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        )!.suggestionGenericError('$e');
        _isLoading = false;
        _missing = null;
        _isLoadingMissing = false;
      });
    }
  }

  Future<void> _generateSuggestions() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final result = await DailyMealSuggestionService.generateSuggestions(
        date: _selectedDate,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  AppLocalizations.of(context)!.suggestionGenerateSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSuggestions();
      } else {
        setState(() {
          _errorMessage =
              result['error'] ??
              AppLocalizations.of(context)!.suggestionGenerateError;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        )!.suggestionGenericError('$e');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _acceptSuggestion(DailyMealSuggestion suggestion) async {
    setState(() {
      _processingIds.add(suggestion.id);
    });

    try {
      final result = await DailyMealSuggestionService.acceptSuggestion(
        suggestion.id,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  AppLocalizations.of(context)!.suggestionAcceptSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSuggestions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ??
                  AppLocalizations.of(context)!.suggestionAcceptError,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingIds.remove(suggestion.id);
        });
      }
    }
  }

  Future<void> _rejectSuggestion(DailyMealSuggestion suggestion) async {
    setState(() {
      _processingIds.add(suggestion.id);
    });

    try {
      final result = await DailyMealSuggestionService.rejectSuggestion(
        suggestion.id,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  AppLocalizations.of(context)!.suggestionSwapSuccess,
            ),
            backgroundColor: Colors.orange,
          ),
        );
        await _loadSuggestions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ??
                  AppLocalizations.of(context)!.suggestionSwapError,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingIds.remove(suggestion.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : _generateSuggestions,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(
          _isGenerating
              ? AppLocalizations.of(context)!.suggestionGenerating
              : AppLocalizations.of(context)!.suggestionCreateNew,
        ),
        backgroundColor: _isGenerating ? Colors.grey : Colors.orange,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              _loadSuggestions();
            },
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 7)),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _loadSuggestions();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
              _loadSuggestions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = AppLocalizations.of(context)!;
    final hasSuggestions = _suggestions != null && !_suggestions!.isEmpty;

    return RefreshIndicator(
      onRefresh: _loadSuggestions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          if (_isLoadingMissing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            MissingNutrientsCard(
              macros: _missing?['macros'] as Map<String, dynamic>?,
              missingNutrients: _missing?['missing_nutrients'] as List?,
              title: 'Chất còn thiếu trong ngày',
            ),

          if (_errorMessage != null)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(
                icon: Icons.error_outline,
                title: l10n.error,
                message: _errorMessage!,
                actionLabel: l10n.retry,
                onAction: _loadSuggestions,
              ),
            )
          else if (!hasSuggestions)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(
                icon: Icons.restaurant_menu,
                title: l10n.suggestionEmptyTitle,
                message: l10n.suggestionEmptyMessage,
                actionLabel: l10n.suggestionEmptyAction,
                onAction: _generateSuggestions,
              ),
            )
          else ...[
            if (_suggestions!.nutrientSummary != null)
              _buildNutrientSummaryCard(_suggestions!.nutrientSummary!),

            if (_suggestions!.breakfast.isNotEmpty)
              _buildMealSection(
                'breakfast',
                l10n.breakfast,
                _suggestions!.breakfast,
                Icons.free_breakfast,
              ),
            if (_suggestions!.lunch.isNotEmpty)
              _buildMealSection(
                'lunch',
                l10n.lunch,
                _suggestions!.lunch,
                Icons.lunch_dining,
              ),
            if (_suggestions!.dinner.isNotEmpty)
              _buildMealSection(
                'dinner',
                l10n.dinner,
                _suggestions!.dinner,
                Icons.dinner_dining,
              ),
            if (_suggestions!.snack.isNotEmpty)
              _buildMealSection(
                'snack',
                l10n.snack,
                _suggestions!.snack,
                Icons.cookie,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealSection(
    String mealType,
    String title,
    List<DailyMealSuggestion> suggestions,
    IconData icon,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final selectedId = _selectedSuggestionIdByMeal[mealType];
    final selected = suggestions.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => suggestions.first,
    );

    final isSelectedLoading = _processingIds.contains(selected.id);
    final isSelectedAccepted = selected.isAccepted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.suggestionCountLabel(suggestions.length),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...suggestions.map((suggestion) {
          return SuggestionCard(
            suggestion: suggestion,
            onTap: () {
              setState(() {
                _selectedSuggestionIdByMeal[mealType] = suggestion.id;
              });
            },
            isSelected: suggestion.id == selected.id,
            isLoading: _processingIds.contains(suggestion.id),
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (isSelectedAccepted || isSelectedLoading)
                      ? null
                      : () => _rejectSuggestion(selected),
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: (isSelectedAccepted || isSelectedLoading)
                        ? Colors.grey
                        : Colors.red,
                  ),
                  label: Text(
                    l10n.swapSuggestion,
                    style: TextStyle(
                      color: (isSelectedAccepted || isSelectedLoading)
                          ? Colors.grey
                          : Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: (isSelectedAccepted || isSelectedLoading)
                          ? Colors.grey
                          : Colors.red,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (isSelectedAccepted || isSelectedLoading)
                      ? null
                      : () => _acceptSuggestion(selected),
                  icon: isSelectedLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(
                    isSelectedLoading ? l10n.processing : l10n.accept,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientSummaryCard(NutrientSummary summary) {
    final overallPctInt = summary.overallCompletion.clamp(0, 100);
    final overallPct = overallPctInt.toDouble();

    NutrientDetail? findNutrient(String key) {
      for (final n in summary.nutrients) {
        final name = n.nutrientName.toLowerCase();
        if (name == key) return n;
      }
      return null;
    }

    final ordered = <NutrientDetail>[];
    final kcal = findNutrient('kcal');
    final carb = findNutrient('carb');
    final fat = findNutrient('fat');
    final protein = findNutrient('protein');
    final water = findNutrient('water');
    if (kcal != null) ordered.add(kcal);
    if (carb != null) ordered.add(carb);
    if (fat != null) ordered.add(fat);
    if (protein != null) ordered.add(protein);
    if (water != null) ordered.add(water);

    final unmet = ordered
        .where((n) => n.percentage.toDouble() < 100)
        .toList(growable: false);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tổng hợp dinh dưỡng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  '$overallPctInt%',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ((overallPct / 100).clamp(0.0, 1.0)).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
            ),
          ),
          if (unmet.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Bạn đã đạt đủ 5 chỉ số mục tiêu hôm nay',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (unmet.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < unmet.length; i++) ...[
                    _buildNutrientRow(unmet[i]),
                    if (i != unmet.length - 1) const Divider(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutrientRow(NutrientDetail nutrient) {
    final rawPct = nutrient.percentage.toDouble();
    final pct = nutrient.percentage.clamp(0.0, 150.0).toDouble();
    final icon = switch (nutrient.nutrientName.toLowerCase()) {
      'kcal' => Icons.local_fire_department,
      'carb' => Icons.rice_bowl,
      'fat' => Icons.oil_barrel,
      'protein' => Icons.fitness_center,
      'water' => Icons.water_drop,
      _ => Icons.analytics,
    };

    final color = switch (nutrient.status) {
      'high' => Colors.red.shade700,
      'met' => Colors.green.shade700,
      'near' => Colors.orange.shade800,
      'low' => Colors.orange.shade800,
      _ => Colors.grey,
    };

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nutrient.nutrientName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${rawPct.toStringAsFixed(0)}%',
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ((pct.clamp(0.0, 100.0) / 100).clamp(0.0, 1.0)).toDouble(),
              minHeight: 7,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hôm nay';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return 'Ngày mai';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
