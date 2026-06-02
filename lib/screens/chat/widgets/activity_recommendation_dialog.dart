import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/activity_card.dart';

/// 피그마의 `활동 추천 모달` 다이얼로그 컴포넌트.
class ActivityRecommendationDialog extends StatefulWidget {
  final ValueChanged<String> onActivitySelected;
  final VoidCallback onSkip;

  const ActivityRecommendationDialog({
    super.key,
    required this.onActivitySelected,
    required this.onSkip,
  });

  @override
  State<ActivityRecommendationDialog> createState() =>
      _ActivityRecommendationDialogState();
}

class _ActivityRecommendationDialogState
    extends State<ActivityRecommendationDialog> {
  int _selectedActivityIndex = -1;
  final List<String> _activities = [
    '좋아하는 노래 들으며 산책하기',
    '따뜻한 물로 샤워하기',
    '따뜻한 차 한 잔 마시기',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: 300,
        height: 417,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 모달 내 활동 추천 리스트
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(_activities.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ActivityCard(
                        label: _activities[index],
                        isSelected: _selectedActivityIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedActivityIndex = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 추천 받기/완료 버튼 (공용 CustomButton 사용)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: CustomButton(
                label: '이걸로 해볼래!',
                isFullWidth: true,
                onPressed: _selectedActivityIndex == -1
                    ? () {}
                    : () {
                        Navigator.pop(context);
                        widget.onActivitySelected(
                          _activities[_selectedActivityIndex],
                        );
                      },
                backgroundColor: _selectedActivityIndex == -1
                    ? AppColors.gray3
                    : AppColors.mainColor,
              ),
            ),
            const SizedBox(height: 12),
            // 이번엔 건너뛰기 텍스트 링크
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onSkip();
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '이번엔 건너뛰기',
                  style: AppTextStyle.caption1.copyWith(
                    color: AppColors.gray4,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.gray4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
