import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/delivery.dart';

class DeliveryFiltersScreen extends StatefulWidget {
  const DeliveryFiltersScreen({super.key});

  @override
  State<DeliveryFiltersScreen> createState() => _DeliveryFiltersScreenState();
}

class _DeliveryFiltersScreenState extends State<DeliveryFiltersScreen> {
  DeliveryStatus? _selectedStatus;
  RangeValues _scoreRange = const RangeValues(0.0, 1.0);

  void _applyFilters() {
    Navigator.pop(context, {
      'status': _selectedStatus,
      'minScore': _scoreRange.start,
      'maxScore': _scoreRange.end,
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _scoreRange = const RangeValues(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Deliveries'),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset', style: TextStyle(color: AppTheme.accentAmber)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('Filter by current delivery status', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(height: 14),

            _StatusFilterOption(label: 'All Statuses', color: cs.onSurfaceVariant, isSelected: _selectedStatus == null, onTap: () => setState(() => _selectedStatus = null)),
            const SizedBox(height: 8),
            _StatusFilterOption(label: 'Pending', color: AppTheme.accentAmber, isSelected: _selectedStatus == DeliveryStatus.pending, onTap: () => setState(() => _selectedStatus = DeliveryStatus.pending)),
            const SizedBox(height: 8),
            _StatusFilterOption(label: 'In Progress', color: AppTheme.infoBlue, isSelected: _selectedStatus == DeliveryStatus.inProgress, onTap: () => setState(() => _selectedStatus = DeliveryStatus.inProgress)),
            const SizedBox(height: 8),
            _StatusFilterOption(label: 'Completed', color: AppTheme.successGreen, isSelected: _selectedStatus == DeliveryStatus.completed, onTap: () => setState(() => _selectedStatus = DeliveryStatus.completed)),
            const SizedBox(height: 8),
            _StatusFilterOption(label: 'Failed', color: AppTheme.errorRed, isSelected: _selectedStatus == DeliveryStatus.failed, onTap: () => setState(() => _selectedStatus = DeliveryStatus.failed)),
            const SizedBox(height: 32),

            Text('Confidence Score Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('Filter by address verification confidence score', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ScoreLabel(value: _scoreRange.start, label: 'Min'),
                      _ScoreLabel(value: _scoreRange.end, label: 'Max'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.accentAmber,
                      inactiveTrackColor: cs.outline,
                      thumbColor: AppTheme.accentAmber,
                      overlayColor: AppTheme.accentAmber.withValues(alpha: 0.12),
                      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                      trackHeight: 4,
                    ),
                    child: RangeSlider(
                      values: _scoreRange,
                      min: 0.0, max: 1.0, divisions: 20,
                      onChanged: (values) => setState(() => _scoreRange = values),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ScoreRangeLabel(label: 'Low', range: '0-49%', color: AppTheme.errorRed),
                      _ScoreRangeLabel(label: 'Medium', range: '50-79%', color: AppTheme.warningYellow),
                      _ScoreRangeLabel(label: 'High', range: '80-100%', color: AppTheme.successGreen),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_list, size: 22),
                label: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _StatusFilterOption({required this.label, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : cs.outline, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isSelected ? color : cs.onSurface, fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ScoreLabel extends StatelessWidget {
  final double value;
  final String label;
  const _ScoreLabel({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
        Text('${(value * 100).round()}%', style: TextStyle(color: AppTheme.getScoreColor(value), fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ScoreRangeLabel extends StatelessWidget {
  final String label;
  final String range;
  final Color color;
  const _ScoreRangeLabel({required this.label, required this.range, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(range, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
      ],
    );
  }
}
