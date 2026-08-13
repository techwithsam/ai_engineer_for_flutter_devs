# AI Engineering for Flutter Developers – Smart Text Analyzer

> **Free resource from [Tech With Sam](https://techwithsam.dev)** — companion repo for the [*AI Engineering for Flutter Developers* YouTube series](https://www.youtube.com/playlist?list=PLE9YRxI_vdvE).

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Google AI](https://img.shields.io/badge/Google%20AI-googleai__dart-4285F4?logo=google)](https://pub.dev/packages/googleai_dart)
[![TensorFlow Lite](https://img.shields.io/badge/TFLite-tflite__flutter-FF6F00?logo=tensorflow)](https://pub.dev/packages/tflite_flutter)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![YouTube Playlist](https://img.shields.io/badge/YouTube-Series_Playlist-FF0000?logo=youtube)](https://www.youtube.com/playlist?list=PLE9YRxI_vdvE)

---

## 📦 What's in This Repo

| Folder / File | Contents |
|---------------|----------|
| `/lib/services` | Cloud Gemini (`GeminiService`), On-Device TFLite (`OnDeviceClassifierService`), & Resilient AI Engine (`ResilientAIService`, `RetryHelper`) |
| `/lib/models` | Data models (`TextAnalysisResult`), Structured Output schemas (`ArticleBlueprint`), & Custom AI Exceptions (`ai_exceptions.dart`) |
| `/lib/widgets` | UI components: Gemini/On-Device cards, `StreamingOutputWidget`, `StructuredBlueprintCard`, & `ErrorResilienceBanner` |
| `/lib/theme` | Dark & light mode brand theme system (`AppTheme`) |
| `/lib/part_two_app.dart` | Video 2 entry point & studio screen for Structured Output, Token Streaming, and Fault Injection testing |
| `/lib/main.dart` | Main root app launcher coexisting across all video series modules |

---

## 🚀 Quick Setup

```bash
# 1. Clone the repo
git clone https://github.com/techwithsam/ai_engineer_for_flutter_devs.git

# 2. Navigate into the project
cd ai_engineer_for_flutter_devs

# 3. Get dependencies
flutter pub get

# 4. Run the application
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

**Requirements:** Flutter 3.x (stable channel), Dart 3.x, null-safety enabled, and a Gemini API Key (can also be entered dynamically in-app via the API Key dialog).

---

## 🧩 Reusable AI Services & Components

All AI services and widgets live in `/lib` — modular, self-contained, and ready to drop into production Flutter apps.

| Component / Class | File | What it does |
|-------------------|------|-------------|
| `GeminiService` | `services/gemini_service.dart` | Cloud AI semantic summarization & key insight extraction using `googleai_dart` |
| `OnDeviceClassifierService` | `services/on_device_classifier_service.dart` | Zero-latency local TFLite text sentiment & category classification |
| `ResilientAIService` | `services/resilient_ai_service.dart` | Production AI wrapper supporting JSON mode, token streaming, & fault injection |
| `RetryHelper` | `services/retry_helper.dart` | Exponential backoff utility for recovering from rate limits (429) & network glitches |
| `StreamingOutputWidget` | `widgets/streaming_output_widget.dart` | Real-time typewriter output widget with live metrics and stream cancellation |
| `StructuredBlueprintCard` | `widgets/structured_blueprint_card.dart` | Formatted presentation card for deserialized JSON schema outputs |
| `ErrorResilienceBanner` | `widgets/error_resilience_banner.dart` | User-friendly error alert banner with actionable recovery steps |

### Usage Example: Structured Output (JSON Mode)

```dart
import 'services/resilient_ai_service.dart';
import 'models/article_blueprint.dart';

final aiService = ResilientAIService(apiKey: 'YOUR_GEMINI_API_KEY');

// Generate strongly-typed structured output from prompt
final ArticleBlueprint blueprint = await aiService.generateStructuredBlueprint(
  'Building a Real-Time Chat App with Flutter & Firebase',
  onRetry: (attempt, delay, error) {
    print('Retry attempt $attempt after ${delay.inSeconds}s due to $error');
  },
);

print('Title: ${blueprint.title}');
print('Key Takeaways: ${blueprint.keyTakeaways}');
```

---

## 📚 Series Outline

| Part | Topic | Key Features | Status |
|------|-------|--------------|--------|
| **Part 1** | Cloud AI + On-Device Hybrid | Zero-latency local TFLite classification + Cloud Gemini semantic summaries | ✅ Live |
| **Part 2** | Reliable AI Features | Structured Output (JSON mode), Real-time token streaming, & Resilient error handling |  🔜 Coming |
| **Part 3** | AI Agents & Tool Calling | Multi-step reasoning, function calling, & local database integration | 🔜 Coming |
| **Part 4** | Multimodal AI & Context | Image understanding, audio processing, & live multimodal context streams | 🔜 Coming |

---

## ⚡ Key Concepts (Quick Reference)

### 1. Structured Output (Guaranteed JSON Schema)

```dart
// Enforce JSON output format using googleai_dart configuration
final request = GenerateContentRequest(
  contents: [Content.text(prompt)],
  generationConfig: GenerationConfig(
    responseMimeType: 'application/json',
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
// Subscribe to streamed content tokens with explicit cancellation handle
StreamSubscription<String>? subscription;

subscription = resilientService.streamTextContent(prompt).listen(
  (token) => setState(() => buffer += token),
  onError: (err) => handleStreamError(err),
  onDone: () => finalizeStream(),
);

// User taps "Cancel Stream"
void cancelStream() {
  subscription?.cancel(); // ← Cleanly stop background tokens & free network resources
}
```

### 3. Exponential Backoff Retry Strategy

```dart
// Retries ephemeral network/rate limit errors automatically
Future<T> retryWithBackoff<T>({
  required Future<T> Function() action,
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await action();
    } catch (e) {
      attempt++;
      if (attempt > maxRetries || !isTransientError(e)) rethrow;
      final delay = initialDelay * math.pow(2, attempt - 1);
      await Future.delayed(delay);
    }
  }
}
```

---

## 🎯 Production AI Checklist

- [ ] Use `googleai_dart` package (`^11.0.0`) instead of the deprecated `google_generative_ai`
- [ ] Store API keys securely — use `--dart-define` or user-input modals, never hardcode in source code
- [ ] Enforce Structured Output via `responseMimeType: 'application/json'` to avoid parsing crashes
- [ ] Wrap model invocation with `try-catch` using strongly-typed `AIException` sub-classes
- [ ] Implement exponential backoff for HTTP `429` Rate Limit and transient network errors
- [ ] Provide explicit `StreamSubscription.cancel()` controls for long-running text generation streams
- [ ] Combine local zero-latency TFLite models with cloud LLMs for hybrid speed & depth
- [ ] Test error recovery gracefully with simulated fault injection UI widgets

---

## 📬 Get the Full AI Engineering Guide

Download the **AI Engineering for Flutter Developers Guide PDF** (includes architecture diagrams, full code walkthroughs, and production checklists):

👉 **[techwithsam.dev/ai-starter-kit](https://techwithsam.dev/ai-starter-kit)**

---

## 🔔 Stay Updated

- **YouTube Playlist:** Watch the [AI Engineering for Flutter Developers Series](https://www.youtube.com/playlist?list=PLE9YRxI_vdvE)
- **YouTube Channel:** [youtube.com/@techwithsam](https://youtube.com/@techwithsam) — Subscribe for new video releases
- **Newsletter:** Join 2,000+ Flutter developers at [techwithsam.dev/newsletter](https://techwithsam.dev/newsletter)
- **Twitter/X:** Follow for quick tips between videos [twitter.com/techwithsam_](https://twitter.com/techwithsam_)

---

## 📄 License

MIT — use freely in personal and commercial projects. Attribution appreciated but not required.

---

*Built with ❤️ by Samuel — Tech With Sam*
