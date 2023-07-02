import 'dart:async';
import 'dart:ffi';
import 'package:sqlite3/sqlite3.dart';
import 'condition_configuration.dart';
import 'condition_data_management_driver_sql_settings.dart';

class Sqlite3DB {
  Sqlite3DB() {
    // now windows only
  }

  static Future<dynamic> getDBObject(dynamic settings_sqlite3) {
    if (settings_sqlite3 == null ||
        settings_sqlite3 is! ConditionDataManagementDriverSqlSettingsSqlite3?) {
      throw Exception(
          '[Sqlite3DB] native platform version class exception: settings_sqlite3 is! ConditionDataManagementDriverSqlSettingsSqlite3?');
    }
    Completer<dynamic> completer = Completer<dynamic>();
    scheduleMicrotask(() {
      DynamicLibrary.open(ConditionConfiguration
          .paths_to_sqlite_core_library[ConditionPlatforms.Windows]);
      dynamic db = sqlite3.open(settings_sqlite3!
          .native_platform_sqlite3_db_paths[ConditionPlatforms.Windows]!);
      completer.complete(db);
    });
    return completer.future;
  }

  static Future<String>? httpGetFileContents(String path) {
    return null;
  }
}
