import 'package:flutter/material.dart';
import 'location_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(Icons.work_rounded, size: 96, color: cs.onPrimary),
              const SizedBox(height: 24),
              Text('JobFinder',
                  style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                      letterSpacing: -1)),
              const SizedBox(height: 12),
              Text(
                'Find jobs near you, build your resume,\nand apply — all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: cs.onPrimary.withOpacity(0.85),
                    height: 1.5),
              ),
              const Spacer(),
              const _FeatureRow(
                  icon: Icons.location_on_rounded,
                  text: 'Search by neighborhood or zip code'),
              const SizedBox(height: 16),
              const _FeatureRow(
                  icon: Icons.description_rounded,
                  text: 'Upload or build a resume in minutes'),
              const SizedBox(height: 16),
              const _FeatureRow(
                  icon: Icons.send_rounded,
                  text: 'Apply to multiple places at once'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.onPrimary,
                    foregroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const LocationScreen())),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.onPrimary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: cs.onPrimary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: cs.onPrimary.withOpacity(0.9), fontSize: 15)),
        ),
      ],
    );
  }
}