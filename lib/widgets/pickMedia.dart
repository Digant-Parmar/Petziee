// @dart=2.9
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';


   openFileExplorer({bool multiPick = false, FileType pickingType = FileType.any}) async {
    String _filename;
    List<PlatformFile> _paths;
    String _directoryPath;
    String _extension;
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: pickingType,
        allowMultiple: multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null,
        allowCompression: true,

      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    // _filename = _paths != null ? _paths.map((e) => e.name).toString() : '...';
     return _paths;

  }


