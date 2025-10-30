import 'package:flutter/material.dart';
import '../presentation/widgets/quick_action_button.dart';

/// Quick action button configurations for different parenting stages.
/// Provides contextual suggestions based on pregnancy stage or baby age.
class QuickActionsConfig {
  /// Quick actions for pregnancy mode
  static const List<QuickAction> pregnancyActions = [
    QuickAction(
      icon: Icons.pregnant_woman,
      label: 'Morning sickness tips',
      message: 'What can I do about morning sickness?',
    ),
    QuickAction(
      icon: Icons.food_bank,
      label: 'Nutrition advice',
      message: 'What should I eat during pregnancy?',
    ),
    QuickAction(
      icon: Icons.fitness_center,
      label: 'Safe exercises',
      message: 'What exercises are safe during pregnancy?',
    ),
    QuickAction(
      icon: Icons.medical_services,
      label: 'Doctor visit prep',
      message: 'What should I ask at my next prenatal appointment?',
    ),
    QuickAction(
      icon: Icons.baby_changing_station,
      label: 'Birth preparation',
      message: 'How should I prepare for labor and delivery?',
    ),
  ];

  /// Quick actions for newborn stage (0-3 months)
  static const List<QuickAction> newbornActions = [
    QuickAction(
      icon: Icons.nightlight,
      label: 'Sleep tips',
      message: 'How can I help my newborn sleep better?',
    ),
    QuickAction(
      icon: Icons.restaurant,
      label: 'Feeding schedule',
      message: 'How often should I feed my newborn?',
    ),
    QuickAction(
      icon: Icons.baby_changing_station,
      label: 'Diaper changes',
      message: 'How many diapers should my newborn use per day?',
    ),
    QuickAction(
      icon: Icons.spa,
      label: 'Soothing techniques',
      message: 'How can I calm my crying baby?',
    ),
    QuickAction(
      icon: Icons.healing,
      label: 'Umbilical cord care',
      message: 'How do I care for my baby\'s umbilical cord stump?',
    ),
  ];

  /// Quick actions for infant stage (3-12 months)
  static const List<QuickAction> infantActions = [
    QuickAction(
      icon: Icons.restaurant_menu,
      label: 'Starting solids',
      message: 'When and how should I start solid foods?',
    ),
    QuickAction(
      icon: Icons.directions_walk,
      label: 'Milestones',
      message: 'What developmental milestones should I expect?',
    ),
    QuickAction(
      icon: Icons.vaccines,
      label: 'Vaccination schedule',
      message: 'What vaccinations does my baby need?',
    ),
    QuickAction(
      icon: Icons.bedtime,
      label: 'Sleep training',
      message: 'Should I consider sleep training?',
    ),
    QuickAction(
      icon: Icons.child_care,
      label: 'Teething relief',
      message: 'How can I help with teething pain?',
    ),
  ];

  /// Quick actions for toddler stage (12+ months)
  static const List<QuickAction> toddlerActions = [
    QuickAction(
      icon: Icons.directions_run,
      label: 'Toddler activities',
      message: 'What activities are good for toddlers?',
    ),
    QuickAction(
      icon: Icons.psychology,
      label: 'Behavior guidance',
      message: 'How should I handle tantrums?',
    ),
    QuickAction(
      icon: Icons.wc,
      label: 'Potty training',
      message: 'When should I start potty training?',
    ),
    QuickAction(
      icon: Icons.menu_book,
      label: 'Language development',
      message: 'How can I encourage my toddler to talk?',
    ),
    QuickAction(
      icon: Icons.local_dining,
      label: 'Picky eating',
      message: 'My toddler is a picky eater, what should I do?',
    ),
  ];

  /// Quick actions for general parenting (any age)
  static const List<QuickAction> generalActions = [
    QuickAction(
      icon: Icons.medical_services,
      label: 'When to call doctor',
      message: 'When should I call the doctor?',
    ),
    QuickAction(
      icon: Icons.local_hospital,
      label: 'Emergency signs',
      message: 'What are signs of a medical emergency?',
    ),
    QuickAction(
      icon: Icons.favorite,
      label: 'Self-care tips',
      message: 'How can I take care of myself as a parent?',
    ),
    QuickAction(
      icon: Icons.family_restroom,
      label: 'Partner involvement',
      message: 'How can my partner help with baby care?',
    ),
  ];

  /// Get quick actions based on user mode and baby age
  /// Returns appropriate quick action set based on parenting stage
  static List<QuickAction> getActionsForStage({
    required String mode, // 'PREGNANCY' or 'PARENTING'
    DateTime? babyBirthDate,
  }) {
    // Pregnancy mode
    if (mode == 'PREGNANCY') {
      return pregnancyActions;
    }

    // Parenting mode - determine age-based actions
    if (babyBirthDate != null) {
      final ageInMonths = DateTime.now().difference(babyBirthDate).inDays ~/ 30;

      if (ageInMonths < 3) {
        // Newborn (0-3 months)
        return newbornActions;
      } else if (ageInMonths < 12) {
        // Infant (3-12 months)
        return infantActions;
      } else {
        // Toddler (12+ months)
        return toddlerActions;
      }
    }

    // Default to general actions if no specific stage determined
    return generalActions;
  }

  /// Get a mixed set of actions (stage-specific + general)
  /// Returns 3 stage-specific actions + 2 general actions for variety
  static List<QuickAction> getMixedActions({
    required String mode,
    DateTime? babyBirthDate,
  }) {
    final stageActions = getActionsForStage(
      mode: mode,
      babyBirthDate: babyBirthDate,
    );

    // Take first 3 stage-specific actions
    final selectedStageActions = stageActions.take(3).toList();

    // Add 2 general actions
    final selectedGeneralActions = generalActions.take(2).toList();

    return [...selectedStageActions, ...selectedGeneralActions];
  }
}
