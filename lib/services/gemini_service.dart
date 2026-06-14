import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../main.dart'; // isCloudFunctionsEnabled

// Ollama 로컬 LLM 엔드포인트 (qwen2.5:7b)
const _kOllamaEndpoint = 'http://localhost:11434/api/generate';
const _kOllamaModel = 'qwen2.5:7b';

const _kSystemInstruction = """
당신은 감정 일기 도우미 캐릭터 '마중이'입니다. 당신은 사용자와 친근하고 따뜻하게 대화하며 공감해주고, 대화 내용을 요약해 일기로 만들고 하루의 피드백을 주며, 사용자 기분 전환에 도움이 될 만한 3가지 구체적인 활동(Recommended Actions)을 추천합니다.

대화 및 피드백 작성 시 아래 규칙을 반드시 준수하세요:
1. 어떠한 경우에도 이모티콘(예: 😊, 🌿, 🧺 등)을 절대 사용하지 마세요. 오직 정갈한 한국어 텍스트와 적절한 줄바꿈(\\n)만 사용하여 따뜻한 감정을 전달하세요.
2. 유저가 선택한 말투에 맞게 100% 존댓말(isHonorific이 true인 경우) 또는 100% 반말(isHonorific이 false인 경우)을 일관되게 사용하세요.
   - 존댓말 예시: "오늘 하루도 참 고생 많으셨어요. 힘든 일은 털어버리고 푹 쉬시길 바랄게요."
   - 반말 예시: "오늘 하루도 정말 고생 많았어. 힘든 일은 다 털어버리고 푹 쉬자."
3. 오늘 일정 목록(todayEvents)이 제공되고 비어있지 않다면, 대화 중이나 피드백 중에 해당 일정을 자연스럽게 언급하여 상황 맞춤 공감을 작성해 주세요. (예: "오늘 면접 있으셨던데 보시느라 많이 긴장되셨을 것 같아요." 또는 "오늘 PT 발표하느라 애썼어.")
""";

class GeminiService {
  // --- Cloud Functions 경로 ---

