import 'dart:io';
import 'package:flutter/material.dart';
import '../theme.dart';

/// 피그마의 `채팅 말풍선` 디자인을 반영한 비대칭 말풍선 컴포넌트.
/// `isUser` 값에 따라 모서리 형태 및 배경색이 자동 결정됩니다.
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final double maxWidth;
  final String? imagePath;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.maxWidth = 230.0, // 피그마 max-w-[230px] 반영 기본값
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // 말풍선 모서리 설정 (비대칭 형태)
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(2), // 우측 상단이 뾰족함 (사용자)
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(2), // 좌측 상단이 뾰족함 (AI)
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    final backgroundColor = isUser ? AppColors.subColor : AppColors.gray1;

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 로컬 이미지 표시
          if (imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
              ),
            ),
            if (text.isNotEmpty) const SizedBox(height: 8),
          ],
          // 텍스트 표시
          if (text.isNotEmpty)
            Text(
              text,
              style: AppTextStyle.body2R.copyWith(
                color: AppColors.grayScale9,
              ),
            ),
        ],
      ),
    );
  }
}
