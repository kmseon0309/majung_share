import 'package:flutter/material.dart';
import '../../../theme.dart';
import 'editable_image_card.dart';

/// 일기 작성 및 편집화면에서 공통으로 사용되는 사진 추가/수정 수평 스크롤 리스트.
/// 최대 5장 제한 하에, 이미지가 들어간 카드들과 마지막 추가(카메라) 버튼을 수평 리스트로 렌더링합니다.
class DiaryEditableImageScrollList extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback onAddImageTap;
  final ValueChanged<int> onRemoveImage;

  const DiaryEditableImageScrollList({
    super.key,
    required this.imagePaths,
    required this.onAddImageTap,
    required this.onRemoveImage,
  });

  List<Widget> _buildEditImageItems() {
    final List<Widget> items = [];
    for (int i = 0; i < imagePaths.length; i++) {
      if (i > 0) items.add(const SizedBox(width: 12));
      items.add(
        EditableImageCard(
          imagePath: imagePaths[i],
          size: 101,
          borderRadius: 16,
          onRemove: () => onRemoveImage(i),
        ),
      );
    }

    if (imagePaths.length < 5) {
      if (items.isNotEmpty) items.add(const SizedBox(width: 12));
      items.add(
        GestureDetector(
          onTap: onAddImageTap,
          child: Container(
            width: 101,
            height: 101,
            decoration: BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray2, width: 1.0),
            ),
            child: const Center(
              child: Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.gray4,
                size: 28,
              ),
            ),
          ),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 101,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _buildEditImageItems(),
      ),
    );
  }
}
