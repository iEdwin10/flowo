import 'package:flutter/material.dart';

class FlowoCategory {
  final String name;
  final String emoji;
  final Color color;
  final List<String> subCategories;

  const FlowoCategory({
    required this.name,
    required this.emoji,
    required this.color,
    required this.subCategories,
  });
}

class FlowoCategories {
  static const List<FlowoCategory> all = [
    FlowoCategory(
      name: 'Logement',
      emoji: '🏠',
      color: Color(0xFF5B8DEF),
      subCategories: ['Loyer', 'Charges', 'Assurance', 'Travaux'],
    ),
    FlowoCategory(
      name: 'Transport',
      emoji: '🚗',
      color: Color(0xFFFF6B6B),
      subCategories: ['Voiture', 'Transports en commun', 'Taxi/Uber', 'Carburant'],
    ),
    FlowoCategory(
      name: 'Alimentation',
      emoji: '🛒',
      color: Color(0xFF51CF66),
      subCategories: ['Courses', 'Restaurant', 'Fast-food', 'Livraison'],
    ),
    FlowoCategory(
      name: 'Santé',
      emoji: '❤️',
      color: Color(0xFFFF8CC8),
      subCategories: ['Pharmacie', 'Médecin', 'Mutuelle', 'Sport'],
    ),
    FlowoCategory(
      name: 'Loisirs',
      emoji: '🎬',
      color: Color(0xFFFFD43B),
      subCategories: ['Cinéma', 'Abonnements', 'Sorties', 'Jeux vidéo'],
    ),
    FlowoCategory(
      name: 'Voyage',
      emoji: '✈️',
      color: Color(0xFF74C0FC),
      subCategories: ['Transport', 'Hébergement', 'Activités', 'Nourriture'],
    ),
    FlowoCategory(
      name: 'Shopping',
      emoji: '🛍️',
      color: Color(0xFFB197FC),
      subCategories: ['Vêtements', 'Téléphone', 'Électronique', 'Maison'],
    ),
    FlowoCategory(
      name: 'Épargne',
      emoji: '💰',
      color: Color(0xFF63E6BE),
      subCategories: ['LDDS', 'PEA', 'Livret A', 'Autre'],
    ),
    FlowoCategory(
      name: 'Autre',
      emoji: '📦',
      color: Color(0xFFADB5BD),
      subCategories: ['Divers', 'Impôts', 'Cadeaux', 'Don'],
    ),
  ];

  static FlowoCategory? findByName(String name) {
    try {
      return all.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }
}
