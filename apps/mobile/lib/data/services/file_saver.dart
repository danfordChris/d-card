import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Writes files the user asked for (e.g. "Download my data") to app storage. Fakes in tests.
abstract interface class FileSaver {
  /// Saves [bytes] as [fileName] and returns the full path.
  Future<String> save(String fileName, List<int> bytes);
}

/// The app's documents folder (visible in the Files app on iOS, app storage on Android).
class DocumentsFileSaver implements FileSaver {
  const DocumentsFileSaver();

  @override
  Future<String> save(String fileName, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
