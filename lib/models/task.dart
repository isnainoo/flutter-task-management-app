class Task {
  final int id;
  String name;
  DateTime? deadline;
  bool isDone;
  String? submissionLink;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.name,
    this.deadline,
    this.isDone = false,
    this.submissionLink,
    this.completedAt,
  });
}