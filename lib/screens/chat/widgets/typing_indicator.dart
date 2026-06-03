import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme.dart';
import '../../../widgets/app_icons.dart';

/// 마중이가 응답을 작성 중일 때 보여줄 로딩 인디케이터 말풍선 위젯.
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            AppIcons.profile,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          // 타이핑 로딩 점 버블
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.gray4,
        shape: BoxShape.circle,
      ),
    );
  }
}
