import 'package:flutter/material.dart';

class SavingsIcon {
  final String path;
  final String name;
  final IconData fallbackIcon;

  const SavingsIcon({
    required this.path,
    required this.name,
    required this.fallbackIcon,
  });
}

class SavingsIcons {
  static const List<SavingsIcon> icons = [
    SavingsIcon(
      path: 'assets/icons/ic_wallet.png',
      name: 'Wallet',
      fallbackIcon: Icons.account_balance_wallet,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_house.png',
      name: 'House',
      fallbackIcon: Icons.home,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_car.png',
      name: 'Car',
      fallbackIcon: Icons.directions_car,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_education.png',
      name: 'Education',
      fallbackIcon: Icons.school,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_travel.png',
      name: 'Travel',
      fallbackIcon: Icons.flight,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_gift.png',
      name: 'Gift',
      fallbackIcon: Icons.card_giftcard,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_health.png',
      name: 'Health',
      fallbackIcon: Icons.health_and_safety,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_shopping_bag.png',
      name: 'Shopping',
      fallbackIcon: Icons.shopping_bag,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_food_drink.png',
      name: 'Food',
      fallbackIcon: Icons.restaurant,
    ),
    SavingsIcon(
      path: 'assets/icons/ic_entertainment.png',
      name: 'Entertainment',
      fallbackIcon: Icons.movie,
    ),
  ];
}
