import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:finalpdf/widgets/constant.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:path_provider/path_provider.dart';

class ConvertPage extends StatelessWidget {
  const ConvertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 80, 20, 40),
      child: Column(
        children: const <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Convert Page ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // color: headerColor,
                fontSize: 30,
              ),
            ),
          ),
          Divider(
            color: lineColor,
            height: 50,
            thickness: 2,
          ),
        ],
      ),
    );
  }
}

class Conv extends StatefulWidget {
  ConvertImage createState() => ConvertImage();
}

class ConvertImage extends State<Conv> {
  // const ConvertImage({super.key});
  final picker = ImagePicker();
  final pdf = pw.Document();
  File? _image;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      alignment: Alignment.center,
      // width: 160,
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 160,
            // child: Image.asset('images/sett.png'),
            child: _image == null
                ? Image.asset('images/sett.png')
                : Image.file(
                    File(_image!.path),
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(
            child: Text(
              'Oops There are no converted files',
              textAlign: TextAlign.center,
              textWidthBasis: TextWidthBasis.parent,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 15,
                color: upperText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Con extends StatefulWidget {
  ConvertFile createState() => ConvertFile();
}

class ConvertFile extends State<Con> {
//   // const ConvertFile({super.key});
  final picker = ImagePicker();
  //image picker
  final pdf = pw.Document();
  late File _image;
  PlatformFile? files;

  getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        //if image was picked
        _image = File(pickedFile.path);
      } else {
        log('no image selected');
      }
    });
  }

  createPDF() async {
    //convert image to bytes
    final image = pw.MemoryImage(_image.readAsBytesSync());
    final bits = _image.readAsBytesSync().lengthInBytes;
    // files = PlatformFile( name: 'image', size: 2);
    pdf.addPage(pw.Page(
      //create pdf file
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context contex) {
          return pw.Center(child: pw.Image(image));
          //write bytes to file
        }));
  }

  savePDF() async {
    try {
      String? fileS = _image.path.split("/").last;
      String? fileSec = fileS.split(".").first;
      //get image name for save
      final dir = await getExternalStorageDirectory();
      final file = File('/storage/emulated/0/Download/$fileSec.pdf');
      //write as bytes to file
      await file.writeAsBytes(await pdf.save());
      log(file.toString());
      showPrintedMessage('Sucess', 'Saved to $file');
    } catch (e) {
      log('hey');
      log(e.toString());
    }
  }

  showPrintedMessage(String title, String msg) {
    //printed message
    Flushbar(
            title: title,
            message: msg,
            duration: const Duration(seconds: 5),
            flushbarPosition: FlushbarPosition.TOP,
            icon: const Icon(Icons.info, color: primaryColor))
        .show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      alignment: Alignment.center,
      // width: 200,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Divider(
              color: lineColor,
              height: 10,
              thickness: 2,
            ),
            SizedBox(
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    // foregroundColor: txtColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(280, 70),
                  ),
                  icon: const Text(
                    'Select Image File  ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  label: const Icon(Icons.insert_drive_file_outlined),
                  onPressed: () {
                    //call get function
                    getImageFromGallery();
                  } //Backend
                  ),
            ),
            SizedBox(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  // foregroundColor: txtColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(280, 70),
                ),
                icon: const Text(
                  'Convert File  ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                label: const Icon(Icons.file_open_outlined),
                onPressed: () {
                  //call function
                  createPDF();
                  savePDF();
                }, //Backend
              ),
            ),
          ]),
    );
  }
}

class ImagePage extends StatefulWidget {
  final List<PlatformFile> files;
  // final bits;
  final ValueChanged<PlatformFile> onOpenedFile;
  const ImagePage(
      {Key? key,
      required this.files,
      // required this.bits,
      required this.onOpenedFile})
      : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Image to PDF page',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: primaryColor,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.navigate_before),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Center(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: widget.files.length,
            itemBuilder: (context, index) {
              final file = widget.files[index];
              return buildFile(file);
            },
          ),
        ),
        bottomNavigationBar: SizedBox(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: const RoundedRectangleBorder(),
              minimumSize: const Size(220, 80),
            ),
            child: const Text(
              'Convert to PDF',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              showPrintedMessage(String title, String msg) {
                Flushbar(
                        title: title,
                        message: msg,
                        duration: const Duration(seconds: 2),
                        flushbarPosition: FlushbarPosition.TOP,
                        icon: const Icon(Icons.info, color: primaryColor))
                    .show(context);
              }
              showPrintedMessage('Pdf file created Successfully', 'Saved to Download Folder');
              // Future <File> help(Platform file) async{
              //   final appStorage = File('/storage/emulated/0/Download/');
              //   final newFile = File('${appStorage.path}/${file}');
              //   PdfTextExtractor extractor = PdfTextExtractor(newFile);
              //   return newFile;
              //  }
            },
          ),
        ),
      );

  Widget buildFile(PlatformFile file) {
    // ConvertFile();
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    final extension = file.extension ?? 'none';
    const color = primaryColor;

    return InkWell(
      onTap: () => widget.onOpenedFile(file),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '.$extension',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              file.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              fileSize,
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}

