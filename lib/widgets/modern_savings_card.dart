import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ModernSavingsCard extends StatelessWidget {
  final String title;
  final double currentAmount;
  final double targetAmount;
  final String iconPath;
  final VoidCallback onTap;
  final Widget? bottomWidget;
  final NumberFormat? currencyFormat;

  const ModernSavingsCard({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.iconPath,
    required this.onTap,
    this.bottomWidget,
    this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.10),
              Colors.purple.withOpacity(0.07),
              Colors.orange.withOpacity(0.05),
              Colors.white.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  color: Colors.grey[600],
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.savings,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              _formatAmount(currentAmount),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '/${_formatAmount(targetAmount)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
            if (bottomWidget != null) ...[const Spacer(), bottomWidget!],
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (currencyFormat != null) {
      return currencyFormat!.format(amount);
    }
    if (amount >= 1000000000) {
      return 'Rp${(amount / 1000000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (amount >= 1000000) {
      return 'Rp${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    } else if (amount >= 1000) {
      return 'Rp${(amount / 1000).toStringAsFixed(0)}k';
    } else {
      return 'Rp${amount.toStringAsFixed(0)}';
    }
  }
}
