import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/app_icons.dart';

/// 일기 작성/편집 화면에서 공통으로 사용되는 5단계 기분 선택 행 UI.
/// 선택된 기분은 불투명도 1.0, 선택되지 않은 기분은 불투명도 0.3으로 표시됩니다.
class DiaryMoodSelectorRow extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodChanged;

  const DiaryMoodSelectorRow({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
  });

  String _getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return AppIcons.mood1;
      case 2:
        return AppIcons.mood2;
      case 3:
        return AppIcons.mood3;
      case 4:
        return AppIcons.mood4;
      case 5:
      default:
        return AppIcons.mood5;
    }
  }

  Widget _buildMoodSelectorItem(int moodIndex) {
    final isSelected = selectedMood == moodIndex;
    return GestureDetector(
      onTap: () => onMoodChanged(moodIndex),
      child: Padding(
        padding: const EdgeInsets.all(6), // 터치 영역(Hit Target) 보강
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.3,
          child: SvgPicture.asset(
            _getMoodIcon(moodIndex),
            width: 56,
            height: 56,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMoodSelectorItem(1),
        _buildMoodSelectorItem(2),
        _buildMoodSelectorItem(3),
        _buildMoodSelectorItem(4),
        _buildMoodSelectorItem(5),
      ],
    );
  }
}
