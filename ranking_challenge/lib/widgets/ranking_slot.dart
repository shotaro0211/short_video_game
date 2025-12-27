import 'package:flutter/material.dart';
import '../models/item.dart';

class RankingSlot extends StatelessWidget {
  final int rank;
  final Item? item;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final Color themeColor;

  const RankingSlot({
    super.key,
    required this.rank,
    this.item,
    this.isHighlighted = false,
    this.onTap,
    required this.themeColor,
  });

  Color _getRankColor() {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = item == null;

    return GestureDetector(
      onTap: isEmpty ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isHighlighted
              ? themeColor.withOpacity(0.2)
              : (isEmpty ? Colors.grey.shade100 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted
                ? themeColor
                : (isEmpty ? Colors.grey.shade300 : themeColor.withOpacity(0.5)),
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: isEmpty
              ? null
              : [
                  BoxShadow(
                    color: themeColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getRankColor(),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: rank <= 3 ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item?.name ?? (isHighlighted ? 'ここに配置' : '---'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: isEmpty ? FontWeight.normal : FontWeight.bold,
                  color: isEmpty
                      ? (isHighlighted ? themeColor : Colors.grey)
                      : Colors.black87,
                ),
              ),
            ),
            if (isEmpty && onTap != null)
              Icon(
                Icons.add_circle_outline,
                size: 28,
                color: isHighlighted ? themeColor : Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}
