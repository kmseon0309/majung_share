import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import 'app_icons.dart';

/// 피그마의 `행동 카드` 디자인을 반영한 행동 추천 가이드 카드.
/// 우측 버튼 모드에 따라 다음과 같이 동작합니다:
/// 1. `isChevronStyle == false` (기본값): 우측에 좋아요 하트 아이콘이 노출되며, 클릭 시 [onLikeToggle] 콜백이 동작합니다.
/// 2. `isChevronStyle == true`: 우측에 오른쪽 꺽쇠 화살표 아이콘이 노출되며, 카드 전체 터치 시 [onTap] 콜백이 동작합니다.
class BehaviorCard extends StatelessWidget {
  final String title;
  final bool isLiked;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onTap;
  final bool isChevronStyle;

  const BehaviorCard({
    super.key,
    required this.title,
    this.isLiked = false,
    this.onLikeToggle,
    this.onTap,
    this.isChevronStyle = false,
  });

  String get _widgetIcon =>
      isLiked ? AppIcons.heartFilled : AppIcons.heartRegular;

  @override
  Widget build(BuildContext context) {
    // 내부 행(Row) 구성
    final Widget cardContent = Row(
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
        // 화살표 꺽쇠 모드와 좋아요 모드 분기 처리
        if (isChevronStyle)
          SvgPicture.asset(AppIcons.arrowRight, width: 20, height: 20)
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLikeToggle,
              borderRadius: BorderRadius.circular(100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(_widgetIcon, width: 24, height: 24),
              ),
            ),
          ),
      ],
    );

    // 화살표(Chevron) 모드는 카드 전체 터치 동작 지원
    if (isChevronStyle) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.subColor, // 피그마 bg-[#f4faff]
            borderRadius: BorderRadius.circular(12),
          ),
          child: cardContent,
        ),
      );
    }

    // 기본 좋아요 모드 카드 렌더링
    return Container(
      width: 328,
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.subColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: cardContent,
    );
  }
}
