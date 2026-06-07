import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';

final reportRepositoryProvider = Provider((ref) => ReportRepository());

/// 편지 보관함 전체 목록 상태를 관리하는 Notifier.
class ReportListNotifier extends Notifier<List<ReportLetter>> {
  ReportRepository get _repo => ref.read(reportRepositoryProvider);

  @override
  List<ReportLetter> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    if (_repo.isEnabled) {
      final list = await _repo.getReports();
      state = list;
    }
  }

  /// 특정 편지를 읽음 처리합니다 (isRead -> true, isNew -> false).
  Future<void> markAsRead(String id) async {
    state = [
      for (final report in state)
        if (report.id == id)
          report.copyWith(isRead: true, isNew: false)
        else
          report
    ];

    await _repo.updateReportReadStatus(id, isRead: true, isNew: false);
  }
}

/// 전체 리포트 편지 리스트 공급자
final reportListProvider =
    NotifierProvider<ReportListNotifier, List<ReportLetter>>(
  ReportListNotifier.new,
);

/// 편지 보관함 탭 선택 상태 관리 (0: 주간, 1: 월간)
class ReportTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int tabIndex) {
    state = tabIndex;
  }
}

/// 탭 선택 상태 제공자
final reportTabProvider = NotifierProvider<ReportTabNotifier, int>(
  ReportTabNotifier.new,
);

/// 탭 필터링 조건에 따라 주간 혹은 월간 리스트를 가공하여 제공하는 Computed Provider
final filteredReportsProvider = Provider<List<ReportLetter>>((ref) {
  final reports = ref.watch(reportListProvider);
  final activeTab = ref.watch(reportTabProvider);

  // activeTab == 0 이면 주간(isWeekly == true), 1 이면 월간(isWeekly == false)
  final filterWeekly = activeTab == 0;
  return reports.where((r) => r.isWeekly == filterWeekly).toList();
});
