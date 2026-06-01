import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

import 'theme.dart';
import 'widgets/custom_button.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/activity_card.dart';
import 'widgets/selection_card.dart';
import 'widgets/behavior_card.dart';

// 신규 추가된 6종 컴포넌트 임포트
import 'widgets/chat_inner_button.dart';
import 'widgets/custom_toggle.dart';
import 'widgets/like_filter_button.dart';
import 'widgets/style_segmented_slider.dart';
import 'widgets/mini_segmented_slider.dart';
import 'widgets/send_icon_button.dart';
import 'screens/onboarding_screen.dart';

// --- Riverpod Providers (로직 분리 상태 관리) ---

// 1. 활동 카드 선택 상태 공급자
class SelectedActivity extends Notifier<String> {
  @override
  String build() => '산책하기';
  void select(String val) => state = val;
}
final selectedActivityProvider = NotifierProvider<SelectedActivity, String>(SelectedActivity.new);

// 2. 선택 카드(대화 스타터) 상태 공급자
class SelectedStarter extends Notifier<int> {
  @override
  int build() => 0;
  void select(int val) => state = val;
}
final selectedStarterProvider = NotifierProvider<SelectedStarter, int>(SelectedStarter.new);

// 3. 행동 카드 좋아요 토글 상태 공급자
class BehaviorLiked extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}
final behaviorLikedProvider = NotifierProvider<BehaviorLiked, bool>(BehaviorLiked.new);

// 4. 대화 스타일 세그먼트 상태 공급자
class SelectedStyle extends Notifier<int> {
  @override
  int build() => 0; // 0: 반말, 1: 높임말
  void select(int val) => state = val;
}
final selectedStyleProvider = NotifierProvider<SelectedStyle, int>(SelectedStyle.new);

// 5. 대화/쓰기 모드 세그먼트 상태 공급자
class ChatMode extends Notifier<int> {
  @override
  int build() => 0; // 0: 대화, 1: 쓰기
  void select(int val) => state = val;
}
final chatModeProvider = NotifierProvider<ChatMode, int>(ChatMode.new);

// 6. 커스텀 토글 스위치 상태 공급자
class ToggleState extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool val) => state = val;
}
final toggleStateProvider = NotifierProvider<ToggleState, bool>(ToggleState.new);

// 7. 좋아요 필터 버튼 상태 공급자
class FilterSelected extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}
final filterSelectedProvider = NotifierProvider<FilterSelected, bool>(FilterSelected.new);

// 8. 전송 버튼 시뮬레이션용 상태 공급자 (입력창 활성 상태)
class SendActive extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool val) => state = val;
}
final sendActiveProvider = NotifierProvider<SendActive, bool>(SendActive.new);


