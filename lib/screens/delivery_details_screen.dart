import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/delivery.dart';
import '../services/delivery_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/score_indicator.dart';
import '../widgets/risk_flag_chip.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  Delivery? _delivery;
  bool _isLoading = false;
  bool _hasRefreshed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_delivery == null) {
      _delivery = ModalRoute.of(context)!.settings.arguments as Delivery?;
    }
    if (!_hasRefreshed && _delivery != null) {
      _hasRefreshed = true;
      _refreshDelivery();
    }
  }

  Future<void> _refreshDelivery() async {
    if (_delivery == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await DeliveryService.getDeliveryById(_delivery!.id);
      if (updated != null && mounted) {
        setState(() {
          _delivery = updated;
        });
      }
    } catch (e) {
      // Ignore or show error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> openDirections(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open maps');
    }
  }

  Widget _buildMapSection(Delivery delivery) {
    final lat = delivery.addressVerification?.latitude;
    final lng = delivery.addressVerification?.longitude;

    final hasLocation = lat != null && lng != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, color: AppTheme.accentPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                "Map & Location",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// MAP CONTAINER
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasLocation
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat!, lng!),
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'dz.algeo.delivery.agent.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        "📍 Location not available — address could not be geocoded",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          /// RAW ADDRESS
          _InfoRow(label: 'Raw Address', value: delivery.rawAddress),

          /// NORMALIZED ADDRESS
          if (delivery.addressVerification?.normalizedAddress != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Normalized',
              value: delivery.addressVerification!.normalizedAddress,
              valueColor: AppTheme.accentPrimary,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_delivery == null) return const Scaffold();
    final delivery = _delivery!;
    final verification = delivery.addressVerification;
    final feedback = delivery.feedback;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(delivery.id),
        actions: [
          if (delivery.status != DeliveryStatus.completed)
            IconButton(
              icon: const Icon(Icons.feedback_outlined),
              tooltip: 'Submit Feedback',
              onPressed: () {
                Navigator.pushNamed(context, '/submit-feedback',
                    arguments: delivery);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Date card
            _SectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      StatusBadge(status: delivery.statusLabel, fontSize: 14),
                      if (verification != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                          ),
                          child: const Text('Verified', style: TextStyle(color: AppTheme.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  _isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          DateFormat('MMM d, yyyy • HH:mm')
                              .format(delivery.scheduledDate),
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Customer Info
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(icon: Icons.person_outline, title: 'Customer'),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Name', value: delivery.customerName),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Phone', value: delivery.customerPhone),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Address Info Map Section
            _buildMapSection(delivery),
            if (delivery.addressVerification?.latitude != null && delivery.addressVerification?.longitude != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final lat = delivery.addressVerification?.latitude;
                    final lng = delivery.addressVerification?.longitude;

                    if (lat != null && lng != null) {
                      openDirections(lat, lng);
                    }
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text("Directions"),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Verification Score
            if (verification != null) ...[
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                        icon: Icons.verified_outlined,
                        title: 'Verification Score'),
                    const SizedBox(height: 16),
                    Center(
                      child: ScoreIndicator(
                        score: verification.confidenceScore,
                        size: 90,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ScoreBar(score: verification.confidenceScore),
                    if (verification.matchDetails.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          verification.matchDetails,
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Detected Entities
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                        icon: Icons.account_tree_outlined,
                        title: 'Detected Entities'),
                    const SizedBox(height: 12),
                    if (verification.detectedEntities.wilaya != null)
                      _EntityRow(label: 'Wilaya', value: verification.detectedEntities.wilaya!),
                    if (verification.detectedEntities.commune != null)
                      _EntityRow(label: 'Commune', value: verification.detectedEntities.commune!),
                    if (verification.detectedEntities.postalCode != null)
                      _EntityRow(label: 'Postal Code', value: verification.detectedEntities.postalCode.toString()),
                    if (verification.detectedEntities.street != null)
                      _EntityRow(label: 'Street', value: verification.detectedEntities.street!),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Risk Flags
              if (verification.riskFlags.isNotEmpty) ...[
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        icon: Icons.flag_outlined,
                        title: 'Risk Flags (${verification.riskFlags.length})',
                      ),
                      const SizedBox(height: 12),
                      ...verification.riskFlags.map((flag) => RiskFlagChip(flag: flag)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],

            // Feedback
            if (feedback != null) ...[
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(icon: Icons.rate_review_outlined, title: 'Feedback'),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Outcome', value: feedback.outcomeLabel),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Notes', value: feedback.notes),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Submitted',
                      value: DateFormat('MMM d, yyyy • HH:mm').format(feedback.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            if (verification == null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/verify-address', arguments: delivery);
                    if (result == true) {
                      _refreshDelivery();
                    }
                  },
                  icon: const Icon(Icons.verified_outlined, size: 22),
                  label: const Text('Verify Address'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/verification-result', arguments: verification);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 22),
                  label: const Text('View Full Verification'),
                ),
              ),

            if (feedback == null && delivery.status != DeliveryStatus.completed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/submit-feedback', arguments: delivery);
                  },
                  icon: const Icon(Icons.feedback_outlined, size: 22),
                  label: const Text('Submit Feedback'),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentPrimary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? cs.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EntityRow extends StatelessWidget {
  final String label;
  final String value;
  const _EntityRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.accentPrimary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
