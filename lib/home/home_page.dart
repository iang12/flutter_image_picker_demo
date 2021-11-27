import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;

  _imageFromCamera() async {
    _image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (_image != null) {
      setState(() {
        file = File(_image!.path);
      });
      saveInStorage(file!);
    }
  }

  _imageFromGallery() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      setState(() {
        file = File(_image!.path);
      });
      saveInStorage(file!);
    }
  }

  Future<void> _checkPermission() async {
    // storage permission ask
    var statusStorage = await Permission.storage.status;

    if (!statusStorage.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> saveInStorage(File file) async {
    await _checkPermission();
    var statusStorage = await Permission.storage.status;

    if (statusStorage.isGranted) {
      try {
        final Directory _appDocDir = await getApplicationDocumentsDirectory();

        final Directory _appDocDirFolder = Platform.isIOS
            ? Directory('${_appDocDir.path}/App_demo/Images Media')
            : Directory('/storage/emulated/0/App_demo/Images Media');

        String filePath;

        if (await _appDocDirFolder.exists()) {
          filePath = _appDocDirFolder.path;
        } else {
          final Directory _appDocDirNewFolder =
              await _appDocDirFolder.create(recursive: true);
          filePath = _appDocDirNewFolder.path;
        }

        var format = file.path.split('.').last;
        debugPrint(filePath);

        await file.copy('$filePath/${timestamp()}.$format');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Salvo com sucesso na pasta App_demo/Images Media',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint('Não tem permisssão para salvar o arquivo');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não tem permisssão para salvar o arquivo',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //function to let use choose what to use
  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher foto da galeria'),
                onTap: () {
                  _imageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Escolher foto da camera'),
                onTap: () {
                  _imageFromCamera();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'IMAGE PICKER EXAMPLE',
        ),
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(15.0),
          width: 300,
          height: 300,
          color: Colors.black26,
          child: file != null
              ? Image.file(
                  file!,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.camera_alt_outlined),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPicker(context);
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
