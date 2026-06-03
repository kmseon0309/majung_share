import 'package:flutter/material.dart';
import '../../../theme.dart';

/// 일기 작성 및 편집화면에서 공통으로 사용되는 본문 입력 필드.
/// 별도의 테두리 없이 일기장 같은 개방감을 주며, 줄간격이 지정되어 있습니다.
class DiaryContentInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const DiaryContentInputField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: AppTextStyle.body2R.copyWith(
          color: AppColors.grayScale9,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.gray4),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
