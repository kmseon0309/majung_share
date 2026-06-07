import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

final activityRepositoryProvider = Provider((ref) => ActivityRepository());

/// 추천 활동 목록 상태를 관리하는 Riverpod Notifier.
class ActivityListNotifier extends Notifier<List<RecommendationActivity>> {
  ActivityRepository get _repo => ref.read(activityRepositoryProvider);

  @override
  List<RecommendationActivity> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    if (_repo.isEnabled) {
      final list = await _repo.getActivities();
      state = list;
    }
  }

  /// 새로운 활동을 추천받아 목록에 추가합니다. (중복 방지)
  Future<void> addActivity(String title) async {
    // 중복 여부 확인
    final exists = state.any((act) => act.title == title);
    if (exists) return;

    final newActivity = RecommendationActivity(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      isLiked: false,
    );

    final updatedList = [...state, newActivity];
    updatedList.sort((a, b) => b.id.compareTo(a.id));
    state = updatedList;
    
    if (_repo.isEnabled) {
      await _repo.updateActivityLike(newActivity); // Firestore에 저장
    }
  }

  /// 특정 활동의 타이틀을 받아 목록에서 삭제합니다. (Firestore 동기화 포함)
  Future<void> removeActivityByTitle(String title) async {
    final targets = state.where((act) => act.title == title).toList();
    if (targets.isEmpty) return;

    final targetId = targets.first.id;
    state = state.where((act) => act.title != title).toList();

    if (_repo.isEnabled) {
      await _repo.deleteActivity(targetId);
    }
  }

  /// 특정 활동의 좋아요(하트) 상태를 토글합니다.
  Future<void> toggleLike(String id) async {
    RecommendationActivity? target;
    final updatedList = state.map((act) {
      if (act.id == id) {
        target = act.copyWith(isLiked: !act.isLiked);
        return target!;
      }
      return act;
    }).toList();

    state = updatedList;

    if (target != null) {
      await _repo.updateActivityLike(target!);
    }
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
