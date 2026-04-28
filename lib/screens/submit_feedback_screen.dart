import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/delivery.dart';
import '../models/feedback.dart';
import '../services/api_service.dart';

class SubmitFeedbackScreen extends StatefulWidget {
  const SubmitFeedbackScreen({super.key});

  @override
  State<SubmitFeedbackScreen> createState() => _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends State<SubmitFeedbackScreen> {
  FeedbackOutcome? _selectedOutcome;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final delivery = ModalRoute.of(context)?.settings.arguments as Delivery?;
    if (delivery == null) return;

    if (_selectedOutcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery outcome'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        '/deliveries/${delivery.id}/feedback',
        body: {
          'outcome': _selectedOutcome!.name,
          'notes': _notesController.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context, DeliveryFeedback(
          id: 'FB-${DateTime.now().millisecondsSinceEpoch}',
          outcome: _selectedOutcome!,
          notes: _notesController.text,
          createdAt: DateTime.now(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        ApiService.handleUnauthorized(context);
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delivery = ModalRoute.of(context)?.settings.arguments as Delivery?;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (delivery != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: AppTheme.accentPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(delivery.id, style: const TextStyle(color: AppTheme.accentPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(delivery.customerName, style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(delivery.rawAddress, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            Text('Delivery Outcome', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('Select the result of this delivery', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(height: 14),

            _OutcomeOption(
              icon: Icons.check_circle_outline, label: 'Delivered', description: 'Package delivered successfully',
              color: AppTheme.successGreen, isSelected: _selectedOutcome == FeedbackOutcome.delivered,
              onTap: () => setState(() => _selectedOutcome = FeedbackOutcome.delivered),
            ),
            const SizedBox(height: 10),
            _OutcomeOption(
              icon: Icons.cancel_outlined, label: 'Failed', description: 'Could not deliver the package',
              color: AppTheme.errorRed, isSelected: _selectedOutcome == FeedbackOutcome.failed,
              onTap: () => setState(() => _selectedOutcome = FeedbackOutcome.failed),
            ),
            const SizedBox(height: 10),
            _OutcomeOption(
              icon: Icons.info_outline, label: 'Partial', description: 'Partially delivered or left with neighbor',
              color: AppTheme.warningYellow, isSelected: _selectedOutcome == FeedbackOutcome.partial,
              onTap: () => setState(() => _selectedOutcome = FeedbackOutcome.partial),
            ),
            const SizedBox(height: 24),

            Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('Add any additional details about the delivery', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              style: TextStyle(color: cs.onSurface),
              decoration: const InputDecoration(hintText: 'e.g., Customer was not home, left with neighbor...'),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryDark))
                    : const Icon(Icons.send_rounded, size: 22),
                label: Text(_isLoading ? 'Submitting...' : 'Submit Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OutcomeOption({
    required this.icon, required this.label, required this.description, required this.color,
    required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? color : cs.outline, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isSelected ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: isSelected ? color : cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(description, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
