import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_data.dart';

/// 일기 비즈니스 상태 관리 및 데이터 연산을 담당하는 Notifier 및 Provider.
class DiaryNotifier extends Notifier<DiaryData?> {
  @override
  DiaryData? build() => null;

  /// 대화 내역(업로드된 이미지 목록 등)과 온보딩 설정을 바탕으로 새로운 일기 생성 (비동기 시뮬레이션)
  Future<void> generateDiary({
    required String date,
    required List<String> imagePaths,
    required String userName,
    required bool isHonorific,
    String? selectedActivity,
  }) async {
    // 1. 실제 네트워크 및 DNS 쿼리 동작을 모방하기 위해 lookup 수행.
    // 만약 macOS 샌드박스로 인해 네트워크가 차단되어 있다면 'OS Error: Operation not permitted' 등이 발생합니다.
    try {
      await InternetAddress.lookup('images.unsplash.com').timeout(const Duration(seconds: 3));
    } on SocketException catch (e) {
      throw Exception('네트워크 연결이 원활하지 않거나 권한이 제한되어 있습니다.\n(상세 에러: $e)');
    }

    // 2. 테스트용 인위적 에러 유발 체크
    final cleanName = userName.trim().toLowerCase();
    if (cleanName == '에러' || cleanName == 'error' || cleanName == 'fail') {
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('일기 생성 중 예상치 못한 백엔드 서버 오류가 발생했습니다. (오류 코드: 500)');
    }

    // 백엔드 API 요청 딜레이 시뮬레이션 (1.5초)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 말투(반말/존댓말)에 따라 격려 피드백 문구를 동적으로 변경합니다.
    final String feedback = isHonorific
        ? '오늘 하루를 보내면서 마음이 복잡하셨겠지만, 그래도 스스로의 감정을 이렇게 기록하셨다는 것만으로도 충분히 잘하신 일이에요.\n해야 할 일이 많을수록 시작이 더 어렵게 느껴질 수 있어요. 내일은 큰 목표보다 "과제 10분만 하기"처럼 아주 작은 행동부터 시작해보면 좋을 것 같아요.\n남들과 비교되는 마음이 들어도, 본인만의 속도로 가고 있다는 걸 잊지 않으셨으면 해요. 오늘의 바닐라 라떼처럼 작지만 기분 좋아지는 순간도 잘 발견한 하루였어요.'
        : '오늘 하루를 보내면서 마음이 복잡했겠지만, 그래도 네가 스스로의 감정을 이렇게 기록했다는 것 만으로도 충분히 잘한 일이야.\n해야 할 일이 많을수록 시작이 더 어렵게 느껴질 수 있어. 내일은 큰 목표보다 “과제 10분만 하기”처럼 아주 작은 행동부터 시작해보면 좋을 것 같아.\n남들과 비교되는 마음이 들어도, 너는 너만의 속도로 가고 있다는 걸 잊지 않았으면 해. 오늘의 바닐라 라떼처럼 작지만 기분 좋아지는 순간도 잘 발견한 하루였어.';

    state = DiaryData(
      date: date,
      title: '기분 전환이 필요한 요즘',
      content: '오늘은 별일 없는 하루였는데도 괜히 마음이 조금 복잡했다. 학교 갔다가 카페에서 과제 조금 하고, 집에 와서는 계속 핸드폰만 봤다. 해야 할 일은 많은데 막상 시작하려니까 자꾸 미루게 된다.\n요즘 내가 잘하고 있는 건지 모르겠고, 남들은 다 열심히 사는 것 같아서 괜히 비교하게 된다. 그래도 오늘 카페에서 마신 바닐라 라떼는 맛있었고, 날씨도 좋아서 잠깐 기분이 나아졌다.\n내일은 너무 완벽하게 하려고 하지 말고, 작은 것 하나라도 끝내봐야겠다.',
      mood: 5, // 피그마 시안 기준 감정 5단계 (아주 나쁨/우울)
      imagePaths: imagePaths,
      mascotFeedback: feedback,
      recommendedAction: selectedActivity ?? '',
    );
  }


  /// 일기 제목, 내용, 감정 단계 및 이미지 경로를 수정할 수 있는 비즈니스 로직
  void updateDiary({
    String? title,
    String? content,
    int? mood,
    List<String>? imagePaths,
    String? recommendedAction,
  }) {
    if (state != null) {
      state = state!.copyWith(
        title: title,
        content: content,
        mood: mood,
        imagePaths: imagePaths,
        recommendedAction: recommendedAction,
      );
    }
  }

  /// 일기를 삭제하는 비즈니스 로직
  void deleteDiary() {
    state = null;
  }

  /// 신규 일기를 저장/세팅하는 비즈니스 로직 (직접 작성 대응)
  void saveNewDiary(DiaryData diary) {
    state = diary;
  }

  /// 이미 생성된 일기(isDirectWrite)에 대해 마중이의 답장(mascotFeedback)을 생성하여 업데이트
  Future<void> generateMascotFeedbackOnly({
    required String userName,
    required bool isHonorific,
  }) async {
    if (state == null) return;

    // 1. 네트워크 확인 시뮬레이션
    try {
      await InternetAddress.lookup('images.unsplash.com').timeout(const Duration(seconds: 3));
    } on SocketException catch (e) {
      throw Exception('네트워크 연결이 원활하지 않거나 권한이 제한되어 있습니다.\n(상세 에러: $e)');
    }

    // 2. 딜레이 시뮬레이션 (1.5초)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. 피드백 문구 생성
    final String feedback = isHonorific
        ? '오늘 하루를 보내면서 마음이 많이 따뜻해지는 하루이셨나 봐요.\n 특별한 사건이 없어도 친구와 웃고, 맛있는 걸 먹고, 맑은 날씨를 느낀 것만으로 충분히 좋은 하루가 될 수 있어요. 요즘 지쳐 계셨다면 오늘 같은 날이 더 소중하게 느껴지셨을 것 같아요. 본인이 다시 괜찮아지는 감각을 느끼셨다는 것도 참 좋은 신호예요.\n 내일도 오늘의 기분을 조금만 가져가시면서, 작고 행복한 순간들을 잘 발견하시길 바랄게요.'
        : '오늘 하루를 보내면서 마음이 많이 따뜻해지는 하루였나 봐.\n 특별한 사건이 없어도 친구와 웃고, 맛있는 걸 먹고, 맑은 날씨를 느낀 것만으로 충분히 좋은 하루가 될 수 있어. 요즘 지쳐 있었다면 오늘 같은 날이 더 소중하게 느껴졌을 것 같아. 네가 다시 괜찮아지는 감각을 느꼈다는 것도 참 좋은 신호야.\n 내일도 오늘의 기분을 조금만 가져가면서, 작고 행복한 순간들을 잘 발견하길 바라.';

    state = state!.copyWith(mascotFeedback: feedback);
  }
}

final diaryProvider = NotifierProvider<DiaryNotifier, DiaryData?>(DiaryNotifier.new);
