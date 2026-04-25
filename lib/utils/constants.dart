import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Expense Tracker';
  
  static const List<String> paymentMethods = [
    'Cash',
    'Card',
    'UPI',
    'Net Banking',
  ];

  static const Map<String, Map<String, dynamic>> defaultCategories = {
    'food': {
      'name': 'Food & Dining',
      'icon': 'restaurant',
      'color': '#FF5722',
    },
    'transport': {
      'name': 'Transportation',
      'icon': 'directions_car',
      'color': '#2196F3',
    },
    'shopping': {
      'name': 'Shopping',
      'icon': 'shopping_bag',
      'color': '#E91E63',
    },
    'bills': {
      'name': 'Bills & Utilities',
      'icon': 'receipt',
      'color': '#FFC107',
    },
    'entertainment': {
      'name': 'Entertainment',
      'icon': 'movie',
      'color': '#9C27B0',
    },
    'healthcare': {
      'name': 'Healthcare',
      'icon': 'local_hospital',
      'color': '#F44336',
    },
    'education': {
      'name': 'Education',
      'icon': 'school',
      'color': '#3F51B5',
    },
    'others': {
      'name': 'Others',
      'icon': 'category',
      'color': '#607D8B',
    },
  };

  static IconData getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'receipt': Icons.receipt,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'category': Icons.category,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
