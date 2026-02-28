import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/resume_data.dart';

class ResumeService {
  static Future<String> generateResumePdf(ResumeData data) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text(data.fullName,
            style: pw.TextStyle(font: fontBold, fontSize: 24)),
        pw.SizedBox(height: 4),
        pw.Text('${data.email}  •  ${data.phone}  •  ${data.address}',
            style: pw.TextStyle(
                font: font, fontSize: 11, color: PdfColors.grey700)),
        pw.Divider(height: 20),

        if (data.summary.isNotEmpty) ...[
          _sectionHeader('Summary', fontBold),
          pw.Text(data.summary,
              style: pw.TextStyle(font: font, fontSize: 11)),
          pw.SizedBox(height: 12),
        ],

        if (data.workExperience.any((e) => e.company.isNotEmpty)) ...[
          _sectionHeader('Work Experience', fontBold),
          ...data.workExperience
              .where((e) => e.company.isNotEmpty)
              .map((e) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                          mainAxisAlignment:
                              pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(e.jobTitle,
                                style: pw.TextStyle(
                                    font: fontBold, fontSize: 12)),
                            pw.Text('${e.startDate} – ${e.endDate}',
                                style: pw.TextStyle(
                                    font: font,
                                    fontSize: 10,
                                    color: PdfColors.grey600)),
                          ]),
                      pw.Text(e.company,
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 11,
                              color: PdfColors.blueGrey700)),
                      if (e.description.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              top: 2, bottom: 8),
                          child: pw.Text(e.description,
                              style:
                                  pw.TextStyle(font: font, fontSize: 10)),
                        ),
                    ],
                  )),
          pw.SizedBox(height: 4),
        ],

        if (data.education.any((e) => e.school.isNotEmpty)) ...[
          _sectionHeader('Education', fontBold),
          ...data.education
              .where((e) => e.school.isNotEmpty)
              .map((e) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(e.degree,
                          style: pw.TextStyle(
                              font: fontBold, fontSize: 12)),
                      pw.Text(
                          '${e.school}  •  ${e.graduationYear}',
                          style:
                              pw.TextStyle(font: font, fontSize: 11)),
                      pw.SizedBox(height: 6),
                    ],
                  )),
        ],

        if (data.skills.isNotEmpty) ...[
          _sectionHeader('Skills', fontBold),
          pw.Wrap(
            spacing: 8,
            runSpacing: 4,
            children: data.skills
                .map((s) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(s,
                          style:
                              pw.TextStyle(font: font, fontSize: 10)),
                    ))
                .toList(),
          ),
        ],
      ],
    ));

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/resume_${data.fullName.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _sectionHeader(String title, pw.Font fontBold) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 13,
                  color: PdfColors.blue800)),
          pw.Divider(color: PdfColors.blue200, height: 8),
          pw.SizedBox(height: 4),
        ]);
  }
}