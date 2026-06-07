extension DateTimeExtension on DateTime {
  /// DateTime을 'YYYY.MM.DD' 형식의 점(.) 구분자 텍스트로 변환합니다.
  String toDotString() {
    final y = year;
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  /// DateTime을 'MM.DD' 형식의 텍스트로 변환합니다.
  String toMMDD() {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$m.$d';
  }
}

extension StringDateTimeExtension on String {
  /// '2026.06.07-1' 또는 '2026.06.07' 형식의 문자열에서
  /// 연도와 뒤쪽의 대시 구분번호를 제거하고 'MM.dd' (예: '06.07') 형식으로 반환합니다.
  String toMMDD() {
    // 1. '-' 구분번호가 있는 경우 먼저 제거
    final datePart = split('-').first; // '2026.06.07'
    // 2. '.' 기준으로 쪼갬
    final parts = datePart.split('.');
    if (parts.length >= 3) {
      // parts[1] (월), parts[2] (일) 결합
      return '${parts[1]}.${parts[2]}';
    }
    return this; // 파싱 실패 시 원본 반환
  }
}
