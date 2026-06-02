import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `좋아요 필터 버튼` 디자인을 반영한 미니 필터 칩 위젯.
/// `isSelected` 상태에 따라 채워진 하트/아웃라인 하트 및 배경/글씨색이 동적으로 바뀝니다.
class LikeFilterButton extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const LikeFilterButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.label = '좋아요',
  });

  @override
  State<LikeFilterButton> createState() => _LikeFilterButtonState();
}

class _LikeFilterButtonState extends State<LikeFilterButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    // 선택 여부에 따른 스타일 매핑
    final backgroundColor = widget.isSelected ? AppColors.mainColor : AppColors.white;
    
    final border = widget.isSelected
        ? Border.all(color: AppColors.mainColor, width: 1.0)
        : Border.all(color: AppColors.mainColor, width: 1.5); // 피그마 border-[1.5px] 반영

    final textColor = widget.isSelected ? AppColors.white : AppColors.mainColor;
    
    final textStyle = widget.isSelected
        ? AppTextStyle.caption1Bold.copyWith(color: textColor, fontSize: 14) // 피그마 SemiBold 14px
        : AppTextStyle.caption1.copyWith(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500, // 피그마 Medium 14px
          );

    final iconData = widget.isSelected ? Icons.favorite : Icons.favorite_border;

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: BorderRadius.circular(100), // 피그마 rounded-[100px]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color: textColor,
                size: 16, // 피그마 size-[16px] 반영
              ),
              const SizedBox(width: 4), // 피그마 gap-[4px] 반영
              Text(
                widget.label,
                style: textStyle.copyWith(
                  height: 1.5, // 피그마 leading-[1.5]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
