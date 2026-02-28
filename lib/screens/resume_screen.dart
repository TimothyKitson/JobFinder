import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/app_state.dart';
import 'resume_builder_screen.dart';
import 'preview_screen.dart';

class ResumeScreen extends StatelessWidget {
  const ResumeScreen({super.key});

  Future<void> _pickResume(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      dialogTitle: 'Select your resume',
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      // ignore: use_build_context_synchronously
      context.read<AppState>().setUploadedResume(path);
      // ignore: use_build_context_synchronously
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PreviewScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = context.watch<AppState>().selectedJobIds.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Resume')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Almost there!',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'You\'re applying to $count place${count == 1 ? '' : 's'}. '
              'Add your resume and we\'ll put your application together.',
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.65), height: 1.5),
            ),
            const SizedBox(height: 40),
            _OptionCard(
              icon: Icons.upload_file_rounded,
              title: 'Upload my resume',
              subtitle: 'PDF, DOC, or DOCX',
              color: cs.primaryContainer,
              iconColor: cs.primary,
              onTap: () => _pickResume(context),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.edit_document,
              title: 'Build a resume',
              subtitle:
                  'Answer a few questions and we\'ll create one for you',
              color: cs.secondaryContainer,
              iconColor: cs.secondary,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ResumeBuilderScreen())),
            ),
            const Spacer(),
            Row(children: [
              Icon(Icons.lock_outline_rounded,
                  size: 14, color: cs.onSurface.withOpacity(0.4)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your resume is only shared with businesses you choose.',
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.4), fontSize: 12),
                ),
              ),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.55))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}