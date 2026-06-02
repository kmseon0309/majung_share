import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `미니 슬라이더` 디자인을 반영한 가로 128px, 세로 24px 크기의 미니 세그먼트 슬라이더.
/// 외부에서 주입받은 `labels`를 렌더링하며 전환 시 메인 블루 색상의 슬라이더 카드가 좌우로 오가는 고품질 애니메이션이 포함되어 있습니다.
class MiniSegmentedSlider extends StatelessWidget {
  final int selectedIndex; // 활성 탭 인덱스
  final ValueChanged<int> onChanged;
  final List<String> labels; // 표시할 탭 레이블 리스트

  const MiniSegmentedSlider({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.labels = const ['대화', '쓰기'], // 기존 호환성을 위한 기본값 지정
  });

  @override
  Widget build(BuildContext context) {
    const double sliderWidth = 128.0;
    const double sliderHeight = 24.0;
    const double cardWidth = sliderWidth / 2; // 64.0

    return Container(
      width: sliderWidth,
      height: sliderHeight,
      decoration: BoxDecoration(
        color: AppColors.gray2, // 피그마 bg-[#e9eaec]
        borderRadius: BorderRadius.circular(100), // 피그마 rounded-[100px]
      ),
      child: Stack(
        children: [
          // 메인 블루 색상의 슬라이딩 활성 카드 배경
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: selectedIndex == 0 ? 0 : cardWidth,
            width: cardWidth,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.mainColor, // 피그마 bg-[#356d96]
                borderRadius: BorderRadius.all(Radius.circular(100)), // 피그마 rounded-[100px]
              ),
            ),
          ),

          // 텍스트 정렬 및 터치 감지
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 첫 번째 탭
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(0),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: AppTextStyle.caption1.copyWith(
                          fontSize: 14,
                          color: selectedIndex == 0 ? AppColors.white : AppColors.gray4,
                          fontWeight: selectedIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: Text(labels.isNotEmpty ? labels[0] : ''),
                      ),
                    ),
                  ),
                ),

                // 2. 두 번째 탭
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(1),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: AppTextStyle.caption1.copyWith(
                          fontSize: 14,
                          color: selectedIndex == 1 ? AppColors.white : AppColors.gray4,
                          fontWeight: selectedIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: Text(labels.length > 1 ? labels[1] : ''),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
