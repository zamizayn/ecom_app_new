import 'package:flutter/material.dart';

/// 3-step checkout progress indicator.
class CheckoutStepper extends StatelessWidget {
  final int step; // 1 = Address, 2 = Summary, 3 = Success

  const CheckoutStepper({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Step(label: 'Address', index: 1, currentStep: step, primary: primary),
          _Connector(active: step >= 2, primary: primary),
          _Step(label: 'Summary', index: 2, currentStep: step, primary: primary),
          _Connector(active: step >= 3, primary: primary),
          _Step(label: 'Done', index: 3, currentStep: step, primary: primary),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final int index;
  final int currentStep;
  final Color primary;

  const _Step({
    required this.label,
    required this.index,
    required this.currentStep,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final done = currentStep > index;
    final active = currentStep == index;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (done || active) ? primary : Colors.grey[200],
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.white : Colors.grey[500],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: (done || active) ? primary : Colors.grey[400],
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool active;
  final Color primary;
  const _Connector({required this.active, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: active ? primary : Colors.grey[200],
    );
  }
}

/// Full-width continue/action button bar pinned at the bottom.
class CheckoutContinueBar extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback? onTap;

  const CheckoutContinueBar({
    super.key,
    required this.enabled,
    this.label = 'Continue',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
