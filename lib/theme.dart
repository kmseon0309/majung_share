import 'package:flutter/material.dart';

/// 피그마 디자인 시스템의 컬러 파레트 정의
class AppColors {
  // 메인 테마 컬러군
  static const Color mainColor = Color(0xFF356D96);
  static const Color subColor = Color(0xFFF4FAFF);
  
  // 기본 컬러
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFE64242);
  static const Color pink = Color(0xFFFF8383); // 연한 핑크

  // 그레이스케일 컬렉션 (피그마 7단계 명도 구성)
  static const Color gray1 = Color(0xFFF6F8FA);
  static const Color gray2 = Color(0xFFE9EAEC);
  static const Color gray3 = Color(0xFFCDD0D5);
  static const Color gray4 = Color(0xFF9EA4A9);
  static const Color gray5 = Color(0xFF70777D);
  static const Color grayScale1 = Color(0xFFFDFDFD);
  static const Color grayScale9 = Color(0xFF1A1A1A);

  // 5종 감정(Mood) 색상군 (피그마 감정 5단계)
  static const Color mood1 = Color(0xFF8CDF9B); // 연두 (기분 좋음 극대화)
  static const Color mood2 = Color(0xFF6CDBDC); // 민트
  static const Color mood3 = Color(0xFFFFD07A); // 노랑 (중간 단계)
  static const Color mood4 = Color(0xFFFFB1B1); // 연분홍
  static const Color mood5 = Color(0xFFFD929C); // 진분홍 (별로인 극대화)
}

/// 피그마 디자인 시스템의 타이포그래피 스타일 정의
/// 기본 서체는 'Pretendard'를 지향하며, 기본 폰트와 결합할 수 있도록 폴백 스타일을 지원합니다.
class AppTextStyle {
  static const String fontFamily = 'Pretendard';

  // H1: 20pt / Bold / 150%
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // body1: 18pt / Bold / 160%
  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.6,
    color: AppColors.grayScale9,
  );

  // body2_B: 16pt / Bold / 150%
  static const TextStyle body2B = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // body2_SB: 16pt / SemiBold / 150%
  static const TextStyle body2SB = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // body2_R: 16pt / Regular / 150%
  static const TextStyle body2R = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // text: 16pt / Regular / 160%
  static const TextStyle text = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.grayScale9,
  );

  // caption1: 14pt / Regular / 150%
  static const TextStyle caption1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // caption1_B: 14pt / Bold / 150%
  static const TextStyle caption1Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // caption2: 12pt / Bold(or Regular) / 150%
  static const TextStyle caption2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // caption3: 10pt / Bold(or Regular) / 150%
  static const TextStyle caption3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: AppColors.grayScale9,
  );

  // Poppins 전용 서체 계열
  static const String poppinsFontFamily = 'Poppins';

  static const TextStyle poppinsBody = TextStyle(
    fontFamily: poppinsFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
}
