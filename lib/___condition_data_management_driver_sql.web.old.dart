//https://pub.dev/documentation/sqlite3/latest/

//https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3
//Make sure sqlite3 is available as a shared library in your environment (see supported platforms below).
//Import package:sqlite3/sqlite3.dart.
//Use sqlite3.open() to open a database file, or sqlite3.openInMemory() to open a temporary in-memory database.
//Use Database.execute or Database.prepare to execute statements directly or by prepar

//https://github.com/ujjwalguptaofficial/sqlweb/wiki - this one uses jsstore - it allows sql - sqlite3 cannot start so this plugin could be an alternative
import 'dart:async';
import 'condition_data_managging.dart';

//import 'dart:indexed_db';
import 'package:http/http.dart' as http;
import 'package:sqlite3/common.dart';
import 'package:sqlite3/wasm.dart'; // !!! READ: here you can find info how to get sqlite3.wasm needed to work https://pub.dev/packages/sqflite_common_ffi

class ConditionDataManagementDriverSqllite3
    extends ConditionDataManagementDriver {
  ConditionDataManagementDriverSqllite3(
      {initCompleter, dbNamePrefix = '', tableNamePrefix = ''})
      : super(
            initCompleter: initCompleter,
            dbNamePrefix: dbNamePrefix,
            tableNamePrefix: tableNamePrefix) {}

  //https://pub.dev/documentation/sqlite3/latest/
  static dynamic getDbEngine() async {
    final response = await http.get(Uri.parse('sqlite3.wasm'));
    final fs = await IndexedDbFileSystem.open(
        dbName:
            'test' /*'condition_data_management_driver_sql_dot_web_dot_dart'*/);

    dynamic db = await WasmSqlite3.load(
        response.bodyBytes, SqliteEnvironment(fileSystem: fs));

    print(response.runtimeType.toString());
    print(response.toString());
    print(response.bodyBytes.toString());

    print(db.runtimeType.toString());

    db.execute('''
      CREATE TABLE artists (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL
        ''');

    return db;
  }
  // Create a table and insert some data
  //db.execute('''
  //CREATE TABLE artists (
  //  id INTEGER NOT NULL PRIMARY KEY,
  //  name TEXT NOT NULL
  //);
  //''');
}
