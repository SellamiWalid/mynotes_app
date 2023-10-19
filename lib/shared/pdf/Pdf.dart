import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class Pdf {

   static Future<File> generate({
     required String title,
     required String content,
     required String imagePath,
}) async {

     final pdf = Document();

     var customFont = Font.ttf(await rootBundle.load("assets/fonts/VarelaRound-Regular.ttf"));

     pdf.addPage(MultiPage(
         build: (context) => <Widget> [
           Paragraph(
               text: title,
               textAlign: TextAlign.center,
               style: TextStyle(
                   fontSize: 28.0,
                   letterSpacing: 0.6,
                   fontWeight: FontWeight.bold,
                   font: customFont)),
           SizedBox(
             height: 20.0,
           ),
           Paragraph(
               text: content,
               style: TextStyle(
                   fontSize: 20.0,
                   letterSpacing: 0.6,
                   height: 1.2,
                   fontWeight: FontWeight.bold,
                   font: customFont)),
           SizedBox(
             height: 60.0,
           ),
           // Create image
            if(imagePath != '')
              Center(
                child: Container(
                  width: 250.0,
                  height: 450.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                      color: PdfColors.grey,
                    )
                  ),
                  child: Image(
                    MemoryImage((File(imagePath).readAsBytesSync()).buffer.asUint8List()),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
         ]));


     return saveDocument(name: 'Notes_$title.pdf', pdf: pdf);

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