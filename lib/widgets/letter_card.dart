import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import 'app_icons.dart';

/// 피그마 "편지 보관함" 목록 아이템 디자인(node 16:70)을 100% 반영한 공통 편지 카드 위젯.
/// 우측에 미확인 알림 "NEW" 배지를 동적으로 표출할 수 있으며,
/// 읽음 여부에 따라 열린 편지 봉투 / 닫힌 편지 봉투 SVG 아이콘을 스위칭합니다.
class LetterCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isRead;
  final bool isNew;
  final VoidCallback onTap;

  const LetterCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isRead,
    required this.isNew,
    required this.onTap,
  });

  @override
  State<LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<LetterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 읽음 상태에 따른 왼쪽 봉투 아이콘 분기
    final String envelopeIcon = widget.isRead
        ? AppIcons.envelopeOpen
        : AppIcons.envelope;

    final cardContent = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.subColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. 편지 봉투 아이콘 (28x28)
            SvgPicture.asset(envelopeIcon, width: 28, height: 28),
            const SizedBox(width: 16),

            // 2. 텍스트 정보 (제목 & 기간)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.body2SB.copyWith(
                      color: AppColors.grayScale9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: AppTextStyle.caption2.copyWith(
                      color: AppColors.gray4, // 피그마 #848484 적용
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. 우측 이동 화살표 아이콘 (24x24)
            SvgPicture.asset(AppIcons.arrowRight, width: 24, height: 24),
          ],
        ),
      ),
    );

    if (widget.isNew) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          cardContent,
          Positioned(
            top: -8, // 피그마 이미지 상 상단 테두리에 걸쳐지도록 조정
            right: 12,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity:
                      0.3 +
                      (_animationController.value *
                          0.7), // 0.3 ~ 1.0 부드러운 호흡 애니메이션
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFD7E7E), // 피그마 이미지와 일치하는 코랄 색상
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'NEW',
                  style: AppTextStyle.caption3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800, // 굵은 흰색 글씨
                    height: 1.1,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return cardContent;
  }
}
