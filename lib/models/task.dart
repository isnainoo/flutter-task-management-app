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

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']).toLocal() : null,

      isDone: json['is_done'] == 1 || json['is_done'] == true,
      submissionLink: json['submission_link'],

      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']).toLocal() : null,
    );
  }
}