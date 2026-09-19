import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/styles/AppColors.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<File> generateNotePdf(List<dynamic> args) async {

  final RootIsolateToken rootIsolateToken = args[0] as RootIsolateToken;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  final pdf = pw.Document();

  final String title = args[1];
  final String body = args[2];
  final List<File> imageFiles = args[3];
  final DateTime date = args[4];
  final fontRegular = pw.Font.ttf(args[5]);
  final fontBold = pw.Font.ttf(args[6]);

  final formattedDate = DateFormat('MMMM dd, yyyy • HH:mm').format(date);

  List<pw.MemoryImage> pdfImages = [];
  for (var file in imageFiles) {
    if (await file.exists()) {
      pdfImages.add(pw.MemoryImage(await file.readAsBytes()));
    }
  }

  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);

  final slate900 = PdfColor.fromHex('#0f172a');
  final slate800 = PdfColor.fromHex('#1e293b');
  final slate600 = PdfColor.fromHex('#475569');
  final slate500 = PdfColor.fromHex('#64748b');
  final slate200 = PdfColor.fromHex('#e2e8f0');
  final slate100 = PdfColor.fromHex('#f1f5f9');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      // Set global theme to override default Helvetica with Roboto
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
      ),
      build: (pw.Context context) {
        return [
          // Header Accent Line
          pw.Container(
            height: 4,
            width: double.infinity,
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue600,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
          ),
          pw.SizedBox(height: 16),

          // Title
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: slate900,
            ),
          ),
          pw.SizedBox(height: 4),

          // Date
          pw.Text(
            'Created on $formattedDate',
            style: pw.TextStyle(
              fontSize: 10,
              color: slate500,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Divider(color: slate200, thickness: 1),
          pw.SizedBox(height: 12),

          // Body Text
          ..._buildBodyWithLinks(body, urlRegex, slate800),

          // Attached Images Grid
          if (pdfImages.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text(
              'IMAGES (${pdfImages.length})',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: slate600,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pdfImages.map((img) {
                return pw.Container(
                  width: 167,
                  height: 167,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: slate200, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    color: PdfColors.grey50,
                  ),
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(
                      img,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ];
      },
      footer: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: slate100)),
          ),
          child: pw.Text(
            '${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: slate500),
          ),
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/Note_${DateTime.now().millisecondsSinceEpoch}.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}


List<pw.Widget> _buildBodyWithLinks(String text, RegExp urlRegex, PdfColor textColor) {
  List<pw.Widget> widgets = [];
  final lines = text.split('\n');

  for (var line in lines) {
    if (line.trim().isEmpty) {
      widgets.add(pw.SizedBox(height: 8));
      continue;
    }

    final matches = urlRegex.allMatches(line);
    if (matches.isEmpty) {
      widgets.add(
        pw.Text(
          line,
          style: pw.TextStyle(fontSize: 12, color: textColor, lineSpacing: 3),
        ),
      );
    } else {
      List<pw.Widget> lineSegments = [];
      int lastIndex = 0;

      for (var match in matches) {
        if (match.start > lastIndex) {
          lineSegments.add(
            pw.Text(
              line.substring(lastIndex, match.start),
              style: pw.TextStyle(fontSize: 12, color: textColor),
            ),
          );
        }

        final url = match.group(0)!;
        lineSegments.add(
          pw.UrlLink(
            destination: url,
            child: pw.Text(
              url,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.blue600,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
        );
        lastIndex = match.end;
      }

      if (lastIndex < line.length) {
        lineSegments.add(
          pw.Text(
            line.substring(lastIndex),
            style: pw.TextStyle(fontSize: 12, color: textColor),
          ),
        );
      }

      widgets.add(
        pw.Wrap(
          crossAxisAlignment: pw.WrapCrossAlignment.center,
          children: lineSegments,
        ),
      );
    }
  }

  return widgets;
}


Future<void> openPdfFile(File file, bool isDarkTheme, BuildContext context) async {
  if (!await file.exists()) {
    print('File does not exist at path: ${file.path}');
    snackBar(
        context: context,
        title: 'File does not exist at path: ${file.path}',
        isDarkTheme: isDarkTheme,
        bgColor: AppColors.redColor,
    );
    return;
  }

  // Opens native viewer
  final OpenResult result = await OpenFilex.open(file.path);

  if (result.type != ResultType.done) {
    // ResultType.noAppHandler: No app installed on device that can open PDFs
    // ResultType.permissionDenied: Storage permission issue on older Android versions
    print('Failed to open file: ${result.message} (Type: ${result.type})');
    snackBar(
        context: context,
        title: 'Failed to open file: ${result.message} (Type: ${result.type})',
        isDarkTheme: isDarkTheme,
        bgColor: AppColors.redColor,
    );
  }
}