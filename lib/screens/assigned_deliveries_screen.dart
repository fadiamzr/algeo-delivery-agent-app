import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/delivery.dart';
import '../services/api_service.dart';
import '../services/delivery_service.dart';
import '../widgets/delivery_card.dart';
import '../widgets/search_bar_widget.dart';

class AssignedDeliveriesScreen extends StatefulWidget {
  const AssignedDeliveriesScreen({super.key});

  @override
  State<AssignedDeliveriesScreen> createState() =>
      _AssignedDeliveriesScreenState();
}

class _AssignedDeliveriesScreenState extends State<AssignedDeliveriesScreen> {
  List<Delivery> _deliveries = [];
  List<Delivery> _filteredDeliveries = [];
  bool _isLoading = false;
  String? _errorMessage;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final deliveries = await DeliveryService.getAssignedDeliveries();
      setState(() {
        _deliveries = deliveries;
        _filteredDeliveries = deliveries;
      });
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        ApiService.handleUnauthorized(context);
        return;
      }
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDeliveries = _deliveries;
      } else {
        final q = query.toLowerCase();
        _filteredDeliveries = _deliveries.where((d) {
          return d.customerName.toLowerCase().contains(q) ||
              d.rawAddress.toLowerCase().contains(q) ||
              d.id.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _openFilters() async {
    final result = await Navigator.pushNamed(context, '/filters');
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final filtered = await DeliveryService.filterDeliveries(
          status: result['status'],
          minScore: result['minScore'],
          maxScore: result['maxScore'],
        );
        setState(() {
          _filteredDeliveries = filtered;
        });
      } catch (e) {
        if (e.toString().contains('SESSION_EXPIRED')) {
          ApiService.handleUnauthorized(context);
          return;
        }
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatsBar() {
    final cs = Theme.of(context).colorScheme;
    final pending =
        _deliveries.where((d) => d.status == DeliveryStatus.pending).length;
    final inProgress =
        _deliveries.where((d) => d.status == DeliveryStatus.inProgress).length;
    final completed =
        _deliveries.where((d) => d.status == DeliveryStatus.completed).length;
    final failed =
        _deliveries.where((d) => d.status == DeliveryStatus.failed).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              count: pending, label: 'Pending', color: AppTheme.accentPrimary),
          _StatItem(
              count: inProgress, label: 'Active', color: AppTheme.infoBlue),
          _StatItem(
              count: completed, label: 'Done', color: AppTheme.successGreen),
          _StatItem(
              count: failed, label: 'Failed', color: AppTheme.errorRed),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'My Deliveries',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredDeliveries.length} total',
                  style: const TextStyle(
                    color: AppTheme.accentPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_isLoading) _buildStatsBar(),
        SearchBarWidget(
          controller: _searchController,
          onChanged: _onSearch,
          onFilterTap: _openFilters,
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.accentPrimary),
                )
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _filteredDeliveries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              color: cs.onSurfaceVariant, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No deliveries found',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDeliveries,
                      color: AppTheme.accentPrimary,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _filteredDeliveries.length,
                        itemBuilder: (context, index) {
                          final delivery = _filteredDeliveries[index];
                          return DeliveryCard(
                            delivery: delivery,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/delivery-details',
                                arguments: delivery,
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
