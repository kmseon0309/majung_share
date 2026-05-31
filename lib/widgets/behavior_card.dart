import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `행동 카드` 디자인을 반영한 행동 추천 가이드 카드.
/// 좌측에는 추천 텍스트가 노출되며, 우측에는 좋아요 토글 하트 버튼이 위치합니다.
class BehaviorCard extends StatelessWidget {
  final String title;
  final bool isLiked;
  final VoidCallback onLikeToggle;

  const BehaviorCard({
    super.key,
    required this.title,
    required this.isLiked,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328,
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.subColor, // 피그마 bg-[#f4faff]
        borderRadius: BorderRadius.circular(12), // 피그마 rounded-[12px]
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.body2R.copyWith(
                color: AppColors.grayScale9,
                height: 1.5, // 피그마 leading-[1.5]
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 우측 하트 토글 버튼
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLikeToggle,
              borderRadius: BorderRadius.circular(100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  widgetIcon,
                  color: AppColors.mainColor, // 피그마 메인 컬러 적용
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 좋아요 여부에 따라 채워진 하트 / 빈 하트 아이콘 매핑
  IconData get widgetIcon => isLiked ? Icons.favorite : Icons.favorite_border;
}
