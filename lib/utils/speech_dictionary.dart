/// 말투 스타일에 따른 고정 문구 키 정의
enum SpeechKey {
  /// 일기 생성 로딩 메시지
  loadingDiary,

  /// 대화 종료 컨펌 타이틀
  finishConfirmTitle,

  /// 일기 제목 입력 힌트
  placeholderDiaryTitle,

  /// 일기 본문 입력 힌트
  placeholderDiaryContent,

  /// 직접 쓰기 플러그인 안내 메시지
  directWritePlaceholder,

  /// 일기 삭제 컨펌 타이틀
  deleteConfirmTitle,

  /// 활동 모음 서브 헤더 타이틀
  behaviorRecommendationSubHeader,
}

/// 말투 설정(존댓말/반말)에 대응하여 고정 텍스트 문구를 일괄 관리하는 사전(Dictionary) 클래스.
/// 피그마 원안의 문구 및 일관성을 유지하고, UI 내의 인라인 하드코딩 분기를 배제하여 유지보수성을 극대화합니다.
class SpeechDictionary {
  static const Map<SpeechKey, Map<bool, String>> _dictionary = {
    SpeechKey.loadingDiary: {
      true: '대화 내용을 바탕으로\n일기를 작성하고 있어요!',
      false: '대화 내용을 바탕으로\n일기를 작성하고 있어!',
    },
    SpeechKey.finishConfirmTitle: {
      true: '대화를 끝마치고\n일기를 자동 생성할까요?',
      false: '대화를 끝마치고\n일기를 자동 생성할까?',
    },
    SpeechKey.placeholderDiaryTitle: {true: '일기 제목을 써주세요', false: '일기 제목을 써줘'},
    SpeechKey.placeholderDiaryContent: {
      true: '일기 본문을 써주세요.',
      false: '일기 본문을 써줘',
    },
    SpeechKey.directWritePlaceholder: {
      true: '직접 쓰기 모드는 준비 중입니다. 대화 모드로 대화를 이어나가 주세요.',
      false: '직접 쓰기 모드는 준비 중이야. 대화 모드로 대화를 이어나가 줘.',
    },
    SpeechKey.deleteConfirmTitle: {
      true: '이 일기를 정말 삭제할까요?',
      false: '이 일기를 정말 삭제할거야?',
    },
    SpeechKey.behaviorRecommendationSubHeader: {
      true: '마음에 들었던 행동들에\n하트를 눌러주세요!',
      false: '마음에 들었던 행동들에\n하트를 눌러줘!',
    },
  };

  /// 말투 스타일(존댓말 true / 반말 false)과 키를 사용하여 사전에 정의된 고정 멘트를 반환합니다.
  static String get(SpeechKey key, bool isHonorific) {
    return _dictionary[key]?[isHonorific] ?? '';
  }
}
