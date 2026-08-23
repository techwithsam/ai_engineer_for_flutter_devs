# AI Agents & Workflows in Flutter – Video 3 Companion Repo

> **Free resource from [Tech With Sam](https://techwithsam.dev)** — companion repository for Video 3 of the *AI Engineering for Flutter Developers* YouTube series.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Google AI](https://img.shields.io/badge/Google%20AI-googleai__dart-4285F4?logo=google)](https://pub.dev/packages/googleai_dart)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![YouTube Series Playlist](https://img.shields.io/badge/YouTube-Series_Playlist-FF0000?logo=youtube)](https://www.youtube.com/playlist?list=PLE9YRxI_vdvE)

---

## 📦 What's in This Branch (`video-3`)

This branch contains the full source code for **Video 3: AI Agents & Workflows in Flutter – Planning, Generation & Validation Agents** (`Smart Feature Builder`).

| Folder / File | Contents |
|---------------|----------|
| `lib/video_3/video_3_app.dart` | Video 3 Studio App (`Video3App` & `Video3StudioScreen`) with responsive Web/Mobile workspace |
| `lib/video_3/agents/planning_agent.dart` | **Stage 1 Agent**: Senior Architect turning raw prompts into structured `FeaturePlan` schemas |
| `lib/video_3/agents/generation_agent.dart` | **Stage 2 Agent**: Flutter Engineer generating complete widget code & module dependencies |
| `lib/video_3/agents/validation_agent.dart` | **Stage 3 Agent**: Code Auditor evaluating quality (0–100 score), security, & suggested code patches |
| `lib/video_3/services/agent_orchestrator.dart` | Pipeline state machine coordinating the 3-stage agent sequence and real-time telemetry logs |
| `lib/video_3/models/` | Structured JSON schemas (`feature_plan.dart`, `generated_feature_code.dart`, `validation_report.dart`, `agent_workflow_state.dart`) |
| `lib/video_3/widgets/` | Studio UI widgets: `AgentWorkflowStepper`, `PlanSummaryCard`, `CodeOutputCard`, `ValidationReportCard`, `AgentTelemetrySheet` |
| `video_3_tutorial_script.md` | Full video recording script, timestamp outline, & line-by-line code walkthrough |
| `lib/main.dart` | Root app entry point running `Video3App()` by default |

---

## 🚀 Quick Setup

```bash
# 1. Clone the repo and checkout the video-3 branch
git clone https://github.com/techwithsam/ai_engineer_for_flutter_devs.git
cd ai_engineer_for_flutter_devs
git checkout video-3

# 2. Get dependencies
flutter pub get

# 3. Run the application (Supports Web, Desktop, & Mobile)
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```

**Requirements:** Flutter 3.x (stable channel), Dart 3.x, and a Gemini API Key (can also be entered dynamically in-app via the top-right key icon).

---

## 🤖 The Multi-Agent Workflow Pattern

Single prompt LLM calls struggle with complex, multi-step engineering tasks. The **Smart Feature Builder** architecture breaks complex generation into a specialized 3-stage agentic pipeline:

```
[User Request] 
      │
      ▼
🧠 1. Planning Agent (Architect)
      │  └── Outputs Structured FeaturePlan (Components, Steps, Risks)
      ▼
⚡ 2. Generation Agent (Engineer)
      │  └── Receives Plan → Outputs Production Flutter Code + Pub Dependencies
      ▼
🛡️ 3. Validation Agent (Auditor)
      │  └── Audits Code Quality (Score 0-100), Issues, & Refinement Patch
      ▼
[Completed Feature Output & Telemetry]
```

---

## 🧩 Reusable Code Snippets (Quick Reference)

### 1. Multi-Agent Pipeline Orchestrator

```dart
class AgentOrchestrationService extends ValueNotifier<AgentWorkflowState> {
  Future<void> runWorkflow(String prompt, {required String apiKey}) async {
    // Stage 1: Planning Agent
    value = value.copyWith(stage: AgentStage.planning);
    final plan = await planningAgent.planFeature(prompt);

    // Stage 2: Generation Agent (passes Stage 1 Plan)
    value = value.copyWith(stage: AgentStage.generating, plan: plan);
    final code = await generationAgent.generateCode(userPrompt: prompt, plan: plan);

    // Stage 3: Validation Agent (audits Stage 2 Code against Stage 1 Plan)
    value = value.copyWith(stage: AgentStage.validating, generatedCode: code);
    final report = await validationAgent.validateOutput(userPrompt: prompt, plan: plan, generatedCode: code);

    // Pipeline Complete
    value = value.copyWith(stage: AgentStage.completed, validationReport: report);
  }
}
```

### 2. Enforcing JSON Mode Schemas across Agents

```dart
final request = GenerateContentRequest(
  contents: [Content.text('Feature Request:\n$prompt')],
  systemInstruction: Content.text(architectSystemInstruction),
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
return FeaturePlan.fromJson(jsonMap);
```

---

## 📚 Series Outline

| Part | Topic | Key Features | Status |
|------|-------|--------------|--------|
| **Part 1** | Cloud AI + On-Device Hybrid | Zero-latency local TFLite classification + Cloud Gemini semantic summaries | ✅ Live |
| **Part 2** | Reliable AI Features | Structured Output (JSON mode), Real-time token streaming, & Resilient error handling | ✅ Live |
| **Part 3** | AI Agents & Workflows | Planning Agent → Generation Agent → Validation Agent multi-step pipeline | 🟢 **Active Branch** |
| **Part 4** | Multimodal AI & Context | Image understanding, audio processing, & live multimodal context streams | 🔜 Coming |

---

## 🎯 Production Multi-Agent Checklist

- [ ] Use specialized system instructions to assign distinct roles (Architect, Engineer, Auditor) to each agent
- [ ] Enforce Structured Output via `responseMimeType: 'application/json'` so agents exchange type-safe schemas
- [ ] Pass context sequentially from earlier stages to downstream agents (e.g. Stage 2 receives Stage 1's plan)
- [ ] Implement an orchestrator state machine (`ValueNotifier` / `StreamController`) to track live progress and step timing
- [ ] Provide real-time UI telemetry logs so users and developers can inspect inter-agent JSON payloads
- [ ] Ensure cross-platform compatibility (Web, Desktop, Mobile) using conditional imports for native plugins

---

## 📬 Get the Full AI Starter Kit

Download the **AI Engineering for Flutter Developers Guide PDF** (includes architecture diagrams, full code walkthroughs, and production checklists):

👉 **[techwithsam.dev/ai-starter-kit](https://techwithsam.dev/ai-starter-kit)**

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
