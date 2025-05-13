import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String iconPath;
  final Color iconBgColor;
  final bool isExpense;

  const Category({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.iconBgColor,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'iconBgColor': iconBgColor.value,
      'isExpense': isExpense,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconPath: map['iconPath'] ?? '',
      iconBgColor: Color(map['iconBgColor'] ?? 0xFF000000),
      isExpense: map['isExpense'] ?? true,
    );
  }
}
