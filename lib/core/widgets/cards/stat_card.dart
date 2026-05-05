import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final String prefix;
  final bool isSelected;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.prefix,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final amountText = '$prefix${amount.toStringAsFixed(2)}';

        // Calculate if text overflows
        final textPainter = TextPainter(
          text: TextSpan(
            text: amountText,
            style: const TextStyle(
              fontSize: 18.0, // Explicit double
              fontWeight: FontWeight.bold,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth - 24); // Subtract padding

        // Only shrink font if text overflows (explicit double values)
        final double fontSize = textPainter.didExceedMaxLines ? 14.0 : 18.0;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.2),
                width: isSelected ? 0 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: isSelected ? Colors.white : color),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}