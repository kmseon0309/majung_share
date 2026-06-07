import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

/// 사용자 이름 상태를 관리하는 Riverpod Notifier 및 Provider.
class UserNameNotifier extends Notifier<String> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  @override
  String build() {
    _init();
    return '00이'; // 피그마 온보딩 기본 예시 이름
  }

  Future<void> _init() async {
    final settings = await _repo.getUserSettings();
    if (settings != null && settings['name'] != null) {
      state = settings['name'] as String;
    }
  }

  Future<void> updateName(String name) async {
    final cleanName = name.trim();
    if (cleanName.isNotEmpty) {
      state = cleanName;
      await _repo.saveUserSettings(name: cleanName);
    }
  }
}

final userNameProvider = NotifierProvider<UserNameNotifier, String>(UserNameNotifier.new);
