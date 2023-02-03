import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> saveImageFileFromApiResponseToTemp(
    {required List<int> fileData}) async {
  final tempDir = await getTemporaryDirectory();
  final filePath = "${tempDir.path}/tempFile.png";
  File imageFile = await File(filePath).writeAsBytes(fileData);
  XFile file = XFile.fromData(imageFile.readAsBytesSync(), path: filePath);
  return file.path;
}
