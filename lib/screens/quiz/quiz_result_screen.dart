import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/module_model.dart';
import '../../models/quiz_model.dart';

/// Displays the quiz completion result: score, pass/fail status,
/// and action buttons to retry or return to the module.
class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final Module? module;
  final SubModule subModule;
  final Color moduleColor;

  const QuizResultScreen({
    super.key,
    required this.result,
    this.module,
    required this.subModule,
    required this.moduleColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = moduleColor;
    final score = result.scorePercent;
    final passed = result.isPassed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Result icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: passed
                        ? [AppColors.success, const Color(0xFF2ECC71)]
                        : [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (passed ? AppColors.success : Colors.red)
                          .withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    passed ? '🏆' : '💪',
                    style: const TextStyle(fontSize: 52),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quiz title
              Text(
                result.quizTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Pass/fail badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: (passed ? AppColors.success : Colors.red)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (passed ? AppColors.success : Colors.red)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  passed ? '✓ PASSED' : '✗ FAILED — Try Again',
                  style: TextStyle(
                    color: passed ? AppColors.success : Colors.red.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Score card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${score.toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.correctAnswers} out of ${result.totalQuestions} correct',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          passed ? AppColors.success : Colors.red.shade400,
                        ),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats row
                    Row(
                      children: [
                        _statChip(
                          '✓ ${result.correctAnswers}',
                          'Correct',
                          AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        _statChip(
                          '✗ ${result.totalQuestions - result.correctAnswers}',
                          'Wrong',
                          Colors.red.shade400,
                        ),
                        const SizedBox(width: 10),
                        _statChip(
                          '${result.totalQuestions}',
                          'Total',
                          color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Minimum score info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: passed
                      ? AppColors.successLight
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: passed
                        ? AppColors.success.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      passed
                          ? Icons.emoji_events_rounded
                          : Icons.info_outline_rounded,
                      color:
                          passed ? AppColors.success : Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        passed
                            ? 'Congratulations! The topic "${subModule.name}" is now marked as completed.'
                            : 'Minimum passing score is 60%. Review the materials and try again.',
                        style: TextStyle(
                          color: passed
                              ? AppColors.success
                              : Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              if (!passed) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Pop result and quiz screens, return to module
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    label: const Text(
                      'Retry Quiz',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Pop back to SubDetailPage (pops QuizResultScreen and QuizScreen)
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  label: const Text(
                    'Back to Topic',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side:
                        BorderSide(color: color.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
