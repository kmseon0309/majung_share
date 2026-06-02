import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `button` 및 `온보딩 하단 버튼` 디자인을 반영한 알약(Pill) 형태의 공통 버튼 위젯.
/// 터치 시 미세하게 축소되는 마이크로 인터랙션 애니메이션이 포함되어 있습니다.
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final Color backgroundColor;
  final double? height;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = false,
    this.backgroundColor = AppColors.mainColor,
    this.height,
    this.textColor = AppColors.white,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // 풀사이즈일 때의 기본 높이는 47.0, 아닐 때는 43.0
    final buttonHeight = widget.height ?? (widget.isFullWidth ? 47.0 : 43.0);

    Widget buttonChild = Container(
      height: buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(
          1000,
        ), // 피그마의 rounded-[1000px] (알약 형태)
        boxShadow: widget.backgroundColor == AppColors.mainColor
            ? [
                BoxShadow(
                  color: AppColors.mainColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        widget.label,
        style: AppTextStyle.body2B.copyWith(
          color: widget.textColor,
          letterSpacing: 0.64, // 피그마 tracking-[0.64px] 반영
        ),
      ),
    );

    if (widget.isFullWidth) {
      buttonChild = SizedBox(width: double.infinity, child: buttonChild);
    } else {
      buttonChild = IntrinsicWidth(child: buttonChild);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scaleAnimation, child: buttonChild),
    );
  }
}
