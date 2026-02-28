import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/places_service.dart';
import 'results_screen.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  final List<String> _jobTypes =
      PlacesService.jobTypeToPlaceTypes.keys.toList();
  final Set<String> _selected = {};
  String _experience = 'No experience';
  final _skillsController = TextEditingController();
  bool _loading = false;
  String? _error;

  final List<String> _levels = [
    'No experience',
    '1–2 years',
    '3–5 years',
    '5+ years',
  ];

  @override
  void dispose() {
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Please select at least one job type.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final state = context.read<AppState>();
    state.setExperience(
        _selected.toList(), _experience, _skillsController.text.trim());

    final coords = await PlacesService.geocodeAddress(state.location);
    if (coords == null) {
      setState(() {
        _loading = false;
        _error =
            'Could not find "${state.location}". Please check the spelling and try again.';
      });
      return;
    }

    state.setCoordinates(coords['lat']!, coords['lng']!);

    final results = await PlacesService.searchNearbyBusinesses(
      lat: coords['lat']!,
      lng: coords['lng']!,
      radiusMiles: state.searchRadius,
      selectedJobTypes: _selected.toList(),
    );

    state.setSearchResults(results);

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ResultsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Your Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What kind of work are you looking for?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _jobTypes.map((type) {
                final selected = _selected.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selected.remove(type);
                      } else {
                        _selected.add(type);
                      }
                      _error = null;
                    });
                  },
                );
              }).toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: cs.error, fontSize: 13)),
            ],
            const SizedBox(height: 28),
            Text('Experience level',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _experience,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: _levels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _experience = v!),
            ),
            const SizedBox(height: 24),
            Text('Skills (optional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _skillsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'e.g. customer service, cash handling, Excel...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _search,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search_rounded),
                label: Text(_loading ? 'Searching...' : 'Find Jobs',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}