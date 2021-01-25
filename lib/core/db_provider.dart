import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class SqliteDatabaseProvider {
  static final bool needUpdate = true;

  final String pathToDBFile;

  Database _database;
  Database get connection {
    if (_database == null) {
      throw Exception("not initialized");
    }
    return _database;
  }

  SqliteDatabaseProvider(pathToDBFile) : this.pathToDBFile = joinAll(pathToDBFile);

  Future<void> open() async {
    if (isOpen) {
      throw new UnsupportedError('_database is already opened');
    }

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, pathToDBFile);

    var exists = await databaseExists(path);
    if (!exists || needUpdate) {
      if (exists) {
        await deleteDatabase(path);
      }

      await Directory(dirname(path)).create(recursive: true);

      ByteData data = await rootBundle.load(pathToDBFile);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    _database = await openDatabase(path, readOnly: true);
  }

  void close() async {
    if (!isOpen) {
      throw UnsupportedError('_database is not open');
    }
    await _database.close();
  }

  bool get isOpen => _database != null && _database.isOpen;
}
