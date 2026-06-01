import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../widgets/custom_button.dart';
import 'onboarding_bubble.dart';
import 'onboarding_illustration.dart';

/// 온보딩 인트로 1, 2, 3단계를 위한 독립 모듈 위젯.
class OnboardingIntroStep extends StatelessWidget {
  final String bubbleText;
  final String subTitle;
  final VoidCallback onNextPressed;

  const OnboardingIntroStep({
    super.key,
    required this.bubbleText,
    required this.subTitle,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            subTitle,
            style: AppTextStyle.h1.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          OnboardingBubble(text: bubbleText),
          const SizedBox(height: 28),
          const Center(child: OnboardingIllustration()),
          const Spacer(),
          CustomButton(
            label: '다음',
            isFullWidth: true,
            onPressed: onNextPressed,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
