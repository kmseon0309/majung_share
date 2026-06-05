import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

/// 알림 목록 및 개별 알림의 읽음(확인) 상태를 관리하는 Notifier.
class NotificationListNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    // 피그마 v.4 시안 기반 목데이터 리스트 초기 구성
    return [
      const NotificationItem(
        id: '1',
        title: '저번 달 이맘때 쯤 기억해?',
        date: '어제',
        isUnread: true,
      ),
      const NotificationItem(
        id: '2',
        title: '5월 둘째주 답장이 도착했어!',
        date: '7일 전',
        isUnread: false,
      ),
      const NotificationItem(
        id: '3',
        title: '오늘 한강 잘 다녀왔어? 한강에서 뭐했는 지 얘기해 줘!',
        date: '5월 5일',
        isUnread: false,
      ),
      const NotificationItem(
        id: '4',
        title: '저번 달 이맘때 쯤엔 친구랑 소금빵을 먹었었구나',
        date: '5월 1일',
        isUnread: false,
      ),
    ];
  }

  /// 특정 알림을 확인(읽음) 처리하는 메서드
  void markAsRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isUnread: false) else item
    ];
  }

  /// 모든 알림을 확인 처리하는 메서드 (추후 전역 제어 대비)
  void markAllAsRead() {
    state = [for (final item in state) item.copyWith(isUnread: false)];
  }
}

final notificationListProvider =
    NotifierProvider<NotificationListNotifier, List<NotificationItem>>(
        NotificationListNotifier.new);
