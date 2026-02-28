import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/job_listing.dart';
import '../services/places_service.dart';
import 'resume_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final Set<String> _detailsFetched = {};

  Future<void> _fetchDetails(AppState state, JobListing job) async {
    if (_detailsFetched.contains(job.id)) return;
    _detailsFetched.add(job.id);
    final details = await PlacesService.getPlaceDetails(job.id);
    state.updateJobDetails(job.id, details['phone'], details['website']);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final jobs = state.searchResults;

    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs near ${state.location}'),
        actions: [
          if (state.selectedJobIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.selectedJobIds.length} selected',
                    style: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 64,
                      color: cs.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No businesses found nearby.',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.6),
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Try a larger radius or different job types.',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.4),
                          fontSize: 13)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16,
                          color: cs.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 6),
                      Text(
                        '${jobs.length} businesses found  •  tap to select',
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.5),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: jobs.length,
                    itemBuilder: (ctx, i) {
                      final job = jobs[i];
                      _fetchDetails(state, job);
                      return _JobCard(job: job);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: state.selectedJobIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ResumeScreen())),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                  'Apply to ${state.selectedJobIds.length} place${state.selectedJobIds.length == 1 ? '' : 's'}'),
            )
          : null,
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobListing job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final selected = state.isJobSelected(job.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => state.toggleJobSelection(job.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : Colors.transparent,
                    border: Border.all(
                        color: selected
                            ? cs.primary
                            : cs.outline.withOpacity(0.5),
                        width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded,
                          color: cs.onPrimary, size: 16)
                      : null,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(job.businessType ?? 'Business',
                            style: TextStyle(
                                fontSize: 11,
                                color: cs.onSecondaryContainer)),
                      ),
                      const SizedBox(width: 8),
                      if (job.rating != null)
                        Row(children: [
                          Icon(Icons.star_rounded,
                              size: 14,
                              color: Colors.amber.shade600),
                          const SizedBox(width: 2),
                          Text(job.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12)),
                        ]),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.location_on_rounded,
                          size: 14,
                          color: cs.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(job.address,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withOpacity(0.6)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                        '${job.distance.toStringAsFixed(1)} mile${job.distance == 1 ? '' : 's'} away',
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.primary,
                            fontWeight: FontWeight.w500)),
                    if (job.phoneNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.phone_rounded,
                            size: 13,
                            color: cs.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(job.phoneNumber!,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withOpacity(0.6))),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}