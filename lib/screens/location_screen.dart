import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'experience_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _controller = TextEditingController();
  double _radius = 5.0;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Please enter a city, neighborhood, or zip code.');
      return;
    }
    context.read<AppState>().setLocation(text, _radius);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ExperienceScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Where are you looking?')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your location',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'We\'ll search for businesses within your chosen distance. '
              'Your exact location is never stored or shared.',
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.6), height: 1.5),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'e.g.  Chicago, IL  or  60601',
                prefixIcon: const Icon(Icons.location_city_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Search radius',
                    style: Theme.of(context).textTheme.titleMedium),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_radius.round()} mile${_radius.round() == 1 ? '' : 's'}',
                    style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Slider(
              value: _radius,
              min: 1,
              max: 25,
              divisions: 24,
              label: '${_radius.round()} mi',
              onChanged: (v) => setState(() => _radius = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 mile',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.5),
                        fontSize: 12)),
                Text('25 miles',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.5),
                        fontSize: 12)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _next,
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}