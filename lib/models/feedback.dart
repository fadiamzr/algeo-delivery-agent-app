enum FeedbackOutcome { delivered, failed, partial }

class DeliveryFeedback {
  final String id;
  final FeedbackOutcome outcome;
  final String notes;
  final DateTime createdAt;

  DeliveryFeedback({
    required this.id,
    required this.outcome,
    required this.notes,
    required this.createdAt,
  });

  String get outcomeLabel {
    switch (outcome) {
      case FeedbackOutcome.delivered:
        return 'Delivered';
      case FeedbackOutcome.failed:
        return 'Failed';
      case FeedbackOutcome.partial:
        return 'Partial';
    }
  }

  factory DeliveryFeedback.fromJson(Map<String, dynamic> json) {
    return DeliveryFeedback(
      id: json['id'] as String,
      outcome: FeedbackOutcome.values.firstWhere(
        (value) => value.name == json['outcome'],
        orElse: () => FeedbackOutcome.partial,
      ),
      notes: (json['notes'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'outcome': outcome.name,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };
}
