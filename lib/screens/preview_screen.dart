import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';
import '../models/job_listing.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _sent = false;

  Future<void> _sendViaEmail(AppState state, JobListing job) async {
    final resume = state.resumeData;
    final name =
        resume.fullName.isNotEmpty ? resume.fullName : 'Applicant';
    final subject = Uri.encodeComponent('Job Application from $name');
    final body = Uri.encodeComponent(_buildEmailBody(state, job));
    final uri = Uri.parse('mailto:?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app.')),
        );
      }
    }
  }

  Future<void> _callBusiness(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWebsite(String website) async {
    final uri = Uri.parse(
        website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _buildEmailBody(AppState state, JobListing job) {
    final r = state.resumeData;
    final skills =
        r.skills.isNotEmpty ? r.skills.join(', ') : state.skills;
    return '''Hello,

I am writing to express my interest in any open positions at ${job.name}.

Name: ${r.fullName.isNotEmpty ? r.fullName : '[Your Name]'}
Email: ${r.email.isNotEmpty ? r.email : '[Your Email]'}
Phone: ${r.phone.isNotEmpty ? r.phone : '[Your Phone]'}
${r.address.isNotEmpty ? 'Location: ${r.address}' : ''}
Experience Level: ${state.experienceLevel}
${skills.isNotEmpty ? 'Skills: $skills' : ''}

${r.summary.isNotEmpty ? r.summary : ''}

${r.workExperience.where((e) => e.company.isNotEmpty).map((e) => '${e.jobTitle} at ${e.company} (${e.startDate} – ${e.endDate})\n${e.description}').join('\n\n')}

${r.education.where((e) => e.school.isNotEmpty).map((e) => '${e.degree} — ${e.school} (${e.graduationYear})').join('\n')}

Thank you for your time and consideration.

${r.fullName.isNotEmpty ? r.fullName : '[Your Name]'}''';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final jobs = state.selectedJobs;
    final resume = state.resumeData;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Your Application')),
      body: _sent
          ? _SentConfirmation(
              onDone: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: cs.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.person_rounded, color: cs.primary),
                          const SizedBox(width: 8),
                          Text('Your Info',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                  fontSize: 16)),
                        ]),
                        const SizedBox(height: 12),
                        if (state.resumeUploaded)
                          const _InfoRow(
                              icon: Icons.attach_file_rounded,
                              text: 'Resume uploaded ✓')
                        else ...[
                          if (resume.fullName.isNotEmpty)
                            _InfoRow(
                                icon: Icons.badge_rounded,
                                text: resume.fullName),
                          if (resume.email.isNotEmpty)
                            _InfoRow(
                                icon: Icons.email_rounded,
                                text: resume.email),
                          if (resume.phone.isNotEmpty)
                            _InfoRow(
                                icon: Icons.phone_rounded,
                                text: resume.phone),
                          _InfoRow(
                              icon: Icons.work_history_rounded,
                              text:
                                  'Experience: ${state.experienceLevel}'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                    'Applying to ${jobs.length} place${jobs.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'Choose how to reach each employer. '
                  'Your email app will open so you can review before sending.',
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.55),
                      fontSize: 13,
                      height: 1.4),
                ),
                const SizedBox(height: 12),
                ...jobs.map((job) => _JobApplicationCard(
                      job: job,
                      onEmail: () => _sendViaEmail(state, job),
                      onCall: job.phoneNumber != null
                          ? () => _callBusiness(job.phoneNumber!)
                          : null,
                      onWebsite: job.website != null
                          ? () => _openWebsite(job.website!)
                          : null,
                    )),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _sent = true),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('I\'m done applying',
                      style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _JobApplicationCard extends StatelessWidget {
  final JobListing job;
  final VoidCallback onEmail;
  final VoidCallback? onCall;
  final VoidCallback? onWebsite;

  const _JobApplicationCard({
    required this.job,
    required this.onEmail,
    this.onCall,
    this.onWebsite,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            Text(job.address,
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.55))),
            const SizedBox(height: 12),
            Text('Send your application via:',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionChip(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    onTap: onEmail,
                    primary: true),
                if (onCall != null)
                  _ActionChip(
                      icon: Icons.phone_rounded,
                      label: job.phoneNumber ?? 'Call',
                      onTap: onCall!),
                if (onWebsite != null)
                  _ActionChip(
                      icon: Icons.open_in_browser_rounded,
                      label: 'Website',
                      onTap: onWebsite!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primary ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: primary ? cs.onPrimary : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: primary
                        ? cs.onPrimary
                        : cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}

class _SentConfirmation extends StatelessWidget {
  final VoidCallback onDone;
  const _SentConfirmation({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 96, color: cs.primary),
            const SizedBox(height: 24),
            Text('Applications Sent!',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Good luck! Keep an eye on your email and phone for responses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.6), height: 1.5),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Find More Jobs',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}