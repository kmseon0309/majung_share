import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore의 사용자 설정 문서를 가리키는 DocumentReference 반환
  DocumentReference? get _userDoc {
    final uid = currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  /// Firestore에서 사용자 설정 정보를 가져옵니다.
  Future<Map<String, dynamic>?> getUserSettings() async {
    if (!isEnabled) return null;
    try {
      final doc = await _userDoc?.get();
      if (doc != null && doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('UserRepository: getUserSettings error: $e');
    }
    return null;
  }

  /// Firestore에 FCM 토큰을 저장/업데이트합니다.
  Future<void> saveFcmToken(String token) async {
    if (!isEnabled) return;
    try {
      await _userDoc?.set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserRepository: saveFcmToken error: $e');
    }
  }

  /// Firestore에 사용자 설정 정보를 저장/업데이트합니다.
  Future<void> saveUserSettings({
    String? name,
    int? selectedStyle,
    bool? notificationEnabled,
  }) async {
    if (!isEnabled) return;
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (selectedStyle != null) data['selectedStyle'] = selectedStyle;
      if (notificationEnabled != null) data['notificationEnabled'] = notificationEnabled;

      if (data.isNotEmpty) {
        await _userDoc?.set(data, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('UserRepository: saveUserSettings error: $e');
    }
  }
}
