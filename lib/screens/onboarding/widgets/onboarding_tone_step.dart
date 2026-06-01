import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/selection_card.dart';
import 'onboarding_illustration.dart';

/// 온보딩 6단계: 말투 선택 단계 위젯.
class OnboardingToneStep extends StatefulWidget {
  final int initialTone;
  final ValueChanged<int> onToneChanged;
  final VoidCallback onNextPressed;

  const OnboardingToneStep({
    super.key,
    required this.initialTone,
    required this.onToneChanged,
    required this.onNextPressed,
  });

  @override
  State<OnboardingToneStep> createState() => _OnboardingToneStepState();
}

class _OnboardingToneStepState extends State<OnboardingToneStep> {
  late int _selectedTone;

  @override
  void initState() {
    super.initState();
    _selectedTone = widget.initialTone;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            '어떤 말투로 대화를 시작해볼까요?',
            style: AppTextStyle.h1.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // 말투 카드 선택 영역 (피그마 x축 격차 16px을 정밀 반영하기 위해 center 정렬로 묶음)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. 편안한 반말 카드
              Column(
                children: [
                  Text(
                    '편안한 반말',
                    style: AppTextStyle.body2SB.copyWith(
                      color: _selectedTone == 0
                          ? AppColors.mainColor
                          : AppColors.gray4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectionCard(
                    label: '"오늘 어땠어?"',
                    isSelected: _selectedTone == 0,
                    onTap: () {
                      setState(() {
                        _selectedTone = 0;
                      });
                      widget.onToneChanged(0);
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16), // 피그마와 일치하는 간격 16px 적용
              // 2. 다정한 존댓말 카드
              Column(
                children: [
                  Text(
                    '다정한 존댓말',
                    style: AppTextStyle.body2SB.copyWith(
                      color: _selectedTone == 1
                          ? AppColors.mainColor
                          : AppColors.gray4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectionCard(
                    label: '"오늘 어땠어요?"',
                    isSelected: _selectedTone == 1,
                    onTap: () {
                      setState(() {
                        _selectedTone = 1;
                      });
                      widget.onToneChanged(1);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(child: OnboardingIllustration()),
          const Spacer(),
          CustomButton(
            label: '다음',
            isFullWidth: true,
            onPressed: widget.onNextPressed,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
