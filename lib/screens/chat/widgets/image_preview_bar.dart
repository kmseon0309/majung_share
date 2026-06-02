import 'dart:io';
import 'package:flutter/material.dart';
import '../../../theme.dart';

/// 전송 대기 중인 이미지를 입력 필드 위에 미리 보여주고 취소할 수 있는 바 위젯.
class ImagePreviewBar extends StatelessWidget {
  final String imagePath;
  final VoidCallback onCancel;

  const ImagePreviewBar({
    super.key,
    required this.imagePath,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.gray1,
        border: Border(top: BorderSide(color: AppColors.gray2, width: 1.0)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gray4,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
