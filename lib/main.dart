import 'package:flutter/material.dart';

import 'models/text_analysis_models.dart';
import 'services/gemini_service.dart';
import 'services/on_device_classifier_service.dart';
import 'theme/app_theme.dart';
import 'widgets/api_key_dialog.dart';
import 'widgets/gemini_results_card.dart';
import 'widgets/on_device_results_card.dart';
import 'widgets/sample_text_presets.dart';

void main() {
  runApp(const SmartTextAnalyzerApp());
}

class SmartTextAnalyzerApp extends StatelessWidget {
  const SmartTextAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Text Analyzer',
      debugShowCheckedModeBanner: false,

    
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,

      home: const SmartTextAnalyzerScreen(),
    );
  }
}

class SmartTextAnalyzerScreen extends StatefulWidget {
  const SmartTextAnalyzerScreen({super.key});

  @override
  State<SmartTextAnalyzerScreen> createState() => _SmartTextAnalyzerScreenState();
}

class _SmartTextAnalyzerScreenState extends State<SmartTextAnalyzerScreen> {
  // Controller for user text input
  final TextEditingController _textController = TextEditingController();

  // STEP 1: Service Instances
  final OnDeviceClassifierService _onDeviceService = OnDeviceClassifierService();

  // Gemini API key state (can be passed via --dart-define or entered in UI)
  String _geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  // STEP 2: Main Analysis State
  TextAnalysisResult _state = TextAnalysisResult();

  @override
  void initState() {
    super.initState();
    // Initialize TFLite model on app startup
    _onDeviceService.initializeModel();
  }

  @override
  void dispose() {
    _textController.dispose();
    _onDeviceService.dispose();
    super.dispose();
  }

  // STEP 2: Execution Controller & Parallel State Handler
  Future<void> _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text to analyze.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    // 1. Reset state & trigger loading indicators for both Cloud & On-Device
    setState(() {
      _state = TextAnalysisResult(
        isGeminiLoading: true,
        isOnDeviceLoading: true,
      );
    });

    // 2. Trigger parallel background execution
    _runOnDeviceClassification(text);
    _runGeminiAnalysis(text);
  }

  /// Step 2a: Run On-Device TFLite Model
  Future<void> _runOnDeviceClassification(String text) async {
    try {
      final classification = await _onDeviceService.classifyText(text);
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          onDeviceClassification: classification,
          isOnDeviceLoading: false,
          clearOnDeviceError: true,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          onDeviceError: 'On-Device Analysis Failed: $e',
          isOnDeviceLoading: false,
        );
      });
    }
  }

  /// Step 2b: Run Cloud Gemini AI via googleai_dart
  Future<void> _runGeminiAnalysis(String text) async {
    if (_geminiApiKey.isEmpty) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          geminiError: 'Gemini API Key is missing. Tap the key icon to configure.',
          isGeminiLoading: false,
        );
      });
      return;
    }

    try {
      final geminiService = GeminiService(apiKey: _geminiApiKey);
      final insight = await geminiService.analyzeText(text);
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          geminiInsight: insight,
          isGeminiLoading: false,
          clearGeminiError: true,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          geminiError: "An error occured.",
          isGeminiLoading: false,
        );
      });
    }
  }

  /// Dialog helper to set or update Gemini API Key
  Future<void> _configureApiKey() async {
    final newKey = await showDialog<String>(
      context: context,
      builder: (context) => ApiKeyDialog(currentApiKey: _geminiApiKey),
    );

    if (newKey != null) {
      setState(() {
        _geminiApiKey = newKey;
      });

      // Re-run analysis if input text is present
      if (_textController.text.trim().isNotEmpty && _geminiApiKey.isNotEmpty) {
        setState(() {
          _state = _state.copyWith(
            isGeminiLoading: true,
            clearGeminiError: true,
          );
        });
        _runGeminiAnalysis(_textController.text.trim());
      }
    }
  }

  // STEP 3: Displaying Results Side-by-Side
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktopOrTablet = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppTheme.xBlue, size: 24),
            SizedBox(width: 8),
            Text(
              'Smart Text Analyzer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _geminiApiKey.isEmpty ? 'Set Gemini API Key' : 'API Key Configured',
            icon: Icon(
              _geminiApiKey.isEmpty ? Icons.vpn_key_outlined : Icons.vpn_key_rounded,
              color: _geminiApiKey.isEmpty ? AppTheme.xWarningYellow : AppTheme.xSuccessGreen,
            ),
            onPressed: _configureApiKey,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner
                _buildHeaderBanner(isDark),

                const SizedBox(height: 20),

                // Input Text Area
                _buildInputSection(isDark),

                const SizedBox(height: 16),

                // Sample Text Presets
                SampleTextPresets(
                  onSelectPreset: (sampleText) {
                    _textController.text = sampleText;
                    setState(() {});
                  },
                ),

                const SizedBox(height: 20),

                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.xBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (_state.isGeminiLoading || _state.isOnDeviceLoading)
                      ? null
                      : _analyzeText,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_state.isGeminiLoading || _state.isOnDeviceLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        (_state.isGeminiLoading || _state.isOnDeviceLoading)
                            ? 'Analyzing with Hybrid AI...'
                            : 'Analyze Text (Cloud + On-Device)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Results Section Header
                const Row(
                  children: [
                    Text(
                      'SIDE-BY-SIDE HYBRID ANALYSIS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(child: Divider(indent: 12)),
                  ],
                ),

                const SizedBox(height: 16),

                // STEP 3: Responsive Side-by-Side Cards
                if (isDesktopOrTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Cloud AI (Gemini)
                      Expanded(
                        child: GeminiResultsCard(
                          insight: _state.geminiInsight,
                          isLoading: _state.isGeminiLoading,
                          error: _state.geminiError,
                          onRetry: _analyzeText,
                          onConfigureKey: _configureApiKey,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right Column: On-Device Model (TFLite)
                      Expanded(
                        child: OnDeviceResultsCard(
                          classification: _state.onDeviceClassification,
                          isLoading: _state.isOnDeviceLoading,
                          error: _state.onDeviceError,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      // Stacked view for Mobile screens
                      OnDeviceResultsCard(
                        classification: _state.onDeviceClassification,
                        isLoading: _state.isOnDeviceLoading,
                        error: _state.onDeviceError,
                      ),
                      const SizedBox(height: 16),
                      GeminiResultsCard(
                        insight: _state.geminiInsight,
                        isLoading: _state.isGeminiLoading,
                        error: _state.geminiError,
                        onRetry: _analyzeText,
                        onConfigureKey: _configureApiKey,
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Tutorial Comparison Footer
                _buildArchitectureFooter(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.xBlue.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HYBRID AI ENGINE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.xBlue,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cloud Gemini AI + On-Device TFLite',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Compare instant zero-latency local classification with deep cloud semantic summaries side-by-side.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.xBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: AppTheme.xBlue,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(bool isDark) {
    final textLength = _textController.text.length;
    final wordCount = _textController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Input Text',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_textController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _textController.clear();
                    setState(() {});
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.xDangerRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            maxLines: 5,
            minLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Type, paste, or select a sample preset below to analyze text...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.xBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$wordCount words | $textLength characters',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Powered by googleai_dart & tflite_flutter',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.xBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.xDarkCard : AppTheme.xLightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.xDarkBorder : AppTheme.xLightBorder,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppTheme.xBlue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tutorial Architecture: On-Device TFLite gives instant local sentiment & category scores with zero network latency. Cloud Gemini provides rich executive summaries and action plans.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
