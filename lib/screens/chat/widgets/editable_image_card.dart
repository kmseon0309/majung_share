import 'dart:io';
import 'package:flutter/material.dart';
import '../../../theme.dart';

/// 앱 전역에서 이미지 파일 첨부 및 등록 상태에서 삭제 기능을 수반하는 공용 액자 카드 위젯.
/// 채팅 이미지 대기열 프리뷰 및 일기 작성/편집 화면 앨범 목록에서 공유 재사용됩니다.
class EditableImageCard extends StatelessWidget {
  final String imagePath;
  final double size;
  final double borderRadius;
  final VoidCallback onRemove;

  const EditableImageCard({
    super.key,
    required this.imagePath,
    required this.size,
    this.borderRadius = 16.0,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 이미지 카드 액자 프레임
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.gray2, width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.file(File(imagePath), fit: BoxFit.cover),
          ),
        ),

        // 동그라미 닫기(X) 삭제 버튼 오버레이 (안쪽 배치하여 클리핑 방지)
        Positioned(
          top: 6,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gray4,
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.close, color: AppColors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
