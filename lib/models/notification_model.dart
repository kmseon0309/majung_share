/// 개별 알림 항목의 데이터 불변 모델 정의 클래스
class NotificationItem {
  final String id;
  final String title;
  final String date;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.date,
    required this.isUnread,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      isUnread: json['isUnread'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'isUnread': isUnread,
    };
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? date,
    bool? isUnread,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
