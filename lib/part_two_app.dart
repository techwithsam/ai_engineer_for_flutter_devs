import 'dart:async';
import 'package:flutter/material.dart';

import 'models/article_blueprint.dart';
import 'services/resilient_ai_service.dart';
import 'theme/app_theme.dart';
import 'widgets/api_key_dialog.dart';
import 'widgets/error_resilience_banner.dart';
import 'widgets/streaming_output_widget.dart';
import 'widgets/structured_blueprint_card.dart';

/// Video 2 Production App - Building Reliable AI Features
/// (Structured Output, Streaming, & Resilient Error Handling)
class PartTwoApp extends StatelessWidget {
  const PartTwoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Engineering Video 2 - Reliable AI Features',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      home: const Video2StudioScreen(),
    );
  }
}

class Video2StudioScreen extends StatefulWidget {
  const Video2StudioScreen({super.key});

  @override
  State<Video2StudioScreen> createState() => _Video2StudioScreenState();
}

class _Video2StudioScreenState extends State<Video2StudioScreen> {
  final TextEditingController _promptController = TextEditingController(
    text: 'Building a Real-Time Chat App with Flutter & Firebase',
  );

  String _geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  // Tab 1 State: Structured Output
  bool _isStructuredLoading = false;
  ArticleBlueprint? _structuredBlueprint;
  Object? _structuredError;

  // Tab 2 State: Real-Time Streaming
  bool _isStreaming = false;
  String _streamBuffer = '';
  int _streamChunkCount = 0;
  DateTime? _streamStartTime;
  Duration _streamElapsedDuration = Duration.zero;
  Timer? _streamTimer;
  StreamSubscription<String>? _streamSubscription;
  Object? _streamError;

  // Tab 3 State: Resilience & Fault Testing
  bool _isResilienceLoading = false;
  int _retryAttemptCount = 0;
  Object? _simulatedError;
  String _selectedFaultType = 'mock_429_rate_limit';

