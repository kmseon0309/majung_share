import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/behavior_card.dart';
import '../widgets/like_filter_button.dart';
import '../providers/activity_recommendation_provider.dart';
import '../main.dart'; // selectedStyleProvider
import '../utils/speech_dictionary.dart';

/// 피그마 "행동 추천" 시안(node 100:1179)의 레이아웃을 반영한 활동 모음 화면.
/// 사용자는 추천받은 활동 목록을 보고 좋아요(하트)를 눌러 북마크할 수 있으며, 
/// 우상단 필터 버튼을 통해 좋아요를 누른 항목들만 모아서 볼 수 있습니다.
class ActivityCollectionScreen extends ConsumerWidget {
  const ActivityCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 말투 선택 상태 로드 (존댓말 / 반말)
    final isHonorific = ref.watch(selectedStyleProvider) == 1;

    // 필터링 적용된 추천 활동 목록 로드 (Computed Provider)
    final filteredActivities = ref.watch(filteredActivitiesProvider);

    // 좋아요 필터 활성화 상태 로드
    final isFilterActive = ref.watch(behaviorFilterProvider);

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
          '활동 모음',
          style: AppTextStyle.body2B,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 1. 서브 헤더 (마중이 원형 아바타 + 말풍선 대용 텍스트 안내)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    AppIcons.profile,
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 20),
                  // 말투 대응된 다국어/사전 안내 멘트
                  Expanded(
                    child: Text(
                      SpeechDictionary.get(
                        SpeechKey.behaviorRecommendationSubHeader,
                        isHonorific,
                      ),
                      style: AppTextStyle.body2R.copyWith(
                        color: AppColors.grayScale9,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. 좋아요 필터 버튼 (우상단 정렬 배치)
              Align(
                alignment: Alignment.centerRight,
                child: LikeFilterButton(
                  isSelected: isFilterActive,
                  onTap: () {
                    ref.read(behaviorFilterProvider.notifier).toggle();
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. 추천 행동 카드 리스트 (동적 맵핑 렌더링)
              Expanded(
                child: filteredActivities.isEmpty
                    ? Center(
                        child: Text(
                          isFilterActive
                              ? '좋아요를 표시한 활동이 없어요.'
                              : '추천할 활동이 존재하지 않습니다.',
                          style: AppTextStyle.caption1.copyWith(
                            color: AppColors.gray4,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredActivities.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final act = filteredActivities[index];
                          return Center(
                            child: BehaviorCard(
                              title: act.title,
                              isLiked: act.isLiked,
                              onLikeToggle: () {
                                ref
                                    .read(activityListProvider.notifier)
                                    .toggleLike(act.id);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
