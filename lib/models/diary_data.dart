/// 완성된 일기 데이터를 표현하는 데이터 모델 클래스.
class DiaryData {
  final String date;
  final String title;
  final String content;
  final int mood; // 1 (아주 좋음) ~ 5 (아주 나쁨)
  final List<String> imagePaths;
  final String mascotFeedback;
  final String recommendedAction;
  final bool isDirectWrite;
  final List<String> tags;

  DiaryData({
    required this.date,
    required this.title,
    required this.content,
    required this.mood,
    required this.imagePaths,
    required this.mascotFeedback,
    required this.recommendedAction,
    this.isDirectWrite = false,
    this.tags = const [],
  });

  factory DiaryData.fromJson(Map<String, dynamic> json) {
    return DiaryData(
      date: json['date'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      mood: json['mood'] as int? ?? 3,
      imagePaths: (json['imagePaths'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      mascotFeedback: json['mascotFeedback'] as String? ?? '',
      recommendedAction: json['recommendedAction'] as String? ?? '',
      isDirectWrite: json['isDirectWrite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'title': title,
      'content': content,
      'mood': mood,
      'imagePaths': imagePaths,
      'mascotFeedback': mascotFeedback,
      'recommendedAction': recommendedAction,
      'isDirectWrite': isDirectWrite,
      'tags': tags,
    };
  }

  DiaryData copyWith({
    String? date,
    String? title,
    String? content,
    int? mood,
    List<String>? imagePaths,
    String? mascotFeedback,
    String? recommendedAction,
    bool? isDirectWrite,
    List<String>? tags,
  }) {
    return DiaryData(
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      imagePaths: imagePaths ?? this.imagePaths,
      mascotFeedback: mascotFeedback ?? this.mascotFeedback,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      isDirectWrite: isDirectWrite ?? this.isDirectWrite,
      tags: tags ?? this.tags,
    );
  }
}


