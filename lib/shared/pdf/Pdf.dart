import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<File> generateDoc(List<dynamic> args) async {

  final RootIsolateToken rootIsolateToken = args[3] as RootIsolateToken;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  final fontData = args[4];
  var customFont = pw.Font.ttf(fontData);

  final pw.Document pdf = pw.Document();


  String title = args[0];
  String content = args[1];
  List<dynamic> imagePaths = args[2];

  pdf.addPage(pw.MultiPage(
    maxPages: 50,
      build: (context) => [
            pw.Paragraph(
                text: title,
                style: pw.TextStyle(
                    fontSize: 30.0,
                    letterSpacing: 0.6,
                    fontWeight: pw.FontWeight.bold,
                    font: customFont
                )),
            pw.SizedBox(
              height: 20.0,
            ),
            pw.Paragraph(
                text: content,
                style: pw.TextStyle(
                    fontSize: 22.0,
                    letterSpacing: 0.6,
                    height: 2.2,
                    fontWeight: pw.FontWeight.bold,
                    font: customFont
                )),
            pw.SizedBox(
              height: 40.0,
            ),
            if (imagePaths.isNotEmpty) ...[
              pw.Wrap(
                direction: pw.Axis.horizontal,
                children: imagePaths
                    .map((imagePath) => buildItemImage(imagePath['image']))
                    .toList(),
                spacing: 80.0, // Spacing between images
                runSpacing: 30.0, // Spacing between rows
              ),
            ],
          ]));

  return saveDocument(name: '${args[1]}_Note.pdf', pdf: pdf);
}


pw.Widget buildItemImage(String imagePath) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(
        width: 1.0,
        color: PdfColors.blueGrey,
      ),
    ),
    child: pw.Image(
      pw.MemoryImage((File(imagePath).readAsBytesSync()).buffer.asUint8List()),
      width: 200,
      height: 300.0,
      fit: pw.BoxFit.contain,
    ),
  );
}


Future<File> saveDocument({
  required String name,
  required pw.Document pdf,
}) async {
  final bytes = await pdf.save();

  final Directory dir = await getApplicationDocumentsDirectory();
  final File file = File('${dir.path}/$name');

  await file.writeAsBytes(bytes);

  return file;
}


Future openFile(File file) async {
  final String path = file.path;

  await OpenFilex.open(path);
}

