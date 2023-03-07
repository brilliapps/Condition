import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart'; // debugPrint f.e. but probably also for Platform detection - don't remember now.
import 'condition_data_managging.dart';

import 'condition_custom_annotations.dart';
import 'condition_configuration.dart';

import 'condition_app_base.dart'; //empty informational and later etended class used by server and frontend/native/web
import 'condition_data_management_driver_sql.dart'
    if (dart.library.html) 'condition_data_management_driver_sql.web.dart'; // especially for web (!now indexedDB) localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later
import 'condition_data_management_driver_sql_settings.dart';

class ConditionDataManagementDriverServerFallback
    extends ConditionDataManagementDriver {
  /// this is a fully operational simulation of a server for any native and for web platforms
  /// update prefix can be used to have 2 or more databases in one phisical db !!! Prefix is only in development mode for simulating backend data storage and loading, see the [_prefix] property desc, see method [getNewDefaultDriver] code for backend driver
  ConditionDataManagementDriverServerFallback(
      {Completer<ConditionDataManagementDriver>? initCompleter,
      String db_name_prefix = '',
      String table_name_prefix = ''})
      : super(
          initCompleter: initCompleter ??
              Completer(), // super does this check ?? you don't need it here do you?
          dbNamePrefix: db_name_prefix,
          tableNamePrefix: table_name_prefix,
        ) {
    //ConditionConfiguration.

    //_initStorage(prefix, init_completer);
  }

  @override
  static Future<ConditionDataManagementDriverServerFallback> createDriver(
      {String db_name_prefix = '', String table_name_prefix = ''}) {
    Completer<ConditionDataManagementDriverServerFallback> initCompleter =
        new Completer();
    ConditionDataManagementDriverServerFallback(
        initCompleter: initCompleter,
        db_name_prefix: db_name_prefix,
        table_name_prefix: table_name_prefix);
    return initCompleter.future;
  }

  @override
  void _initStorage(String? prefix,
      [Completer<ConditionDataManagementDriver>? init_completer]) {
    if (prefix == null) prefix = '';
    debugPrint('initStorage 1');
    debugPrint('initStorage 1' + prefix);

    /*Hive.init('./'); //-> not needed in browser
    Hive.openBox(prefix).then((box) {
      debugPrint('initStorage2');
      _box = box;
      debugPrint(box.toString());
      debugPrint('initStorage2');
      init_completer.complete(this);
    });*/
  }
}
