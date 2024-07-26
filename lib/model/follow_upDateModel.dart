class FollowUp {
  final int id;
  final String followUpDate;
  final int leadId;
  final String createdAt;
  final String updatedAt;

  FollowUp({
    required this.id,
    required this.followUpDate,
    required this.leadId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'],
      followUpDate: json['follow_up_dates'], // Fixed key name
      leadId: json['lead_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
