import 'package:flutter/material.dart';
import '../../../utils/speech_dictionary.dart';
import 'diary_mood_selector_row.dart';
import 'diary_title_input_field.dart';
import 'diary_editable_image_scroll_list.dart';
import 'diary_content_input_field.dart';

/// 직접 작성("쓰기") 모드의 입력 폼을 렌더링하는 전용 컴포넌트.
/// ChatScreen의 토글이 "쓰기" 탭일 때 노출되며, 입력값을 부모 상태로 보존합니다.
class DirectWriteView extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final int selectedMood;
  final ValueChanged<int> onMoodChanged;
  final List<String> imagePaths;
  final VoidCallback onAddImageTap;
  final ValueChanged<int> onRemoveImage;
  final bool isHonorific;

  const DirectWriteView({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.selectedMood,
    required this.onMoodChanged,
    required this.imagePaths,
    required this.onAddImageTap,
    required this.onRemoveImage,
    required this.isHonorific,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // 1. 공통 기분 선택 영역
          DiaryMoodSelectorRow(
            selectedMood: selectedMood,
            onMoodChanged: onMoodChanged,
          ),
          const SizedBox(height: 32),

          // 2. 공통 일기 제목 입력 필드
          DiaryTitleInputField(
            controller: titleController,
            hintText: SpeechDictionary.get(
              SpeechKey.placeholderDiaryTitle,
              isHonorific,
            ),
          ),
          const SizedBox(height: 24),

          // 3. 공통 일기 앨범 편집 리스트 (최대 5장 수평 스크롤)
          DiaryEditableImageScrollList(
            imagePaths: imagePaths,
            onAddImageTap: onAddImageTap,
            onRemoveImage: onRemoveImage,
          ),
          const SizedBox(height: 24),

          // 4. 공통 일기 본문 입력 필드
          DiaryContentInputField(
            controller: contentController,
            hintText: SpeechDictionary.get(
              SpeechKey.placeholderDiaryContent,
              isHonorific,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
