import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class Pdf {

  Future<File> generate({
     required String title,
     required String content,
     required List<dynamic> imagePaths,
}) async {

     final pdf = Document();

     var customFont = Font.ttf(await rootBundle.load("assets/fonts/VarelaRound-Regular.ttf"));

     pdf.addPage(MultiPage(
         build: (context) => [
           Paragraph(
               text: title,
               style: TextStyle(
                   fontSize: 30.0,
                   letterSpacing: 0.6,
                   fontWeight: FontWeight.bold,
                   font: customFont)),
           SizedBox(
             height: 20.0,
           ),
           Paragraph(
               text: content,
               style: TextStyle(
                   fontSize: 22.0,
                   letterSpacing: 0.6,
                   height: 2.2,
                   fontWeight: FontWeight.bold,
                   font: customFont)),
           SizedBox(
             height: 40.0,
           ),
           if (imagePaths.isNotEmpty) ...[
             Wrap(
               direction: Axis.horizontal,
               children: imagePaths.map((imagePath) => buildItemImage(imagePath['image'])).toList(),
               spacing: 80.0, // Spacing between images
               runSpacing: 30.0, // Spacing between rows
             ),
           ],
         ]));


     return saveDocument(name: '${title}_Note.pdf', pdf: pdf);

   }


   Widget buildItemImage(String imagePath) {
     return Container(
       decoration: BoxDecoration(
         border: Border.all(
           width: 1.0,
           color: PdfColors.blueGrey,
         ),
       ),
       child: Image(
         MemoryImage((File(imagePath).readAsBytesSync()).buffer.asUint8List()),
         width: 200,
         height: 300.0,
         fit: BoxFit.contain,
       ),
     );
   }


   static Future<File> saveDocument({
     required String name,
     required Document pdf,
   }) async {
     final bytes = await pdf.save();

     final dir = await getApplicationDocumentsDirectory();
     final file = File('${dir.path}/$name');

     await file.writeAsBytes(bytes);

     return file;

   }


   static Future openFile(File file) async {
     final path = file.path;

     await OpenFilex.open(path);

   }


}