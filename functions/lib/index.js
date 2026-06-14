"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.dailyDiaryReminder = exports.onDiaryCreated = exports.onReportCreated = exports.generateDiaryAndFeedback = exports.chatWithMascot = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const params_1 = require("firebase-functions/params");
const genai_1 = require("@google/genai");
const admin = __importStar(require("firebase-admin"));
const geminiApiKey = (0, params_1.defineSecret)("GEMINI_API_KEY");
admin.initializeApp();
// Helper to get Gemini Client
function getGeminiClient() {
    const apiKey = process.env.GEMINI_API_KEY;
    console.log("GEMINI_API_KEY present:", !!apiKey, "prefix:", apiKey?.substring(0, 5));
    // SDK가 환경변수(GEMINI_API_KEY)를 자동으로 읽음
    return new genai_1.GoogleGenAI({});
}
// System Instruction outlining the Mascot persona & core constraints (no emojis, style match, calendar check)
const SYSTEM_INSTRUCTION = `
당신은 감정 일기 도우미 캐릭터 '마중이'입니다. 당신은 사용자와 친근하고 따뜻하게 대화하며 공감해주고, 대화 내용을 요약해 일기로 만들고 하루의 피드백을 주며, 사용자 기분 전환에 도움이 될 만한 3가지 구체적인 활동(Recommended Actions)을 추천합니다.

대화 및 피드백 작성 시 아래 규칙을 반드시 준수하세요:
1. 어떠한 경우에도 이모티콘(예: 😊, 🌿, 🧺 등)을 절대 사용하지 마세요. 오직 정갈한 한국어 텍스트와 적절한 줄바꿈(\\n)만 사용하여 따뜻한 감정을 전달하세요.
2. 유저가 선택한 말투에 맞게 100% 존댓말(isHonorific이 true인 경우) 또는 100% 반말(isHonorific이 false인 경우)을 일관되게 사용하세요.
   - 존댓말(isHonorific=true): 문장 끝을 반드시 ~요, ~습니다, ~세요, ~겠어요 등으로 끝내세요. ~야, ~어, ~잖아, ~자 등 반말 어미 절대 사용 금지.
   - 반말(isHonorific=false): 문장 끝을 반드시 ~야, ~어, ~잖아, ~자, ~네, ~거야 등으로 끝내세요. ~요, ~습니다, ~세요 등 존댓말 어미 절대 사용 금지.
   - 존댓말 예시: "오늘 하루도 참 고생 많으셨어요. 힘든 일은 털어버리고 푹 쉬시길 바랄게요."
   - 반말 예시: "오늘 하루도 정말 고생 많았어. 힘든 일은 다 털어버리고 푹 쉬자."
3. 오늘 일정 목록(todayEvents)이 제공되고 비어있지 않다면, 대화 중이나 피드백 중에 해당 일정을 자연스럽게 언급하여 상황 맞춤 공감을 작성해 주세요. (예: "오늘 면접 있으셨던데 보시느라 많이 긴장되셨을 것 같아요." 또는 "오늘 PT 발표하느라 애썼어.")
`;
/**
 * 1. 실시간 대화 API (chatWithMascot)
 * 유저의 입력에 실시간으로 따뜻하게 응답하고, 필요시 행동 추천 목록을 동적으로 반환합니다.
 */
exports.chatWithMascot = (0, https_1.onCall)({ maxInstances: 10, secrets: [geminiApiKey] }, async (request) => {
    const { messages, userName, isHonorific, todayEvents } = request.data;
    if (!messages || !Array.isArray(messages)) {
        throw new https_1.HttpsError("invalid-argument", "messages list is required.");
    }
    const ai = getGeminiClient();
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
        console.log("Calling Gemini API with model: gemini-2.0-flash");
        const response = await ai.models.generateContent({
            model: "gemini-3.1-flash-lite",
            contents: prompt,
            config: { responseMimeType: "application/json" },
        });
        console.log("Gemini response text:", response.text?.substring(0, 100));
        const jsonResponse = JSON.parse(response.text ?? "");
        return jsonResponse;
    }
    catch (error) {
        console.error("chatWithMascot Gemini error:", JSON.stringify(error), error.message);
        throw new https_1.HttpsError("internal", error.message || "Failed to generate AI response.");
    }
});
/**
 * 2. 일기 및 피드백 생성 API (generateDiaryAndFeedback)
 * 대화 마무리 시점에 감정, 일기 내용, 피드백을 한 번에 생성하거나, 직접 작성 시 피드백과 추천 행동을 생성합니다.
 */
