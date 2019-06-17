import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<File> _getFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';
    final file = File(path);
    final entityType = await FileSystemEntity.type(path);
    if (entityType == FileSystemEntityType.notFound) {
      await file.writeAsString("");
    }
    return file;
  }

  Future<String> getContent(String filename) async {
    final file = await _getFile(filename);
    final content = await file.readAsString();
    return content;
  }

  Future<bool> writeContent(String filename, String content) async {
    final file = await _getFile(filename);
    try {
      await file.writeAsString(content);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

final fileStorage = FileStorage();