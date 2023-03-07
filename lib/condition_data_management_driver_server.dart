import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart'; // debugPrint f.e. but probably also for Platform detection - don't remember now.

// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'condition_configuration.dart';
import 'condition_data_managging.dart';
import 'condition_storage_drag_and_drop_box.dart';

import 'condition_data_management_driver_sql_settings.dart';
import 'condition_data_management_driver_sql.dart';
import 'condition_data_management_driver_server_settings.dart';

// for education purposes this is native platform not web file
// so we will not import web:    if (dart.library.html) 'condition_data_management_driver_sql.web.dart'; // especially for web (!now indexedDB) localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later
class ConditionDataManagementDriverServer
    extends ConditionDataManagementDriver {
  late final ConditionDataManagementDriverServerSettings http_server_settings;

  /// this is past to the constructor if it is set up this [ConditionDataManagementDriverServer] object is a local server, because it will synchronize all it's own data with the global server [_synchronizing_global_server_driver] you passed to the constructor.
  late final ConditionDataManagementDriverServer?
      _synchronizing_global_server_driver;

  /// convenience property - if [_synchronizing_global_server_driver] was past to the main constructor - it is not a global server driver - it is a local server which has it's own global server which it needs to synchronize all local server data with.
  late final bool _is_global_server_driver;

  /// update prefix can be used to have 2 or more databases in one phisical db!!! Prefix is only in development mode for simulating backend data storage and loading, see the [_prefix] property desc, see method [getNewDefaultDriver] code for backend driver
  ConditionDataManagementDriverServer(
      {Completer<ConditionDataManagementDriver>? initCompleter,
      required ConditionDataManagementDriverServerSettings http_server_settings,
      ConditionDataManagementDriverServer? synchronizing_global_server_driver})
      : super(
          initCompleter: initCompleter,
          dbNamePrefix: http_server_settings.db_name_prefix,
          tableNamePrefix: http_server_settings.table_name_prefix,
        ) {
    this._synchronizing_global_server_driver =
        synchronizing_global_server_driver;
    this._is_global_server_driver =
        null == synchronizing_global_server_driver ? true : false;
    this.http_server_settings =
        ConditionDataManagementDriverServerSettings.getDefaultSettings(
            null == synchronizing_global_server_driver ? true : false);

    _initStorage();
  }

  @override
  static Future<ConditionDataManagementDriverServer> createDriver(
      {ConditionDataManagementDriverServer? synchronizing_global_server_driver,
      required ConditionDataManagementDriverServerSettings
          http_server_settings}) {
    Completer<ConditionDataManagementDriverServer> initCompleter =
        new Completer();

    ConditionDataManagementDriverServer(
      initCompleter: initCompleter,
      http_server_settings: http_server_settings,
      synchronizing_global_server_driver: synchronizing_global_server_driver,
    );
    return initCompleter.future;
  }

  @override
  void _initStorage() {
    // READ ! init_completer and table prefixes are in this. - compare with ConditionDataManagementDriver and ConditionDataManagementDriverHive

    debugPrint('initStorage 1');
    //debugPrint('initStorage 1' + prefix);

    /*Hive.init('./'); //-> not needed in browser
    Hive.openBox(prefix).then((box) {
      debugPrint('initStorage2');
      _box = box;
      debugPrint(box.toString());
      debugPrint('initStorage2');
      init_completer.complete(this);
    });*/
  }

  /// more in the description on [_synchronizing_global_server_driver] property (is it exposed in the documentation?)
  bool get is_global_server_driver {
    return this._is_global_server_driver;
  }

  /// more in the description on [_synchronizing_global_server_driver] property (is it exposed in the documentation?)
  bool get is_local_server_driver {
    return !this._is_global_server_driver;
  }
}

///!!! You don't need this, there is a built in http server capability in dart-native
class ShelfTesting {
  static void main_shelf() async {
    print('main_shelf we are here 1');
    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(ShelfTesting.echoRequest);
    print('main_shelf we are here 2');

    var server = await shelf_io.serve(handler, 'localhost', 8080);
    print('main_shelf we are here 3');

    // Enable content compression
    server.autoCompress = true;

    print('Serving at http://${server.address.host}:${server.port}');
  }

  static Response echoRequest(Request request) =>
      Response.ok('Request for "${request.url}"');
}
