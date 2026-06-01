import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../widgets/custom_button.dart';

/// 온보딩 4단계: 스마트폰 캘린더 동기화 동의 단계 위젯.
class OnboardingCalendarStep extends StatelessWidget {
  final VoidCallback onNextPressed;

  const OnboardingCalendarStep({
    super.key,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            '오늘의 일정으로 시작하는 대화',
            style: AppTextStyle.h1.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '“오늘 무슨 일 있어?" 같은 뻔한 질문 대신\n캘린더 일정을 파악해 개인에 맞춘 질문을 해요.',
            style: AppTextStyle.body2R.copyWith(
              color: AppColors.grayScale9,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // 스마트폰 캘린더 질문 시뮬레이션 카드 (Figma 디자인 반영)
          Center(
            child: Container(
              width: 280,
              height: 263,
              decoration: const BoxDecoration(
                color: Color(0xFF3C5A70), // Rectangle 271 색상
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(30),
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 246,
                height: 246,
                margin: const EdgeInsets.only(left: 17, right: 17, top: 17),
                decoration: const BoxDecoration(
                  color: Colors.white, // Rectangle 272 색상
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 70, // y: 375 - 305 = 70
                      left: 8, // x: 65 - 57 = 8
                      child: Container(
                        width: 230,
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF4FAFF,
                          ), // Rectangle 273 색상 (subColor)
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Ellipse 2 (Avatar circle)
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F8FA), // gray1
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.mainColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Texts
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '00이',
                                  style: AppTextStyle.caption2.copyWith(
                                    color: AppColors.grayScale9,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '오늘 피크닉 잘 다녀왔어?',
                                  style: AppTextStyle.caption1.copyWith(
                                    color: AppColors.grayScale9,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            '*캘린더 데이터는 대화의 맥락을 이해하는 데만 사용되며,\n절대 외부에 유출되거나 상업적으로 활용되지 않습니다.',
            style: AppTextStyle.caption1.copyWith(
              fontSize: 12,
              color: AppColors.gray4,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: '캘린더 연동하기',
            isFullWidth: true,
            onPressed: onNextPressed,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
