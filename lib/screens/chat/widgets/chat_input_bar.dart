import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../widgets/send_icon_button.dart';

/// 채팅 메시지 입력 필드, 이미지 첨부 버튼, 전송 버튼을 포함하는 하단 입력바 위젯.
class ChatInputBar extends StatelessWidget {
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
        children: [
          // 원형 플러스 버튼
          GestureDetector(
            onTap: onImagePickerPressed,
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
          const SizedBox(width: 12),
          // 입력 필드
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: TextField(
                controller: controller,
                style: AppTextStyle.body2R,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: TextStyle(color: AppColors.gray4),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 전송 아이콘 버튼 (SendIconButton 재사용)
          SendIconButton(
            isActive: isInputActive,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
