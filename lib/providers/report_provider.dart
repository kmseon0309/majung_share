import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';

/// 편지 보관함 전체 목록 상태를 관리하는 Notifier.
class ReportListNotifier extends Notifier<List<ReportLetter>> {
  @override
  List<ReportLetter> build() {
    return [
      ReportLetter(
        id: 'report_w1',
        title: '5월 둘째주',
        dateRange: '05.04 ~ 05.10',
        isWeekly: true,
        isRead: false,
        isNew: true,
        oneLiner: {
          true: '이번 주는 어떠셨나요? 한눈에 분석해 드려요.',
          false: '이번 주는 어땠는지 한문장으로?',
        },
        content: {
          true: '안녕하세요, 00님! 이번 한 주도 정말 치열하게 달리시느라 고생 많으셨어요. 이번 주 초반에는 새로운 프로젝트 때문에 머리가 많이 복잡해 보이셨어요. 밤늦게까지 고민하고, 마음에 드는 아웃풋이 나올 때까지 몰입하는 모습이 일기 속에서도 고스란히 느껴지더라고요. 무언가에 온전히 집중하는 모습은 멋지지만, 조금 걱정되기도 했답니다. 다행히 주말에 좋아하는 카페에서 커피를 마시면서 잠시 숨을 돌린 덕분에 오랜만에 기분이 좋아 보이셨어요. 일상 속 작은 아늑함으로 스스로를 돌볼 줄 아는 분이라 참 다행이에요.\n\n이번 주엔 유독 무언가를 \'완성해야 한다\'는 조급함이 네 마음을 자주 누른 것 같아요. 다음 주에는 노트북을 잠시 닫고, 마음의 채도를 조금 낮춘 채 푹 쉬셨으면 좋겠어요.',
          false: '안녕, 00아! 이번 한 주도 정말 치열하게 달리느라 고생 많았어. 이번 주 초반에는 새로운 프로젝트 때문에 머리가 많이 복잡해 보였어. 밤늦게까지 고민하고, 마음에 드는 아웃풋이 나올 때까지 몰입하는 모습이 일기 속에서도 고스란히 느껴지더라. 무언가에 온전히 집중하는 네 모습은 멋지지만, 조금 걱정되기도 했어. 다행히 주말에 좋아하는 카페에서 커피를 마시면서 잠시 숨을 돌린 덕분에 오랜만에 기분이 좋아보이더라. 일상 속 작은 아늑함으로 스스로를 돌볼 줄 아는 사람이라 참 다행이야.\n\n이번 주엔 유독 무언가를 \'완성해야 한다\'는 조급함이 네 마음을 자주 누른 것 같아. 다음 주에는 노트북을 잠시 닫고, 네 마음의 채도를 조금 낮춘 채 푹 쉬었으면 좋겠어.',
        },
        signature: {
          true: '늘 당신을 응원하는 마중이가 드림',
          false: '늘 너를 응원하는 마중이가',
        },
        recommendationTitle: '늘 완벽한 결과물을 내야 한다는 부담이 올 때',
        recommendations: [
          '좋아하는 카페 가서 아무 생각 없이 있기',
          '음악들으며 공원 산책하기',
        ],
      ),
      ReportLetter(
        id: 'report_w2',
        title: '5월 첫째주',
        dateRange: '04.27 ~ 05.03',
        isWeekly: true,
        isRead: true,
        isNew: false,
        oneLiner: {
          true: '생각보다 여유롭고 안락했던 지난주의 분석 리포트입니다.',
          false: '생각보다 여유롭고 안락했던 지난주 회고',
        },
        content: {
          true: '안녕하세요, 00님! 지난주는 근로자의 날과 징검다리 휴일이 있어 마음의 여유가 많이 생겼던 한 주였던 것 같아요. 특별한 갈등 상황이나 스트레스 요인 없이 편안하게 잠을 푹 자며 충전하는 건강한 라이프스타일을 보존하셨더라고요. 가끔은 이렇게 가만히 누워 아무런 걱정도 하지 않는 시간이 우리 마음에 가장 든든한 영양분이 되곤 해요. 충분한 휴식을 통해 에너지를 비축하신 만큼 이번 달도 활기차게 열어보시길 바라요!',
          false: '안녕, 00아! 지난주는 근로자의 날이랑 징검다리 휴일이 껴서 마음의 여유가 꽤 많았던 한 주였던 것 같아. 특별히 스트레스 받는 일도 없었고, 집에서 푹 자면서 충전하는 건강한 시간을 잘 보냈더라고요. 가끔은 이렇게 가만히 누워서 아무런 걱정 없이 보내는 시간이 우리 마음에 가장 큰 영양이 돼. 휴식으로 에너지를 꽉 채웠으니 이번 달도 즐겁게 시작해보자!',
        },
        signature: {
          true: '늘 당신을 응원하는 마중이가 드림',
          false: '늘 너를 응원하는 마중이가',
        },
        recommendationTitle: '바쁜 일상에서 잠시 한 걸음 물러나 쉬어가고 싶을 때',
        recommendations: [
          '따뜻한 차 한 잔 우려 마시기',
          '좋아하는 잠옷 입고 10분 스트레칭하기',
        ],
      ),
      ReportLetter(
        id: 'report_m1',
        title: '5월의 기록',
        dateRange: '05.01 ~ 05.31',
        isWeekly: false,
        isRead: true,
        isNew: false,
        oneLiner: {
          true: '어느새 푸르던 5월도 끝자락에 다다랐네요.',
          false: '어느새 푸르던 5월도 끝자락에 다다랐어.',
        },
        content: {
          true: '어느새 푸른 5월도 끝자락에 다다랐네요. 한 달 동안 저와 소소한 이야기를 나눠주셔서 감사해요. 00님이 남겨주신 대화들을 모아봤는데, 이번 5월은 참 다채로운 감정으로 채워진 한 달이었던 것 같아요.',
          false: '어느새 푸른 5월도 끝자락에 다다랐네. 한 달 동안 나와 소소한 이야기를 나눠줘서 고마워. 네가 남겨준 대화들을 모아봤는데, 이번 5월은 참 다채로운 감정으로 채워진 한 달이었던 것 같아.',
        },
        signature: {
          true: '늘 당신을 응원하는 마중이가 드림',
          false: '늘 너를 응원하는 마중이가',
        },
        wrapUp: {
          true: '5월 동안 00님은 흔들리는 순간마다 스스로를 다독이고 일상을 회복해나가는 단단함을 보여주셨어요. 다가오는 6월에도 00님이 길을 잃지 않도록 제가 먼저 다정하게 말을 걸어드릴게요. 우리 다음 달에도 천천히, 즐겁게 이야기 나누어요!',
          false: '5월 동안 너는 흔들리는 순간마다 스스로를 다독이고 일상을 회복해나가는 단단함을 보여줬어. 다가오는 6월에도 네가 길을 잃지 않도록 내가 먼저 다정하게 말을 걸어줄게. 우리 다음 달에도 천천히, 즐겁게 이야기 나누자!',
        },
        weeklySummaries: [
          WeeklySummary(
            weekTitle: '5월 초',
            description: '새로운 한 달을 시작하며 의욕이 돋보였던 시기. 일기를 3회 작성하며 긍정적인 감정이 많았음.',
          ),
          WeeklySummary(
            weekTitle: '5월 중',
            description: '과제와 프로젝트 압박으로 일기 속에 스트레스와 번아웃 징후가 보였으나, 산책 등으로 현명하게 해소함.',
          ),
          WeeklySummary(
            weekTitle: '5월 말',
            description: '주변 정리를 통해 안정감을 되찾고, 아늑한 일상을 회복하며 차분하게 마무리함.',
          ),
        ],
      ),
    ];
  }

