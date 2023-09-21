import 'dart:async';
import 'package:flutter/foundation.dart' show protected;
import 'package:collection/collection.dart';

import 'dart:ffi';
import 'package:sqlite3/sqlite3.dart';
import 'condition_configuration.dart';
//import 'condition_data_management_driver_sql_settings.dart';
//import 'condition_data_management_driver_sql.dart';
import 'condition_data_managging.dart';

//import 'condition_data_management_driver_SQLDBCommonRawDriverSqlite3CompatibilityInterface.dart';

/// [To do: at the time of writing only windows sqlite3 library could be loaded and windows tested db file name] This class is an implementation of native version of the [ConditionRawSQLDBDriverWrapperCommon] interface.
class ConditionRawSQLDBDriverWrapperSqlite3
    extends ConditionRawSQLDBDriverWrapperSqlite3Base {
  ConditionRawSQLDBDriverWrapperSqlite3(
    super.dbSettings,
  ) {
    // now windows only
    //if (dbSettings == null ||
    //    dbSettings is! ConditionDataManagementDriverSqlSettingsSqlite3?) {
    //  throw Exception(
    //      '[Sqlite3DB] native platform version class exception: settings_sqlite3 is! ConditionDataManagementDriverSqlSettingsSqlite3?');
    //}

    scheduleMicrotask(() {
      DynamicLibrary.open(ConditionConfiguration
          .paths_to_sqlite_core_library[ConditionPlatforms.Windows]);
      db = sqlite3.open(
          (dbSettings as ConditionDataManagementDriverSqlSettingsSqlite3)
              .dbPath);
      initCompleter.complete(this);
    });
  }

  @override
  Future<String>? httpGetFileContents(String path) {
    return null;
  }

  @override
  bool operator ==(Object other) => super == other;

  @override
  int get hashCode => super.hashCode;
}
