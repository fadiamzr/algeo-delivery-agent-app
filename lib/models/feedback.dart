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
}
