/// Comprehensive Drug Model with all pharmaceutical information
/// Includes interactions, side effects, dosage, pharmacology, etc.
class Drug {
  // Basic Information
  final int drugId;
  final String nameVi;
  final String? nameEn;
  final String? brandNameVi;
  final String? brandNameEn;
  final String? genericName;
  final String? activeIngredient;
  final String? drugClass;
  final String? therapeuticClass;
  final String? description;
  final String? descriptionVi;
  final String? imageUrl;

  // Formulation
  final String? dosageForm; // viên, tiêm, siro, kem
  final String? strength; // 500mg, 10mg/ml
  final String? packaging; // Hộp 3 vỉ x 10 viên

  // Indications (Chỉ định)
  final String? indicationsVi;
  final String? indicationsEn;

  // Dosage (Liều dùng - Cách dùng)
  final String? dosageAdultVi;
  final String? dosageAdultEn;
  final String? dosagePediatricVi;
  final String? dosagePediatricEn;
  final String? dosageSpecialVi; // Suy gan, thận
  final String? dosageSpecialEn;

  // Contraindications (Chống chỉ định)
  final String? contraindicationsVi;
  final String? contraindicationsEn;

  // Warnings (Cảnh báo & thận trọng)
  final String? warningsVi;
  final String? warningsEn;
  final String? blackBoxWarningVi;
  final String? blackBoxWarningEn;

  // Side Effects (Tác dụng phụ)
  final String? commonSideEffectsVi;
  final String? commonSideEffectsEn;
  final String? seriousSideEffectsVi;
  final String? seriousSideEffectsEn;

  // Pharmacology (Dược lực học & dược động học)
  final String? mechanismOfActionVi; // Cơ chế tác dụng
  final String? mechanismOfActionEn;
  final String? pharmacokineticsVi; // ADME
  final String? pharmacokineticsEn;

  // Overdose (Quá liều & xử lý)
  final String? overdoseSymptomsVi;
  final String? overdoseSymptomsEn;
  final String? overdoseTreatmentVi;
  final String? overdoseTreatmentEn;

  // Pregnancy & Lactation
  final String? pregnancyCategory; // FDA: A, B, C, D, X
  final String? pregnancyNotesVi;
  final String? pregnancyNotesEn;
  final String? lactationNotesVi;
  final String? lactationNotesEn;

  // Storage (Điều kiện bảo quản)
  final String? storageConditionsVi;
  final String? storageConditionsEn;

  // References (Link bài báo uy tín)
  final String? articleLinkVi;
  final String? articleLinkEn;
  final String? sourceLink;
  final String? referenceSources; // JSON array

  // System fields
  final bool isActive;
  final int? createdByAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related data
  final List<RelatedCondition>? relatedConditions;
  final List<DrugInteraction>? interactions;
  final List<DrugSideEffect>? sideEffects;

