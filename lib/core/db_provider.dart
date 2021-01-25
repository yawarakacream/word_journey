import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class SqliteDatabaseProvider {
  static final dictionariesVersion = 1;
  final String pathToDBFile;

  Database _database;
  Database get connection {
    if (_database == null) {
      throw Exception("not initialized");
    }
    return _database;
  }

  SqliteDatabaseProvider(pathToDBFile) : this.pathToDBFile = joinAll(pathToDBFile);

  Future<void> open({var forceUpdate = false}) async {
    if (isOpen) {
      throw new UnsupportedError('_database is already opened');
    }

    var path = join(await getDatabasesPath(), pathToDBFile);

    await _updateDatabase(path, forceUpdate: forceUpdate);

    _database = await openDatabase(path, readOnly: true);
  }

  void close() async {
    if (!isOpen) {
      throw UnsupportedError('_database is not open');
    }
    await _database.close();
  }

  Future<void> _updateDatabase(var path, {forceUpdate = false}) async {
    var exists = await databaseExists(path);

    if (!forceUpdate && exists) {
      await deleteDatabase(path);
      var database = await openDatabase(path, readOnly: true);
      var version = await database
          .rawQuery("SELECT version FROM information")
          .then((value) => value[0]["version"]);
      if (dictionariesVersion == version) {
        return;
      }
    }

    if (exists) {
      await deleteDatabase(path);
    }

    await Directory(dirname(path)).create(recursive: true);

    ByteData data = await rootBundle.load(pathToDBFile);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(path).writeAsBytes(bytes, flush: true);
  }

  bool get isOpen => _database != null && _database.isOpen;
}
