import { onCall, HttpsError } from "firebase-functions/v2/https";
import { GoogleGenerativeAI } from "@google/generative-ai";
import * as admin from "firebase-admin";

admin.initializeApp();

// Helper to get Gemini Client
function getGeminiClient(): GoogleGenerativeAI {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "GEMINI_API_KEY environment variable is not set."
    );
  }
  return new GoogleGenerativeAI(apiKey);
}

// System Instruction outlining the Mascot persona & core constraints (no emojis, style match, calendar check)
const SYSTEM_INSTRUCTION = `
당신은 감정 일기 도우미 캐릭터 '마중이'입니다. 당신은 사용자와 친근하고 따뜻하게 대화하며 공감해주고, 대화 내용을 요약해 일기로 만들고 하루의 피드백을 주며, 사용자 기분 전환에 도움이 될 만한 3가지 구체적인 활동(Recommended Actions)을 추천합니다.

대화 및 피드백 작성 시 아래 규칙을 반드시 준수하세요:
1. 어떠한 경우에도 이모티콘(예: 😊, 🌿, 🧺 등)을 절대 사용하지 마세요. 오직 정갈한 한국어 텍스트와 적절한 줄바꿈(\\n)만 사용하여 따뜻한 감정을 전달하세요.
2. 유저가 선택한 말투에 맞게 100% 존댓말(isHonorific이 true인 경우) 또는 100% 반말(isHonorific이 false인 경우)을 일관되게 사용하세요.
   - 존댓말 예시: "오늘 하루도 참 고생 많으셨어요. 힘든 일은 털어버리고 푹 쉬시길 바랄게요."
   - 반말 예시: "오늘 하루도 정말 고생 많았어. 힘든 일은 다 털어버리고 푹 쉬자."
3. 오늘 일정 목록(todayEvents)이 제공되고 비어있지 않다면, 대화 중이나 피드백 중에 해당 일정을 자연스럽게 언급하여 상황 맞춤 공감을 작성해 주세요. (예: "오늘 면접 있으셨던데 보시느라 많이 긴장되셨을 것 같아요." 또는 "오늘 PT 발표하느라 애썼어.")
`;

interface ChatMessage {
  sender: "user" | "mascot";
  content: string;
  imagePath?: string; // image is not directly processed by text gemini but is part of context
}

/**
 * 1. 실시간 대화 API (chatWithMascot)
 * 유저의 입력에 실시간으로 따뜻하게 응답하고, 필요시 행동 추천 목록을 동적으로 반환합니다.
 */
export const chatWithMascot = onCall({ maxInstances: 10 }, async (request) => {
  const { messages, userName, isHonorific, todayEvents } = request.data as {
    messages: ChatMessage[];
    userName: string;
    isHonorific: boolean;
    todayEvents: string[];
  };

  if (!messages || !Array.isArray(messages)) {
    throw new HttpsError("invalid-argument", "messages list is required.");
  }

  const genAI = getGeminiClient();
  const model = genAI.getGenerativeModel({
    model: "gemini-3.5-flash",
    generationConfig: {
      responseMimeType: "application/json",
    },
  });

  // Build the conversation transcript
  let conversationHistory = "";
  for (const msg of messages) {
    const senderName = msg.sender === "user" ? userName : "마중이";
    conversationHistory += `${senderName}: ${msg.content}\n`;
  }

  const prompt = `
${SYSTEM_INSTRUCTION}

[사용자 프로필 및 일정 컨텍스트]
- 사용자 이름: ${userName}
- 적용할 말투: ${isHonorific ? "존댓말" : "반말"}
- 오늘 기기 일정 목록: ${todayEvents && todayEvents.length > 0 ? todayEvents.join(", ") : "없음"}

[지금까지의 대화 기록]
${conversationHistory}

위 대화 기록을 바탕으로 사용자의 마지막 말에 마중이(대화 참여자)로서 공감하는 다음 한마디 대답(reply)을 생성해 주세요.
또한, 사용자와 충분한 대화(턴이 2~3회 이상 진행됨)가 이루어졌거나 대화가 잘 마무리되는 느낌이 드는 시점이라고 판단될 경우, 기분 전환을 위한 구체적이고 실천하기 쉬운 행동(활동) 3가지를 함께 추천할 시점인지 결정해 주세요.

출력은 반드시 아래 스키마를 만족하는 JSON 형태여야 합니다:
{
  "reply": "마중이로서의 다음 응답 대사 (줄바꿈 가능, 절대 이모티콘 사용 금지)",
  "shouldRecommendActions": boolean (추천 활동을 보여줄 타이밍인지 여부),
  "recommendedActions": ["행동1", "행동2", "행동3"] (shouldRecommendActions가 true일 때만 추천할 구체적 행동 3가지)
}
`;

  try {
    const result = await model.generateContent(prompt);
    const textResponse = result.response.text();
    const jsonResponse = JSON.parse(textResponse);
    return jsonResponse;
  } catch (error: any) {
    throw new HttpsError("internal", error.message || "Failed to generate AI response.");
  }
});

/**
 * 2. 일기 및 피드백 생성 API (generateDiaryAndFeedback)
 * 대화 마무리 시점에 감정, 일기 내용, 피드백을 한 번에 생성하거나, 직접 작성 시 피드백과 추천 행동을 생성합니다.
 */
