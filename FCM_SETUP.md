# FCM 푸시 알림 설정 가이드

## Android 설정

Android는 별도 설정 없이 `google-services.json`만 있으면 FCM이 동작합니다.

`android/app/google-services.json` 파일이 Firebase Console에서 다운로드한 최신 파일인지 확인하세요.

---

## iOS 설정 (APNs 인증 키 등록 필수)

iOS에서 FCM 푸시를 받으려면 Apple Developer 계정의 APNs 인증 키를 Firebase에 등록해야 합니다.

### 1단계: APNs 인증 키 발급

1. [Apple Developer Console](https://developer.apple.com/account) 접속
2. **Certificates, Identifiers & Profiles** > **Keys** 이동
3. **+** 버튼 클릭 → Key Name 입력 (예: `MajungFCMKey`)
4. **Apple Push Notifications service (APNs)** 체크
5. **Continue** > **Register** > **Download** 클릭
6. `.p8` 파일 저장 (한 번만 다운로드 가능)
7. Key ID 메모 (화면에 표시됨, 예: `ABCD1234EF`)

### 2단계: Team ID 확인

1. Apple Developer Console 우측 상단 계정 이름 클릭
2. **Membership** 탭에서 **Team ID** 확인 (예: `TEAMID12345`)

### 3단계: Firebase Console에 APNs 키 등록

1. [Firebase Console](https://console.firebase.google.com) > 프로젝트 `majung-ce508` 접속
2. **프로젝트 설정** (톱니바퀴) > **클라우드 메시징** 탭
3. **Apple 앱 구성** 섹션에서 iOS 앱 선택
4. **APNs 인증 키** > **업로드** 클릭
5. 1단계에서 다운로드한 `.p8` 파일 업로드
6. Key ID, Team ID 입력 후 **업로드** 완료

### 4단계: iOS 프로젝트 설정 확인

Xcode에서 아래 설정이 되어 있는지 확인:

1. `ios/Runner.xcworkspace` 실행
2. **Runner** 타겟 > **Signing & Capabilities** 탭
3. **+ Capability** > **Push Notifications** 추가
4. **Background Modes** 추가 후 **Remote notifications** 체크

### 5단계: `GoogleService-Info.plist` 배치

Firebase Console에서 다운로드한 `GoogleService-Info.plist`를 `ios/Runner/` 폴더에 배치하고 Xcode 프로젝트에 추가합니다.

---

## 웹 설정 (선택)

웹에서 FCM을 사용하려면 VAPID 키가 필요합니다. 현재 앱은 `kIsWeb` 체크로 웹에서 토큰 발급을 생략하고 있습니다. 웹 알림이 필요하다면:

1. Firebase Console > **프로젝트 설정** > **클라우드 메시징** > **웹 푸시 인증서** > **키 쌍 생성**
2. 생성된 VAPID 키를 `FcmService._syncToken()` 내 `getToken(vapidKey: '...')` 에 전달

---

## 동작 흐름 요약

| 이벤트 | Cloud Function | 알림 내용 |
|--------|---------------|----------|
| 일기 저장 완료 | `onDiaryCreated` | "마중이의 답장이 도착했어요" |
| 리포트 생성 | `onReportCreated` | "주간/월간 리포트가 도착했어요" |
| 매일 저녁 8시 (미작성자) | `dailyDiaryReminder` | 캘린더 일정 기반 맞춤 리마인드 |