  Drug({
    required this.drugId,
    required this.nameVi,
    this.nameEn,
    this.brandNameVi,
    this.brandNameEn,
    this.genericName,
    this.activeIngredient,
    this.drugClass,
    this.therapeuticClass,
    this.description,
    this.descriptionVi,
    this.imageUrl,
    this.dosageForm,
    this.strength,
    this.packaging,
    this.indicationsVi,
    this.indicationsEn,
    this.dosageAdultVi,
    this.dosageAdultEn,
    this.dosagePediatricVi,
    this.dosagePediatricEn,
    this.dosageSpecialVi,
    this.dosageSpecialEn,
    this.contraindicationsVi,
    this.contraindicationsEn,
    this.warningsVi,
    this.warningsEn,
    this.blackBoxWarningVi,
    this.blackBoxWarningEn,
    this.commonSideEffectsVi,
    this.commonSideEffectsEn,
    this.seriousSideEffectsVi,
    this.seriousSideEffectsEn,
    this.mechanismOfActionVi,
    this.mechanismOfActionEn,
    this.pharmacokineticsVi,
    this.pharmacokineticsEn,
    this.overdoseSymptomsVi,
    this.overdoseSymptomsEn,
    this.overdoseTreatmentVi,
    this.overdoseTreatmentEn,
    this.pregnancyCategory,
    this.pregnancyNotesVi,
    this.pregnancyNotesEn,
    this.lactationNotesVi,
    this.lactationNotesEn,
    this.storageConditionsVi,
    this.storageConditionsEn,
    this.articleLinkVi,
    this.articleLinkEn,
    this.sourceLink,
    this.referenceSources,
    this.isActive = true,
    this.createdByAdmin,
    this.createdAt,
    this.updatedAt,
    this.relatedConditions,
    this.interactions,
    this.sideEffects,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      drugId: json['drug_id'] as int,
      nameVi: json['name_vi'] as String,
      nameEn: json['name_en'] as String?,
      brandNameVi: json['brand_name_vi'] as String?,
      brandNameEn: json['brand_name_en'] as String?,
      genericName: json['generic_name'] as String?,
      activeIngredient: json['active_ingredient'] as String?,
      drugClass: json['drug_class'] as String?,
      therapeuticClass: json['therapeutic_class'] as String?,
      description: json['description'] as String?,
      descriptionVi: json['description_vi'] as String?,
      imageUrl: json['image_url'] as String?,
      dosageForm: json['dosage_form'] as String?,
      strength: json['strength'] as String?,
      packaging: json['packaging'] as String?,
      indicationsVi: json['indications_vi'] as String?,
      indicationsEn: json['indications_en'] as String?,
      dosageAdultVi: json['dosage_adult_vi'] as String?,
      dosageAdultEn: json['dosage_adult_en'] as String?,
      dosagePediatricVi: json['dosage_pediatric_vi'] as String?,
      dosagePediatricEn: json['dosage_pediatric_en'] as String?,
      dosageSpecialVi: json['dosage_special_vi'] as String?,
      dosageSpecialEn: json['dosage_special_en'] as String?,
      contraindicationsVi: json['contraindications_vi'] as String?,
      contraindicationsEn: json['contraindications_en'] as String?,
      warningsVi: json['warnings_vi'] as String?,
      warningsEn: json['warnings_en'] as String?,
      blackBoxWarningVi: json['black_box_warning_vi'] as String?,
      blackBoxWarningEn: json['black_box_warning_en'] as String?,
      commonSideEffectsVi: json['common_side_effects_vi'] as String?,
      commonSideEffectsEn: json['common_side_effects_en'] as String?,
      seriousSideEffectsVi: json['serious_side_effects_vi'] as String?,
      seriousSideEffectsEn: json['serious_side_effects_en'] as String?,
      mechanismOfActionVi: json['mechanism_of_action_vi'] as String?,
      mechanismOfActionEn: json['mechanism_of_action_en'] as String?,
      pharmacokineticsVi: json['pharmacokinetics_vi'] as String?,
      pharmacokineticsEn: json['pharmacokinetics_en'] as String?,
      overdoseSymptomsVi: json['overdose_symptoms_vi'] as String?,
      overdoseSymptomsEn: json['overdose_symptoms_en'] as String?,
      overdoseTreatmentVi: json['overdose_treatment_vi'] as String?,
      overdoseTreatmentEn: json['overdose_treatment_en'] as String?,
      pregnancyCategory: json['pregnancy_category'] as String?,
      pregnancyNotesVi: json['pregnancy_notes_vi'] as String?,
      pregnancyNotesEn: json['pregnancy_notes_en'] as String?,
      lactationNotesVi: json['lactation_notes_vi'] as String?,
      lactationNotesEn: json['lactation_notes_en'] as String?,
      storageConditionsVi: json['storage_conditions_vi'] as String?,
      storageConditionsEn: json['storage_conditions_en'] as String?,
      articleLinkVi: json['article_link_vi'] as String?,
      articleLinkEn: json['article_link_en'] as String?,
      sourceLink: json['source_link'] as String?,
      referenceSources: json['reference_sources'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdByAdmin: json['created_by_admin'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      relatedConditions: json['related_conditions'] != null
          ? (json['related_conditions'] as List)
                .map(
                  (c) => RelatedCondition.fromJson(c as Map<String, dynamic>),
                )
                .toList()
          : null,
      interactions: json['interactions'] != null
          ? (json['interactions'] as List)
                .map((i) => DrugInteraction.fromJson(i as Map<String, dynamic>))
                .toList()
          : null,
      sideEffects: json['side_effects'] != null
          ? (json['side_effects'] as List)
                .map((s) => DrugSideEffect.fromJson(s as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug_id': drugId,
      'name_vi': nameVi,
      'name_en': nameEn,
      'brand_name_vi': brandNameVi,
      'brand_name_en': brandNameEn,
      'generic_name': genericName,
      'active_ingredient': activeIngredient,
      'drug_class': drugClass,
      'therapeutic_class': therapeuticClass,
      'description': description,
      'description_vi': descriptionVi,
      'image_url': imageUrl,
      'dosage_form': dosageForm,
      'strength': strength,
      'packaging': packaging,
      'indications_vi': indicationsVi,
      'indications_en': indicationsEn,
      'dosage_adult_vi': dosageAdultVi,
      'dosage_adult_en': dosageAdultEn,
      'dosage_pediatric_vi': dosagePediatricVi,
      'dosage_pediatric_en': dosagePediatricEn,
      'dosage_special_vi': dosageSpecialVi,
      'dosage_special_en': dosageSpecialEn,
      'contraindications_vi': contraindicationsVi,
      'contraindications_en': contraindicationsEn,
      'warnings_vi': warningsVi,
      'warnings_en': warningsEn,
      'black_box_warning_vi': blackBoxWarningVi,
      'black_box_warning_en': blackBoxWarningEn,
      'common_side_effects_vi': commonSideEffectsVi,
      'common_side_effects_en': commonSideEffectsEn,
      'serious_side_effects_vi': seriousSideEffectsVi,
      'serious_side_effects_en': seriousSideEffectsEn,
      'mechanism_of_action_vi': mechanismOfActionVi,
      'mechanism_of_action_en': mechanismOfActionEn,
      'pharmacokinetics_vi': pharmacokineticsVi,
      'pharmacokinetics_en': pharmacokineticsEn,
      'overdose_symptoms_vi': overdoseSymptomsVi,
      'overdose_symptoms_en': overdoseSymptomsEn,
      'overdose_treatment_vi': overdoseTreatmentVi,
      'overdose_treatment_en': overdoseTreatmentEn,
      'pregnancy_category': pregnancyCategory,
      'pregnancy_notes_vi': pregnancyNotesVi,
      'pregnancy_notes_en': pregnancyNotesEn,
      'lactation_notes_vi': lactationNotesVi,
      'lactation_notes_en': lactationNotesEn,
      'storage_conditions_vi': storageConditionsVi,
      'storage_conditions_en': storageConditionsEn,
      'article_link_vi': articleLinkVi,
      'article_link_en': articleLinkEn,
      'source_link': sourceLink,
      'reference_sources': referenceSources,
      'is_active': isActive,
      'created_by_admin': createdByAdmin,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Related condition for drug treatment
class RelatedCondition {
  final int conditionId;
  final String nameVi;
  final String? nameEn;
  final String? category;
  final String? severityLevel;
  final String? imageUrl;
  final String? treatmentNotesVi;
  final String? treatmentNotes;
  final bool isPrimary;

  RelatedCondition({
    required this.conditionId,
    required this.nameVi,
    this.nameEn,
    this.category,
    this.severityLevel,
    this.imageUrl,
    this.treatmentNotesVi,
    this.treatmentNotes,
    this.isPrimary = false,
  });

  factory RelatedCondition.fromJson(Map<String, dynamic> json) {
    return RelatedCondition(
      conditionId: json['condition_id'] as int,
      nameVi: json['name_vi'] as String,
      nameEn: json['name_en'] as String?,
      category: json['category'] as String?,
      severityLevel: json['severity_level'] as String?,
      imageUrl: json['image_url'] as String?,
      treatmentNotesVi: json['treatment_notes_vi'] as String?,
      treatmentNotes: json['treatment_notes'] as String?,
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
    );
  }
}

/// Drug interaction (drug-drug, drug-food, drug-disease)
class DrugInteraction {
  final int interactionId;
  final String interactionType; // 'drug', 'food', 'disease'
  final String interactsWith;
  final String? severity; // 'major', 'moderate', 'minor'
  final String? descriptionVi;
  final String? descriptionEn;
  final String? clinicalEffectsVi;
  final String? clinicalEffectsEn;
  final String? managementVi;
  final String? managementEn;

  DrugInteraction({
    required this.interactionId,
    required this.interactionType,
    required this.interactsWith,
    this.severity,
    this.descriptionVi,
    this.descriptionEn,
    this.clinicalEffectsVi,
    this.clinicalEffectsEn,
    this.managementVi,
    this.managementEn,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      interactionId: json['interaction_id'] as int,
      interactionType: json['interaction_type'] as String,
      interactsWith: json['interacts_with'] as String,
      severity: json['severity'] as String?,
      descriptionVi: json['description_vi'] as String?,
      descriptionEn: json['description_en'] as String?,
      clinicalEffectsVi: json['clinical_effects_vi'] as String?,
      clinicalEffectsEn: json['clinical_effects_en'] as String?,
      managementVi: json['management_vi'] as String?,
      managementEn: json['management_en'] as String?,
    );
  }
}

/// Drug side effect with frequency and severity
class DrugSideEffect {
  final int sideEffectId;
  final String effectNameVi;
  final String? effectNameEn;
  final String?
  frequency; // 'very_common' (>10%), 'common' (1-10%), 'uncommon', 'rare'
  final String? severity; // 'mild', 'moderate', 'severe'
  final String? descriptionVi;
  final String? descriptionEn;
  final bool isSerious;

  DrugSideEffect({
    required this.sideEffectId,
    required this.effectNameVi,
    this.effectNameEn,
    this.frequency,
    this.severity,
    this.descriptionVi,
    this.descriptionEn,
    this.isSerious = false,
  });

  factory DrugSideEffect.fromJson(Map<String, dynamic> json) {
    return DrugSideEffect(
      sideEffectId: json['side_effect_id'] as int,
      effectNameVi: json['effect_name_vi'] as String,
      effectNameEn: json['effect_name_en'] as String?,
      frequency: json['frequency'] as String?,
      severity: json['severity'] as String?,
      descriptionVi: json['description_vi'] as String?,
      descriptionEn: json['description_en'] as String?,
      isSerious: json['is_serious'] == true || json['is_serious'] == 1,
    );
  }

  // Helper for frequency display
  String get frequencyLabel {
    switch (frequency) {
      case 'very_common':
        return 'Rất thường gặp (>10%)';
      case 'common':
        return 'Thường gặp (1-10%)';
      case 'uncommon':
        return 'Ít gặp (0.1-1%)';
      case 'rare':
        return 'Hiếm (<0.1%)';
      default:
        return 'Không rõ';
    }
  }

  // Helper for severity color
  String get severityColor {
    switch (severity) {
      case 'severe':
        return 'red';
      case 'moderate':
        return 'orange';
      case 'mild':
        return 'yellow';
      default:
        return 'gray';
    }
  }
}
