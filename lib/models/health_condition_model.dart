class HealthCondition {
  final int conditionId;
  final String nameVi;
  final String nameEn;
  final String? category;
  final String? description;
  final String? descriptionVi;
  final String? causes;
  final String? imageUrl;
  final String? treatmentDurationReference;
  final String? articleLinkVi;
  final String? articleLinkEn;
  final String? preventionTips;
  final String? preventionTipsVi;
  final String? severityLevel;
  final bool isChronic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HealthCondition({
    required this.conditionId,
    required this.nameVi,
    required this.nameEn,
    this.category,
    this.description,
    this.descriptionVi,
    this.causes,
    this.imageUrl,
    this.treatmentDurationReference,
    this.articleLinkVi,
    this.articleLinkEn,
    this.preventionTips,
    this.preventionTipsVi,
    this.severityLevel,
    this.isChronic = false,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthCondition.fromJson(Map<String, dynamic> json) {
    return HealthCondition(
      conditionId: json['condition_id'] as int,
      nameVi: json['name_vi'] as String,
      nameEn: json['name_en'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      descriptionVi: json['description_vi'] as String?,
      causes: json['causes'] as String?,
      imageUrl: json['image_url'] as String?,
      treatmentDurationReference:
          json['treatment_duration_reference'] as String?,
      articleLinkVi: json['article_link_vi'] as String?,
      articleLinkEn: json['article_link_en'] as String?,
      preventionTips: json['prevention_tips'] as String?,
      preventionTipsVi: json['prevention_tips_vi'] as String?,
      severityLevel: json['severity_level'] as String?,
      isChronic: json['is_chronic'] == true || json['is_chronic'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition_id': conditionId,
      'name_vi': nameVi,
      'name_en': nameEn,
      'category': category,
      'description': description,
      'description_vi': descriptionVi,
      'causes': causes,
      'image_url': imageUrl,
      'treatment_duration_reference': treatmentDurationReference,
      'article_link_vi': articleLinkVi,
      'article_link_en': articleLinkEn,
      'prevention_tips': preventionTips,
      'prevention_tips_vi': preventionTipsVi,
      'severity_level': severityLevel,
      'is_chronic': isChronic,
    };
  }
}

class FoodRecommendation {
  final int recommendationId;
  final int? conditionId;
  final int? foodId;
  final String recommendationType; // 'avoid' or 'recommend'
  final String? notes;
  final String? foodNameVi;
  final String? foodName;
  final String? category;
  final String? imageUrl;

  FoodRecommendation({
    required this.recommendationId,
    this.conditionId,
    this.foodId,
    required this.recommendationType,
    this.notes,
    this.foodNameVi,
    this.foodName,
    this.category,
    this.imageUrl,
  });

  factory FoodRecommendation.fromJson(Map<String, dynamic> json) {
    return FoodRecommendation(
      recommendationId: json['recommendation_id'] as int,
      conditionId: json['condition_id'] as int?,
      foodId: json['food_id'] as int?,
      recommendationType: json['recommendation_type'] as String,
      notes: json['notes'] as String?,
      foodNameVi: json['name_vi'] as String?,
      foodName: json['food_name'] as String?,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class NutrientEffect {
  final int effectId;
  final int nutrientId;
  final String nutrientName;
  final String? nutrientNameVi;
  final String? unit;
  final double adjustmentPercent;

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  NutrientEffect({
    required this.effectId,
    required this.nutrientId,
    required this.nutrientName,
    this.nutrientNameVi,
    this.unit,
    required this.adjustmentPercent,
  });

  factory NutrientEffect.fromJson(Map<String, dynamic> json) {
    return NutrientEffect(
      effectId: json['effect_id'] as int,
      nutrientId: json['nutrient_id'] as int,
      nutrientName: json['nutrient_name'] as String,
      nutrientNameVi: json['nutrient_name_vi'] as String?,
      unit: json['unit'] as String?,
      adjustmentPercent: _parseDouble(json['adjustment_percent']),
    );
  }
}

class DrugTreatment {
  final int drugId;
  final String nameVi;
  final String? nameEn;
  final String? description;
  final String? descriptionVi;
  final String? imageUrl;
  final String? treatmentNotes;
  final String? treatmentNotesVi;
  final bool isPrimary;

  DrugTreatment({
    required this.drugId,
    required this.nameVi,
    this.nameEn,
    this.description,
    this.descriptionVi,
    this.imageUrl,
    this.treatmentNotes,
    this.treatmentNotesVi,
    this.isPrimary = false,
  });

  factory DrugTreatment.fromJson(Map<String, dynamic> json) {
    return DrugTreatment(
      drugId: json['drug_id'] as int,
      nameVi: json['name_vi'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      descriptionVi: json['description_vi'] as String?,
      imageUrl: json['image_url'] as String?,
      treatmentNotes: json['treatment_notes'] as String?,
      treatmentNotesVi: json['treatment_notes_vi'] as String?,
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
    );
  }
}
