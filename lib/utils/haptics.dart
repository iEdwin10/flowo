import 'package:flutter/services.dart';

class FlowoHaptics {
  /// Léger – appui simple, navigation
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Moyen – confirmation action
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Fort – succès objectif, milestone
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Sélection – scroll, switch
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibration courte custom – erreur / limite dépassée
  static Future<void> error() async {
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.vibrate();
  }

  /// Double pulse – objectif atteint
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