  @override
  void dispose() {
    _promptController.dispose();
    _streamTimer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // PILLAR 1: Structured Output Execution
  // ---------------------------------------------------------------------------
  Future<void> _executeStructuredOutput() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isStructuredLoading = true;
      _structuredBlueprint = null;
      _structuredError = null;
    });

    try {
      final service = ResilientAIService(apiKey: _geminiApiKey);
      final blueprint = await service.generateStructuredBlueprint(prompt);
      if (!mounted) return;
      setState(() {
        _structuredBlueprint = blueprint;
        _isStructuredLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _structuredError = e;
        _isStructuredLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // PILLAR 2: Real-Time Streaming & Cancellation Execution
  // ---------------------------------------------------------------------------
  Future<void> _startStreaming() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    await _streamSubscription?.cancel();
    _streamTimer?.cancel();

    setState(() {
      _isStreaming = true;
      _streamBuffer = '';
      _streamChunkCount = 0;
      _streamError = null;
      _streamStartTime = DateTime.now();
      _streamElapsedDuration = Duration.zero;
    });

    _streamTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_streamStartTime != null && mounted) {
        setState(() {
          _streamElapsedDuration = DateTime.now().difference(_streamStartTime!);
        });
      }
    });

    try {
      final service = ResilientAIService(apiKey: _geminiApiKey);
      final stream = service.streamTextContent(prompt);

      _streamSubscription = stream.listen(
        (token) {
          if (!mounted) return;
          setState(() {
            _streamBuffer += token;
            _streamChunkCount++;
          });
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _streamError = err;
            _isStreaming = false;
          });
          _streamTimer?.cancel();
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _isStreaming = false;
          });
          _streamTimer?.cancel();
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _streamError = e;
        _isStreaming = false;
      });
      _streamTimer?.cancel();
    }
  }

  /// Cancels active token stream subscription (Pillar 2 Core Requirement)
  void _cancelStream() {
    _streamSubscription?.cancel();
    _streamTimer?.cancel();
    setState(() {
      _isStreaming = false;
    });
  }

  // ---------------------------------------------------------------------------
  // PILLAR 3: Resilience & Fault Testing Execution
  // ---------------------------------------------------------------------------
  Future<void> _executeFaultSimulation() async {
    setState(() {
      _isResilienceLoading = true;
      _simulatedError = null;
      _retryAttemptCount = 0;
    });

    try {
      final service = ResilientAIService(apiKey: _geminiApiKey);

      if (_selectedFaultType.startsWith('mock_')) {
        await service.simulateFault(_selectedFaultType.replaceFirst('mock_', ''));
      } else {
        await service.generateStructuredBlueprint(
          _promptController.text.trim(),
          onRetry: (attempt, delay, error) {
            if (mounted) {
              setState(() {
                _retryAttemptCount = attempt;
              });
            }
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _simulatedError = e;
        _isResilienceLoading = false;
      });
    }
  }

  Future<void> _configureApiKey() async {
    final newKey = await showDialog<String>(
      context: context,
      builder: (context) => ApiKeyDialog(currentApiKey: _geminiApiKey),
    );

    if (newKey != null) {
      setState(() {
        _geminiApiKey = newKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.shield_moon_outlined, color: AppTheme.xBlue, size: 22),
              SizedBox(width: 8),
              Text(
                'Reliable AI Studio (Part 2)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: _geminiApiKey.isEmpty ? 'Set Gemini Key' : 'Key Configured',
              icon: Icon(
                _geminiApiKey.isEmpty ? Icons.vpn_key_outlined : Icons.vpn_key_rounded,
                color: _geminiApiKey.isEmpty ? AppTheme.xWarningYellow : AppTheme.xSuccessGreen,
              ),
              onPressed: _configureApiKey,
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            indicatorColor: AppTheme.xBlue,
            labelColor: AppTheme.xBlue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.data_object), text: '1. Structured'),
              Tab(icon: Icon(Icons.stream), text: '2. Streaming'),
              Tab(icon: Icon(Icons.healing_rounded), text: '3. Resilience'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Banner
                  _buildHeaderBanner(isDark),

                  const SizedBox(height: 12),

                  // Prompt Input Box
                  _buildPromptInput(isDark),

                  const SizedBox(height: 16),

                  // Tab Content View
                  Expanded(
                    child: TabBarView(
                      children: [
                        // TAB 1: Structured Output Demo
                        _buildStructuredOutputTab(isDark),

                        // TAB 2: Streaming Demo
                        _buildStreamingTab(isDark),

                        // TAB 3: Resilience & Fault Injection Demo
                        _buildResilienceTab(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.xBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_outlined, color: AppTheme.xBlue, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Building Production-Ready AI Features',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  'Learn how to enforce Structured Output, stream real-time tokens, and handle AI failures gracefully.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PROMPT INPUT',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _promptController,
          decoration: InputDecoration(
            hintText: 'Enter topic prompt for AI generation...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.xBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 1: Structured Output UI
  Widget _buildStructuredOutputTab(bool isDark) {
    return ListView(
      children: [
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.xBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: _isStructuredLoading ? null : _executeStructuredOutput,
          icon: _isStructuredLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.data_object_rounded),
          label: Text(_isStructuredLoading ? 'Generating JSON Schema...' : 'Generate Structured Output'),
        ),
        const SizedBox(height: 16),
        if (_structuredError != null)
          ErrorResilienceBanner(
            error: _structuredError!,
            onRetry: _executeStructuredOutput,
            onConfigureKey: _configureApiKey,
          )
        else if (_structuredBlueprint != null)
          StructuredBlueprintCard(blueprint: _structuredBlueprint!)
        else
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Press "Generate Structured Output" to enforce JSON schema deserialization.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }

  // TAB 2: Streaming UI
  Widget _buildStreamingTab(bool isDark) {
    return ListView(
      children: [
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.xBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: _isStreaming ? null : _startStreaming,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(_isStreaming ? 'Streaming Tokens Live...' : 'Start Live Token Stream'),
        ),
        const SizedBox(height: 16),
        if (_streamError != null)
          ErrorResilienceBanner(
            error: _streamError!,
            onRetry: _startStreaming,
            onConfigureKey: _configureApiKey,
          ),
        StreamingOutputWidget(
          textBuffer: _streamBuffer,
          isStreaming: _isStreaming,
          chunkCount: _streamChunkCount,
          elapsedDuration: _streamElapsedDuration,
          onCancelStream: _cancelStream,
        ),
      ],
    );
  }

  // TAB 3: Resilience & Fault Testing UI
  Widget _buildResilienceTab(bool isDark) {
    return ListView(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.xWarningYellow.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.xWarningYellow.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FAULT INJECTION TESTER',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.xWarningYellow),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select an intentional failure type below to test exponential backoff retries and UI error resilience.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedFaultType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'mock_429_rate_limit', child: Text('Simulate HTTP 429 Rate Limit')),
                  DropdownMenuItem(value: 'mock_network_timeout', child: Text('Simulate Network Timeout')),
                  DropdownMenuItem(value: 'mock_schema_invalid', child: Text('Simulate Invalid JSON Schema')),
                  DropdownMenuItem(value: 'mock_safety_refusal', child: Text('Simulate Safety Refusal')),
                  DropdownMenuItem(value: 'real_retry_test', child: Text('Test Real Gemini API Request')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedFaultType = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.xDangerRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: _isResilienceLoading ? null : _executeFaultSimulation,
          icon: const Icon(Icons.bug_report_outlined),
          label: Text(_isResilienceLoading ? 'Executing Test Case...' : 'Trigger Fault / Resilience Test'),
        ),
        const SizedBox(height: 16),
        if (_simulatedError != null)
          ErrorResilienceBanner(
            error: _simulatedError!,
            currentAttempt: _retryAttemptCount,
            onRetry: _executeFaultSimulation,
            onConfigureKey: _configureApiKey,
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                'Select a fault test case above to evaluate error banners and retry metrics.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }
}
