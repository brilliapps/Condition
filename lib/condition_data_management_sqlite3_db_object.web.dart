import 'dart:async';
import 'package:http/http.dart'
    as http; // originally imported here with 'package:sqlite3/wasm.dart' in mind
import 'package:sqlite3/wasm.dart';
//import 'condition_data_management_driver_SQLDBCommonRawDriverSqlite3CompatibilityInterface.dart';
//import 'condition_data_management_driver_sql_settings.dart';
import 'condition_configuration.dart';
import 'condition_data_managging.dart';

/// Web version of the native class with the same name - loaded optionally if the platform is not native but web
class ConditionRawSQLDBDriverWrapperSqlite3
    extends ConditionRawSQLDBDriverWrapperSqlite3Base {
  /// This stores information whether or not the triver has already been inited and ready to work with, returns [this] object itself
  @override
  final Completer<ConditionRawSQLDBDriverWrapperCommon> initCompleter =
      Completer<ConditionRawSQLDBDriverWrapperCommon>();

  ConditionRawSQLDBDriverWrapperSqlite3(
    super.dbSettings,
  ) {
    // -==== WARNING!!! =================-
    // IN CASE IT HAS NOT BEEN DONE YET:
    // As you can see for web the settings are ignored and it could change
    // and take care in case of changes it is compatible with native platform version of the class
    // but also update the workings of == operator and hashcode method.
    // Probably wrapper classes won't be used massively so hashcode won't be used
    // probably then just take care for the == operator to work precisely
    // -==== end of the warning :) ======-
    scheduleMicrotask(() async {
      final response = await http.get(Uri.parse('sqlite3.wasm'));

      // The [IndexedDbFileSystem] class is descentant of [VirtualFileSystem] which will be needed in a while
      IndexedDbFileSystem fs = await IndexedDbFileSystem.open(dbName: 'test');
      WasmSqlite3 wasmSqlite3Object =
          await WasmSqlite3.load(response.bodyBytes);

      // So here as a param wee need to pass the mentioned [VirtualFileSystem] object and [IndexedDbFileSystem] is descentant of the class [VirtualFileSystem]
      wasmSqlite3Object.registerVirtualFileSystem(fs);

      db = wasmSqlite3Object.open('testsname.sqlite3');
      initCompleter.complete(this);
    });
  }

  @override
  Future<String>? httpGetFileContents(String path) async {
    return http.read(Uri.parse(path));
  }

  @override
  bool operator ==(Object other) => super == other;

  @override
  int get hashCode => super.hashCode;
}
