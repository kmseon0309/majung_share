import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 직접 쓰기("쓰기") 모드의 임시 입력 상태를 보존하기 위한 불변 데이터 구조.
class DirectWriteState {
  final String title;
  final String content;
  final int mood;
  final List<String> imagePaths;

  DirectWriteState({
    this.title = '',
    this.content = '',
    this.mood = 3,
    this.imagePaths = const [],
  });

  DirectWriteState copyWith({
    String? title,
    String? content,
    int? mood,
    List<String>? imagePaths,
  }) {
    return DirectWriteState(
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  /// 제목과 내용이 모두 작성되었을 때 유효한 것으로 판단합니다.
  bool get isValid => title.trim().isNotEmpty && content.trim().isNotEmpty;
}

/// 직접 쓰기 상태를 갱신 및 관리하는 비즈니스 로직 핸들러.
class DirectWriteNotifier extends Notifier<DirectWriteState> {
  @override
  DirectWriteState build() {
    return DirectWriteState();
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void updateMood(int mood) {
    state = state.copyWith(mood: mood);
  }

  void addImage(String path) {
    state = state.copyWith(imagePaths: [...state.imagePaths, path]);
  }

  void removeImage(int index) {
    final list = List<String>.from(state.imagePaths)..removeAt(index);
    state = state.copyWith(imagePaths: list);
  }

  /// 모든 작성 상태를 공백 및 기본값으로 초기화합니다.
  void clear() {
    state = DirectWriteState();
  }
}

/// 직접 쓰기 상태 공급자 선언.
final directWriteProvider =
    NotifierProvider<DirectWriteNotifier, DirectWriteState>(DirectWriteNotifier.new);
