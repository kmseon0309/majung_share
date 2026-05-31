import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `대화 스타일 선택 슬라이더` 디자인을 반영한 가로 252px, 세로 52px의 세그먼트 슬라이더.
/// 반말/높임말 선택 시 흰색 활성 카드(Background Card)가 부드럽게 밀려가는(Slide) 슬라이딩 애니메이션이 내장되어 있습니다.
class StyleSegmentedSlider extends StatelessWidget {
  final int selectedIndex; // 0: 반말, 1: 높임말
  final ValueChanged<int> onChanged;

  const StyleSegmentedSlider({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double sliderWidth = 252.0;
    const double sliderHeight = 52.0;
    const double padding = 4.0; // 피그마 7.69%/1.59% 패딩을 4px로 매핑
    const double cardWidth = (sliderWidth - (padding * 2)) / 2; // 122.0

    return Container(
      width: sliderWidth,
      height: sliderHeight,
      decoration: BoxDecoration(
        color: AppColors.gray2, // 피그마 bg-[#e9eaec]
        borderRadius: BorderRadius.circular(12), // 피그마 rounded-[12px]
      ),
      child: Stack(
        children: [
          // 슬라이딩 흰색 카드 배경
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            top: padding,
            bottom: padding,
            // 0일 때 좌측(4.0px), 1일 때 우측(126.0px)
            left: selectedIndex == 0 ? padding : padding + cardWidth,
            width: cardWidth,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8), // 피그마 rounded-[8px]
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // 텍스트 선택 탭 영역 (터치 영역 매칭)
          Row(
            children: [
              // 1. 반말 탭
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(0),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyle.body2R.copyWith(
                        color: selectedIndex == 0
                            ? AppColors.grayScale9 // 활성: black
                            : AppColors.gray4, // 비활성: gray4
                        fontWeight: selectedIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                      ),
                      child: const Text('반말'),
                    ),
                  ),
                ),
              ),

              // 2. 높임말 탭
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(1),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyle.body2R.copyWith(
                        color: selectedIndex == 1
                            ? AppColors.grayScale9 // 활성: black
                            : AppColors.gray4, // 비활성: gray4
                        fontWeight: selectedIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                      ),
                      child: const Text('높임말'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
