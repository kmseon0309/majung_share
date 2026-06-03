import 'package:flutter/material.dart';
import '../../../theme.dart';

/// 피그마의 `채팅 내 버튼` 디자인을 반영한 아웃라인 알약 버튼.
/// 터치 시 미세 스케일 수축 마이크로 애니메이션이 탑재되어 있습니다.
class ChatInnerButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const ChatInnerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 196.0, // 피그마 w-[196px] 반영
    this.height = 39.0, // 피그마 h-[39px] 반영
  });

  @override
  State<ChatInnerButton> createState() => _ChatInnerButtonState();
}

class _ChatInnerButtonState extends State<ChatInnerButton> with SingleTickerProviderStateMixin {
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(
              color: AppColors.mainColor, // 피그마 border-[#356d96]
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(100), // 피그마 rounded-[100px]
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: AppTextStyle.body2SB.copyWith(
              color: AppColors.mainColor, // 피그마 text-[#356d96]
              fontSize: 15, // 피그마의 16px 대비 약간 정밀화된 아웃라인 텍스트 크기
            ),
          ),
        ),
      ),
    );
  }
}
