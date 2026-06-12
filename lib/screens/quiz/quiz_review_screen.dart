import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/quiz_model.dart';

class QuizReviewScreen extends StatelessWidget {
  final QuizResult result;
  final Color moduleColor;

  const QuizReviewScreen({
    super.key,
    required this.result,
    required this.moduleColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: moduleColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        title: const Text(
          'Quiz Review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Stats Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [moduleColor, moduleColor.withValues(alpha: 0.85)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Score', '${result.scorePercent.toInt()}%', Colors.white),
                  _statItem('Correct', '${result.correctAnswers}', Colors.white70),
                  _statItem('Wrong', '${result.totalQuestions - result.correctAnswers}', Colors.white70),
                ],
              ),
            ),

            // Question List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: result.questions.length,
                itemBuilder: (context, index) {
                  final question = result.questions[index];
                  final userAns = result.userAnswers[index];
                  final isUserCorrect = userAns == question.correctAnswer;

                  return _buildQuestionCard(context, index, question, userAns, isUserCorrect);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    int index,
    QuizQuestion q,
    String? userAns,
    bool isCorrect,
  ) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isCorrect ? AppColors.success : Colors.red).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: TextStyle(
                    color: isCorrect ? AppColors.success : Colors.red.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct ✓' : 'Incorrect ✗',
                style: TextStyle(
                  color: isCorrect ? AppColors.success : Colors.red.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Text
          Text(
            q.question,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Options List
          ...q.options.map((option) => _buildOptionRow(colors, option, q.correctAnswer, userAns)),
          const SizedBox(height: 16),

          // Explanation Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Explanation',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  q.explanation,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    dynamic colors,
    String option,
    String correctAns,
    String? userAns,
  ) {
    bool isUserSelected = option == userAns;
    bool isCorrectOption = option == correctAns;

    Color bgColor = colors.cardBg as Color;
    Color borderColor = colors.divider as Color;
    Color textColor = colors.textPrimary as Color;
    Widget? trailing;

    if (isCorrectOption) {
      bgColor = AppColors.successLight;
      borderColor = AppColors.success;
      textColor = AppColors.success;
      trailing = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18);
    } else if (isUserSelected) {
      bgColor = const Color(0xFFFFEEEE);
      borderColor = Colors.red;
      textColor = Colors.red.shade700;
      trailing = const Icon(Icons.cancel_rounded, color: Colors.red, size: 18);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: (isUserSelected || isCorrectOption) ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
