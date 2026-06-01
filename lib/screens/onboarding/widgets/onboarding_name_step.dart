import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../widgets/custom_button.dart';
import 'onboarding_illustration.dart';

/// 온보딩 5단계: 사용자 이름 설정 입력 단계 위젯.
class OnboardingNameStep extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onNextPressed;

  const OnboardingNameStep({
    super.key,
    required this.controller,
    required this.onNextPressed,
  });

  @override
  State<OnboardingNameStep> createState() => _OnboardingNameStepState();
}

class _OnboardingNameStepState extends State<OnboardingNameStep> {
  bool _isNameEmpty = true;

  @override
  void initState() {
    super.initState();
    _isNameEmpty = widget.controller.text.trim().isEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isEmpty = widget.controller.text.trim().isEmpty;
    if (_isNameEmpty != isEmpty) {
      setState(() {
        _isNameEmpty = isEmpty;
      });
    }
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
            '어떤 이름으로 불러 드릴까요?',
            style: AppTextStyle.h1.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // 피그마 width 280을 감안하여 컨스트레인트 부여
          SizedBox(
            width: 280,
            child: TextFormField(
              controller: widget.controller,
              autofocus: true, // 자동 포커싱 적용
              textAlign: TextAlign.center, // 입력 텍스트 및 커서 가운데 정렬
              style: AppTextStyle.body2SB.copyWith(color: AppColors.grayScale9),
              cursorColor: AppColors.mainColor,
              maxLength: 8,
              decoration: InputDecoration(
                hintText: '이름을 입력해주세요 (최대 8자)',
                hintStyle: AppTextStyle.body2R.copyWith(color: AppColors.gray3),
                counterStyle: AppTextStyle.caption2.copyWith(
                  color: AppColors.gray4,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: true,
                fillColor: AppColors.white, // 흰색 배경색 적용
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.gray2,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.mainColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Center(child: OnboardingIllustration()),
          const Spacer(),
          CustomButton(
            label: '다음',
            isFullWidth: true,
            onPressed: _isNameEmpty ? () {} : widget.onNextPressed,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