  /// 특정 편지를 읽음 처리합니다 (isRead -> true, isNew -> false).
  void markAsRead(String id) {
    state = [
      for (final report in state)
        if (report.id == id)
          report.copyWith(isRead: true, isNew: false)
        else
          report
    ];
  }
}

/// 전체 리포트 편지 리스트 공급자
final reportListProvider =
    NotifierProvider<ReportListNotifier, List<ReportLetter>>(
  ReportListNotifier.new,
);

/// 편지 보관함 탭 선택 상태 관리 (0: 주간, 1: 월간)
class ReportTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int tabIndex) {
    state = tabIndex;
  }
}

/// 탭 선택 상태 제공자
final reportTabProvider = NotifierProvider<ReportTabNotifier, int>(
  ReportTabNotifier.new,
);

/// 탭 필터링 조건에 따라 주간 혹은 월간 리스트를 가공하여 제공하는 Computed Provider
final filteredReportsProvider = Provider<List<ReportLetter>>((ref) {
  final reports = ref.watch(reportListProvider);
  final activeTab = ref.watch(reportTabProvider);

  // activeTab == 0 이면 주간(isWeekly == true), 1 이면 월간(isWeekly == false)
  final filterWeekly = activeTab == 0;
  return reports.where((r) => r.isWeekly == filterWeekly).toList();
});
