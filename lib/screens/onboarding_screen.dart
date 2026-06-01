import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/selection_card.dart';
import '../widgets/app_icons.dart';

/// 마중 앱의 6단계 온보딩 플로우를 담당하는 단독 페이지 컴포넌트.
/// PageView를 기반으로 linear한 마이크로 화면 흐름과 스무스한 트랜지션을 제공합니다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  
  // 온보딩 입력/선택 상태 데이터
  final TextEditingController _nameController = TextEditingController();
  int _selectedTone = 0; // 0: 반말, 1: 존댓말
  bool _isNameEmpty = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {
      _isNameEmpty = _nameController.text.trim().isEmpty;
    });
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      // 온보딩 완료 시 뒤로가기
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '온보딩 완료: 이름 - ${_nameController.text}, 말투 - ${_selectedTone == 0 ? "반말" : "존댓말"}',
          ),
        ),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBack,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.grayScale9, BlendMode.srcIn),
          ),
          onPressed: _prevPage,
        ),
        title: _buildProgressBar(_currentPage),
        centerTitle: true,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          // 4단계부터는 유효성 확인을 강제하기 위해 손가락 스와이프를 막고 버튼 제어 적용
          physics: _currentPage >= 3 
              ? const NeverScrollableScrollPhysics() 
              : const BouncingScrollPhysics(),
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            _buildIntroPage1(),
            _buildIntroPage2(),
            _buildIntroPage3(),
            _buildCalendarSyncPage(),
            _buildNameInputPage(),
            _buildToneSelectPage(),
          ],
        ),
      ),
    );
  }

  // 상단 진행상황을 알려주는 가로 세그먼트 프로그레스 인디케이터
  Widget _buildProgressBar(int currentStep) {
    return SizedBox(
      height: 4,
      width: 140,
      child: Row(
        children: List.generate(6, (index) {
          final isPassed = index <= currentStep;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: isPassed ? AppColors.mainColor : AppColors.gray2,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- 1단계: 소개 1 (어떤 앱인가) ---
  Widget _buildIntroPage1() {
    return _buildIntroLayout(
      bubbleText: '안녕하세요!\n여기선 일기를 써야 한다는\n부담은 내려 놓으세요. 😊',
      subTitle: null,
      child: _buildCharacterIllustration(),
    );
  }

  // --- 2단계: 소개 2 (대화로 쓰기) ---
  Widget _buildIntroPage2() {
    return _buildIntroLayout(
      bubbleText: '저와의 대화가 끝나면,\n우리가 나눈 이야길 모아\n하루를 기록해 드릴게요!',
      subTitle: '대화로 완성되는 쉬운 일기',
      child: _buildCharacterIllustration(),
    );
  }

  // --- 3단계: 소개 3 (해결책 제안) ---
  Widget _buildIntroPage3() {
    return _buildIntroLayout(
      bubbleText: '지친 하루에는\n마음을 달래줄\n해결책도 알려드려요! 🌿',
      subTitle: '건강한 기분 전환 해결책 제안',
      child: _buildCharacterIllustration(),
    );
  }

  // --- 4단계: 캘린더 동기화 동의 ---
  Widget _buildCalendarSyncPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            '오늘의 일정으로 시작하는 대화',
            style: AppTextStyle.h1.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            '“오늘 무슨 일 있어?" 같은 뻔한 질문 대신\n캘린더 일정을 파악해 개인에 맞춘 질문을 해요.',
            style: AppTextStyle.caption1.copyWith(
              color: AppColors.gray4,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // 스마트폰 캘린더 피크닉 질문 박스 시뮬레이션 카드
          Center(
            child: Container(
              width: 280,
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gray2, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 영역
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.subColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gray2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/character.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '마중이',
                        style: AppTextStyle.caption1Bold.copyWith(color: AppColors.grayScale9),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 피그마 질문 렌더링
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.subColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      '오늘 피크닉 잘 다녀왔어?\n거기서 맛있는 것도 많이 먹었니? 🧺',
                      style: AppTextStyle.caption1.copyWith(
                        color: AppColors.grayScale9,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        '응! 날씨도 좋아서 정말 힐링됐어.',
                        style: AppTextStyle.caption1.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            '*캘린더 데이터는 대화의 맥락을 이해하는 데만 사용되며, 절대 외부에 유출되거나 상업적으로 활용되지 않습니다.',
            style: AppTextStyle.caption3.copyWith(
              color: AppColors.gray3,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: '캘린더 연동하기',
            isFullWidth: true,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // --- 5단계: 이름 입력 ---
  Widget _buildNameInputPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            '어떤 이름으로 불러 드릴까요?',
            style: AppTextStyle.h1.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 28),
          // 텍스트 필드 설계
          TextFormField(
            controller: _nameController,
            style: AppTextStyle.body2SB.copyWith(color: AppColors.grayScale9),
            cursorColor: AppColors.mainColor,
            maxLength: 8,
            decoration: InputDecoration(
              hintText: '이름을 입력해주세요 (최대 8자)',
              hintStyle: AppTextStyle.body2R.copyWith(color: AppColors.gray3),
              counterStyle: AppTextStyle.caption2.copyWith(color: AppColors.gray4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: AppColors.gray1,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray2, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.mainColor, width: 1.5),
              ),
            ),
          ),
          const Spacer(),
          Center(child: _buildCharacterIllustration(scale: 0.8)),
          const Spacer(),
          CustomButton(
            label: '다음',
            isFullWidth: true,
            onPressed: _isNameEmpty ? () {} : _nextPage, // 비어있으면 비활성
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // --- 6단계: 말투 선택 ---
  Widget _buildToneSelectPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            '어떤 말투로 대화를 시작해볼까요?',
            style: AppTextStyle.h1.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 32),
          // 말투 카드 선택 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. 편안한 반말 카드
              Column(
                children: [
                  Text(
                    '편안한 반말',
                    style: AppTextStyle.body2SB.copyWith(
                      color: _selectedTone == 0 ? AppColors.mainColor : AppColors.gray4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectionCard(
                    label: '"오늘 어땠어?"',
                    isSelected: _selectedTone == 0,
                    onTap: () {
                      setState(() {
                        _selectedTone = 0;
                      });
                    },
                  ),
                ],
              ),
              // 2. 다정한 존댓말 카드
              Column(
                children: [
                  Text(
                    '다정한 존댓말',
                    style: AppTextStyle.body2SB.copyWith(
                      color: _selectedTone == 1 ? AppColors.mainColor : AppColors.gray4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectionCard(
                    label: '"오늘 어땠어요?"',
                    isSelected: _selectedTone == 1,
                    onTap: () {
                      setState(() {
                        _selectedTone = 1;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Center(child: _buildCharacterIllustration(scale: 0.75)),
          const Spacer(),
          CustomButton(
            label: '다음',
            isFullWidth: true,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 소개 카드 레이아웃 유틸 템플릿
  Widget _buildIntroLayout({
    required String bubbleText,
    required String? subTitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          if (subTitle != null) ...[
            Text(
              subTitle,
              style: AppTextStyle.h1.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
          ] else ...[
            const SizedBox(height: 48),
          ],
          
          // 피그마 온보딩 특유의 말풍선 유니온 데코 상자
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.subColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.mainColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  bubbleText,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.body2R.copyWith(
                    color: AppColors.grayScale9,
                    height: 1.5,
                  ),
                ),
              ),
              // 말풍선 삼각형 꼬리 (Union Beak)
              Positioned(
                bottom: 4,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(45 / 360),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.subColor,
                      border: Border(
                        bottom: BorderSide(color: AppColors.mainColor.withValues(alpha: 0.2)),
                        right: BorderSide(color: AppColors.mainColor.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(child: child),
          const Spacer(),
          CustomButton(
            label: '다음',
            isFullWidth: true,
            onPressed: _nextPage,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 마중이 일러스트와 타원형 그림자
  Widget _buildCharacterIllustration({double scale = 1.0}) {
    return SizedBox(
      width: 160 * scale,
      height: 240 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 바닥 타원형 부드러운 그림자 (Ellipse 1)
          Positioned(
            bottom: 0,
            child: Container(
              width: 150 * scale,
              height: 24 * scale,
              decoration: BoxDecoration(
                color: AppColors.grayScale9.withValues(alpha: 0.05),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(150 * scale, 24 * scale),
                ),
              ),
            ),
          ),
          // 원본 캐릭터 PNG 이미지 (image 52)
          Positioned(
            top: 0,
            bottom: 12 * scale,
            child: Image.asset(
              'assets/images/character.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
