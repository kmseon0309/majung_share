import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mini_segmented_slider.dart';
import '../models/chat_message.dart';
import 'chat/widgets/typing_indicator.dart';
import 'chat/widgets/recommendation_bubble.dart';
import 'chat/widgets/activity_recommendation_dialog.dart';
import '../widgets/confirm_dialog.dart';
import 'chat/widgets/image_source_sheet.dart';
import 'chat/widgets/image_preview_bar.dart';
import 'chat/widgets/chat_input_bar.dart';

/// 마중이 앱의 핵심 기능인 AI 대화 화면.
/// 모듈화된 위젯과 대화 상태 기계, 이미지 첨부 및 미리보기 대기 업로드 기능을 탑재하고 있습니다.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  int _toggleIndex = 0; // 0: 대화, 1: 쓰기
  bool _isInputActive = false;
  bool _isMascotTyping = false;
  String? _selectedImagePath; // 미리보기용 이미지 대기 상태

  // 모크 응답 순서 제어용 시퀀스 인덱스
  int _mockSequenceIndex = 0;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChange);

    // 최초 마중이 환영 인사 메시지 적재
    _messages.add(
      ChatMessage(
        id: 'm_init',
        sender: MessageSender.mascot,
        content: '오늘 무슨 일 있었어?',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChange);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onInputChange() {
    final hasText = _inputController.text.trim().isNotEmpty;
    final hasImage = _selectedImagePath != null;
    final isActive = hasText || hasImage;
    if (_isInputActive != isActive) {
      setState(() {
        _isInputActive = isActive;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 이미지 가져오기 및 전송 대기 처리
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
          _onInputChange(); // 전송 활성화 상태 체크
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '이미지를 가져오는 중 오류가 발생했습니다: $e',
              style: AppTextStyle.caption1.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  /// 이미지 첨부 경로 선택 바텀 시트 호출
  void _showImagePickerSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ImageSourceSheet(
          onSourceSelected: (source) {
            Navigator.pop(context);
            _pickImage(source);
          },
        );
      },
    );
  }

  /// 사용자 메시지 전송 처리 (텍스트 및 이미지 동시/개별 전송 대응)
  void _sendMessage() {
    final text = _inputController.text.trim();
    final imagePath = _selectedImagePath;

    if (text.isEmpty && imagePath == null) return;

    _inputController.clear();

    setState(() {
      _selectedImagePath = null;
      _isInputActive = false;
      _messages.add(
        ChatMessage(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.user,
          content: text,
          timestamp: DateTime.now(),
          imagePath: imagePath,
        ),
      );
      _isMascotTyping = true;
    });

    _scrollToBottom();

    // 마중이의 AI 응답 딜레이 시뮬레이션
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isMascotTyping = false;
      });

      if (imagePath != null) {
        // 이미지가 포함된 업로드의 경우 공감 모크 피드백
        setState(() {
          _messages.add(
            ChatMessage(
              id: 'm_${DateTime.now().millisecondsSinceEpoch}',
              sender: MessageSender.mascot,
              content: '우와, 정말 예쁜 사진이네! 무슨 일이었는지 나한테도 더 이야기해줄래?',
              timestamp: DateTime.now(),
            ),
          );
        });
      } else {
        // 일반 텍스트 전송 시 기존 피그마 시퀀스 전개
        _triggerMascotResponse();
      }
      _scrollToBottom();
    });
  }

  /// 마중이 모크 응답 시나리오 시퀀스
  void _triggerMascotResponse() {
    if (!mounted) return;

    final now = DateTime.now();

    if (_mockSequenceIndex == 0) {
      // 1단계 마중이 응답
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'm_${now.millisecondsSinceEpoch}',
            sender: MessageSender.mascot,
            content: '그러면 요즘 하루가 버겁겠다..',
            timestamp: now,
          ),
        );
        _mockSequenceIndex = 1;
      });
    } else if (_mockSequenceIndex == 1) {
      // 2단계 마중이 응답 + 활동 추천 카드 순차 노출
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'm_${now.millisecondsSinceEpoch}_1',
            sender: MessageSender.mascot,
            content: '하루 전체를 실패로 정리하기엔\n네가 버틴 시간도 분명히 있었을 거야',
            timestamp: now,
          ),
        );
      });

      _scrollToBottom();

      // 카드는 800ms 뒤에 한 템포 늦게 노출하여 시각적 리듬감 부여
      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _messages.add(
            ChatMessage(
              id: 'm_${now.millisecondsSinceEpoch}_2',
              sender: MessageSender.mascot,
              content: '이런 행동은 어때?\n기분이 바뀔지도 몰라',
              timestamp: now,
              type: MessageType.activityRecommendation,
            ),
          );
          _mockSequenceIndex = 2;
        });
        _scrollToBottom();
      });
    } else {
      // 그 외 일반 응답 처리
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'm_${now.millisecondsSinceEpoch}',
            sender: MessageSender.mascot,
            content: '오늘 이야기를 나누며 하루를 남기는 용기를 내 줘서 고마워.\n내일은 너무 완벽하지 않아도 괜찮아.',
            timestamp: now,
          ),
        );
      });
    }

    _scrollToBottom();
  }

  /// 활동 추천 받기 탭 시 피그마의 `활동 추천 모달` 호출
  void _showActivityRecommendationModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ActivityRecommendationDialog(
          onActivitySelected: _selectActivity,
          onSkip: _skipActivityRecommendation,
        );
      },
    );
  }

  /// 추천 활동을 선택했을 때 피드백 전송
  void _selectActivity(String activityLabel) {
    setState(() {
      // 사용자의 답변으로 활동 추가
      _messages.add(
        ChatMessage(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.user,
          content: '$activityLabel 활동을 추천받아 볼래!',
          timestamp: DateTime.now(),
        ),
      );
      _isMascotTyping = true;
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isMascotTyping = false;
        _messages.add(
          ChatMessage(
            id: 'm_${DateTime.now().millisecondsSinceEpoch}',
            sender: MessageSender.mascot,
            content: '탁월한 선택이야! 오늘 저녁엔 $activityLabel 활동을 해보자. 한결 기분이 가벼워질 거야.',
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  /// 이번엔 건너뛰기 선택 시 피드백 전송
  void _skipActivityRecommendation() {
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.user,
          content: '이번에는 건너뛸래.',
          timestamp: DateTime.now(),
        ),
      );
      _isMascotTyping = true;
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isMascotTyping = false;
        _messages.add(
          ChatMessage(
            id: 'm_${DateTime.now().millisecondsSinceEpoch}',
            sender: MessageSender.mascot,
            content: '알겠어. 굳이 뭔가를 하지 않아도 편안히 쉬는 것도 훌륭한 해결책이야. 오늘 푹 쉬자!',
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  /// 대화 끝내기 처리
  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: '대화를 끝마치고\n일기를 자동 생성할까요?',
          onConfirm: _finishConversation,
        );
      },
    );
  }

  void _finishConversation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '마중이가 일기를 작성하고 있습니다! (일기 작성 완료 씬 추후 연동 예정)',
          style: AppTextStyle.caption1.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.mainColor,
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context); // 홈 화면으로 복귀
  }

  void _showWritePlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '직접 쓰기 모드는 준비 중입니다. 대화 모드로 대화를 이어나가 주세요.',
          style: AppTextStyle.caption1.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.mainColor,
        duration: const Duration(seconds: 2),
      ),
    );
    // 강제로 대화 탭으로 복구
    setState(() {
      _toggleIndex = 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // 뒤로가기 버튼
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBack,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.mainColor,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // 피그마 문자열 그대로 "05.20"
        title: const Text('05.20', style: AppTextStyle.body2B),
        centerTitle: true,
        // 우측 끝내기 버튼 (체크 서클 SVG 아이콘)
        actions: [
          SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: IconButton(
                icon: SvgPicture.asset(
                  AppIcons.checkCircle,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.mainColor,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: _showFinishDialog,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // "대화" / "쓰기" 모드 토글 (MiniSegmentedSlider 재사용)
            Center(
              child: MiniSegmentedSlider(
                selectedIndex: _toggleIndex,
                onChanged: (index) {
                  if (index == 1) {
                    _showWritePlaceholder();
                  } else {
                    setState(() {
                      _toggleIndex = index;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // 대화 목록 영역
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length + (_isMascotTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  // mascot 타이핑 중인 인디케이터 처리
                  if (index == _messages.length && _isMascotTyping) {
                    return const TypingIndicator();
                  }

                  final msg = _messages[index];
                  final isMascot = msg.sender == MessageSender.mascot;

                  if (isMascot) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 프로필 아바타 (profile.svg)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.subColor,
                            ),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                AppIcons.profile,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 메시지 본문
                          if (msg.type == MessageType.activityRecommendation)
                            RecommendationBubble(
                              content: msg.content,
                              onRecommendationTap:
                                  _showActivityRecommendationModal,
                            )
                          else
                            ChatBubble(
                              text: msg.content,
                              isUser: false,
                              imagePath: msg.imagePath,
                            ),
                        ],
                      ),
                    );
                  } else {
                    // 사용자 메시지
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ChatBubble(
                          text: msg.content,
                          isUser: true,
                          imagePath: msg.imagePath,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // 이미지 프리뷰 대기 영역
            if (_selectedImagePath != null)
              ImagePreviewBar(
                imagePath: _selectedImagePath!,
                onCancel: () {
                  setState(() {
                    _selectedImagePath = null;
                    _onInputChange(); // 전송 상태 체크 업데이트
                  });
                },
              ),

            // 하단 입력 표시줄
            ChatInputBar(
              controller: _inputController,
              isInputActive: _isInputActive,
              onSend: _sendMessage,
              onImagePickerPressed: _showImagePickerSourceSheet,
            ),
          ],
        ),
      ),
    );
  }
}
