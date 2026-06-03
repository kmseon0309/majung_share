import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 사용자 이름 상태를 관리하는 Riverpod Notifier 및 Provider.
class UserNameNotifier extends Notifier<String> {
  @override
  String build() => '00이'; // 피그마 온보딩 기본 예시 이름

  void updateName(String name) {
    if (name.trim().isNotEmpty) {
      state = name.trim();
    }
  }
}

final userNameProvider = NotifierProvider<UserNameNotifier, String>(UserNameNotifier.new);
