/// Represents a checkpoint practice question shown mid-lesson.
///
/// Checkpoint questions appear after slides 4, 8, 12, and 16.
/// They are formative (practice) questions — not part of the final quiz.
class CheckpointQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const CheckpointQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
