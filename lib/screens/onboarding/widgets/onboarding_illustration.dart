import 'package:flutter/material.dart';

/// 마중이 캐릭터 일러스트 위젯.
/// 기본 크기는 160x240 (scale = 1.0)으로 렌더링됩니다.
class OnboardingIllustration extends StatelessWidget {
  final double scale;

  const OnboardingIllustration({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160 * scale,
      height: 240 * scale,
      child: Image.asset(
        'assets/images/character.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
