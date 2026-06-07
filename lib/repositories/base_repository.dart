import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // isFirebaseEnabled

abstract class BaseRepository {
  /// Firebase가 올바르게 초기화되어 사용 가능한 상태인지 확인하는 플래그
  bool get isEnabled => isFirebaseEnabled && FirebaseAuth.instance.currentUser != null;

  /// 현재 로그인된 익명 사용자의 고유 UID 반환. 미로그인 시 null 반환.
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
}
