import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/app_localizations.dart';
import '../../models/module_model.dart';
import '../../models/quiz_model.dart';
import '../../services/api_service.dart';
import '../../services/streak_service.dart';
import '../../services/user_progress_service.dart';
import 'quiz_result_screen.dart';

/// Quiz screen: loads questions from the API and presents them one at a time.
/// Supports 4 multiple-choice options, tracks score, and navigates to results.
class QuizScreen extends StatefulWidget {
  final Module? module;
  final SubModule subModule;
  final Color moduleColor;

  const QuizScreen({
    super.key,
    this.module,
    required this.subModule,
    required this.moduleColor,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _api = ApiService();
  final _progress = UserProgressService.instance;

  ModuleQuizResponse? _quiz;
  bool _isLoading = true;
  String? _error;

  int _currentQuestion = 0;
  String? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  final Map<int, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final quiz = await _api.fetchQuiz(widget.subModule.apiKey);
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('failed_load_quiz');
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final correct = _quiz!.questions[_currentQuestion].correctAnswer;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _userAnswers[_currentQuestion] = answer;
      if (answer == correct) _correctCount++;
    });
  }

  void _nextQuestion() {
    if (_quiz == null) return;
    if (_currentQuestion < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    if (_quiz == null) return;
    final total = _quiz!.questions.length;
    final score = total == 0 ? 0.0 : (_correctCount / total) * 100;
    final passed = score >= 60;

    // Save quiz result and update module progress
    await _progress.saveQuizResult(widget.subModule.apiKey, score, passed);
    // Record streak activity for quiz submission
    await StreakService.instance.recordActivity();
    if (passed) {
      widget.subModule.progress = 1.0;
      widget.subModule.isQuizPassed = true;
      widget.subModule.isCompleted = true;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          result: QuizResult(
            moduleId: _quiz!.moduleId,
            quizTitle: _quiz!.quizTitle,
            totalQuestions: total,
            correctAnswers: _correctCount,
            questions: _quiz!.questions,
            userAnswers: _userAnswers,
          ),
          module: widget.module,
          subModule: widget.subModule,
          moduleColor: widget.moduleColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.moduleColor;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(color),
      body: _isLoading
          ? _buildLoading(color)
          : _error != null
              ? _buildError()
              : _buildQuizBody(color),
    );
  }

  AppBar _buildAppBar(Color color) {
    return AppBar(
      backgroundColor: color,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white),
        ),
      ),
      title: Text(
        '${widget.subModule.name} Quiz',
        style: const TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildLoading(Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color)),
          const SizedBox(height: 16),
          Text(context.tr('loading_quiz'),
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadQuiz,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizBody(Color color) {
    final questions = _quiz!.questions;
    final q = questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / questions.length;

    return Column(
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${context.tr('question_label')} ${_currentQuestion + 1} ${context.tr('of')} ${questions.length}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '✓ $_correctCount ${context.tr('correct')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        // Question + Options
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Q${_currentQuestion + 1}',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        q.question,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                ...q.options.map((option) => _buildOption(option, q, color)),
                const SizedBox(height: 20),

                // Explanation when answered
                if (_answered)
                  AnimatedOpacity(
                    opacity: _answered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedAnswer == q.correctAnswer
                            ? AppColors.successLight
                            : const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedAnswer == q.correctAnswer
                              ? AppColors.success.withValues(alpha: 0.4)
                              : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedAnswer == q.correctAnswer
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: _selectedAnswer == q.correctAnswer
                                ? AppColors.success
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedAnswer == q.correctAnswer
                                  ? context.tr('correct_feedback')
                                  : context.tr('correct_answer_is').replaceAll('{ans}', q.correctAnswer),
                              style: TextStyle(
                                color: _selectedAnswer == q.correctAnswer
                                    ? AppColors.success
                                    : Colors.red.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Next button
        if (_answered) _buildNextButton(color, questions.length),
      ],
    );
  }

  Widget _buildOption(String option, QuizQuestion q, Color color) {
    Color bgColor = AppColors.cardBg;
    Color borderColor = AppColors.divider;
    Color textColor = AppColors.textPrimary;
    Widget? trailingIcon;

    if (_answered) {
      if (option == q.correctAnswer) {
        bgColor = AppColors.successLight;
        borderColor = AppColors.success;
        textColor = AppColors.success;
        trailingIcon = const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 20);
      } else if (option == _selectedAnswer) {
        bgColor = const Color(0xFFFFEEEE);
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
        trailingIcon =
            Icon(Icons.cancel_rounded, color: Colors.red.shade400, size: 20);
      }
    } else if (option == _selectedAnswer) {
      bgColor = color.withValues(alpha: 0.08);
      borderColor = color;
      textColor = color;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(Color color, int totalQuestions) {
    final isLast = _currentQuestion == totalQuestions - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _nextQuestion,
          icon: Icon(
            isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
            size: 20,
          ),
          label: Text(
            isLast ? context.tr('see_results') : context.tr('next_question'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
