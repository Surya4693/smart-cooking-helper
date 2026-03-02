import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Ensure this is in pubspec.yaml
import 'dart:async';
import '../../models/recipe_model.dart';
import '../../services/api_service.dart';

class CookingAssistantScreen extends StatefulWidget {
  final String recipeId;

  const CookingAssistantScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<CookingAssistantScreen> createState() => _CookingAssistantScreenState();
}

class _CookingAssistantScreenState extends State<CookingAssistantScreen> {
  final _apiService = ApiService();
  late Future<Recipe> _recipeFuture; // Renamed to avoid confusion

  // FIX 1: Create an instance of FlutterTts
  final FlutterTts flutterTts = FlutterTts();

  int _currentStepIndex = 0;
  bool _isTimerRunning = false;
  int _timerSeconds = 0;
  Timer? _timer;
  bool _isVoiceEnabled = false;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _apiService.getRecipeDetails(widget.recipeId);
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    try {
      // FIX 2: Use the instance 'flutterTts' instead of static 'Tts'
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  void _speakInstruction(String instruction) async {
    if (_isVoiceEnabled) {
      // Stop previous speech to prevent overlapping
      await flutterTts.stop();
      await flutterTts.speak(instruction);
    }
  }

  // FIX 3: Helper method to handle step changes safely
  // This prevents the infinite loop/audio spam issue
  void _changeStep(int newIndex, Recipe recipe) {
    _timer?.cancel(); // Cancel any existing timer
    flutterTts.stop(); // Stop any existing speech

    setState(() {
      _currentStepIndex = newIndex;
      _isTimerRunning = false;
      // Optional: Reset timer display to new step's duration
      _timerSeconds = recipe.steps[newIndex].durationSeconds ?? 0;
    });

    // Speak the new instruction automatically
    _speakInstruction(recipe.steps[newIndex].instruction);
  }

  void _startTimer(int duration) {
    setState(() {
      _timerSeconds = duration;
      _isTimerRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isTimerRunning = false);
        _showTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _showTimerComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timer completed!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    flutterTts.stop(); // Use instance here too
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Assistant'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Recipe not found'));
          }

          final recipe = snapshot.data!;
          final currentStep = recipe.steps[_currentStepIndex];

          // CRITICAL FIX: Removed the automatic speech trigger from build()
          // It is now handled in the _changeStep method.

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${_currentStepIndex + 1} of ${recipe.steps.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentStepIndex + 1) / recipe.steps.length,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                // Step content
                if (currentStep.imageUrl != null)
                  Image.network(
                    currentStep.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                // Step instruction
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Step ${currentStep.stepNumber}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                            ),
                            onPressed: () {
                              setState(() => _isVoiceEnabled = !_isVoiceEnabled);
                              if (_isVoiceEnabled) {
                                _speakInstruction(currentStep.instruction);
                              } else {
                                flutterTts.stop(); // Fixed static call
                              }
                            },
                            tooltip: _isVoiceEnabled ? 'Disable voice' : 'Enable voice',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentStep.instruction,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Timer section
                if (currentStep.durationSeconds != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: _isTimerRunning ? Colors.orange.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Cooking Timer',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _formatTime(_isTimerRunning ? _timerSeconds : (currentStep.durationSeconds ?? 0)),
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isTimerRunning ? Colors.orange : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isTimerRunning)
                                  ElevatedButton.icon(
                                    onPressed: _pauseTimer,
                                    icon: const Icon(Icons.pause),
                                    label: const Text('Pause'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                    ),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () => _startTimer(currentStep.durationSeconds ?? 0),
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Start Timer'),
                                  ),
                                if (_isTimerRunning) ...[
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _pauseTimer();
                                      setState(() => _timerSeconds = currentStep.durationSeconds ?? 0);
                                    },
                                    icon: const Icon(Icons.stop),
                                    label: const Text('Reset'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentStepIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _changeStep(_currentStepIndex - 1, recipe);
                            },
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentStepIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentStepIndex < recipe.steps.length - 1
                              ? () {
                            _changeStep(_currentStepIndex + 1, recipe);
                          }
                              : null,
                          child: Text(
                            _currentStepIndex < recipe.steps.length - 1
                                ? 'Next Step'
                                : 'Finished!',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}