void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Majung App',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mainColor,
          primary: AppColors.mainColor,
        ),
        scaffoldBackgroundColor: AppColors.white,
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 모든 Riverpod 상태 감시(Watch)
    final selectedActivity = ref.watch(selectedActivityProvider);
    final selectedStarter = ref.watch(selectedStarterProvider);
    final isBehaviorLiked = ref.watch(behaviorLikedProvider);
    final selectedStyle = ref.watch(selectedStyleProvider);
    final chatMode = ref.watch(chatModeProvider);
    final toggleState = ref.watch(toggleStateProvider);
    final isFilterSelected = ref.watch(filterSelectedProvider);
    final isSendActive = ref.watch(sendActiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '마중 UI 플레이그라운드',
          style: AppTextStyle.body2B.copyWith(color: AppColors.grayScale9),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.gray2,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 소개 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('마중 디자인 시스템 고도화', style: AppTextStyle.body1),
                  const SizedBox(height: 6),
                  Text(
                    '피그마 color 섹션의 16색 팔레트와 11종의 모든 공통 컴포넌트 이식이 완료되었습니다.',
                    style: AppTextStyle.caption1.copyWith(color: AppColors.grayScale9),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: '✨ 1단계: 온보딩 플로우(UI 껍데기) 테스트',
                    isFullWidth: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- 0. 피그마 16색 감정 & 테마 팔레트 시각화 ---
            _buildSectionTitle('피그마 16색 감정 & 테마 컬러 팔레트'),
            const SizedBox(height: 12),
            _buildColorPaletteSection(),
            const SizedBox(height: 28),

            // --- 1. Buttons ---
            _buildSectionTitle('1. 버튼 라이브러리 (Buttons)'),
            const SizedBox(height: 12),
            CustomButton(
              label: '기본 메인 버튼 (Pill)',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: '온보딩용 하단 풀 버튼',
              isFullWidth: true,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            ChatInnerButton(
              label: '채팅 내 아웃라인 버튼 (196x39)',
              onPressed: () {},
            ),
            const SizedBox(height: 28),

            // --- 2. Custom Switches & Small Buttons ---
            _buildSectionTitle('2. 스위치 & 필터 칩 (Switches & Filters)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray2),
              ),
              child: Column(
                children: [
                  _buildControlTile(
                    title: '토글 스위치 (CustomToggle)',
                    child: CustomToggle(
                      value: toggleState,
                      onChanged: (val) => ref.read(toggleStateProvider.notifier).toggle(val),
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.gray2),
                  _buildControlTile(
                    title: '좋아요 필터 칩 (LikeFilterButton)',
                    child: LikeFilterButton(
                      isSelected: isFilterSelected,
                      onTap: () => ref.read(filterSelectedProvider.notifier).toggle(),
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.gray2),
                  _buildControlTile(
                    title: '전송 버튼 활성화 상태',
                    child: CustomToggle(
                      value: isSendActive,
                      onChanged: (val) => ref.read(sendActiveProvider.notifier).toggle(val),
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.gray2),
                  _buildControlTile(
                    title: '원형 전송 버튼 (SendIconButton)',
                    child: SendIconButton(
                      isActive: isSendActive,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메시지가 전송되었습니다!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- 3. Segmented Sliders ---
            _buildSectionTitle('3. 세그먼트 슬라이더 (Segmented Controls)'),
            const SizedBox(height: 12),
            Text('대화 스타일 슬라이더 (StyleSegmentedSlider - 252x52)', style: AppTextStyle.caption1Bold),
            const SizedBox(height: 8),
            StyleSegmentedSlider(
              selectedIndex: selectedStyle,
              onChanged: (val) => ref.read(selectedStyleProvider.notifier).select(val),
            ),
            const SizedBox(height: 16),
            Text('채팅 모드 미니 슬라이더 (MiniSegmentedSlider - 128x24)', style: AppTextStyle.caption1Bold),
            const SizedBox(height: 8),
            MiniSegmentedSlider(
              selectedIndex: chatMode,
              onChanged: (val) => ref.read(chatModeProvider.notifier).select(val),
            ),
            const SizedBox(height: 28),

            // --- 4. Chat & Dialog Cards ---
            _buildSectionTitle('4. 대화 & 감정 카드 (Chat & Dialog)'),
            const SizedBox(height: 12),
            const ChatBubble(
              text: '안녕하세요! 오늘 기분은 좀 어떤가요? 사소한 이야기라도 좋아요.',
              isUser: false,
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerRight,
              child: ChatBubble(
                text: '오늘 오랜만에 날씨도 맑고 해서 기분이 한결 밝아졌어요!',
                isUser: true,
              ),
            ),
            const SizedBox(height: 16),
            Text('활동 추천 모달 카드 (ActivityCard - 228x80)', style: AppTextStyle.caption1Bold),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActivityCard(
                    label: '익숙한 산책로 걷기\n(2줄까지 정렬 완료)',
                    isSelected: selectedActivity == '산책하기',
                    onTap: () => ref.read(selectedActivityProvider.notifier).select('산책하기'),
                  ),
                  ActivityCard(
                    label: '향긋한 바닐라 라떼\n한 잔 마시기 ☕️',
                    isSelected: selectedActivity == '커피마시기',
                    onTap: () => ref.read(selectedActivityProvider.notifier).select('커피마시기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('대화 스타터 카드 (SelectionCard - 144x81)', style: AppTextStyle.caption1Bold),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SelectionCard(
                  label: '"오늘 어땠어요?"',
                  isSelected: selectedStarter == 0,
                  onTap: () => ref.read(selectedStarterProvider.notifier).select(0),
                ),
                SelectionCard(
                  label: '"특별한 일 있나요?"',
                  isSelected: selectedStarter == 1,
                  onTap: () => ref.read(selectedStarterProvider.notifier).select(1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('행동 가이드 카드 (BehaviorCard - 328x76)', style: AppTextStyle.caption1Bold),
            const SizedBox(height: 8),
            Center(
              child: BehaviorCard(
                title: '너는 이런 행동들을 하면 기분이 한결 가벼워지는 것 같아. 😊',
                isLiked: isBehaviorLiked,
                onLikeToggle: () {
                  ref.read(behaviorLikedProvider.notifier).toggle();
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.body2B.copyWith(
            color: AppColors.mainColor,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildControlTile({required String title, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyle.caption1Bold.copyWith(color: AppColors.grayScale9),
          ),
        ),
        child,
      ],
    );
  }

  // 피그마의 16개 서클 컬러 칩을 뷰로 예쁘게 렌더링하는 영역
  Widget _buildColorPaletteSection() {
    final Map<String, List<Map<String, dynamic>>> colorGroups = {
      '메인 테마군': [
        {'name': 'mainColor', 'color': AppColors.mainColor, 'hex': '#356D96'},
        {'name': 'subColor', 'color': AppColors.subColor, 'hex': '#F4FAFF'},
        {'name': 'red', 'color': AppColors.red, 'hex': '#E64242'},
        {'name': 'pink', 'color': AppColors.pink, 'hex': '#FF8383'},
      ],
      '감정(Mood) 명도 단계': [
        {'name': 'mood1(연두)', 'color': AppColors.mood1, 'hex': '#8CDF9B'},
        {'name': 'mood2(민트)', 'color': AppColors.mood2, 'hex': '#6CDBDC'},
        {'name': 'mood3(노랑)', 'color': AppColors.mood3, 'hex': '#FFD07A'},
        {'name': 'mood4(연분홍)', 'color': AppColors.mood4, 'hex': '#FFB1B1'},
        {'name': 'mood5(진분홍)', 'color': AppColors.mood5, 'hex': '#FD929C'},
      ],
      '그레이스케일': [
        {'name': 'white', 'color': AppColors.white, 'hex': '#FFFFFF'},
        {'name': 'gray1', 'color': AppColors.gray1, 'hex': '#F6F8FA'},
        {'name': 'gray2', 'color': AppColors.gray2, 'hex': '#E9EAEC'},
        {'name': 'gray3', 'color': AppColors.gray3, 'hex': '#CDD0D5'},
        {'name': 'gray4', 'color': AppColors.gray4, 'hex': '#9EA4A9'},
        {'name': 'grayScale9', 'color': AppColors.grayScale9, 'hex': '#1A1A1A'},
        {'name': 'black', 'color': AppColors.black, 'hex': '#000000'},
      ],
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: colorGroups.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: AppTextStyle.caption2.copyWith(color: AppColors.gray4),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: entry.value.map((colorItem) {
                    final Color c = colorItem['color'] as Color;
                    final bool isWhiteOrSub = c == AppColors.white || c == AppColors.subColor || c == AppColors.grayScale1;
                    return Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isWhiteOrSub
                                ? Border.all(color: AppColors.gray3, width: 0.8)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          colorItem['name'] as String,
                          style: AppTextStyle.caption3.copyWith(fontSize: 9),
                        ),
                        Text(
                          colorItem['hex'] as String,
                          style: AppTextStyle.caption3.copyWith(
                            fontSize: 8,
                            color: AppColors.gray4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
