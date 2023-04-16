import 'dart:developer';
import 'package:file_selector/file_selector.dart';
import 'package:finalpdf/widgets/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syc;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../screen/secscreen.dart';

class EncryptHeader extends StatelessWidget {
  const EncryptHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 80, 20, 0),
      child: Column(children: const <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Protection Page",
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
        )
      ]),
    );
  }
}

class EncryptPage extends StatefulWidget {
  const EncryptPage({super.key});

  @override
  State<EncryptPage> createState() => _EncryptPageState();
}

class _EncryptPageState extends State<EncryptPage> {
  bool _isGranted = true;
  // final filename = FilePicker.platform.pickFiles();
  FilePickerResult? filename;
  String? filee;
  final myController = TextEditingController();
  //text controller

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future<Directory?> get getAppDir async {
    final appDocDir = await getExternalStorageDirectory();
    return appDocDir;
  }

  Future<Directory> get getExternalVisibleDir async {
    if (await Directory('/storage/emulated/0/Downloads').exists()) {
      final externalDir = Directory('/storage/emulated/0/Downloads');
      return externalDir;
    } else {
      await Directory('/storage/emulated/0/Downloads').create(recursive: true);
      final externalDir = Directory('/storage/emulated/0/Downloads');
      return externalDir;
    }
  }

  requestStoragePErmission() async {
    if (!await Permission.storage.isGranted) {
      PermissionStatus result = await Permission.storage.request();
      if (result.isGranted) {
        setState(() {
          _isGranted = true;
        });
      } else {
        _isGranted = false;
      }
    }
  }

  //This function is for saving the encrypted document
  static Future<File> saveEncrypt(
      {required String fileName, required syc.PdfDocument document}) async {
    final appDirectory = await getExternalStorageDirectory();
    log(appDirectory.toString());
    String? fileS = fileName.split("/").last;
    //get file path to append to the file
    final File file = File("/storage/emulated/0/Download/$fileS");
    File(file.path).writeAsBytes(await document.save());
    document.dispose();
    log(file.toString());

    return file;
  }

  static Future<File> saveDecrypt(
      {required String fileName, required syc.PdfDocument document}) async {
    final appDirectory = await getExternalStorageDirectory();
    log(appDirectory.toString());
    String? fileS = fileName.split("/").last;
    //get file path to append to the file
    final File file = File("/storage/emulated/0/Download/$fileS");
    File(file.path).writeAsBytes(await document.save());
    document.dispose();
    log(file.toString());

    return file;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    requestStoragePErmission();
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 8;
    final double itemWidth = size.width / 1;
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.count(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: (itemWidth / itemHeight),
            children: [
              InkWell(
                onTap: () async {
                  try {
                    FilePickerResult? pickFile = await FilePicker.platform
                    //file picker
                        .pickFiles(
                            allowedExtensions: ['pdf'],
                            withData: true,
                            allowCompression: true,
                            allowMultiple: false,
                            type: FileType.custom);
                    if (pickFile != null) {
                      //if file is picked, syc to import syncfusion library
                      final File file = File(pickFile.files.first.path!);
                      final syc.PdfDocument document = syc.PdfDocument(
                          inputBytes: File(file.path).readAsBytesSync());
                      log(document.toString());
                      final PdfSecurity security = document.security;

                      //Set password.
                      security.userPassword = 'userpassword@123';
                      security.ownerPassword = 'ownerpassword@123';

                      //setting permissions
                      security.permissions.addAll(<PdfPermissionsFlags>[
                        PdfPermissionsFlags.print,
                        PdfPermissionsFlags.editAnnotations
                      ]);

                      //Set AES encryption algorithm.
                      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;

                      File ourNewFile = await saveEncrypt(
                          fileName: file.path, document: document);
                      log(ourNewFile.toString());
                      encryptFile(pickFile.files);
                    }
                  } catch (e) {
                    log(e.toString());
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const <Widget>[
                      Text(
                        "ENCRYPT",
                        style: TextStyle(
                            // color: txtColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.lock,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  try {
                    FilePickerResult? pickFile = await FilePicker.platform
                    //pick file
                        .pickFiles(
                            allowedExtensions: ['pdf'],
                            withData: true,
                            allowCompression: true,
                            allowMultiple: false,
                            type: FileType.custom);
                    if (pickFile != null) {
                      //if file is picked, syc to import syncfusion library
                      final File file = File(pickFile.files.first.path!);
                      final syc.PdfDocument document = syc.PdfDocument(
                          inputBytes: File(file.path).readAsBytesSync(),
                          password: 'userpassword@123');
                          //remove password
                      log(document.toString());
                      final PdfSecurity security = document.security;

                      //remove password.
                      document.security.userPassword = '';
                      document.security.ownerPassword = '';

                      //setting permissions
                      security.permissions.addAll(<PdfPermissionsFlags>[
                        PdfPermissionsFlags.editContent,
                        PdfPermissionsFlags.copyContent,
                        PdfPermissionsFlags.editAnnotations,
                        PdfPermissionsFlags.fillFields,
                        PdfPermissionsFlags.assembleDocument,
                        PdfPermissionsFlags.print,
                        PdfPermissionsFlags.accessibilityCopyContent,
                        PdfPermissionsFlags.assembleDocument,
                        PdfPermissionsFlags.fullQualityPrint
                      ]);
                      File ourNewFile = await saveDecrypt(
                          fileName: file.path, document: document);
                          //call decrypt function
                      log(ourNewFile.toString());
                      decryptFile(pickFile.files);
                      //second page
                    }
                  } catch (e) {
                    log(e.toString());
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const <Widget>[
                      Text(
                        "DECRYPT",
                        style: TextStyle(
                            // color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.lock_open_outlined,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  try {
                    FilePickerResult? pickFile = await FilePicker.platform
                    //file picker
                        .pickFiles(
                            allowedExtensions: ['pdf'],
                            withData: true,
                            allowCompression: true,
                            allowMultiple: false,
                            type: FileType.custom);
                    if (pickFile != null) {
                      //if file is picked, syc to import syncfusion library
                      final File file = File(pickFile.files.first.path!);
                      final String filo = file.path;
                      passwordFiles(pickFile.files, filo);
                      //call function
                    }
                  } catch (e) {
                    log(e.toString());
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const <Widget>[
                      Text(
                        "PASSWORD",
                        style: TextStyle(
                            // color: txtColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.password,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void encryptFile(List<PlatformFile> files) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EncryptSec(
        files: files,
        onOpenedFile: encryptFiles,
        //push to second page
      ),
    ));
  }

  void encryptFiles(PlatformFile file) {
    OpenFile.open(file.path);
  }

  void decryptFile(List<PlatformFile> files) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DecryptSec(
        files: files,
        onOpenedFile: decryptFiles,
        //push to second page
      ),
    ));
  }

  void decryptFiles(PlatformFile file) {
    OpenFile.open(file.path);
  }

  void passwordFiles(List<PlatformFile> files, String filo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PasswordSec(
        files: files,
        filee: filo,
        onOpenedFile: passwordFile,
        //push to second page
      ),
    ));
  }

  void passwordFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
}

