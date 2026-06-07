/// 리포트(우편함 편지) 데이터 모델 정의 클래스.
class ReportLetter {
  final String id;
  final String title;
  final String dateRange;
  final bool isWeekly; // true: 주간, false: 월간
  final bool isRead;
  final bool isNew;
  
  // 말투 옵션(존댓말 true / 반말 false)에 따른 분기 대응 문자열 맵
  final Map<bool, String> content;      // 편지 본문
  final Map<bool, String> oneLiner;     // 한 줄 요약/질문 (상세 상단에 표출)
  final Map<bool, String> signature;    // 편지 하단 서명 (예: "늘 당신을 응원하는 마중이가 드림")
  final Map<bool, String>? wrapUp;      // [월간 리포트 전용] 하단 마무리 멘트
  
  // [주간 리포트 전용] 행동 추천 관련 데이터
  final String? recommendationTitle;     // 추천 제목 (예: "늘 완벽한 결과물을 내야 한다는 부담이 올 때")
  final List<String>? recommendations;   // 추천 행동 리스트

  // [월간 리포트 전용] 주차별 회고 요약 리스트
  final List<WeeklySummary>? weeklySummaries;

  ReportLetter({
    required this.id,
    required this.title,
    required this.dateRange,
    required this.isWeekly,
    this.isRead = false,
    this.isNew = false,
    required this.content,
    required this.oneLiner,
    required this.signature,
    this.wrapUp,
    this.recommendationTitle,
    this.recommendations,
    this.weeklySummaries,
  });

  factory ReportLetter.fromJson(Map<String, dynamic> json) {
    Map<bool, String> parseBoolMap(Map<dynamic, dynamic>? map) {
      if (map == null) return const {};
      return map.map((key, value) => MapEntry(key.toString() == 'true', value as String));
    }

    final rawContent = json['content'] as Map<dynamic, dynamic>? ?? {};
    final rawOneLiner = json['oneLiner'] as Map<dynamic, dynamic>? ?? {};
    final rawSignature = json['signature'] as Map<dynamic, dynamic>? ?? {};
    final rawWrapUp = json['wrapUp'] as Map<dynamic, dynamic>?;

    return ReportLetter(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dateRange: json['dateRange'] as String? ?? '',
      isWeekly: json['isWeekly'] as bool? ?? true,
      isRead: json['isRead'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      content: parseBoolMap(rawContent),
      oneLiner: parseBoolMap(rawOneLiner),
      signature: parseBoolMap(rawSignature),
      wrapUp: rawWrapUp != null ? parseBoolMap(rawWrapUp) : null,
      recommendationTitle: json['recommendationTitle'] as String?,
      recommendations: (json['recommendations'] as List<dynamic>?)?.map((e) => e as String).toList(),
      weeklySummaries: (json['weeklySummaries'] as List<dynamic>?)
          ?.map((e) => WeeklySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, String> stringifyBoolMap(Map<bool, String> map) {
      return map.map((key, value) => MapEntry(key.toString(), value));
    }

    return {
      'id': id,
      'title': title,
      'dateRange': dateRange,
      'isWeekly': isWeekly,
      'isRead': isRead,
      'isNew': isNew,
      'content': stringifyBoolMap(content),
      'oneLiner': stringifyBoolMap(oneLiner),
      'signature': stringifyBoolMap(signature),
      'wrapUp': wrapUp != null ? stringifyBoolMap(wrapUp!) : null,
      'recommendationTitle': recommendationTitle,
      'recommendations': recommendations,
      'weeklySummaries': weeklySummaries?.map((e) => e.toJson()).toList(),
    };
  }

  ReportLetter copyWith({
    String? id,
    String? title,
    String? dateRange,
    bool? isWeekly,
    bool? isRead,
    bool? isNew,
    Map<bool, String>? content,
    Map<bool, String>? oneLiner,
    Map<bool, String>? signature,
    Map<bool, String>? wrapUp,
    String? recommendationTitle,
    List<String>? recommendations,
    List<WeeklySummary>? weeklySummaries,
  }) {
    return ReportLetter(
      id: id ?? this.id,
      title: title ?? this.title,
      dateRange: dateRange ?? this.dateRange,
      isWeekly: isWeekly ?? this.isWeekly,
      isRead: isRead ?? this.isRead,
      isNew: isNew ?? this.isNew,
      content: content ?? this.content,
      oneLiner: oneLiner ?? this.oneLiner,
      signature: signature ?? this.signature,
      wrapUp: wrapUp ?? this.wrapUp,
      recommendationTitle: recommendationTitle ?? this.recommendationTitle,
      recommendations: recommendations ?? this.recommendations,
      weeklySummaries: weeklySummaries ?? this.weeklySummaries,
    );
  }
}

/// 월간 리포트 내부에서 사용되는 주차별 요약 카드 모델.
class WeeklySummary {
  final String weekTitle; // 예: "5월 초", "5월 중", "5월 말"
  final String description; // 회고 요약 내용

  WeeklySummary({
    required this.weekTitle,
    required this.description,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      weekTitle: json['weekTitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekTitle': weekTitle,
      'description': description,
    };
  }
}
