import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/delivery.dart';
import '../services/verification_service.dart';

class AddressVerificationScreen extends StatefulWidget {
  const AddressVerificationScreen({super.key});

  @override
  State<AddressVerificationScreen> createState() =>
      _AddressVerificationScreenState();
}

class _AddressVerificationScreenState extends State<AddressVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _addressController = TextEditingController();
  bool _isVerifying = false;
  String _currentStep = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delivery =
        ModalRoute.of(context)?.settings.arguments as Delivery?;
    if (delivery != null && _addressController.text.isEmpty) {
      _addressController.text = delivery.rawAddress;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _verifyAddress() async {
    if (_addressController.text.trim().isEmpty) return;

    setState(() {
      _isVerifying = true;
      _currentStep = 'Normalizing address...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _currentStep = 'Detecting entities...');

      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _currentStep = 'Computing confidence score...');

      final result = await VerificationService.verifyAddress(
        _addressController.text.trim(),
      );

      setState(() => _currentStep = 'Verification complete!');
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/verification-result',
          arguments: result,
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _currentStep = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Address')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentAmber.withValues(alpha: 0.12),
                    AppTheme.accentOrange.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.pin_drop_outlined, color: AppTheme.accentAmber, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Address Verification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter a delivery address to verify and normalize it',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Address input
            Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              enabled: !_isVerifying,
              style: TextStyle(color: cs.onSurface, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'e.g., 12 Rue Didouche Mourad, Alger Centre, Alger',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_on_outlined, color: cs.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Verification pipeline
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                children: [
                  _ProcessStep(
                    icon: Icons.text_fields,
                    label: 'Normalization',
                    description: 'Standardize address formatting',
                    isActive: _currentStep.contains('Normalizing'),
                    isDone: _currentStep.contains('Detecting') ||
                        _currentStep.contains('Computing') ||
                        _currentStep.contains('complete'),
                  ),
                  Divider(height: 1, color: cs.outline),
                  _ProcessStep(
                    icon: Icons.account_tree_outlined,
                    label: 'Entity Detection',
                    description: 'Extract wilaya, commune, street, postal code',
                    isActive: _currentStep.contains('Detecting'),
                    isDone: _currentStep.contains('Computing') ||
                        _currentStep.contains('complete'),
                  ),
                  Divider(height: 1, color: cs.outline),
                  _ProcessStep(
                    icon: Icons.score_outlined,
                    label: 'Confidence Scoring',
                    description: 'Compute address match confidence',
                    isActive: _currentStep.contains('Computing'),
                    isDone: _currentStep.contains('complete'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isVerifying ? null : _verifyAddress,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppTheme.primaryDark,
                        ),
                      )
                    : const Icon(Icons.verified_outlined, size: 22),
                label: Text(_isVerifying ? 'Verifying...' : 'Verify Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isActive;
  final bool isDone;

  const _ProcessStep({
    required this.icon,
    required this.label,
    required this.description,
    this.isActive = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color iconColor = cs.onSurfaceVariant;
    if (isDone) iconColor = AppTheme.successGreen;
    if (isActive) iconColor = AppTheme.accentAmber;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDone ? Icons.check_circle : icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isActive || isDone ? cs.onSurface : cs.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isActive)
            const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.accentAmber,
              ),
            ),
        ],
      ),
    );
  }
}
