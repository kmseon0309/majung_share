/// 발신자 타입 정의 (사용자 / 마중이 캐릭터)
enum MessageSender { user, mascot }

/// 메시지 타입 정의 (텍스트 / 행동 추천 카드)
enum MessageType { text, activityRecommendation }

/// 메시지 데이터 모델
class ChatMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? activityTitle;
  final String? activityId;
  final String? imagePath;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.activityTitle,
    this.activityId,
    this.imagePath,
  });
}
