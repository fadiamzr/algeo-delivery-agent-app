import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/address_verification.dart';
import '../widgets/score_indicator.dart';
import '../widgets/risk_flag_chip.dart';

class VerificationResultScreen extends StatelessWidget {
  const VerificationResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final verification =
        ModalRoute.of(context)!.settings.arguments as AddressVerification;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.getScoreColor(verification.confidenceScore)
                        .withValues(alpha: 0.15),
                    cs.surfaceContainerHighest,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.getScoreColor(verification.confidenceScore)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  ScoreIndicator(score: verification.confidenceScore, size: 110),
                  const SizedBox(height: 16),
                  Text(
                    AppTheme.getScoreLabel(verification.confidenceScore),
                    style: TextStyle(
                      color: AppTheme.getScoreColor(verification.confidenceScore),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    verification.matchDetails,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Verified ${DateFormat('MMM d, yyyy • HH:mm').format(verification.createdAt)}',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Addresses
            _ResultSection(
              icon: Icons.location_on_outlined,
              title: 'Address Comparison',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AddressBlock(label: 'RAW INPUT', address: verification.rawAddress, isMuted: true),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: cs.outline,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: cs.surfaceContainerHighest,
                        child: const Icon(Icons.arrow_downward, color: AppTheme.accentAmber, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AddressBlock(label: 'NORMALIZED', address: verification.normalizedAddress, isMuted: false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detected Entities
            _ResultSection(
              icon: Icons.account_tree_outlined,
              title: 'Detected Entities',
              child: Column(
                children: [
                  if (verification.detectedEntities.wilaya != null)
                    _EntityTile(icon: Icons.map_outlined, label: 'Wilaya', value: verification.detectedEntities.wilaya!),
                  if (verification.detectedEntities.commune != null)
                    _EntityTile(icon: Icons.location_city_outlined, label: 'Commune', value: verification.detectedEntities.commune!),
                  if (verification.detectedEntities.postalCode != null)
                    _EntityTile(icon: Icons.markunread_mailbox_outlined, label: 'Postal Code', value: verification.detectedEntities.postalCode.toString()),
                  if (verification.detectedEntities.street != null)
                    _EntityTile(icon: Icons.signpost_outlined, label: 'Street', value: verification.detectedEntities.street!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Risk Flags
            if (verification.riskFlags.isNotEmpty)
              _ResultSection(
                icon: Icons.flag_outlined,
                title: 'Risk Flags (${verification.riskFlags.length})',
                child: Column(
                  children: verification.riskFlags.map((flag) => RiskFlagChip(flag: flag)).toList(),
                ),
              )
            else
              _ResultSection(
                icon: Icons.check_circle_outline,
                title: 'No Risk Flags',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: AppTheme.successGreen, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No risk flags detected. Address appears reliable.',
                          style: TextStyle(color: AppTheme.successGreen, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check, size: 22),
                label: const Text('Done'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _ResultSection({required this.icon, required this.title, required this.child});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final String label;
  final String address;
  final bool isMuted;
  const _AddressBlock({required this.label, required this.address, required this.isMuted});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isMuted ? cs.onSurfaceVariant : AppTheme.accentAmber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(address, style: TextStyle(color: isMuted ? cs.onSurfaceVariant : AppTheme.accentAmber, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _EntityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _EntityTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accentAmber, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              Text(value, style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
