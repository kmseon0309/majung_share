import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';

/// 추천 활동 목록 상태를 관리하는 Riverpod Notifier.
class ActivityListNotifier extends Notifier<List<RecommendationActivity>> {
  @override
  List<RecommendationActivity> build() {
    // 피그마 시안 기준 목업 데이터 및 확장 데이터 구성
    return [
      RecommendationActivity(
        id: 'act_1',
        title: '좋아하는 노래 들으며 산책하기',
        isLiked: true, // 첫 번째 항목은 기본적으로 좋아함 상태로 모크 (피그마 시안 y=281 카드)
      ),
      RecommendationActivity(
        id: 'act_2',
        title: '따뜻한 물로 샤워하기',
        isLiked: false,
      ),
      RecommendationActivity(
        id: 'act_3',
        title: '따뜻한 차 한 잔 마시기',
        isLiked: false,
      ),
      RecommendationActivity(
        id: 'act_4',
        title: '방 정리하고 10분 동안 환기하기',
        isLiked: false,
      ),
      RecommendationActivity(
        id: 'act_5',
        title: '포근한 이불 속에서 좋아하는 책 읽기',
        isLiked: false,
      ),
    ];
  }

  /// 특정 활동의 좋아요(하트) 상태를 토글합니다.
  void toggleLike(String id) {
    state = [
      for (final act in state)
        if (act.id == id) act.copyWith(isLiked: !act.isLiked) else act
    ];
  }
}

/// 전체 활동 목록 상태 제공 프로바이더
final activityListProvider =
    NotifierProvider<ActivityListNotifier, List<RecommendationActivity>>(
  ActivityListNotifier.new,
);

/// 좋아요 필터 활성화 여부 상태를 관리하는 Notifier.
class BehaviorFilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

/// 좋아요 필터 활성화 여부 상태 제공 프로바이더 (true: 좋아요만 보기, false: 전체 보기)
final behaviorFilterProvider =
    NotifierProvider<BehaviorFilterNotifier, bool>(BehaviorFilterNotifier.new);

/// 필터 조건에 맞게 가공된 활동 목록을 계산(Computed)하여 반환하는 프로바이더
final filteredActivitiesProvider = Provider<List<RecommendationActivity>>((ref) {
  final activities = ref.watch(activityListProvider);
  final showOnlyLiked = ref.watch(behaviorFilterProvider);

  if (showOnlyLiked) {
    return activities.where((act) => act.isLiked).toList();
  }
  return activities;
});
