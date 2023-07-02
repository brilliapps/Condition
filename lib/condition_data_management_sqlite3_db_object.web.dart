import 'package:http/http.dart'
    as http; // originally imported here with 'package:sqlite3/wasm.dart' in mind
import 'package:sqlite3/wasm.dart';

class Sqlite3DB {
  Sqlite3DB() {
    // now windows only
  }

  static Future<dynamic> getDBObject(dynamic settings_sqlite3) async {
    if (settings_sqlite3 != null) {
      throw Exception(
          '[Sqlite3DB] web platform version class exception: settings_sqlite3 is! ConditionDataManagementDriverSqlSettingsSqlite3?');
    }
    final response = await http.get(Uri.parse('sqlite3.wasm'));

    // The [IndexedDbFileSystem] class is descentant of [VirtualFileSystem] which will be needed in a while
    IndexedDbFileSystem fs = await IndexedDbFileSystem.open(dbName: 'test');
    WasmSqlite3 wasmSqlite3Object = await WasmSqlite3.load(response.bodyBytes);

    // So here as a param wee need to pass the mentioned [VirtualFileSystem] object and [IndexedDbFileSystem] is descentant of the class [VirtualFileSystem]
    wasmSqlite3Object.registerVirtualFileSystem(fs);

    dynamic db = wasmSqlite3Object.open('testsname.sqlite3');

    return db;
  }

  static Future<String>? httpGetFileContents(String path) async {
    return http.read(Uri.parse(path));
  }
}
