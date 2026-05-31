import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `전송 아이콘` 디자인을 반영한 원형 전송 버튼 위젯.
/// 텍스트 입력창 상태(`isActive`)에 따라 배경색이 메인 블루 또는 회색(`gray3`)으로 부드럽게 애니메이션되며 활성/비활성 처리됩니다.
class SendIconButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final double size;

  const SendIconButton({
    super.key,
    required this.isActive,
    required this.onPressed,
    this.size = 32.0, // 피그마 size-[32px] 반영
  });

  @override
  State<SendIconButton> createState() => _SendIconButtonState();
}

class _SendIconButtonState extends State<SendIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
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
    final backgroundColor = widget.isActive ? AppColors.mainColor : AppColors.gray3;

    return GestureDetector(
      onTapDown: widget.isActive ? (_) => _controller.forward() : null,
      onTapUp: widget.isActive
          ? (_) {
              _controller.reverse();
              widget.onPressed();
            }
          : null,
      onTapCancel: widget.isActive ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.arrow_upward_rounded, // 피그마 line-md:arrow-up 반영
            color: AppColors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
