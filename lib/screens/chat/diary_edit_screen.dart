import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../providers/diary_provider.dart';
import '../../models/diary_data.dart';
import '../../main.dart'; // selectedStyleProvider
import '../../utils/speech_dictionary.dart';
import 'widgets/image_source_sheet.dart';
import 'widgets/diary_mood_selector_row.dart';
import 'widgets/diary_title_input_field.dart';
import 'widgets/diary_editable_image_scroll_list.dart';
import 'widgets/diary_content_input_field.dart';
import '../../utils/datetime_extension.dart';
import '../../utils/form_validation_helper.dart';
import '../../widgets/confirm_dialog.dart';

/// 일기 편집 및 작성 전용 화면.
/// 기분 5단계 선택, 포커스 시에만 나타나는 타이틀 밑줄, 테두리 없는 본문 입력창,
/// 그리고 사진 추가(ImagePicker) 및 개별 삭제(마이너스 오버레이)를 지원합니다.
class DiaryEditScreen extends ConsumerStatefulWidget {
  final DiaryData? initialDiary;

  const DiaryEditScreen({super.key, this.initialDiary});

  @override
  ConsumerState<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends ConsumerState<DiaryEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedMood;
  late List<String> _imagePaths;
  final ImagePicker _picker = ImagePicker();

  late final FormValidationHelper _formHelper;

  @override
  void initState() {
    super.initState();

    if (widget.initialDiary != null) {
      _titleController = TextEditingController(
        text: widget.initialDiary!.title,
      );
      _contentController = TextEditingController(
        text: widget.initialDiary!.content,
      );
      _selectedMood = widget.initialDiary!.mood;
      _imagePaths = List<String>.from(widget.initialDiary!.imagePaths);
    } else {
      // 신규 직접 작성(Direct Write) 연계 대처용 기본 초기값
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _selectedMood = 3; // 기본 보통 기분
      _imagePaths = [];
    }

    _formHelper = FormValidationHelper(
      controllers: [_titleController, _contentController],
      onChanged: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _formHelper.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isButtonEnabled => _formHelper.isValid;

  /// 이미지 첨부 경로 선택 바텀 시트 호출
  void _showImagePickerSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ImageSourceSheet(
          onSourceSelected: (source) {
            Navigator.pop(context);
            _pickImage(source);
          },
        );
      },
    );
  }

  /// 이미지 소스로부터 사진 가져오기
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePaths.add(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: '이미지를 가져오는 중 오류가 발생했습니다: $e',
            cancelLabel: '', // 1버튼 모드로 작동
            onConfirm: () {},
          ),
        );
      }
    }
  }

  /// 수정사항 저장 및 pop 처리
  void _saveDiaryEdit() {
    final newTitle = _titleController.text.trim();
    final newContent = _contentController.text.trim();

    final newDiary = DiaryData(
      date: widget.initialDiary?.date ?? DateTime.now().toDotString(),
      title: newTitle,
      content: newContent,
      mood: _selectedMood,
      imagePaths: _imagePaths,
      mascotFeedback:
          widget.initialDiary?.mascotFeedback ?? '스스로 직접 작성하신 소중한 일기입니다.',
      recommendedAction:
          widget.initialDiary?.recommendedAction ?? '',
      isDirectWrite: widget.initialDiary?.isDirectWrite ?? false,
    );

    if (widget.initialDiary != null) {
      ref
          .read(diaryProvider.notifier)
          .updateDiary(
            title: newTitle,
            content: newContent,
            mood: _selectedMood,
            imagePaths: _imagePaths,
          );
    } else {
      ref.read(diaryProvider.notifier).saveNewDiary(newDiary);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isHonorific = ref.watch(selectedStyleProvider) == 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grayScale9),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${(widget.initialDiary?.date ?? DateTime.now().toDotString()).toMMDD()}(수정 중)',
          style: AppTextStyle.body2B,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.checkCircle,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _isButtonEnabled ? AppColors.mainColor : AppColors.gray3,
                BlendMode.srcIn,
              ),
            ),
            onPressed: _isButtonEnabled ? _saveDiaryEdit : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 1. 공통 기분 선택 영역
              DiaryMoodSelectorRow(
                selectedMood: _selectedMood,
                onMoodChanged: (mood) {
                  setState(() {
                    _selectedMood = mood;
                  });
                },
              ),
              const SizedBox(height: 32),

              // 2. 공통 일기 제목 입력 필드
              DiaryTitleInputField(
                controller: _titleController,
                hintText: SpeechDictionary.get(
                  SpeechKey.placeholderDiaryTitle,
                  isHonorific,
                ),
              ),
              const SizedBox(height: 24),

              // 3. 공통 일기 앨범 편집 리스트 (수정 중에는 항시 편집 슬롯 노출)
              DiaryEditableImageScrollList(
                imagePaths: _imagePaths,
                onAddImageTap: _showImagePickerSourceSheet,
                onRemoveImage: (index) {
                  setState(() {
                    _imagePaths.removeAt(index);
                  });
                },
              ),
              const SizedBox(height: 24),

              // 4. 공통 일기 본문 입력 필드
              DiaryContentInputField(
                controller: _contentController,
                hintText: SpeechDictionary.get(
                  SpeechKey.placeholderDiaryContent,
                  isHonorific,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
