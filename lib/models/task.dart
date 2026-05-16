class Task {
  final int id;
  final int userId;
  String name;
  DateTime? deadline;
  bool isDone;
  String? submissionLink;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.userId,
    required this.name,
    this.deadline,
    this.isDone = false,
    this.submissionLink,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      isDone: json['is_done'] == 1 || json['is_done'] == true,
      submissionLink: json['submission_link'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'deadline': deadline?.toIso8601String().split('T')[0],
      'is_done': isDone,
      'submission_link': submissionLink,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}