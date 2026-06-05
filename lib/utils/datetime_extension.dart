extension DateTimeExtension on DateTime {
  /// DateTime을 'YYYY.MM.DD' 형식의 점(.) 구분자 텍스트로 변환합니다.
  String toDotString() {
    final y = year;
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }
}
