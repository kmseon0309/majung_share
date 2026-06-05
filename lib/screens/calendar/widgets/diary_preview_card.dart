import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme.dart';
import '../../../models/diary_data.dart';
import '../../../widgets/app_icons.dart';
import '../../../providers/diary_provider.dart';
import '../../../utils/datetime_extension.dart';
import '../../chat/diary_completed_screen.dart';

class DiaryPreviewCard extends ConsumerWidget {
  final DateTime selectedDate;
  final DiaryData? diary;

  const DiaryPreviewCard({
    super.key,
    required this.selectedDate,
    required this.diary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = selectedDate.toDotString();

    return Container(
      color: AppColors.gray1,
      width: double.infinity,
      height: 251,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 날짜 표시 헤더 (피그마 x:16, y:545)
          Text(
            formattedDate,
            style: AppTextStyle.body2SB.copyWith(
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 26), // 카드 컴포넌트와의 간격 (피그마 y:587 기준)
          // 일기 정보 유무에 따른 분기
          if (diary != null)
            GestureDetector(
              onTap: () {
                // 전역 일기 공급자 상태 동기화 후 상세 페이지 전환
                ref.read(diaryProvider.notifier).saveNewDiary(diary!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiaryCompletedScreen(fromCalendar: true),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 132,
                decoration: BoxDecoration(
                  color: AppColors.subColor, // 피그마 sub (#F4FAFF)
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 좌측 감정 마스코트 아이콘 (60x60, 피그마 x:32, y:607)
                    Positioned(
                      left: 16,
                      top: 20,
                      child: SvgPicture.asset(
                        AppIcons.getMoodIcon(diary!.mood),
                        width: 60,
                        height: 60,
                      ),
                    ),
                    // 일기 제목 (피그마 x:112, y:603)
                    Positioned(
                      left: 96,
                      top: 16,
                      child: Text(
                        diary!.title,
                        style: AppTextStyle.caption1Bold.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    // 일기 요약 본문 (피그마 x:112, y:633, w:216)
                    Positioned(
                      left: 96,
                      top: 46,
                      width: 216,
                      child: Text(
                        diary!.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption1.copyWith(
                          color: AppColors.black,
                          height: 1.6,
                        ),
                      ),
                    ),
                    // 해시태그 목록 (우측 하단 배치)
                    Positioned(
                      right: 16,
                      bottom: 15,
                      child: Text(
                        diary!.tags.map((t) => '#$t').join(' '),
                        style: AppTextStyle.caption1Bold.copyWith(
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // 빈 상태 가이드 렌더링
            Container(
              width: double.infinity,
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gray2,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  '이날은 작성된 일기가 없습니다.',
                  style: AppTextStyle.caption1.copyWith(
                    color: AppColors.gray5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