export const generateDiaryAndFeedback = onCall({ maxInstances: 10 }, async (request) => {
  const {
    messages,
    userName,
    isHonorific,
    todayEvents,
    selectedActivity,
    isDirectWrite,
    directWriteData,
  } = request.data as {
    messages?: ChatMessage[];
    userName: string;
    isHonorific: boolean;
    todayEvents: string[];
    selectedActivity?: string;
    isDirectWrite: boolean;
    directWriteData?: { title: string; content: string; mood: number };
  };

  const genAI = getGeminiClient();
  const model = genAI.getGenerativeModel({
    model: "gemini-3.5-flash",
    generationConfig: {
      responseMimeType: "application/json",
    },
  });

  let prompt = "";

  if (isDirectWrite) {
    if (!directWriteData) {
      throw new HttpsError("invalid-argument", "directWriteData is required when isDirectWrite is true.");
    }
    prompt = `
${SYSTEM_INSTRUCTION}

[사용자 프로필 및 일정 컨텍스트]
- 사용자 이름: ${userName}
- 적용할 말투: ${isHonorific ? "존댓말" : "반말"}
- 오늘 기기 일정 목록: ${todayEvents && todayEvents.length > 0 ? todayEvents.join(", ") : "없음"}

[사용자가 직접 작성한 일기 데이터]
- 감정 단계: ${directWriteData.mood} (1: 아주 좋음 ~ 5: 아주 나쁨)
- 제목: ${directWriteData.title}
- 내용: ${directWriteData.content}

위 일기 내용(제목, 본문, 감정)을 면밀히 분석하여, 사용자의 감정에 공감하고 조언을 건네는 따뜻한 마중이의 답장(mascotFeedback)과 기분 전환에 도움이 될만한 3가지 추천 행동 목록(recommendedActions)을 생성해 주세요.

출력은 반드시 아래 스키마를 만족하는 JSON 형태여야 합니다 (기존 일기 데이터는 그대로 에코하여 포함시킵니다):
{
  "mood": ${directWriteData.mood},
  "title": "${directWriteData.title}",
  "content": "${directWriteData.content}",
  "mascotFeedback": "마중이가 사용자에게 건네는 따뜻한 위로와 피드백 문구 (줄바꿈 가능, 절대 이모티콘 사용 금지)",
  "recommendedActions": ["추천행동1", "추천행동2", "추천행동3"]
}
`;
  } else {
    if (!messages || !Array.isArray(messages)) {
      throw new HttpsError("invalid-argument", "messages list is required.");
    }
    // Build the conversation transcript
    let conversationHistory = "";
    for (const msg of messages) {
      const senderName = msg.sender === "user" ? userName : "마중이";
      conversationHistory += `${senderName}: ${msg.content}\n`;
    }

    prompt = `
${SYSTEM_INSTRUCTION}

[사용자 프로필 및 일정 컨텍스트]
- 사용자 이름: ${userName}
- 적용할 말투: ${isHonorific ? "존댓말" : "반말"}
- 오늘 기기 일정 목록: ${todayEvents && todayEvents.length > 0 ? todayEvents.join(", ") : "없음"}
- 사용자가 선택하여 실천하기로 한 추천 행동: ${selectedActivity || "없음"}

[나눈 대화 기록]
${conversationHistory}

위 대화 기록을 기반으로 아래 항목들을 생성해 주세요:
1. 사용자의 하루를 마중이 관점이 아닌, 사용자 1인칭 '나' 시점의 솔직하고 담백한 일기 본문(content)으로 재구성해 주세요. 대화에서 드러난 감정과 에피소드를 자연스러운 일기 형식으로 풀어써야 합니다.
2. 일기 본문에 잘 어울리는 감성적인 일기 제목(title)을 정해 주세요.
3. 대화 속 사용자의 감정 상태를 종합 진단하여 감정 단계(mood: 1~5 정수)를 결정해 주세요. (1: 아주 좋음 ~ 5: 아주 나쁨)
4. 마중이로서 대화를 마무리하며 사용자에게 건네는 따뜻한 답장 피드백(mascotFeedback)을 작성해 주세요. 만약 사용자가 실천하기로 선택한 행동(selectedActivity)이 있다면, 이에 대해 힘을 돋우는 응원의 한마디를 포함해 주세요.

출력은 반드시 아래 스키마를 만족하는 JSON 형태여야 합니다:
{
  "mood": number (1~5),
  "title": "일기 제목 string",
  "content": "일기 본문 string (1인칭 '나' 관점)",
  "mascotFeedback": "마중이가 사용자에게 건네는 따뜻한 피드백 문구 (줄바꿈 가능, 절대 이모티콘 사용 금지)",
  "recommendedActions": ["추천행동1", "추천행동2", "추천행동3"]
}
`;
  }

  try {
    const result = await model.generateContent(prompt);
    const textResponse = result.response.text();
    const jsonResponse = JSON.parse(textResponse);
    return jsonResponse;
  } catch (error: any) {
    throw new HttpsError("internal", error.message || "Failed to generate diary and feedback.");
  }
});
