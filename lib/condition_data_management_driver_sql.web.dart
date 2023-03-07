/// READ WEBSQL (SQLITE (3 ?)) OFFICIALLY DEPRECIATED STANDARD IS USED
/// ("CAN I USE?" WEBPAGE 12.2022) AND THIS IS FOR NOW USED BY
/// (CHROME, CHROMIUM, EDGE, SAMSUNG AND SOME MORE USE THIS)
/// EXCEPT FOR SAFARI FOR IOS IT IS USED OR CAN BE BY DEFAULT USED BY "EVERYBODY"
/// (YOU CAN INSTALL CHROME FOR MAC OR IOS) - IT IS FIREFOX PROBLEM IT DOESN'T HAVE IT
/// BUT THERE IS OR IS GOINT TO BE PREPARED FOR MULTIBROWSER SUPPORT (STILL DEVELOPPING)
/// BY USING SQLWEB GITHUB LIBRARY WHICH USES JSSTORE GITHUB LIBRARY.
/// THOSE TWO WILL BE USED, SQLWEB WHEN WEBSQL IS NOT AVAILABLE FOR A BRWSER.

//https://pub.dev/documentation/sqlite3/latest/

//https://github.com/simolus3/sqlite3.dart/tree/main/sqlite3
//Make sure sqlite3 is available as a shared library in your environment (see supported platforms below).
//Import package:sqlite3/sqlite3.dart.
//Use sqlite3.open() to open a database file, or sqlite3.openInMemory() to open a temporary in-memory database.
//Use Database.execute or Database.prepare to execute statements directly or by prepar

//https://github.com/ujjwalguptaofficial/sqlweb/wiki - this one uses jsstore - it allows sql - sqlite3 cannot start so this plugin could be an alternative
import 'dart:async';
import 'condition_data_managging.dart';
import 'condition_custom_annotations.dart';
import 'condition_configuration.dart';

//import 'dart:indexed_db';
import 'package:http/http.dart' as http;
//import 'package:sqlite3/common.dart';
//import 'package:sqlite3/wasm.dart'; // !!! READ: here you can find info how to get sqlite3.wasm needed to work https://pub.dev/packages/sqflite_common_ffi
import 'condition_data_management_driver_sql_settings.dart';

/// See: [condition_data_management_driver_sql.dart] native implementation patterns, documentation there at:
/// Caution! [To do:] More sophisticated db integrity check on initiation, f.e. a ConditionModelClassess table must contain about 10 records (at the time of writing). An work out some rules not to perform integrity check each request or application start or whatever.
class ConditionDataManagementDriverSql extends ConditionDataManagementDriver
    implements
        ConditionDataManagementDriverSqlInitPatternsAndMatchesReplacementMethods {
  late final dynamic _db;
  final ConditionDataManagementDriverSqlSettings settings;

  /// To get to static propertis you will need to use runtimeType.property
  @override
  final ConditionDataManagementDriverSqlite3RegexPatterns patterns =
      ConditionDataManagementDriverSqlite3RegexPatternsSqlite3();

  /// To get to static propertis you will need to use runtimeType.property
  @override
  late final ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethods
      replacementMethods =
      ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethodsSqlite3(
          patterns, super.dbNamePrefix, super.tableNamePrefix);

  @override
  bool _initiated = false;

  ConditionDataManagementDriverSql({
    Completer<ConditionDataManagementDriver>? initCompleter,
    String? dbNamePrefix,
    String? tableNamePrefix,
    bool isGlobalDriver = false,
    bool hasGlobalDriver = false,
    ConditionDataManagementDriver? global_driver,
    ConditionDataManagementDriverSqlSettings? settings,
  })  : settings = settings ??
            ConditionDataManagementDriverSqlSettings.getDefaultSettings(
                // notice that super class also have this condition it probably won't be needed to change it
                !isGlobalDriver &&
                        (hasGlobalDriver == true ||
                            (hasGlobalDriver == false && global_driver != null))
                    ? false
                    : true),
        super(
            initCompleter:
                initCompleter, // ?? Completer(), // do we need this two tims? the optional assigning is already used in super class, isn't it?
            dbNamePrefix: dbNamePrefix,
            tableNamePrefix: tableNamePrefix,
            hasGlobalDriver: hasGlobalDriver,
            driverGlobal: global_driver) {
    //_initStorage();
  }
  static Future /*DatabaseImpl*/ getDbEngine() {
    print('abc');

    // Create a new in-memory database. To use a database backed by a file, you
    // can replace this with sqlite3.open(yourFilePath).
    //final db = sqlite3.openInMemory();
    return Future/*<DatabaseImpl>*/(() {
      return null;
      //return sqlite3.open('./condition_data_management_driver_sql.sqlite');
    });

    // Create a table and insert some data
    //db.execute('''
    //CREATE TABLE artists (
    //  id INTEGER NOT NULL PRIMARY KEY,
    //  name TEXT NOT NULL
    //);
    //''');
  }
}
