import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../providers/direct_write_provider.dart';
import '../../../utils/speech_dictionary.dart';
import '../../../utils/form_validation_helper.dart';
import 'diary_mood_selector_row.dart';
import 'diary_title_input_field.dart';
import 'diary_editable_image_scroll_list.dart';
import 'diary_content_input_field.dart';
import 'image_source_sheet.dart';

/// 직접 작성("쓰기") 모드의 입력 폼을 렌더링하고 상태를 격리 관리하는 전용 컴포넌트.
/// ConsumerStatefulWidget으로 구현하여 로컬 컨트롤러 및 이미지 피커 연동 비즈니스 로직을 자체 캡슐화합니다.
class DirectWriteView extends ConsumerStatefulWidget {
  final bool isHonorific;

  const DirectWriteView({
    super.key,
    required this.isHonorific,
  });

  @override
  ConsumerState<DirectWriteView> createState() => _DirectWriteViewState();
}

class _DirectWriteViewState extends ConsumerState<DirectWriteView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FormValidationHelper _formHelper;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(directWriteProvider);
    _titleController = TextEditingController(text: initialState.title);
    _contentController = TextEditingController(text: initialState.content);

    // FormValidationHelper 연동을 통한 실시간 상태 싱크 및 캡슐화
    _formHelper = FormValidationHelper(
      controllers: [_titleController, _contentController],
      onChanged: () {
        ref.read(directWriteProvider.notifier).updateTitle(_titleController.text);
        ref.read(directWriteProvider.notifier).updateContent(_contentController.text);
      },
    );
  }

  @override
  void dispose() {
    _formHelper.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 이미지 첨부 경로 선택 바텀 시트 호출
  void _showImagePickerSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ImageSourceSheet(
          onSourceSelected: (source) {
            Navigator.pop(context);
            _pickDirectWriteImage(source);
          },
        );
      },
    );
  }

  /// 이미지 소스로부터 사진 가져와 상태 공급자에 적재
  Future<void> _pickDirectWriteImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        ref.read(directWriteProvider.notifier).addImage(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: '이미지를 가져오는 중 오류가 발생했습니다: $e',
            cancelLabel: '', // 1버튼 알럿으로 공통화
            onConfirm: () {},
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(directWriteProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // 1. 공통 기분 선택 영역
          DiaryMoodSelectorRow(
            selectedMood: state.mood,
            onMoodChanged: (mood) {
              ref.read(directWriteProvider.notifier).updateMood(mood);
            },
          ),
          const SizedBox(height: 32),

          // 2. 공통 일기 제목 입력 필드
          DiaryTitleInputField(
            controller: _titleController,
            hintText: SpeechDictionary.get(
              SpeechKey.placeholderDiaryTitle,
              widget.isHonorific,
            ),
          ),
          const SizedBox(height: 24),

          // 3. 공통 일기 앨범 편집 리스트 (최대 5장 수평 스크롤)
          DiaryEditableImageScrollList(
            imagePaths: state.imagePaths,
            onAddImageTap: _showImagePickerSourceSheet,
            onRemoveImage: (index) {
              ref.read(directWriteProvider.notifier).removeImage(index);
            },
          ),
          const SizedBox(height: 24),

          // 4. 공통 일기 본문 입력 필드
          DiaryContentInputField(
            controller: _contentController,
            hintText: SpeechDictionary.get(
              SpeechKey.placeholderDiaryContent,
              widget.isHonorific,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
