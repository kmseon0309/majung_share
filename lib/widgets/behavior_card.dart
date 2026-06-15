import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import 'app_icons.dart';

/// 피그마의 `행동 카드` 디자인을 반영한 행동 추천 가이드 카드.
/// 우측 버튼 모드에 따라 다음과 같이 동작합니다:
/// 1. `isChevronStyle == false` (기본값): 우측에 좋아요 하트 아이콘이 노출되며, 클릭 시 [onLikeToggle] 콜백이 동작합니다.
///    하단에는 해당 활동을 선택했던 일기들의 날짜 목록(selectedDates)이 확장형 아코디언 형태로 노출됩니다.
/// 2. `isChevronStyle == true`: 우측에 오른쪽 꺽쇠 화살표 아이콘이 노출되며, 카드 전체 터치 시 [onTap] 콜백이 동작합니다.
class BehaviorCard extends StatefulWidget {
  final String title;
  final bool isLiked;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onTap;
  final bool isChevronStyle;
  final List<String> selectedDates;
  final ValueChanged<String>? onDateTap;

  const BehaviorCard({
    super.key,
    required this.title,
    this.isLiked = false,
    this.onLikeToggle,
    this.onTap,
    this.isChevronStyle = false,
    this.selectedDates = const [],
    this.onDateTap,
  });

  @override
  State<BehaviorCard> createState() => _BehaviorCardState();
}

class _BehaviorCardState extends State<BehaviorCard> {
  bool _isExpanded = false;

  String get _widgetIcon =>
      widget.isLiked ? AppIcons.heartFilled : AppIcons.heartRegular;

  @override
  Widget build(BuildContext context) {
    // 화살표(Chevron) 모드는 기존처럼 카드 전체 터치 동작 및 단순 Row 형태로 렌더링
    if (widget.isChevronStyle) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.subColor, // 피그마 bg-[#f4faff]
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body2R.copyWith(
                    color: AppColors.grayScale9,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SvgPicture.asset(AppIcons.arrowRight, width: 20, height: 20),
            ],
          ),
        ),
      );
    }

    // 기본 좋아요 모드 카드 구성 (날짜 목록 포함 Column 형태)
    final Widget mainRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.body2R.copyWith(
                color: AppColors.grayScale9,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onLikeToggle,
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(_widgetIcon, width: 24, height: 24),
            ),
          ),
        ),
      ],
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        width: 328,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.subColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            mainRow,
            if (widget.selectedDates.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDatesArea(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatesArea() {
    final showChevron = widget.selectedDates.length > 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아코디언 토글 화살표 버튼 (날짜가 2개 이상일 때만 표시)
        if (showChevron)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: AnimatedRotation(
                turns: _isExpanded ? 0.25 : 0.0, // ▶ (0.0) -> ▼ (0.25 turns, 90도 회전)
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: SvgPicture.asset(
                  AppIcons.rightArrowSmall,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(AppColors.gray4, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        // 날짜 목록 영역
        Expanded(
          child: _isExpanded && showChevron
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 110),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.selectedDates.reversed.map((date) {
                        return _buildDateItem(date);
                      }).toList(),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    if (showChevron) {
                      setState(() {
                        _isExpanded = true;
                      });
                    } else if (widget.onDateTap != null) {
                      widget.onDateTap!(widget.selectedDates.last);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDateItem(widget.selectedDates.last, isClickableForNavigation: showChevron ? false : true),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDateItem(String rawDate, {bool isClickableForNavigation = true}) {
    final cleanDatePart = rawDate.split('-').first;
    final cleanDate = cleanDatePart.length >= 10 && cleanDatePart.startsWith('20')
        ? cleanDatePart.substring(2)
        : cleanDatePart; // '26.06.09'

    // 동일 날짜 중복 시 동적 N번째 일기 표시를 위한 순서 인덱스 계산
    final sameDayDates = widget.selectedDates
        .where((d) => d.split('-').first == cleanDatePart)
        .toList();
    final indexInSameDay = sameDayDates.indexOf(rawDate);

    final displayText = (sameDayDates.length > 1 && indexInSameDay > 0)
        ? '$cleanDate (${indexInSameDay + 1}번째 일기)'
        : cleanDate;

    return GestureDetector(
      onTap: isClickableForNavigation && widget.onDateTap != null
          ? () => widget.onDateTap!(rawDate)
          : () {
              if (widget.selectedDates.length > 1) {
                setState(() {
                  _isExpanded = true;
                });
              } else if (widget.onDateTap != null) {
                widget.onDateTap!(rawDate);
              }
            },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          displayText,
          style: AppTextStyle.caption3.copyWith(
            color: AppColors.gray4,
          ),
        ),
      ),
    );
  }
}
