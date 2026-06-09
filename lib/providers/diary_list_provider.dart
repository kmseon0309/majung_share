import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_data.dart';
import '../repositories/diary_repository.dart';
import 'activity_recommendation_provider.dart';

final diaryRepositoryProvider = Provider((ref) => DiaryRepository());

/// 캘린더 화면을 채우기 위해 과거에 작성된 여러 일기들의 리스트를 제공하는 Provider.
class DiaryListNotifier extends Notifier<List<DiaryData>> {
  DiaryRepository get _repo => ref.read(diaryRepositoryProvider);
  StreamSubscription<List<DiaryData>>? _subscription;

  @override
  List<DiaryData> build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    if (_repo.isEnabled) {
      _subscription?.cancel();
      _subscription = _repo.watchDiaries().listen((diaries) {
        state = diaries;
      });
    }

    return [];
  }

  /// 새로운 일기 추가 또는 캘린더에서 작성한 일기 상태 동기화용 메서드
  Future<void> addOrUpdateDiary(DiaryData newDiary) async {
    if (_repo.isEnabled) {
      await _repo.saveDiary(newDiary);
    } else {
      final index = state.indexWhere((element) => element.date == newDiary.date);
      if (index >= 0) {
        final updated = List<DiaryData>.from(state);
        updated[index] = newDiary;
        state = updated;
      } else {
        state = [...state, newDiary];
      }
    }
  }

  /// 일기 삭제 메서드
  Future<void> deleteDiary(String date) async {
    final targetMatches = state.where((d) => d.date == date).toList();
    if (targetMatches.isNotEmpty) {
      final targetDiary = targetMatches.first;
      final actionTitle = targetDiary.recommendedAction;

      if (_repo.isEnabled) {
        await _repo.deleteDiary(date);
      } else {
        state = state.where((d) => d.date != date).toList();
      }

      // 연쇄 활동 날짜 이력 제거
      if (actionTitle.isNotEmpty) {
        await ref.read(activityListProvider.notifier).removeActivityDate(actionTitle, date);
      }
    }
  }
}

/// 전체 일기 목록 제공자
final diaryListProvider = NotifierProvider<DiaryListNotifier, List<DiaryData>>(DiaryListNotifier.new);

/// 캘린더에서 현재 선택된 날짜 상태 제공자 (기본값: 오늘)
class SelectedCalendarDate extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  
  void setDate(DateTime date) {
    state = date;
  }
}
final selectedCalendarDateProvider = NotifierProvider<SelectedCalendarDate, DateTime>(SelectedCalendarDate.new);

/// 캘린더에서 현재 표시 중인 월 상태 제공자 (기본값: 현재 월의 1일)
class CalendarMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
  
  void setMonth(DateTime month) {
    state = month;
  }
}
final calendarMonthProvider = NotifierProvider<CalendarMonth, DateTime>(CalendarMonth.new);


