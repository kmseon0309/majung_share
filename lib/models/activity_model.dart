/// 추천 활동(행동 추천)을 정의하는 데이터 모델 클래스.
class RecommendationActivity {
  final String id;
  final String title;
  final bool isLiked;

  RecommendationActivity({
    required this.id,
    required this.title,
    this.isLiked = false,
  });

  RecommendationActivity copyWith({
    String? id,
    String? title,
    bool? isLiked,
  }) {
    return RecommendationActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
