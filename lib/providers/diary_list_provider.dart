import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_data.dart';
import '../utils/datetime_extension.dart';

/// 캘린더 화면을 채우기 위해 과거에 작성된 여러 일기들의 리스트를 제공하는 Provider.
class DiaryListNotifier extends Notifier<List<DiaryData>> {
  @override
  List<DiaryData> build() {
    final now = DateTime.now();

    String getFormattedDate(int day) {
      return DateTime(now.year, now.month, day).toDotString();
    }

    // 테스트용 인접 달 일기 (전달 말일 및 다음달 초일)
    final prevMonthEnd = DateTime(now.year, now.month, 0);
    final prevMonthEndStr = prevMonthEnd.toDotString();

    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    final nextMonthStartStr = nextMonthStart.toDotString();

    final nextMonthSecond = DateTime(now.year, now.month + 1, 2);
    final nextMonthSecondStr = nextMonthSecond.toDotString();

    return [
      DiaryData(
        date: prevMonthEndStr,
        title: '지난달 마지막 날 일기',
        content: '흐릿한 반투명 감정 아이콘이 이전 달 날짜 칸에 올바르게 노출되는지 테스트하기 위한 일기입니다.',
        mood: 2, // 민트
        imagePaths: [],
        mascotFeedback: '지난 달도 고생 많으셨어요. 차분하게 마무리하고 새 달을 맞이하는 모습이 보기 좋습니다.',
        recommendedAction: '스스로에게 수고했다고 속삭이기',
        tags: ['마무리', '지난달', '테스트'],
      ),
      DiaryData(
        date: nextMonthStartStr,
        title: '다음달 첫날 일기',
        content: '흐릿한 반투명 뾰족이 아이콘이 다음 달 날짜 칸에 올바르게 노출되는지 테스트하기 위한 일기입니다.',
        mood: 5, // 진분홍 (매우 나쁨)
        imagePaths: [],
        mascotFeedback: '새로운 달의 첫 날부터 힘든 일이 있으셨군요. 너무 자책하지 마시고 푹 쉬시길 바랄게요.',
        recommendedAction: '맛있는 디저트 먹기',
        tags: ['시작', '다음달', '테스트'],
      ),
      DiaryData(
        date: nextMonthSecondStr,
        title: '다음달 둘째 날 일기',
        content: '회색으로 렌더링되는 다음 달 날짜 칸에 또 다른 반투명 아이콘이 올바르게 노출되는지 테스트하기 위한 일기입니다.',
        mood: 3, // 노랑 (보통)
        imagePaths: [],
        mascotFeedback: '다음 달 둘째 날도 차분하게 보내고 계시는군요. 오늘의 보통의 하루도 소중합니다.',
        recommendedAction: '가볍게 스트레칭하기',
        tags: ['일상', '다음달', '테스트'],
      ),
      DiaryData(
        date: getFormattedDate(5),
        title: '평범하고 차분한 월요일',
        content: '오늘은 평범한 월요일이었다. 퇴근 후에 가볍게 산책을 하고 집으로 돌아왔다. 큰 이벤트는 없었지만 차분하게 생각을 정리할 수 있어서 좋았다.',
        mood: 3, // 노랑 (중간 단계)
        imagePaths: [],
        mascotFeedback: '평범함 속에서 스스로 안정을 찾는 모습이 참 보기 좋아. 내일도 너의 페이스를 유지하길 바랄게.',
        recommendedAction: '따뜻한 차 마시기',
        tags: ['일상', '월요일', '산책'],
      ),
      DiaryData(
        date: getFormattedDate(6),
        title: '기분 좋은 화요일 저녁',
        content: '친구와 맛있는 저녁을 먹고 카페에서 오랫동안 즐겁게 수다를 떨었다. 그동안 쌓였던 스트레스가 한 번에 다 해소되는 느낌이었다!',
        mood: 1, // 연두 (아주 좋음)
        imagePaths: [],
        mascotFeedback: '친구분과의 소중한 시간으로 에너지를 많이 얻으셨나 봐요. 이런 기쁨을 함께 나누는 관계가 있다는 건 큰 축복이에요.',
        recommendedAction: '친구에게 감사 인사하기',
        tags: ['친구', '외식', '수다'],
      ),
      DiaryData(
        date: getFormattedDate(7),
        title: '민트빛 상쾌한 성취감',
        content: '이번 주 내내 나를 괴롭히던 어려운 프로젝트 작업을 드디어 성공적으로 마쳤다. 속이 정말 후련하고, 해낼 줄 몰랐는데 뿌듯하다.',
        mood: 2, // 민트 (좋음)
        imagePaths: [],
        mascotFeedback: '노력하던 일을 마쳤을 때의 성취감은 정말 달콤하죠. 끈기 있게 집중하여 이룬 오늘의 결과를 스스로 듬뿍 칭찬해주세요.',
        recommendedAction: '스스로에게 작은 선물 주기',
        tags: ['성공', '업무완료', '뿌듯'],
      ),
      DiaryData(
        date: getFormattedDate(8),
        title: '조금 지쳤던 하루',
        content: '사소한 일로 동료와 의견 차이가 있어서 종일 신경 쓰이고 머리가 아팠다. 감정 소모가 많았던 날이라 집에 가자마자 눕고 싶다.',
        mood: 4, // 연분홍 (나쁨)
        imagePaths: [],
        mascotFeedback: '인간관계에서 오는 감정 소모가 제일 힘든 법이야. 오늘은 더 이상 고민하지 말고 네 몸과 마음의 휴식에만 집중해 줘.',
        recommendedAction: '따뜻한 물로 샤워하고 일찍 자기',
        tags: ['직장', '소통오류', '피곤'],
      ),
      DiaryData(
        date: getFormattedDate(15),
        title: '기분 좋은 하루',
        content: '오늘은 오랜만에 기분이 정말 좋았다. 아침부터 날씨도 맑고, 준비도 생각했던 대로 잘 풀려서 상쾌하게 하루를 열었다.',
        mood: 1, // 연두 (아주 좋음)
        imagePaths: [],
        mascotFeedback: '맑은 날씨만큼이나 기분 좋은 소식이 가득했던 하루를 보내셨네요! 사소하게 흘려보내지 않고 행복을 만끽하신 모습이 정말 훌륭합니다.',
        recommendedAction: '오늘의 행복을 사진으로 남기기',
        tags: ['디자인', '과제', '피드백'],
      ),
    ];
  }

  /// 새로운 일기 추가 또는 캘린더에서 작성한 일기 상태 동기화용 메서드
  void addOrUpdateDiary(DiaryData newDiary) {
    final index = state.indexWhere((element) => element.date == newDiary.date);
    if (index >= 0) {
      final updated = List<DiaryData>.from(state);
      updated[index] = newDiary;
      state = updated;
    } else {
      state = [...state, newDiary];
    }
  }
}

/// 전체 일기 목록 제공자
final diaryListProvider = NotifierProvider<DiaryListNotifier, List<DiaryData>>(DiaryListNotifier.new);

/// 캘린더에서 현재 선택된 날짜 상태 제공자 (기본값: 오늘)
class SelectedCalendarDate extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  
  void setDate(DateTime date) {
    state = date;
  }
}
final selectedCalendarDateProvider = NotifierProvider<SelectedCalendarDate, DateTime>(SelectedCalendarDate.new);

/// 캘린더에서 현재 표시 중인 월 상태 제공자 (기본값: 현재 월의 1일)
class CalendarMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
  
  void setMonth(DateTime month) {
    state = month;
  }
}
final calendarMonthProvider = NotifierProvider<CalendarMonth, DateTime>(CalendarMonth.new);


