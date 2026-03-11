# 💸 Flowo

**Flowo** est une application mobile Flutter (iOS & Android) de gestion de budget personnel, pensée pour les jeunes actifs.

## ✨ Fonctionnalités

- **Onboarding** : saisie du salaire net + objectif d'épargne mensuel
- **Dashboard** : camembert interactif, carte de solde animée, répartition par catégorie
- **Dépenses** : ajout rapide, catégories + sous-catégories, navigation par mois, suppression par swipe
- **Objectifs** : suivi de progression LDDS, PEA, voyages, maison... avec barre animée
- **Analyse** : graphique barres annuel + détail par catégorie (vue mensuelle / annuelle)
- **Animations premium** : flutter_animate, Curves.elasticOut, spring, shimmer
- **Haptics** : retour tactile précis (light, medium, heavy, success, error)
- **Données locales** : tout est stocké sur l'appareil (shared_preferences)

## 🛠 Stack technique

| Lib | Rôle |
|---|---|
| `flutter_animate` | Animations déclaratives fluides |
| `fl_chart` | Camembert + graphiques barres |
| `provider` | State management |
| `shared_preferences` | Stockage local |
| `google_fonts` | Typographie premium (Inter) |
| `haptic_feedback` | Retour haptique natif |

## 🚀 Lancer le projet

```bash
git clone https://github.com/iEdwin10/flowo
cd flowo
flutter pub get
flutter run
```

## 🎨 Design

- Palette : `#5B8DEF` (bleu), `#7C6EF8` (violet), fond `#F8F9FB`
- Typographie : Inter (Google Fonts)
- Style : minimaliste, fluide, inspiré iOS

## 📁 Structure

```
lib/
├── main.dart
├── models/          # Expense, Goal, Budget
├── providers/       # BudgetProvider, ExpenseProvider, GoalProvider
├── screens/         # Onboarding, Dashboard, Expenses, Goals, Analytics
├── widgets/         # BottomNav, AddExpenseSheet, GoalCard, AddGoalSheet
└── utils/           # Categories, Haptics, Formatters
```
