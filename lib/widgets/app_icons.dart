/// 피그마에서 다운로드하여 세팅한 11종의 고품질 오리지널 SVG 아이콘 경로 정의 클래스.
/// 하드코딩으로 인한 오타 발생 및 런타임 이미지 로드 실패를 미연에 방지합니다.
class AppIcons {
  static const String _basePath = 'assets/icons/';

  /// 돌아가기 (왼쪽 화살표 <)
  static const String arrowBack = '${_basePath}arrow_back.svg';

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
}