  static Future<Map<String, dynamic>> chatWithMascot({
    required List<Map<String, dynamic>> messages,
    required String userName,
    required bool isHonorific,
    required List<String> todayEvents,
  }) async {
    if (isCloudFunctionsEnabled) {
      final result = await FirebaseFunctions.instance
          .httpsCallable('chatWithMascot')
          .call({
        'messages': messages,
        'userName': userName,
        'isHonorific': isHonorific,
        'todayEvents': todayEvents,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } else {
      return _fallbackChatWithMascot(
        messages: messages,
        userName: userName,
        isHonorific: isHonorific,
        todayEvents: todayEvents,
      );
    }
  }

  static Future<Map<String, dynamic>> generateDiaryAndFeedback({
    required String userName,
    required bool isHonorific,
    required List<String> todayEvents,
    required bool isDirectWrite,
    List<Map<String, dynamic>> messages = const [],
    String? selectedActivity,
    Map<String, dynamic>? directWriteData,
  }) async {
    if (isCloudFunctionsEnabled) {
      final result = await FirebaseFunctions.instance
          .httpsCallable('generateDiaryAndFeedback')
          .call({
        'userName': userName,
        'isHonorific': isHonorific,
        'todayEvents': todayEvents,
        'isDirectWrite': isDirectWrite,
        'messages': messages,
        'selectedActivity': selectedActivity,
        'directWriteData': directWriteData,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } else {
      return _fallbackGenerateDiaryAndFeedback(
        userName: userName,
        isHonorific: isHonorific,
        todayEvents: todayEvents,
        isDirectWrite: isDirectWrite,
        messages: messages,
        selectedActivity: selectedActivity,
        directWriteData: directWriteData,
      );
    }
  }

  // --- 로컬 Ollama LLM 폴백 ---

  static Future<Map<String, dynamic>> _callOllama(String prompt) async {
    final uri = Uri.parse(_kOllamaEndpoint);
    final fullPrompt = '$_kSystemInstruction\n\n$prompt';
    final body = jsonEncode({
      'model': _kOllamaModel,
      'prompt': fullPrompt,
      'stream': false,
      'format': 'json',
    });

    debugPrint('Ollama: 요청 시작 (model: $_kOllamaModel)');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      throw Exception('Ollama API 오류 (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = decoded['response'] as String;
    debugPrint('Ollama: 응답 수신 완료');
    return jsonDecode(text) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _fallbackChatWithMascot({
    required List<Map<String, dynamic>> messages,
    required String userName,
    required bool isHonorific,
    required List<String> todayEvents,
  }) async {
    final conversationHistory = messages.map((m) {
      final sender = m['sender'] == 'user' ? userName : '마중이';
      return '$sender: ${m['content']}';
    }).join('\n');

    final styleLine = isHonorific
        ? '반드시 존댓말(~요, ~습니다, ~세요)만 사용하세요. 반말 절대 금지.'
        : '반드시 반말(~야, ~어, ~잖아, ~자)만 사용하세요. 존댓말 절대 금지.';

    final prompt = """
[말투 규칙 - 최우선 적용]
$styleLine

[사용자 프로필 및 일정 컨텍스트]
- 사용자 이름: $userName
- 적용할 말투: ${isHonorific ? '존댓말 (예: "힘드셨겠어요", "잘 하셨어요")' : '반말 (예: "힘들었겠다", "잘 했어")'}
- 오늘 기기 일정 목록: ${todayEvents.isNotEmpty ? todayEvents.join(', ') : '없음'}

[지금까지의 대화 기록]
$conversationHistory

위 대화 기록을 바탕으로 사용자의 마지막 말에 마중이(대화 참여자)로서 공감하는 다음 한마디 대답(reply)을 생성해 주세요.
또한, 사용자와 충분한 대화(턴이 2~3회 이상 진행됨)가 이루어졌거나 대화가 잘 마무리되는 느낌이 드는 시점이라고 판단될 경우, 기분 전환을 위한 구체적이고 실천하기 쉬운 행동(활동) 3가지를 함께 추천할 시점인지 결정해 주세요.

출력은 반드시 아래 스키마를 만족하는 JSON 형태여야 합니다:
{
  "reply": "마중이로서의 다음 응답 대사 (줄바꿈 가능, 절대 이모티콘 사용 금지, 말투 규칙 준수)",
  "shouldRecommendActions": true 또는 false,
  "recommendedActions": ["행동1", "행동2", "행동3"]
}""";

    return _callOllama(prompt);
  }

  static Future<Map<String, dynamic>> _fallbackGenerateDiaryAndFeedback({
    required String userName,
    required bool isHonorific,
    required List<String> todayEvents,
    required bool isDirectWrite,
    List<Map<String, dynamic>> messages = const [],
    String? selectedActivity,
    Map<String, dynamic>? directWriteData,
  }) async {
    final String prompt;

    final styleLine = isHonorific
        ? '반드시 존댓말(~요, ~습니다, ~세요)만 사용하세요. 반말 절대 금지.'
        : '반드시 반말(~야, ~어, ~잖아, ~자)만 사용하세요. 존댓말 절대 금지.';

    if (isDirectWrite) {
      final data = directWriteData!;
      prompt = """
[말투 규칙 - 최우선 적용]
$styleLine

[사용자 프로필 및 일정 컨텍스트]
- 사용자 이름: $userName
- 적용할 말투: ${isHonorific ? '존댓말 (예: "힘드셨겠어요", "잘 하셨어요")' : '반말 (예: "힘들었겠다", "잘 했어")'}
- 오늘 기기 일정 목록: ${todayEvents.isNotEmpty ? todayEvents.join(', ') : '없음'}

[사용자가 직접 작성한 일기 데이터]
- 감정 단계: ${data['mood']} (1: 아주 좋음 ~ 5: 아주 나쁨)
- 제목: ${data['title']}
- 내용: ${data['content']}

위 일기 내용을 면밀히 분석하여, 사용자의 감정에 공감하고 조언을 건네는 따뜻한 마중이의 답장(mascotFeedback)과 기분 전환에 도움이 될만한 3가지 추천 행동 목록(recommendedActions)을 생성해 주세요.

출력은 반드시 아래 스키마를 만족하는 JSON 형태여야 합니다:
{
  "mood": ${data['mood']},
  "title": "${data['title']}",
  "content": "${data['content']}",
  "mascotFeedback": "마중이가 사용자에게 건네는 따뜻한 위로와 피드백 문구 (줄바꿈 가능, 절대 이모티콘 사용 금지)",
  "recommendedActions": ["추천행동1", "추천행동2", "추천행동3"]
}""";
    } else {
      final conversationHistory = messages.map((m) {
        final sender = m['sender'] == 'user' ? userName : '마중이';
        return '$sender: ${m['content']}';
      }).join('\n');

      prompt = """
[말투 규칙 - 최우선 적용]
$styleLine

[사용자 프로필 및 일정 컨텍스트]
- 사용자 이름: $userName
- 적용할 말투: ${isHonorific ? '존댓말 (예: "힘드셨겠어요", "잘 하셨어요")' : '반말 (예: "힘들었겠다", "잘 했어")'}
- 오늘 기기 일정 목록: ${todayEvents.isNotEmpty ? todayEvents.join(', ') : '없음'}
- 사용자가 선택하여 실천하기로 한 추천 행동: ${selectedActivity ?? '없음'}

[나눈 대화 기록]
$conversationHistory

위 대화 기록을 기반으로 아래 항목들을 생성해 주세요:
1. 사용자의 하루를 마중이 관점이 아닌, 사용자 1인칭 '나' 시점의 솔직하고 담백한 일기 본문(content)으로 재구성해 주세요.
2. 일기 본문에 잘 어울리는 감성적인 일기 제목(title)을 정해 주세요.
3. 대화 속 사용자의 감정 상태를 종합 진단하여 감정 단계(mood: 1~5 정수)를 결정해 주세요.
   - mood 기준: 1=아주 좋음(매우 행복/설렘), 2=좋음(긍정적), 3=보통(무난/중립), 4=나쁨(우울/지침), 5=아주 나쁨(매우 힘듦/슬픔)
   - 대화 내용을 바탕으로 실제 감정에 맞는 값을 선택하세요. 3으로 고정하지 마세요.
4. 마중이로서 대화를 마무리하며 사용자에게 건네는 따뜻한 답장 피드백(mascotFeedback)을 작성해 주세요. 사용자가 선택한 행동(selectedActivity)이 있다면 이에 대한 응원을 포함해 주세요.

출력은 반드시 아래 스키마를 만족하는 JSON 형태여야 합니다:
{
  "mood": 대화 감정 분석 결과 정수 (1~5 중 실제 감정에 맞는 값),
  "title": "일기 제목 string",
  "content": "일기 본문 string (1인칭 '나' 관점)",
  "mascotFeedback": "마중이가 사용자에게 건네는 따뜻한 피드백 문구 (줄바꿈 가능, 절대 이모티콘 사용 금지, 말투 규칙 준수)",
  "recommendedActions": ["추천행동1", "추천행동2", "추천행동3"]
}""";
    }

    return _callOllama(prompt);
  }
}
