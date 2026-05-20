import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../l10n/app_strings.dart';
import '../models/announcement.dart';

class AnnouncementShareService {
  String _plainTextFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      List<dynamic>? ops;
      if (decoded is List) {
        ops = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final raw = decoded['ops'] ?? decoded['delta'];
        if (raw is List) ops = raw;
      } else if (decoded is Map) {
        final raw = decoded['ops'] ?? decoded['delta'];
        if (raw is List) ops = raw;
      }
      if (ops != null && ops.isNotEmpty) {
        final doc = Document.fromJson(
          List<Map<String, dynamic>>.from(
            ops.map((e) => Map<String, dynamic>.from(e as Map)),
          ),
        );
        return doc.toPlainText().trim();
      }
    } catch (e) {
      debugPrint('AnnouncementShareService: body parse failed: $e');
    }
    return body.trim();
  }

  String buildShareText(AnnouncementModel a, AppStrings s) {
    final dateFmt = DateFormat.yMMMd().add_jm();
    final title = a.type.displayLabel(s, a.customTag);
    final text = _plainTextFromBody(a.body);
    return '${s.appName}\n'
        '$title\n'
        '${dateFmt.format(a.createdAt)}\n\n'
        '$text';
  }

  Future<void> shareAsText(AnnouncementModel a, AppStrings s) async {
    final result = await Share.share(
      buildShareText(a, s),
      subject: a.type.displayLabel(s, a.customTag),
    );
    if (result.status == ShareResultStatus.unavailable) {
      throw StateError('share_unavailable');
    }
  }

  Future<void> shareAsPdf(AnnouncementModel a, AppStrings s) async {
    final pdf = pw.Document();
    final title = a.type.displayLabel(s, a.customTag);
    final dateFmt = DateFormat.yMMMd().add_jm();
    final body = _plainTextFromBody(a.body);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              s.appName,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(dateFmt.format(a.createdAt)),
          pw.SizedBox(height: 16),
          pw.Text(body),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/barangayboard_${a.id}.pdf');
    await file.writeAsBytes(bytes);
    final result = await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      text: title,
      subject: '$title — ${s.appName}',
    );
    if (result.status == ShareResultStatus.unavailable) {
      throw StateError('share_unavailable');
    }
  }
}
