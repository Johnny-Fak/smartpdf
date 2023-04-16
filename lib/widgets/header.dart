import 'dart:convert';
import 'dart:developer';
import 'package:finalpdf/widgets/constant.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syc;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pages/screen/secscreen.dart';

class SmartPDF extends StatelessWidget {
  const SmartPDF({super.key});

  @override
  Widget build(BuildContext context) {
    // double c_width = MediaQuery.of(context).size.width*0.3;
    return Container(
      // width: c_width,
      margin: const EdgeInsets.fromLTRB(30, 80, 30, 40),
      child: Row(
        //main axis alignment space between to seperate cells, similar to css flex 
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text(
                        "Smart ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: domTxtColor,
                            fontSize: 24),
                      ),
                      Text(
                        "PDF",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: domTxtColor,
                            fontSize: 24),
                      ),
                      Text(
                        "Converter",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: domTxtColor,
                            fontSize: 24),
                      ),
                      Text(
                        'The ultimate PDF to text tool for you device',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: false,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: upperText,
                            fontSize: 14),
                      )
                    ],
                    //
                  ),
                )
              ],
            ),
          ),
          SizedBox(
              width: 160, child: Image.asset("images/Scene Wireframe.png")),
        ],
      ),
    );
  }
}

class Oofs extends StatelessWidget {
  const Oofs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      alignment: Alignment.center,
      width: 160,
      child: Column(
        children: <Widget>[
          SizedBox(
            child: Image.asset('images/Asset 100.png'),
          ),
          const SizedBox(
              child: Text(
            'Oops There are no converted files',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w300, fontSize: 15, color: upperText),
          )),
        ],
      ),
    );
  }
}

class Buton extends StatefulWidget {
  const Buton({super.key});

  @override
  State<Buton> createState() => _ButonState();
}

class _ButonState extends State<Buton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      // width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  // foregroundColor: txtColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(220, 80),
                ),
                child: const Text(
                  'PDF to TXT',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  try {
                    //file picker to pick files located in phone storage
                    FilePickerResult? pickFile = await FilePicker.platform
                        .pickFiles(
                            allowedExtensions: ['pdf'],
                            withData: true,
                            allowCompression: true,
                            allowMultiple: false,
                            type: FileType.custom);
                    //if file is picked successfully
                    if (pickFile != null) {
                      //get file path
                      final File file = File(pickFile.files.first.path!);
                      //shorten pdf calling
                      final pdf = pw.Document(verbose: true, compress: false);
                      //read picked file as bytes using syncfusion
                      final syc.PdfDocument document = syc.PdfDocument(
                          inputBytes: File(file.path).readAsBytesSync());
                      //convert bytes to text
                      String texts = PdfTextExtractor(document).extractText();
                      log(texts.toString());
                      //write text to file in a format
                      pdf.addPage(pw.Page(
                          build: (context) =>
                              pw.Text(texts)));
                      //save file function
                      File ourNewFile =
                          await saveDocuments(fileName: file.path, text: texts);
                      log(ourNewFile.toString());
                      //link to second page
                      openFiles(pickFile.files);
                    }
                  } catch (e) {
                    //error checking
                    log(e.toString());
                  }
                }
                ),
          ),
          SizedBox(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  // padding: const EdgeInsets.all(20),
                  // foregroundColor: txtColor,
                  minimumSize: const Size(220, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'TXT to PDF',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  try {
                    //file picker to pick files located in phone storage
                    FilePickerResult? pickFile = await FilePicker.platform
                        .pickFiles(
                            allowedExtensions: ['txt', 'doc', 'docx', 'rtf'],
                            withData: true,
                            allowCompression: true,
                            allowMultiple: false,
                            type: FileType.custom);
                    //if file is picked successfully
                    if (pickFile != null) {
                      //get file path
                      final File file = File(pickFile.files.first.path!);
                      //shorten txt calling
                      final pdf = pw.Document(verbose: true, compress: false);
                      pdf.addPage(pw.Page(
                          build: (context) =>
                              pw.Text(file.readAsStringSync(encoding: utf8))));

                      File ourNewFile =
                          await saveDocument(fileName: file.path, thePdf: pdf);
                      log(ourNewFile.toString());
                      openTxt(pickFile.files);
                      // return file;
                    }
                  } catch (e) {
                    log(e.toString());
                  }
                }),
          ),
        ],
      ),
    );
  }

  void openFiles(List<PlatformFile> files) {
    //function to push file to second page when open file is called
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PdfT(
        files: files,
        onOpenedFile: openFile,
      ),
    ));
  }

  void openFile(PlatformFile file) {
    //open file path
    OpenFile.open(file.path);
  }

  void openTxt(List<PlatformFile> files) {
    //function to push file to second page when open txts is called
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PdfTT(
        files: files,
        onOpenedFile: openTxts,
      ),
    ));
  }

  void openTxts(PlatformFile file) {
    //open file path
    OpenFile.open(file.path);
  }

  static Future<File> saveDocument(
    //save file
      {required String fileName, required pw.Document thePdf}) async {
    final Uint8List bytes = await thePdf.save();

    final appDirectory = await getExternalStorageDirectory();
    String? fileS = fileName.split("/").last;
    String? fileSec = fileS.split(".").first;
    //upper two lines are to get only the filename from the path
    log(appDirectory.toString());
    final File file = File("/storage/emulated/0/Download/$fileSec.pdf");
    await file.writeAsBytes(bytes, flush: true, mode: FileMode.write);
    //write to the saved file
    return file;
  }

  static Future<File> saveDocuments(
    //save file
      {required String fileName, required String text}) async {
    // final Uint8List bytes = await thePdf.save();
    String? fileS = fileName.split("/").last;
    String? fileSec = fileS.split(".").first;
    //upper two lines are to get only the filename from the path
    final appDirectory = await getExternalStorageDirectory();
    log(appDirectory.toString());

    final File file = File("/storage/emulated/0/Download/$fileSec.txt");
    file.writeAsString(text, flush: true, mode: FileMode.write);
    //write to the saved file
    log(fileS);
    log(file.toString());

    return file;
  }
}
