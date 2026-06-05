import 'package:flutter/material.dart';
import '../../../theme.dart';

/// 피그마의 `활동카드(in 모달)` 디자인을 반영한 활동 추천용 선택 위젯.
/// `isSelected` 상태에 따라 테두리 굵기 및 텍스트/배경색이 변합니다.
class ActivityCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> with SingleTickerProviderStateMixin {
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
    // 선택 여부에 따른 스타일 매핑
    final backgroundColor = widget.isSelected ? AppColors.subColor : AppColors.gray1;
    
    final border = widget.isSelected
        ? Border.all(color: AppColors.mainColor, width: 2)
        : Border.all(color: AppColors.gray1, width: 1);

    final textStyle = widget.isSelected
        ? AppTextStyle.body2B.copyWith(color: AppColors.mainColor)
        : AppTextStyle.body2SB.copyWith(color: AppColors.grayScale9);

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
          width: 228,
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: BorderRadius.circular(12), // 피그마 rounded-[12px]
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label.replaceAllMapped(
              RegExp(r'(\S)(?=\S)'),
              (match) => '${match[1]}\u200D',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(
              height: 1.5, // 피그마 leading-[1.5]
            ),
          ),
        ),
      ),
    );
  }
}
