import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme.dart';

/// 사진 업로드 소스(앨범/카메라)를 선택하는 바텀 시트 위젯.
class ImageSourceSheet extends StatelessWidget {
  final ValueChanged<ImageSource> onSourceSelected;

  const ImageSourceSheet({
    super.key,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '사진 첨부하기',
            style: AppTextStyle.body2B.copyWith(
              color: AppColors.grayScale9,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSourceOption(
                icon: Icons.photo_library,
                label: '앨범에서 선택',
                onTap: () => onSourceSelected(ImageSource.gallery),
              ),
              _buildSourceOption(
                icon: Icons.camera_alt,
                label: '카메라로 촬영',
                onTap: () => onSourceSelected(ImageSource.camera),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.subColor,
            ),
            child: Icon(icon, color: AppColors.mainColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyle.caption1.copyWith(
              color: AppColors.grayScale9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
