# Building Reliable AI Features in Flutter – Video 2 Companion Repo

> **Free resource from [Tech With Sam](https://techwithsam.dev)** — companion repository for Video 2 of the *AI Engineering for Flutter Developers* YouTube series.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Google AI](https://img.shields.io/badge/Google%20AI-googleai__dart-4285F4?logo=google)](https://pub.dev/packages/googleai_dart)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![YouTube Series Playlist](https://img.shields.io/badge/YouTube-Series_Playlist-FF0000?logo=youtube)](https://www.youtube.com/playlist?list=PLE9YRxI_vdvE)

---

## 📦 What's in This Branch (`video-2`)

This branch contains the full source code for **Video 2: Building Reliable AI Features in Flutter – Structured Output, Streaming & Error Handling**.

| Folder / File | Contents |
|---------------|----------|
| `lib/part_two_app.dart` | Video 2 studio application (`Video2ProductionApp` & `Video2StudioScreen`) with 3 interactive demo tabs |
| `lib/models/article_blueprint.dart` | Strongly-typed Dart model for JSON Mode structured output deserialization |
| `lib/models/ai_exceptions.dart` | Custom exception taxonomy (`NetworkAIException`, `RateLimitAIException`, `SchemaParsingAIException`, `SafetyRefusalAIException`) |
| `lib/services/resilient_ai_service.dart` | Core AI service utilizing `googleai_dart` for JSON mode, token streaming, & fault injection |
| `lib/services/retry_helper.dart` | Exponential backoff retry utility (`retryWithBackoff`) with customizable delays |
| `lib/widgets/structured_blueprint_card.dart` | Formatted presentation card for deserialized JSON schema outputs |
| `lib/widgets/streaming_output_widget.dart` | Real-time typewriter output widget with live metrics and stream cancellation button |
| `lib/widgets/error_resilience_banner.dart` | Categorized error alert banner with actionable recovery steps |
| `lib/theme/app_theme.dart` | High-contrast light & dark theme definitions |
| `lib/main.dart` | Root app entry point running `Video2ProductionApp` |

---

## 🚀 Quick Setup

```bash
# 1. Clone the repo and checkout the video-2 branch
git clone https://github.com/techwithsam/ai_engineer_for_flutter_devs.git
cd ai_engineer_for_flutter_devs
git checkout video-2

# 2. Get dependencies
flutter pub get

# 3. Run the application
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

**Requirements:** Flutter 3.x (stable channel), Dart 3.x, and a Gemini API Key (can also be entered dynamically in-app via the top-right key icon).

---

## 🛡️ The 3 Pillars of Reliable AI Features

### Pillar 1: Structured Output (Guaranteed JSON Schemas)
Moving beyond free-text outputs. Using `googleai_dart` with `responseMimeType: 'application/json'` guarantees Gemini returns JSON matching a Dart schema (`ArticleBlueprint`), avoiding UI crashes caused by unexpected text formatting.

### Pillar 2: Real-Time Token Streaming & Cancellation
Eliminating loading spinners for long generations. Streaming token chunks live to the UI (`streamTextContent`) while providing users with an explicit `StreamSubscription.cancel()` button to stop background tasks and conserve network bandwidth.

### Pillar 3: Error Resilience & Exponential Backoff
Handling real-world API failures gracefully. Differentiating transient errors (like HTTP `429` Rate Limit or network drops) from permanent errors (like invalid API keys), and automatically retrying with exponential backoff (`delay = initial * 2^(attempt - 1)`).

---

## 🧩 Reusable Code Snippets (Quick Reference)

### 1. Structured Output (JSON Mode)

```dart
// Enforce JSON output format using googleai_dart
final request = GenerateContentRequest(
  contents: [Content.text(prompt)],
  systemInstruction: Content.text(systemPrompt),
  generationConfig: const GenerationConfig(
    responseMimeType: 'application/json',
    temperature: 0.2,
  ),
);

final response = await client.models.generateContent(
  model: 'gemini-3.1-flash-lite',
  request: request,
);

final jsonMap = jsonDecode(response.text!) as Map<String, dynamic>;
return ArticleBlueprint.fromJson(jsonMap);
```

### 2. Real-Time Streaming with Cancellation

```dart
StreamSubscription<String>? _streamSubscription;

// Subscribe to live streamed token chunks
_streamSubscription = resilientService.streamTextContent(prompt).listen(
  (token) => setState(() => buffer += token),
  onError: (err) => handleStreamError(err),
  onDone: () => finalizeStream(),
);

// User taps "Cancel Stream"
void cancelStream() {
  _streamSubscription?.cancel(); // ← Cleanly stop stream & free network resources
}
```

### 3. Exponential Backoff Retry Strategy

```dart
Future<T> retryWithBackoff<T>({
  required Future<T> Function() action,
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
  void Function(int attempt, Duration delay, Object error)? onRetry,
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await action();
    } catch (e) {
      attempt++;
      if (attempt > maxRetries || !isTransientError(e)) rethrow;
      final delay = initialDelay * math.pow(2, attempt - 1);
      onRetry?.call(attempt, delay, e);
      await Future.delayed(delay);
    }
  }
}
```

---

## 📚 Series Outline

| Part | Topic | Key Features | Status |
|------|-------|--------------|--------|
| **Part 1** | Cloud AI + On-Device Hybrid | Zero-latency local TFLite classification + Cloud Gemini semantic summaries | ✅ Live |
| **Part 2** | Reliable AI Features | Structured Output (JSON mode), Real-time token streaming, & Resilient error handling | 🟢 **Active Branch** |
| **Part 3** | AI Agents & Workflows | Planning Agent → Generation Agent → Validation Agent multi-step pipeline | 🔜 Coming |
| **Part 4** | Multimodal AI & Context | Image understanding, audio processing, & live multimodal context streams | 🔜 Coming |

---

## 🎯 Production AI Checklist

- [ ] Use `googleai_dart` package (`^11.0.0`) instead of the deprecated `google_generative_ai`
- [ ] Store API keys securely — use `--dart-define` or user-input modals, never hardcode in client source code
- [ ] Enforce Structured Output via `responseMimeType: 'application/json'` to ensure reliable JSON parsing
- [ ] Wrap model invocations with strongly-typed `AIException` sub-classes (`NetworkAIException`, `RateLimitAIException`)
- [ ] Implement exponential backoff retries for HTTP `429` Rate Limit and transient network drops
- [ ] Provide explicit `StreamSubscription.cancel()` controls for long-running text streams
- [ ] Test error UI recovery using simulated fault injection (Rate limit 429, schema mismatch, safety refusal)

---

## 📬 Get the Full AI Starter Kit

Download the **AI Engineering for Flutter Developers Guide PDF** (includes architecture diagrams, full code walkthroughs, and production checklists):

👉 **[techwithsam.dev/ai-starter-kit-2](https://techwithsam.dev/ai-starter-kit-2)**

---

## 🔔 Stay Updated

- **YouTube Series Playlist:** Watch the [AI Engineering for Flutter Developers Playlist](https://www.youtube.com/playlist?list=PLE9YRxI_vdvE)
- **YouTube Channel:** [youtube.com/@techwithsam](https://youtube.com/@techwithsam) — Subscribe for new video releases
- **Newsletter:** Join 2,000+ Flutter developers at [techwithsam.dev/newsletter](https://techwithsam.dev/newsletter)
- **Twitter/X:** Follow for quick tips between videos [twitter.com/techwithsam_](https://twitter.com/techwithsam_)

---

## 📄 License

MIT — use freely in personal and commercial projects. Attribution appreciated but not required.

---

*Built with ❤️ by Samuel — Tech With Sam*
