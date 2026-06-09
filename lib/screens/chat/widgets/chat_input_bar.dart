import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme.dart';
import 'send_icon_button.dart';

/// 채팅 메시지 입력 필드, 이미지 첨부 버튼, 전송 버튼을 포함하는 하단 입력바 위젯.
class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isInputActive;
  final VoidCallback onSend;
  final VoidCallback onImagePickerPressed;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isInputActive,
    required this.onSend,
    required this.onImagePickerPressed,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter;
          if (isEnter) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              // Shift + Enter: 줄바꿈 허용 (이벤트를 버블링하여 텍스트 필드가 처리하게 함)
              return KeyEventResult.ignored;
            } else {
              // Enter: 메시지 전송
              widget.onSend();
              return KeyEventResult.handled; // 엔터 입력이 텍스트 필드로 들어가 줄바꿈되는 것을 방지
            }
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray2, width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 원형 플러스 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: widget.onImagePickerPressed,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gray2,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.gray4,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 입력 필드
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                style: AppTextStyle.body2R,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 5,
                onSubmitted: (_) => widget.onSend(),
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: AppTextStyle.caption1.copyWith(color: AppColors.gray4),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 전송 아이콘 버튼 (SendIconButton 재사용)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SendIconButton(
              isActive: widget.isInputActive,
              onPressed: widget.onSend,
            ),
          ),
        ],
      ),
    );
  }
}
