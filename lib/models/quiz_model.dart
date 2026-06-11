/// Represents a single quiz question with four options and one correct answer.
class QuizQuestion {
  final int questionId;
  final String question;
  final List<String> options;
  final String correctAnswer;

  const QuizQuestion({
    required this.questionId,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionId: json['question_id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

/// Represents the full quiz response for a module from the backend.
class ModuleQuizResponse {
  final int moduleId;
  final String quizTitle;
  final List<QuizQuestion> questions;

  const ModuleQuizResponse({
    required this.moduleId,
    required this.quizTitle,
    required this.questions,
  });

  factory ModuleQuizResponse.fromJson(Map<String, dynamic> json) {
    return ModuleQuizResponse(
      moduleId: json['module_id'] as int,
      quizTitle: json['quiz_title'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Stores the result of a completed quiz attempt.
class QuizResult {
  final int moduleId;
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;

  const QuizResult({
    required this.moduleId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  double get scorePercent =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;

  bool get isPassed => scorePercent >= 60;
}
