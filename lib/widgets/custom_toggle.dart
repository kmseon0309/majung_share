import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `toggle` 디자인을 반영한 가로 44px, 세로 24px 크기의 슬라이딩 토글 스위치.
/// 터치 시 흰색 썸(Thumb)이 부드럽게 좌우로 미끄러지는 애니메이션을 제공합니다.
class CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = value ? AppColors.mainColor : AppColors.gray3;

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12), // 피그마 rounded-[12px]
        ),
        child: Stack(
          children: [
            // 미끄러지는 흰색 원형 썸(Thumb)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: 2,
              bottom: 2,
              // ON 상태일 때는 우측 정렬(오른쪽 마진 2px), OFF 상태일 때는 좌측 정렬(왼쪽 마진 2px)
              left: value ? 22 : 2,
              right: value ? 2 : 22,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
