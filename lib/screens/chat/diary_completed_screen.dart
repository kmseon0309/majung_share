import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/confirm_dialog.dart';
import '../../providers/user_provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/error_screen.dart';
import 'widgets/chat_inner_button.dart';
import 'diary_edit_screen.dart';
import '../../utils/speech_dictionary.dart';
import '../../main.dart'; // selectedStyleProvider
import 'diary_loading_screen.dart';
import 'widgets/activity_recommendation_dialog.dart';

/// 일기 작성이 완료된 후의 렌더링 화면 (순수 뷰어 역할).
/// 피그마 시안 node 175:862 ("AI 대화(작성 완료)")에 해당하며, 편집은 DiaryEditScreen에서 전담합니다.
class DiaryCompletedScreen extends ConsumerStatefulWidget {
  const DiaryCompletedScreen({super.key});

  @override
  ConsumerState<DiaryCompletedScreen> createState() => _DiaryCompletedScreenState();
}

class _DiaryCompletedScreenState extends ConsumerState<DiaryCompletedScreen> {
  String _getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return AppIcons.mood1;
      case 2:
        return AppIcons.mood2;
      case 3:
        return AppIcons.mood3;
      case 4:
        return AppIcons.mood4;
      case 5:
      default:
        return AppIcons.mood5;
    }
  }

  /// 사용자가 업로드한 이미지가 있으면 렌더링
  List<Widget> _buildImageItems(List<String> imagePaths) {
    final List<Widget> items = [];
    for (int i = 0; i < imagePaths.length; i++) {
      if (i > 0) items.add(const SizedBox(width: 12));
      items.add(
        _buildImageCard(
          child: Image.file(
            File(imagePaths[i]),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return items;
  }

  Widget _buildImageCard({required Widget child}) {
    return Container(
      width: 101,
      height: 101,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray2, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  /// 일기 삭제 컨펌 다이얼로그 호출
  void _showDeleteConfirmDialog() {
    final isHonorific = ref.read(selectedStyleProvider) == 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: SpeechDictionary.get(SpeechKey.deleteConfirmTitle, isHonorific),
          onConfirm: () {
            ref.read(diaryProvider.notifier).deleteDiary();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '일기가 삭제되었습니다.',
                  style: AppTextStyle.caption1.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.mainColor,
              ),
            );
            // 메인 플레이그라운드/홈 화면으로 완전히 복귀
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final diary = ref.watch(diaryProvider);
    final userName = ref.watch(userNameProvider);

    // 일기 데이터가 없는 경우 (삭제되었거나 미생성) 안전하게 전역 에러 화면 표출
    if (diary == null) {
      return ErrorScreen(
        title: '문제가 발생했어요!',
        message: '일기 데이터를 찾을 수 없거나 삭제되었습니다.',
        primaryButtonLabel: '홈으로 돌아가기',
        onPrimaryPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      );
    }

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
          onPressed: () {
            // 일기 완수 후 뒤로가기 탭 시에는 대화방으로 가지 않고 홈 화면으로 복귀
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: Text(diary.date, style: AppTextStyle.body2B),
        centerTitle: true,
        actions: [
          // 일반 뷰 모드: 수정(펜) 및 삭제(휴지통) 버튼
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.pen,
              width: 24,
              height: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryEditScreen(initialDiary: diary),
                ),
              );
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.trash,
              width: 24,
              height: 24,
            ),
            onPressed: _showDeleteConfirmDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // 1. 감정 클라우드 배지 (Pretendard 72x72)
              Center(
                child: SvgPicture.asset(
                  _getMoodIcon(diary.mood),
                  width: 72,
                  height: 72,
                ),
              ),
              const SizedBox(height: 16),

              // 2. 일기 제목 렌더링
              Center(
                child: Text(
                  diary.title,
                  style: AppTextStyle.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grayScale9,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. 일기 앨범 이미지 리스트 (101x101) - 사진이 있을 때만 렌더링
              if (diary.imagePaths.isNotEmpty) ...[
                SizedBox(
                  height: 101,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _buildImageItems(diary.imagePaths),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 4. 일기 본문 렌더링
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  diary.content,
                  style: AppTextStyle.body2R.copyWith(
                    color: AppColors.grayScale9,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 5. 마중이의 건네는 말 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$userName에게 건네는 말',
                  style: AppTextStyle.body2B.copyWith(
                    color: AppColors.grayScale9,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.subColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (diary.mascotFeedback.isNotEmpty)
                      Text(
                        diary.mascotFeedback,
                        style: AppTextStyle.body2R.copyWith(
                          color: AppColors.grayScale9,
                          height: 1.6,
                        ),
                      )
                    else
                      ChatInnerButton(
                        label: '답장 받기',
                        width: double.infinity,
                        height: 48,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiaryLoadingScreen(
                                isDirectWrite: true,
                                isReplyOnly: true,
                                imagePaths: diary.imagePaths,
                              ),
                            ),
                          );
                        },
                      ),
                    if (!diary.isDirectWrite || diary.mascotFeedback.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        '이런 걸 해봐!',
                        style: AppTextStyle.body2R.copyWith(
                          color: AppColors.grayScale9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (diary.recommendedAction.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              diary.recommendedAction,
                              style: AppTextStyle.body2B.copyWith(
                                color: AppColors.mainColor,
                              ),
                            ),
                          ),
                        )
                      else
                        ChatInnerButton(
                          label: '활동 추천 받기',
                          width: double.infinity,
                          height: 48,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ActivityRecommendationDialog(
                                  onActivitySelected: (activityLabel) {
                                    ref.read(diaryProvider.notifier).updateDiary(
                                          recommendedAction: activityLabel,
                                        );
                                  },
                                  onSkip: () {
                                    ref.read(diaryProvider.notifier).updateDiary(
                                          recommendedAction: '오늘 한 일 1개 적기',
                                        );
                                  },
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
