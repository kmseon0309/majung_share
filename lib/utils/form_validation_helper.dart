import 'package:flutter/material.dart';

/// 여러 TextEditingController의 실시간 입력 값 여부를 일괄로 감지하여
/// 활성화 조건(isValid)을 제공해 주는 공통 폼 유효성 헬퍼 클래스.
class FormValidationHelper {
  final List<TextEditingController> controllers;
  final VoidCallback onChanged;

  FormValidationHelper({
    required this.controllers,
    required this.onChanged,
  }) {
    for (final controller in controllers) {
      controller.addListener(onChanged);
    }
  }

  /// 모든 컨트롤러가 비어있지 않은지 검사합니다.
  bool get isValid => controllers.every((c) => c.text.trim().isNotEmpty);

  /// 리스너를 제거하고 객체를 정리합니다.
  void dispose() {
    for (final controller in controllers) {
      controller.removeListener(onChanged);
    }
  }
}
