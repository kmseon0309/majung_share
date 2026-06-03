import 'package:flutter/material.dart';
import '../theme.dart';
import 'custom_button.dart';

/// 피그마 공통 2버튼 다이얼로그 모달 위젯.
/// 대화 끝내기, 탈퇴 확인 등 확인/취소가 수반되는 모든 공통 모달로 재사용 가능합니다.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color backgroundColor;
  final Color cancelTextColor;
  final Color cancelBgColor;
  final Color confirmTextColor;
  final Color confirmBgColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.confirmLabel = '확인',
    this.cancelLabel = '취소',
    required this.onConfirm,
    this.onCancel,
    this.backgroundColor = AppColors.white,
    this.cancelTextColor = AppColors.gray5,
    this.cancelBgColor = AppColors.gray2,
    this.confirmTextColor = AppColors.white,
    this.confirmBgColor = AppColors.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.body2R.copyWith(height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 취소 버튼
                CustomButton(
                  label: cancelLabel,
                  height: 38,
                  textColor: cancelTextColor,
                  backgroundColor: cancelBgColor,
                  onPressed: () {
                    Navigator.pop(context);
                    if (onCancel != null) onCancel!();
                  },
                ),
                // 확인 버튼
                CustomButton(
                  label: confirmLabel,
                  height: 38,
                  textColor: confirmTextColor,
                  backgroundColor: confirmBgColor,
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
