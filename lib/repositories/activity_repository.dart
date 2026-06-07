import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/activity_model.dart';
import 'base_repository.dart';

class ActivityRepository extends BaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference? get _activitiesCollection {
    final uid = currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('activities');
  }

  /// Firestore에서 유저의 활동 목록을 가져옵니다. 없으면 빈 리스트를 반환합니다.
  Future<List<RecommendationActivity>> getActivities() async {
    if (!isEnabled) return [];
    try {
      final snapshot = await _activitiesCollection?.get();
      if (snapshot != null && snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) {
          return RecommendationActivity.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        // ID 내림차순(최신순) 정렬
        list.sort((a, b) => b.id.compareTo(a.id));
        return list;
      }
    } catch (e) {
      debugPrint('ActivityRepository: getActivities error: $e');
    }
    return [];
  }

  /// 특정 추천 활동의 좋아요 상태를 Firestore에 업데이트합니다.
  Future<void> updateActivityLike(RecommendationActivity activity) async {
    if (!isEnabled) return;
    try {
      await _activitiesCollection?.doc(activity.id).set(activity.toJson());
    } catch (e) {
      debugPrint('ActivityRepository: updateActivityLike error: $e');
    }
  }

  /// 특정 추천 활동을 Firestore에서 완전히 삭제합니다.
  Future<void> deleteActivity(String id) async {
    if (!isEnabled) return;
    try {
      await _activitiesCollection?.doc(id).delete();
    } catch (e) {
      debugPrint('ActivityRepository: deleteActivity error: $e');
    }
  }
}
