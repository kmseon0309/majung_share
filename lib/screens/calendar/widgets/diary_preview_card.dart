import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme.dart';
import '../../../models/diary_data.dart';
import '../../../widgets/app_icons.dart';
import '../../../providers/diary_provider.dart';
import '../../../utils/datetime_extension.dart';
import '../../chat/diary_completed_screen.dart';

class DiaryPreviewCard extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final List<DiaryData> diaries;

  const DiaryPreviewCard({
    super.key,
    required this.selectedDate,
    required this.diaries,
  });

  @override
  ConsumerState<DiaryPreviewCard> createState() => _DiaryPreviewCardState();
}

class _DiaryPreviewCardState extends ConsumerState<DiaryPreviewCard> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant DiaryPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.diaries.length != widget.diaries.length) {
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.selectedDate.toDotString();

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
          const SizedBox(height: 16), // 카드 컴포넌트와의 간격
          
          if (widget.diaries.isEmpty)
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
            )
          else ...[
            // 다중 일기 스와이프 카드 (배경 및 그림자 고정)
            Container(
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
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.diaries.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final diary = widget.diaries[index];
                  return _buildDiaryContent(context, ref, diary);
                },
              ),
            ),
            
            // 페이지 도트 인디케이터
            if (widget.diaries.length > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.diaries.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.mainColor
                          : AppColors.gray3,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDiaryContent(BuildContext context, WidgetRef ref, DiaryData diary) {
    return GestureDetector(
      onTap: () {
        // 전역 일기 공급자 상태 동기화 후 상세 페이지 전환
        ref.read(diaryProvider.notifier).setSelectedDiary(diary);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DiaryCompletedScreen(fromCalendar: true),
          ),
        );
      },
      child: Container(
        color: Colors.transparent, // 터치 이벤트를 받기 위해 투명한 배경 설정
        width: double.infinity,
        height: 132,
        child: Stack(
          children: [
            // 좌측 감정 마스코트 아이콘 (60x60)
            Positioned(
              left: 16,
              top: 20,
              child: SvgPicture.asset(
                AppIcons.getMoodIcon(diary.mood),
                width: 60,
                height: 60,
              ),
            ),
            // 일기 제목
            Positioned(
              left: 96,
              top: 16,
              child: Text(
                diary.title,
                style: AppTextStyle.caption1Bold.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
            // 일기 요약 본문
            Positioned(
              left: 96,
              top: 46,
              width: 216,
              child: Text(
                diary.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.caption1.copyWith(
                  color: AppColors.black,
                  height: 1.6,
                ),
              ),
            ),
            // 해시태그 목록
            Positioned(
              right: 16,
              bottom: 15,
              child: Text(
                diary.tags.map((t) => '#$t').join(' '),
                style: AppTextStyle.caption1Bold.copyWith(
                  color: AppColors.mainColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
