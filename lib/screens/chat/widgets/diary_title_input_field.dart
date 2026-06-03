import 'package:flutter/material.dart';
import '../../../theme.dart';

/// 일기 작성 및 편집화면에서 공통으로 사용되는 제목 입력 필드.
/// 포커스 시에만 하단에 메인 색상의 밑줄이 표시되며, 기본 상태에서는 테두리가 노출되지 않습니다.
class DiaryTitleInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const DiaryTitleInputField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: AppTextStyle.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.grayScale9,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.gray4),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.mainColor, width: 1.5),
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }
}
