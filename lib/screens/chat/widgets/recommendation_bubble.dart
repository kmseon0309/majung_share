import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../widgets/chat_inner_button.dart';

/// 마중이의 행동 추천형 커스텀 메시지 버블 위젯.
class RecommendationBubble extends StatelessWidget {
  final String content;
  final VoidCallback onRecommendationTap;

  const RecommendationBubble({
    super.key,
    required this.content,
    required this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: AppTextStyle.body2R.copyWith(
              color: AppColors.grayScale9,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          ChatInnerButton(
            label: '활동 추천 받기',
            onPressed: onRecommendationTap,
          ),
        ],
      ),
    );
  }
}
