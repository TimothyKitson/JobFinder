import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/resume_data.dart';
import 'preview_screen.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skillsController = TextEditingController();
  late final TextEditingController _jobTitle, _company, _startDate,
      _endDate, _jobDesc;
  late final TextEditingController _degree, _school, _gradYear;
  late final TextEditingController _name, _email, _phone, _address,
      _summary;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _address = TextEditingController();
    _summary = TextEditingController();
    _jobTitle = TextEditingController();
    _company = TextEditingController();
    _startDate = TextEditingController();
    _endDate = TextEditingController(text: 'Present');
    _jobDesc = TextEditingController();
    _degree = TextEditingController();
    _school = TextEditingController();
    _gradYear = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      _name, _email, _phone, _address, _summary,
      _jobTitle, _company, _startDate, _endDate, _jobDesc,
      _degree, _school, _gradYear, _skillsController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final resume = ResumeData(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      summary: _summary.text.trim(),
      workExperience: [
        WorkExperience(
          jobTitle: _jobTitle.text.trim(),
          company: _company.text.trim(),
          startDate: _startDate.text.trim(),
          endDate: _endDate.text.trim(),
          description: _jobDesc.text.trim(),
        ),
      ],
      education: [
        Education(
          degree: _degree.text.trim(),
          school: _school.text.trim(),
          graduationYear: _gradYear.text.trim(),
        ),
      ],
      skills: skills,
    );

    context.read<AppState>().setResumeData(resume);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const PreviewScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Build Your Resume')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _Section(
              title: 'Personal Information',
              icon: Icons.person_rounded,
              children: [
                _Field(controller: _name, label: 'Full Name', required: true),
                _Field(controller: _email, label: 'Email Address',
                    required: true, keyboardType: TextInputType.emailAddress),
                _Field(controller: _phone, label: 'Phone Number',
                    required: true, keyboardType: TextInputType.phone),
                _Field(controller: _address, label: 'City, State'),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Professional Summary',
              icon: Icons.format_quote_rounded,
              children: [
                _Field(controller: _summary,
                    label: 'Brief summary about yourself', maxLines: 4,
                    hint: 'e.g. Motivated and hardworking individual seeking entry-level opportunities...'),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Work Experience',
              icon: Icons.work_rounded,
              subtitle: 'Most recent job (leave blank if none)',
              children: [
                _Field(controller: _jobTitle, label: 'Job Title'),
                _Field(controller: _company, label: 'Company / Employer'),
                Row(children: [
                  Expanded(child: _Field(
                      controller: _startDate, label: 'Start (e.g. Jan 2022)')),
                  const SizedBox(width: 12),
                  Expanded(child: _Field(controller: _endDate, label: 'End')),
                ]),
                _Field(controller: _jobDesc, label: 'What did you do?',
                    maxLines: 3,
                    hint: 'e.g. Served customers, handled cash register...'),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Education',
              icon: Icons.school_rounded,
              subtitle: 'Most recent school',
              children: [
                _Field(controller: _degree, label: 'Degree / Diploma',
                    hint: 'e.g. High School Diploma, Associate\'s Degree'),
                _Field(controller: _school, label: 'School Name'),
                _Field(controller: _gradYear, label: 'Graduation Year',
                    keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Skills',
              icon: Icons.star_rounded,
              children: [
                TextFormField(
                  controller: _skillsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Skills (comma-separated)',
                    hintText: 'e.g. Customer service, Microsoft Office, Bilingual (Spanish)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _save,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Build Resume & Preview Application',
                  style: TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: cs.primary)),
        ]),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!,
              style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.5))),
        ],
        const SizedBox(height: 12),
        ...children.map((c) =>
            Padding(padding: const EdgeInsets.only(bottom: 12), child: c)),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool required;
  final int maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }
}