exports.generateDiaryAndFeedback = (0, https_1.onCall)({ maxInstances: 10, secrets: [geminiApiKey] }, async (request) => {
    const { messages, userName, isHonorific, todayEvents, selectedActivity, isDirectWrite, directWriteData, } = request.data;
    const ai = getGeminiClient();
    let prompt = "";
    if (isDirectWrite) {
        if (!directWriteData) {
            throw new https_1.HttpsError("invalid-argument", "directWriteData is required when isDirectWrite is true.");
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
    }
    else {
        if (!messages || !Array.isArray(messages)) {
            throw new https_1.HttpsError("invalid-argument", "messages list is required.");
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
3. 대화 속 사용자의 감정 상태를 종합 진단하여 감정 단계(mood: 1~5 정수)를 결정해 주세요.
   - mood 기준: 1=아주 좋음(매우 행복/설렘), 2=좋음(긍정적), 3=보통(무난/중립), 4=나쁨(우울/지침/힘듦), 5=아주 나쁨(매우 힘듦/슬픔/절망)
   - 반드시 대화 내용을 기반으로 실제 감정에 맞는 값을 판단하세요. 기본값 3으로 처리하지 마세요.
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
        const response = await ai.models.generateContent({
            model: "gemini-3.1-flash-lite",
            contents: prompt,
            config: { responseMimeType: "application/json" },
        });
        const jsonResponse = JSON.parse(response.text ?? "");
        return jsonResponse;
    }
    catch (error) {
        throw new https_1.HttpsError("internal", error.message || "Failed to generate diary and feedback.");
    }
});
/**
 * 3. Firestore 트리거: 새 리포트 생성 시 FCM 푸시 알림 발송
 * 경로: users/{uid}/reports/{reportId}
 */
exports.onReportCreated = (0, firestore_1.onDocumentCreated)("users/{uid}/reports/{reportId}", async (event) => {
    const uid = event.params.uid;
    const data = event.data?.data();
    if (!data)
        return;
    const userDoc = await admin.firestore().collection("users").doc(uid).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken)
        return;
    const isWeekly = data.isWeekly;
    const reportTitle = data.title || "";
    const notifTitle = isWeekly ? "주간 리포트가 도착했어요" : "월간 리포트가 도착했어요";
    try {
        await admin.messaging().send({
            token: fcmToken,
            notification: { title: notifTitle, body: reportTitle },
            data: {
                type: isWeekly ? "weekly_report" : "monthly_report",
                reportId: event.params.reportId,
            },
        });
    }
    catch (e) {
        console.error("FCM 리포트 알림 발송 실패:", e);
        return;
    }
    const notifId = Date.now().toString();
    const today = new Date().toISOString().split("T")[0];
    await admin.firestore()
        .collection("users").doc(uid)
        .collection("notifications").doc(notifId)
        .set({ id: notifId, title: notifTitle, date: today, isUnread: true });
});
/**
 * 4. Firestore 트리거: 새 일기 생성 시 마중이 답장 FCM 푸시 알림 발송
 * 경로: users/{uid}/diaries/{diaryId}
 */
exports.onDiaryCreated = (0, firestore_1.onDocumentCreated)("users/{uid}/diaries/{diaryId}", async (event) => {
    const uid = event.params.uid;
    const data = event.data?.data();
    if (!data)
        return;
    // 마중이 피드백이 없는 문서는 알림 생략 (직접 작성 대기 상태 등)
    const mascotFeedback = data.mascotFeedback || "";
    if (!mascotFeedback)
        return;
    // 사용자 FCM 토큰 조회
    const userDoc = await admin.firestore().collection("users").doc(uid).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken)
        return;
    const title = data.title || "오늘의 일기";
    const notificationBody = mascotFeedback.length > 80
        ? mascotFeedback.substring(0, 80) + "..."
        : mascotFeedback;
    // FCM 발송
    try {
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: "마중이의 답장이 도착했어요",
                body: notificationBody,
            },
            data: {
                type: "diary_feedback",
                diaryId: event.params.diaryId,
            },
        });
    }
    catch (e) {
        console.error("FCM 발송 실패:", e);
        return;
    }
    // Firestore 알림 컬렉션에도 저장 (인앱 알림 목록 표시용)
    const notifId = Date.now().toString();
    const today = new Date().toISOString().split("T")[0];
    await admin.firestore()
        .collection("users").doc(uid)
        .collection("notifications").doc(notifId)
        .set({
        id: notifId,
        title: `[마중이 답장] ${title}`,
        date: today,
        isUnread: true,
    });
});
/**
 * 4. 스케줄 함수: 매일 저녁 8시 (KST) 일기 미작성 사용자에게 리마인드 알림
 * UTC 기준: 11:00 = KST 20:00
 */
exports.dailyDiaryReminder = (0, scheduler_1.onSchedule)({ schedule: "0 11 * * *", timeZone: "Asia/Seoul" }, async () => {
    const now = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    const today = `${now.getFullYear()}.${pad(now.getMonth() + 1)}.${pad(now.getDate())}`; // YYYY.MM.DD (Firestore date 필드 포맷과 일치)
    // 알림 활성화 사용자 목록 조회
    const usersSnapshot = await admin.firestore()
        .collection("users")
        .where("notificationEnabled", "==", true)
        .get();
    const promises = usersSnapshot.docs.map(async (userDoc) => {
        const uid = userDoc.id;
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;
        const userName = userData.name || "사용자";
        if (!fcmToken)
            return;
        // 오늘 일기 작성 여부 확인
        const diarySnapshot = await admin.firestore()
            .collection("users").doc(uid)
            .collection("diaries")
            .where("date", ">=", today)
            .where("date", "<=", today + "￿")
            .get();
        if (!diarySnapshot.empty)
            return; // 이미 일기 작성함
        // 오늘 캘린더 일정 조회 (클라이언트가 앱 시작 시 동기화한 데이터)
        const todayEvents = userData.todayEvents;
        const todayEventsDate = userData.todayEventsDate;
        const hasEvents = Array.isArray(todayEvents) && todayEvents.length > 0 && todayEventsDate === today;
        const notifBody = hasEvents
            ? `오늘 ${todayEvents[0]} 일정이 있으셨네요. 마중이에게 오늘 이야기를 들려주세요.`
            : "마중이가 기다리고 있어요. 오늘의 이야기를 들려주세요.";
        // 리마인드 알림 발송
        try {
            await admin.messaging().send({
                token: fcmToken,
                notification: {
                    title: `${userName}님, 오늘 하루는 어땠나요?`,
                    body: notifBody,
                },
                data: { type: "daily_reminder" },
            });
        }
        catch (e) {
            console.error(`FCM 리마인드 발송 실패 (uid: ${uid}):`, e);
        }
    });
    await Promise.allSettled(promises);
    console.log(`dailyDiaryReminder: ${usersSnapshot.size}명 처리 완료`);
});
//# sourceMappingURL=index.js.map