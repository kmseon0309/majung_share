/// 피그마에서 다운로드하여 세팅한 11종의 고품질 오리지널 SVG 아이콘 경로 정의 클래스.
/// 하드코딩으로 인한 오타 발생 및 런타임 이미지 로드 실패를 미연에 방지합니다.
class AppIcons {
  static const String _basePath = 'assets/icons/';

  /// 돌아가기 (왼쪽 화살표 <)
  static const String arrowBack = '${_basePath}arrow_back.svg';

  /// 마크소트 아이콘 (공용 알림 썸네일로 사용)
  static const String mascotIcon = '${_basePath}icon.svg';

  /// 활동 이동 화살표 (오른쪽 화살표 ->)
  static const String arrowRight = '${_basePath}arrow_right.svg';

  /// 행동 추천 카드 작은 오른쪽/아래쪽 화살표
  static const String rightArrowSmall = '${_basePath}right_arrow_small.svg';

  /// 알림 (벨)
  static const String bell = '${_basePath}bell.svg';

  /// 설정 (톱니바퀴)
  static const String setting = '${_basePath}setting.svg';

  /// 하트 - 아웃라인 (빈 하트)
  static const String heartRegular = '${_basePath}heart_regular.svg';

  /// 하트 - 솔리드 (채워진 하트)
  static const String heartFilled = '${_basePath}heart_filled.svg';

  /// 마이너스 삭제 원형 버튼 (-)
  static const String minusCircle = '${_basePath}minus_circle.svg';

  /// 펜 (수정/작성)
  static const String pen = '${_basePath}pen.svg';

  /// 휴지통 (삭제)
  static const String trash = '${_basePath}trash.svg';

  /// 완료 체크 원형 버튼 (V)
  static const String checkCircle = '${_basePath}check_circle.svg';

  /// 편지 봉투 - 닫힘 (안 읽은 편지)
  static const String envelope = '${_basePath}envelope.svg';

  /// 편지 봉투 - 열림 (읽은 편지)
  static const String envelopeOpen = '${_basePath}envelope_open.svg';

  /// 달력 (캘린더 - 피그마 오리지널)
  static const String calender = '${_basePath}calender.svg';

  /// 말풍선 메시지 (대화 FAB - 피그마 오리지널)
  static const String message = '${_basePath}message.svg';

  /// 대화 상대 프로필 (SVG)
  static const String profile = '${_basePath}profile.svg';

  /// 기분 아이콘 1 ~ 5 (1: 아주 좋음, 5: 아주 나쁨)
  static const String mood1 = '${_basePath}mood_1.svg';
  static const String mood2 = '${_basePath}mood_2.svg';
  static const String mood3 = '${_basePath}mood_3.svg';
  static const String mood4 = '${_basePath}mood_4.svg';
  static const String mood5 = '${_basePath}mood_5.svg';

  /// 기분 정수 값(1~5)을 바탕으로 해당 감정 SVG 아이콘 에셋 경로를 반환합니다.
  static String getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return mood1;
      case 2:
        return mood2;
      case 3:
        return mood3;
      case 4:
        return mood4;
      case 5:
      default:
        return mood5;
    }
  }
}
