import 'package:flutter/material.dart';

/// Model for Daily Meal Suggestion
class DailyMealSuggestion {
  final int id;
  final int userId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final int? dishId;
  final String? dishName;
  final String? dishVietnameseName;
  final String? dishCategory;
  final double? dishServingSizeG;
  final String? dishImageUrl;
  final int? drinkId;
  final String? drinkName;
  final String? drinkVietnameseName;
  final String? drinkCategory;
  final double? drinkDefaultVolumeMl;
  final double? drinkHydrationRatio;
  final String? drinkImageUrl;
  final bool isAccepted;
  final bool isRejected;
  final double suggestionScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyMealSuggestion({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    this.dishId,
    this.dishName,
    this.dishVietnameseName,
    this.dishCategory,
    this.dishServingSizeG,
    this.dishImageUrl,
    this.drinkId,
    this.drinkName,
    this.drinkVietnameseName,
    this.drinkCategory,
    this.drinkDefaultVolumeMl,
    this.drinkHydrationRatio,
    this.drinkImageUrl,
    required this.isAccepted,
    required this.isRejected,
    required this.suggestionScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyMealSuggestion.fromJson(Map<String, dynamic> json) {
    // Parse suggestion_score - handle both String and num types
    double parseSuggestionScore(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    double? parseOptionalDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return DailyMealSuggestion(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      date: DateTime.parse(json['date'] as String),
      mealType: json['meal_type'] as String,
      dishId: json['dish_id'] as int?,
      dishName: json['dish_name'] as String?,
      dishVietnameseName: json['dish_vietnamese_name'] as String?,
      dishCategory: json['dish_category'] as String?,
      dishServingSizeG: parseOptionalDouble(json['dish_serving_size_g']),
      dishImageUrl: json['dish_image_url'] as String?,
      drinkId: json['drink_id'] as int?,
      drinkName: json['drink_name'] as String?,
      drinkVietnameseName: json['drink_vietnamese_name'] as String?,
      drinkCategory: json['drink_category'] as String?,
      drinkDefaultVolumeMl: parseOptionalDouble(
        json['drink_default_volume_ml'],
      ),
      drinkHydrationRatio: parseOptionalDouble(json['drink_hydration_ratio']),
      drinkImageUrl: json['drink_image_url'] as String?,
      isAccepted: json['is_accepted'] as bool? ?? false,
      isRejected: json['is_rejected'] as bool? ?? false,
      suggestionScore: parseSuggestionScore(json['suggestion_score']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'meal_type': mealType,
      'dish_id': dishId,
      'drink_id': drinkId,
      'is_accepted': isAccepted,
      'is_rejected': isRejected,
      'suggestion_score': suggestionScore,
    };
  }

  bool get isDish => dishId != null;
  bool get isDrink => drinkId != null;

  String? get imageUrl {
    if (isDish) return dishImageUrl;
    if (isDrink) return drinkImageUrl;
    return null;
  }

  // Convenience getters
  double get score => suggestionScore;
  double get portionSize => 1.0; // Default portion size
  String? get description => category;

  String get portionLabel {
    if (isDish) {
      final g = dishServingSizeG;
      final display = (g != null && g > 0) ? g : 100.0;
      return '${display.toStringAsFixed(display.roundToDouble() == display ? 0 : 1)} g';
    }
    if (isDrink) {
      final ml = drinkDefaultVolumeMl;
      final display = (ml != null && ml > 0) ? ml : 250.0;
      final liters = display / 1000.0;
      final litersText = liters.toStringAsFixed(liters >= 1 ? 1 : 2);
      return '${display.toStringAsFixed(display.roundToDouble() == display ? 0 : 1)} ml ($litersText L)';
    }
    return '—';
  }

  String get displayName {
    if (isDish) {
      return dishVietnameseName ?? dishName ?? 'Món ăn #$dishId';
    } else if (isDrink) {
      return drinkVietnameseName ?? drinkName ?? 'Đồ uống #$drinkId';
    }
    return 'Unknown';
  }

  String get category {
    if (isDish) return dishCategory ?? 'main_course';
    if (isDrink) return drinkCategory ?? 'water';
    return '';
  }

  IconData get icon {
    if (isDish) {
      switch (dishCategory) {
        case 'vegetarian':
          return Icons.eco;
        case 'soup':
          return Icons.soup_kitchen;
        case 'salad':
          return Icons.restaurant;
        case 'breakfast':
          return Icons.free_breakfast;
        default:
          return Icons.restaurant_menu;
      }
    } else {
      switch (drinkCategory) {
        case 'Tea':
          return Icons.emoji_food_beverage;
        case 'Juice':
          return Icons.local_drink;
        case 'Coffee':
          return Icons.coffee;
        case 'Milk':
          return Icons.breakfast_dining;
        default:
          return Icons.local_cafe;
      }
    }
  }

  Color getScoreColor() {
    if (suggestionScore >= 80) return Colors.green;
    if (suggestionScore >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// Grouped suggestions by meal type
class DailyMealSuggestions {
  final List<DailyMealSuggestion> breakfast;
  final List<DailyMealSuggestion> lunch;
  final List<DailyMealSuggestion> dinner;
  final List<DailyMealSuggestion> snack;
  final NutrientSummary? nutrientSummary;

  DailyMealSuggestions({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
    this.nutrientSummary,
  });

  factory DailyMealSuggestions.fromJson(Map<String, dynamic> json) {
    return DailyMealSuggestions(
      breakfast:
          (json['breakfast'] as List?)
              ?.map((e) => DailyMealSuggestion.fromJson(e))
              .toList() ??
          [],
      lunch:
          (json['lunch'] as List?)
              ?.map((e) => DailyMealSuggestion.fromJson(e))
              .toList() ??
          [],
      dinner:
          (json['dinner'] as List?)
              ?.map((e) => DailyMealSuggestion.fromJson(e))
              .toList() ??
          [],
      snack:
          (json['snack'] as List?)
              ?.map((e) => DailyMealSuggestion.fromJson(e))
              .toList() ??
          [],
      nutrientSummary: json['nutrientSummary'] != null
          ? NutrientSummary.fromJson(json['nutrientSummary'])
          : null,
    );
  }

  List<DailyMealSuggestion> getSuggestionsForMeal(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return breakfast;
      case 'lunch':
        return lunch;
      case 'dinner':
        return dinner;
      case 'snack':
        return snack;
      default:
        return [];
    }
  }

  int get totalCount =>
      breakfast.length + lunch.length + dinner.length + snack.length;

  bool get isEmpty => totalCount == 0;
}

/// Statistics for suggestions
class SuggestionStats {
  final String mealType;
  final int totalSuggestions;
  final int acceptedCount;
  final int rejectedCount;
  final double avgScore;
  final int daysWithSuggestions;

  SuggestionStats({
    required this.mealType,
    required this.totalSuggestions,
    required this.acceptedCount,
    required this.rejectedCount,
    required this.avgScore,
    required this.daysWithSuggestions,
  });

  factory SuggestionStats.fromJson(Map<String, dynamic> json) {
    return SuggestionStats(
      mealType: json['meal_type'] as String,
      totalSuggestions: json['total_suggestions'] as int? ?? 0,
      acceptedCount: json['accepted_count'] as int? ?? 0,
      rejectedCount: json['rejected_count'] as int? ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      daysWithSuggestions: json['days_with_suggestions'] as int? ?? 0,
    );
  }

  double get acceptanceRate {
    if (totalSuggestions == 0) return 0.0;
    return (acceptedCount / totalSuggestions) * 100;
  }

  double get rejectionRate {
    if (totalSuggestions == 0) return 0.0;
    return (rejectedCount / totalSuggestions) * 100;
  }
}

/// Nutrient Summary for Daily Suggestions
class NutrientSummary {
  final int totalSuggestions;
  final List<NutrientDetail> nutrients;
  final int overallCompletion;

  NutrientSummary({
    required this.totalSuggestions,
    required this.nutrients,
    required this.overallCompletion,
  });

  factory NutrientSummary.fromJson(Map<String, dynamic> json) {
    return NutrientSummary(
      totalSuggestions: json['totalSuggestions'] as int? ?? 0,
      nutrients:
          (json['nutrients'] as List?)
              ?.map((e) => NutrientDetail.fromJson(e))
              .toList() ??
          [],
      overallCompletion: json['overallCompletion'] as int? ?? 0,
    );
  }
}

/// Individual Nutrient Detail
class NutrientDetail {
  final int nutrientId;
  final String nutrientName;
  final double provided;
  final double recommended;
  final double percentage;
  final String status; // 'met', 'near', 'low'

  NutrientDetail({
    required this.nutrientId,
    required this.nutrientName,
    required this.provided,
    required this.recommended,
    required this.percentage,
    required this.status,
  });

  factory NutrientDetail.fromJson(Map<String, dynamic> json) {
    return NutrientDetail(
      nutrientId: json['nutrient_id'] as int,
      nutrientName: json['nutrient_name'] as String,
      provided: (json['provided'] as num).toDouble(),
      recommended: (json['recommended'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Color get statusColor {
    switch (status) {
      case 'high':
        return Colors.red;
      case 'met':
        return Colors.green;
      case 'near':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
