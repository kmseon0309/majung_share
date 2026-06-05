import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import 'app_icons.dart';

/// 피그마 "알림" 화면 목록 아이템 디자인(node 174:617)을 반영한 공통 알림 카드 위젯.
/// 왼쪽에는 마스코트 아이콘이 44x44 크기로 고정 렌더링되며,
/// 읽지 않은 알림일 경우 우측 상단 영역에 미확인 알림(붉은색/코랄색) 원형 도트가 노출됩니다.
class NotificationCard extends StatelessWidget {
  final String title;
  final String date;
  final bool isUnread;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.date,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.gray1, // 피그마 bg-[#f6f8fa]
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. 공용 마스코트 아이콘 (icon.svg) 44x44 크기 렌더링
            SvgPicture.asset(
              AppIcons.mascotIcon,
              width: 44,
              height: 44,
            ),
            const SizedBox(width: 12),

            // 2. 알림 내용 및 일시 영역
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 알림 텍스트 본문 (최대 2줄 자동 줄바꿈)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption1.copyWith(
                          color: AppColors.grayScale9,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 우측 일시 정보 & 미확인 도트 스택
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: AppTextStyle.caption3.copyWith(
                            color: AppColors.gray4, // #9EA4A9 적용
                            fontWeight: FontWeight.w400, // Regular style
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFD7E7E), // 코랄 핑크 미확인 도트
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
