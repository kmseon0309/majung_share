import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `선택 카드` 디자인을 반영한 대화 스타터/옵션 선택 위젯.
/// `isSelected` 상태에 따라 테두리 및 텍스트 스타일이 변합니다.
class SelectionCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isSelected ? AppColors.subColor : AppColors.grayScale1;

    final border = widget.isSelected
        ? Border.all(color: AppColors.mainColor, width: 2)
        : Border.all(color: AppColors.gray2, width: 1);

    final textStyle = widget.isSelected
        ? AppTextStyle.body2SB.copyWith(color: AppColors.mainColor)
        : AppTextStyle.body2R.copyWith(color: AppColors.grayScale9);

    final shadow = widget.isSelected
        ? [
            BoxShadow(
              color: AppColors.mainColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
        : [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ];

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 144,
          height: 81,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: BorderRadius.circular(12),
            boxShadow: shadow,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
