import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  /// 캘린더 읽기 권한을 확인하고 요청합니다.
  static Future<bool> requestCalendarPermission() async {
    final status = await Permission.calendarFullAccess.status;
    if (status.isGranted) {
      return true;
    }
    
    final result = await Permission.calendarFullAccess.request();
    return result.isGranted;
  }

  /// 푸시 알림 권한을 확인하고 요청합니다.
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  /// 사진 라이브러리 접근 권한을 확인하고 요청합니다.
  static Future<bool> requestPhotoPermission() async {
    final status = await Permission.photos.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.photos.request();
    return result.isGranted;
  }
}
