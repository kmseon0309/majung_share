import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/notification_card.dart';
import '../providers/notification_provider.dart';

/// 피그마 "알림" 화면(node 100:1488)의 레이아웃을 반영한 고충실도 알림 목록 스크린.
/// 알림 클릭 시 읽음으로 자동 상태 업데이트(빨간색/코랄색 미독 마크 해제) 처리됩니다.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBack,
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '알림',
          style: AppTextStyle.body2B,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const Center(
                child: Text(
                  '알림이 없습니다.',
                  style: AppTextStyle.body2R,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8), // 피그마 실측 8px 간격
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return NotificationCard(
                    title: item.title,
                    date: item.date,
                    isUnread: item.isUnread,
                    onTap: () {
                      ref.read(notificationListProvider.notifier).markAsRead(item.id);
                    },
                  );
                },
              ),
      ),
    );
  }
}
