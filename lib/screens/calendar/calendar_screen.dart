import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/datetime_extension.dart';
import '../../providers/diary_list_provider.dart';
import 'widgets/diary_preview_card.dart';
import 'widgets/month_year_picker_bottom_sheet.dart';


class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _weekdays = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  String _getMonthYearString(DateTime date) {
    return '${_months[date.month - 1]} ${date.year}';
  }

  late final DateTime _initialMonth;
  late final PageController _pageController;
  static const int _initialPage = 1000;

  int _getPageIndex(DateTime month) {
    final diffInMonths = (month.year - _initialMonth.year) * 12 + (month.month - _initialMonth.month);
    return _initialPage + diffInMonths;
  }

  DateTime _getMonthFromPageIndex(int pageIndex) {
    final diffInMonths = pageIndex - _initialPage;
    return DateTime(_initialMonth.year, _initialMonth.month + diffInMonths, 1);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _initialMonth = DateTime(now.year, now.month, 1);
    _pageController = PageController(initialPage: _initialPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(calendarMonthProvider.notifier).setMonth(_initialMonth);
        ref.read(selectedCalendarDateProvider.notifier).setDate(now);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMonth = ref.watch(calendarMonthProvider);
    final selectedDate = ref.watch(selectedCalendarDateProvider);
    final diaries = ref.watch(diaryListProvider);

    final selectedDateStr = selectedDate.toDotString();
    final selectedDiaries = diaries.where((d) => d.date.startsWith(selectedDateStr)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = screenWidth - 34; // 17 horizontal padding on both sides
    final cellWidth = (gridWidth - 60) / 7; // 10px spacing * 6 gaps = 60
    final rowHeight = cellWidth;
    final pageViewHeight = 6 * rowHeight + 50; // 10px spacing * 5 gaps = 50

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: '전체 보기',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 28), // 상단 여백 (피그마 top:84 기준 보정)
                  // 월별 네비게이션 영역 (피그마 x:17, y:84, width:326)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final selected = await showModalBottomSheet<DateTime>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => MonthYearPickerBottomSheet(
                                initialDate: activeMonth,
                              ),
                            );
                            if (selected != null) {
                              ref.read(calendarMonthProvider.notifier).setMonth(selected);
                              final targetPage = _getPageIndex(selected);
                              _pageController.jumpToPage(targetPage);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getMonthYearString(activeMonth),
                                style: AppTextStyle.poppinsBody.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        // 이전/다음 달 이동 화살표
                        Row(
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                AppIcons.arrowBack, // 뒤로가기 화살표 재사용
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: RotatedBox(
                                quarterTurns: 2,
                                child: SvgPicture.asset(
                                  AppIcons.arrowBack, // 뒤로가기 화살표를 180도 회전하여 사용
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // 요일 리스트와의 간격 (피그마 y:151 기준)

                  // 요일 행 (Sun ~ Sat, 피그마 x:17, y:151)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _weekdays.map((day) {
                        return Expanded(
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.poppinsBody.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 15), // 구분선과의 간격 (피그마 y:190 기준)

                  // 구분선 (피그마 y:190)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17),
                    child: Divider(
                      height: 1,
                      color: AppColors.gray2,
                    ),
                  ),
                  const SizedBox(height: 14), // 달력 그리드와의 간격 (피그마 y:205 기준)

                  // 달력 그리드 (피그마 x:17, y:205)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: SizedBox(
                      height: pageViewHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          final newMonth = _getMonthFromPageIndex(index);
                          ref.read(calendarMonthProvider.notifier).setMonth(newMonth);
                        },
                        itemBuilder: (context, pageIndex) {
                          final pageMonth = _getMonthFromPageIndex(pageIndex);
                          final firstDay = DateTime(pageMonth.year, pageMonth.month, 1);
                          final offset = firstDay.weekday % 7;
                          final gridStart = firstDay.subtract(Duration(days: offset));
                          final daysInM = DateTime(pageMonth.year, pageMonth.month + 1, 0).day;
                          final totalOcc = offset + daysInM;
                          final gridCnt = totalOcc <= 35 ? 35 : 42;
                          final gridDays = List.generate(gridCnt, (i) => gridStart.add(Duration(days: i)));

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: gridDays.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              final day = gridDays[index];
                              final isCurrentMonth = day.month == pageMonth.month;
                              final dateStr = day.toDotString();
                              
                              final diaryMatches = diaries.where((d) => d.date.startsWith(dateStr)).toList()
                                ..sort((a, b) => b.date.compareTo(a.date));
                              final diary = diaryMatches.isNotEmpty ? diaryMatches.first : null;
      
                              final isSelected = selectedDate.year == day.year &&
                                  selectedDate.month == day.month &&
                                  selectedDate.day == day.day;
      
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  ref.read(selectedCalendarDateProvider.notifier).setDate(day);
                                  if (day.month != pageMonth.month) {
                                    final targetMonth = DateTime(day.year, day.month, 1);
                                    ref.read(calendarMonthProvider.notifier).setMonth(targetMonth);
                                    final targetPage = _getPageIndex(targetMonth);
                                    _pageController.animateToPage(
                                      targetPage,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: Center(
                                  child: _buildDayCell(
                                    day: day,
                                    isCurrentMonth: isCurrentMonth,
                                    diary: diary,
                                    isSelected: isSelected,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // 하단 일기 프리뷰 영역 (피그마 y:529)
          DiaryPreviewCard(
            selectedDate: selectedDate,
            diaries: selectedDiaries,
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime day,
    required bool isCurrentMonth,
    required var diary,
    required bool isSelected,
  }) {
    // 1. 타 월 일자: 일기가 있으면 반투명(0.3) 감정 아이콘, 없으면 단순 회색 텍스트 렌더링
    if (!isCurrentMonth) {
      if (diary != null) {
        return Opacity(
          opacity: 0.3,
          child: SvgPicture.asset(
            AppIcons.getMoodIcon(diary.mood),
            width: 38,
            height: 38,
          ),
        );
      }
      return Text(
        day.day.toString(),
        style: AppTextStyle.poppinsBody.copyWith(
          color: const Color(0xFFE5E5E5), // 피그마 #e5e5e5 명세 엄수
        ),
      );
    }

    // 2. 당 월 일자이면서 일기 정보가 등록되어 있는 경우
    if (diary != null) {
      final iconPath = AppIcons.getMoodIcon(diary.mood);
      
      if (isSelected) {
        // 선택 상태: Svg 외곽 밀착형 테두리 적용 (배경에 1.15배 메인 컬러 SVG 아웃라인 중첩)
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.scale(
              scale: 1.15,
              child: SvgPicture.asset(
                iconPath,
                width: 38,
                height: 38,
                colorFilter: const ColorFilter.mode(
                  AppColors.mainColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SvgPicture.asset(
              iconPath,
              width: 38,
              height: 38,
            ),
          ],
        );
      } else {
        // 일반 상태
        return SvgPicture.asset(
          iconPath,
          width: 38,
          height: 38,
        );
      }
    }

    // 3. 당 월 일자이면서 일기가 없는 경우 (일반 숫자 렌더링)
    if (isSelected) {
      // 숫자 셀의 선택 형태: 메인 컬러 서클 아웃라인 적용
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.mainColor,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          day.day.toString(),
          style: AppTextStyle.poppinsBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      // 일반 숫자 셀
      return Text(
        day.day.toString(),
        style: AppTextStyle.poppinsBody,
      );
    }
  }
}
