import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:async/async.dart' show FutureGroup;
//import 'dart:ffi';
import 'dart:io';
import 'condition_data_managging.dart';

import 'condition_custom_annotations.dart';
import 'condition_configuration.dart';
import 'condition_data_management_driver_sql_settings.dart';

import 'condition_data_management_sqlite3_db_object.dart'
    if (dart.library.html) 'condition_data_management_sqlite3_db_object.web.dart';

/// This class almost should be made abstract, but it is contstructed in a way to work by default out of the box if not extended using sqlite3 engines, settings, and classess, which is for the app (or system) a default option, while it works on a sqlite3 file database not internet connection. Such an option for an easy start for new developers.
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

  //@override
  //bool inited = false;

  ConditionDataManagementDriverSql({
    Completer<ConditionDataManagementDriver>? initCompleter,
    String? dbNamePrefix,
    String? tableNamePrefix,
    bool isGlobalDriver = false,
    bool hasGlobalDriver = false,
    ConditionDataManagementDriver? driverGlobal,
    Completer<ConditionDataManagementDriver>? initCompleterGlobal,
    ConditionDataManagementDriverSqlSettings? settings,
    ConditionModelApp? conditionModelApp,
  })  : settings = settings ??
            ConditionDataManagementDriverSqlSettings.getDefaultSettings(
                // edit it is simpler: old version text: notice that super class also have this condition it probably won't be needed to change it
                // !(!
                isGlobalDriver
                    // &&
                    //       (hasGlobalDriver == true ||
                    //           (hasGlobalDriver == false && driverGlobal != null)))
                    ? true
                    : false),
        super(
            conditionModelApp: conditionModelApp,
            initCompleter:
                initCompleter, // ?? Completer(), // do we need this two tims? the optional assigning is already used in super class, isn't it?
            dbNamePrefix: dbNamePrefix,
            tableNamePrefix: tableNamePrefix,
            hasGlobalDriver: hasGlobalDriver,
            driverGlobal: driverGlobal,
            initCompleterGlobal: initCompleterGlobal) {
    debugPrint(
        'We are in the constructor of the ConditionDataManagementDriverSql');
    _initStorage();
  }

  @override
  void _initStorage() {
    debugPrint('1We are here aren\'t we?');
    // ! Take note that this code is based on synchronous nature of the pub.dev sqlite3 package
    // To not to block the main layout thread more sophisticated
    // implementation based on isolates should be implemented (the best)
    // for now it is achieved in limited scope using asynchronous scheduleMicrotask()
    scheduleMicrotask(() async {
      try {
        // to do you better make it all const (cannot now)
        // as not confusing any developers pattern for extending the class [settings] property is not of the extending [ConditionDataManagementDriverSqlSettingsSqlite3] class
        // but in the constructor [ConditionDataManagementDriverSqlSettingsSqlite3] object is passed which is allowed as it extends the type allowed for the [settings] property
        // so that it is fully available it must be [settings] must be cast into the [ConditionDataManagementDriverSqlSettingsSqlite3]
        ConditionDataManagementDriverSqlSettingsSqlite3 settings_sqlite3 =
            (settings as ConditionDataManagementDriverSqlSettingsSqlite3);

        //dbNamePrefix use for opening an sqlite3, i think db the file name stands for db name here
        //again you will need some regex string replace for that ./*/*/file.sqlite or .sqlite3 - whatever
        //the outcome would be '.../${dbNamePrefixfile}.sqlite'
        //this is also needed: tableNamePrefix,
        //work out for this: condition_full_db_init.sql a regex replaceAll or something to replace table names to those with prefixex

        //enum: ConditionPlatforms

        debugPrint('Checking out some paths');
        debugPrint(ConditionConfiguration
            .paths_to_sqlite_core_library[ConditionPlatforms.Windows]
            .toString());
        debugPrint(settings_sqlite3
            .native_platform_sqlite3_db_paths[ConditionPlatforms.Windows]
            .toString());

        if (!ConditionConfiguration.isWeb && Platform.isWindows) {
          _db = await Sqlite3DB.getDBObject(settings_sqlite3);

          // now windows only
          //DynamicLibrary.open(ConditionConfiguration
          //    .paths_to_sqlite_core_library[ConditionPlatforms.Windows]);
          //_db = sqlite3.open(settings_sqlite3
          //    .native_platform_sqlite3_db_paths[ConditionPlatforms.Windows]!);
        } else if (ConditionConfiguration.isWeb) {
          _db = await Sqlite3DB.getDBObject(null);
        } else {
          throw UnimplementedError(
              'Not implemented native platform settings for slite3 db. Only windows supported now');
        }
        // a method local variable not to confuse with [inited] this private property
        bool isAppDbinited = true;
        try {
          debugPrint(
              'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;');
          // In this case We can only fully rely on exception thrown when a table doesn't exist
          dynamic select_is_debinited = _db.select('''
          SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;
        ''');
          // when table exists this one will always return result of type int from 0 to more than 0
          debugPrint(
              'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;' +
                  select_is_debinited[0]['count(*)'].toString());
        } catch (e) {
          debugPrint(
              'table doesn\'t exist, so no relevant table with initial data exists');
          isAppDbinited = false;
        }

        if (!isAppDbinited) {
          // HERE WHAT IS TO BE USED, SEE DEFNINITIONS OF THE CLASSES
          //ConditionDataManagementDriverSqlite3RegexPatterns patterns
          //ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethods replacementMethods

          try {
            String contents = '';
            if (!ConditionConfiguration.isWeb && Platform.isWindows) {
              contents = await File(ConditionConfiguration.fullSQLDbInitPath)
                  .readAsString();
            } else if (ConditionConfiguration.isWeb) {
              contents = await Sqlite3DB.httpGetFileContents(
                  'sqlite3/condition_full_db_init.sql') as String;
              debugPrint('Sqlite db init contents are: $contents');
            } // !! no need for else and throw Exception - it is done earlier in this method
            // ?? commented unused variable declaration: this shouldn't be used for native, indexes are to be created, this line was probably for test and preparation for sqlweb github web plugin:  const String create_index_regex_string =   r'CREATE[\r\n\t\s]*INDEX[^;]*[;]*';

            if (contents == '') {
              throw Exception(
                  'ConditionDataManagementDriverSql class _initStorage method exception: No init sql string data');
            }

            //indexes are to be created, this line was probably for test and preparation for sqlweb github web plugin .replaceAll( RegExp(create_index_regex_string, caseSensitive: false), '')
            contents = replacementMethods.replaceAllDropTable(contents);
            contents = replacementMethods.replaceAllCreateTable(contents);
            contents = replacementMethods.replaceAllCreateIndex(contents);
            contents = replacementMethods.replaceAllInsertInto(contents);

            debugPrint(contents);

            dynamic resultdbe = _db.execute(contents);

            debugPrint('db_init result' + resultdbe.toString());

            inited = true;
            initCompleter.complete(this);
          } catch (error) {
            debugPrint('catchError flag #prg1: ${error}');

            initCompleter.completeError(false);
          }
        } else {
          debugPrint(
              'Why i have no access to inited property - prefix ${tableNamePrefix}');
          inited = true;
          initCompleter.complete(this);
        }
      } catch (e) {
        debugPrint("we are here 034503845093485");
        initCompleter.completeError(false);
        debugPrint(e.toString());
      }
    });
  }

  /// Temporary during development stage, this is to be removed or made private.
  //@Deprecated(
  //    'This was (still is?) used only in very early development stages and for testing purposes')
  //static Future /*DatabaseImpl*/ getDbEngine() {
  //  return Future/*<DatabaseImpl>*/(() {
  //    DynamicLibrary.open('./sqlite3.dll');
  //    return sqlite3.open('./condition_data_management_driver_sql.sqlite');
  //  });
//
  //  // Create a table and insert some data
  //  //db.execute('''
  //  //CREATE TABLE artists (
  //  //  id INTEGER NOT NULL PRIMARY KEY,
  //  //  name TEXT NOT NULL
  //  //);
  //  //''');
  //}

  @override
  @protected
  Future<String> _requestGlobalServerAppKeyActualDBRequestHelper(
      String key) async {
    Completer<String> completer = Completer<String>();

    scheduleMicrotask(() async {
      try {
        await createRawer(
            'ConditionModelApps', //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
            {'key': key});
        completer.complete(key);
/*
  List<Map>? conditionMapList = await readAll(
            '${tableNamePrefix}ConditionModelApps',
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
              ..add('key', key),
            limit: 1,
            columnNames: {'id'});

      debugPrint(
          'A result of readAll (that was invoked by requestGlobalServerAppKeyActualDBRequestHelper(key)) has arrived. Here how it looks like:');

      if (conditionMapList == null) {
        debugPrint('It is null :(');
        completer.completeError(
            'error: requestGlobalServerAppKeyActualDBRequestHelper(key) The id value couldn\'t has been obtained. It normally means a record hasn\'t been inserted during a preceding create()/insert into operation. It requires to insert the model again into the db.');
      } else {
        debugPrint(
            'requestGlobalServerAppKeyActualDBRequestHelper(key) result: It is not null :) so we change it toString and parse to int and complete future with this int :${int.tryParse(conditionMapList[0].toString())}');
        // !!!!!! RIDICULOUS RETURN :)
        //return completer.complete(int.tryParse(conditionMapList[0].toString()));
        //completer.complete(int.tryParse(conditionMapList[0].toString()));
        completer.complete(conditionMapList[0]['id']);
      }

*/
      } catch (e) {
        // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
        completer.completeError(
            'requestGlobalServerAppKeyActualDBRequestHelper(key) Predefined error message, rather throw Excepthion custom class, There was a db_error,error $e');
      }
    });

    return completer.future;
  }

  @override
  @protected
  Future<String> requestGlobalServerAppKey() async {
    Completer<String> completer = Completer<String>();

    /// taken from getInsertionKey() => of [ConditionModelIdAndOneTimeInsertionKeyModel] class, you might need to see if there is an improvement to source methods.
    String key = (UniqueKey().toString() +
            UniqueKey().toString() +
            UniqueKey().toString() +
            UniqueKey().toString() +
            UniqueKey().toString())
        .replaceAll(RegExp(r'[\[\]#]'), '');

    // check out if a generated key exists in db cyclically - the app requests
    // the local server, not remote global, if it was a proxy ConditionModelDriver class
    // implementation, proxy like, that constacts remote server via http, it would do it,
    // maybe once not cyclicaly, then te remote server would lauch this cyclical method
    // quite confusing, heh?
    // but with limited number of attempts
    try {
      debugPrint(
          'class [ConditionModelApp], method requestGlobalServerAppKey() now awaiting for up to 10 seconds to create db entry with earlier prepared global server key, inserting to table row. On success we will complete future with the key value ');
      await _requestGlobalServerAppKeyActualDBRequestHelper(key);
      completer.complete(key);
    } catch (e) {
      debugPrint(
          'class [ConditionModelApp], method requestGlobalServerAppKey() error (async ExceptionType: e.runtimetype == ${(e is Exception) ? e.runtimeType.toString() : 'The error object is not an Exception class object.'}): The key couldn\t has been inserted into the db, so will try to insert the key periodically not many times,  Exception thrown: $e');

      int counter = 2;
      // INFO: SOME SOLUTIONS LIKE BELOW MIGHT NEED MORE SOPHISTICATED SOLUTIONS
      Timer.periodic(Duration(seconds: 3), (timer) async {
        counter--;
        try {
          await _requestGlobalServerAppKeyActualDBRequestHelper(key);
          timer.cancel();
        } catch (e) {
          debugPrint(
              'class [ConditionModelApp], method initCompleteModel() trying to periodically get te server_key error (probably timeout, read more, async ExceptionType: e.runtimetype == ${(e is Exception) ? e.runtimeType.toString() : 'The error object is not an Exception class object.'}): After initiation of the model it revealed that server_key property is null, the key is needed to send and receive data (which means synchronize local server data with the remote global server), so setting server_key up failed. Not a big deal it will be set up at a later point in time as needed, and data synchronized. Exception thrown: $e');
        }
        if (counter == 0) {
          timer.cancel();
          completer.completeError(
              'class [ConditionModelApp], method requestGlobalServerAppKey() The key for the app to connect to the global server couldn\'t has been created, and returned');
        }
      });
    }

    return completer.future;
  }

  @override
  @protected
  Future<bool> _checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper(
      String key) async {
    Completer<bool> completer = Completer<bool>();

    // WARNING: TAKE CARE THAT
    // _getAppIdByAGivenGlobalServerKey(String globalServerKey) works similarly
    // the method mentioned returns int or error
    // but this method returns true, false (not error) or error/exception
    // both methods maybe should rather be maintained independently not
    // to miss the important differences in returning results

    try {
      debugPrint(
          'checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper() we are to check if the key == $key is valid using readAll method');
      List<Map>? conditionMapList = await readAll(
          'ConditionModelApps',
          ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
            ..add('key', key),
          limit: 1,
          columnNames: {'id'},
          globalServerRequestKey: key);

      debugPrint(
          'checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper() A result of readAll (that was invoked by requestGlobalServerAppKeyActualDBRequestHelper(key)) has arrived. Here how it looks like: conditionMapList == $conditionMapList and :');

      if (conditionMapList == null || conditionMapList.isEmpty) {
        debugPrint(
            'It is null or empty :( but it is NOT a db error! A new key will be obtained in a while or later');
        completer.complete(false);
      } else {
        debugPrint(
            'checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper(key) result: It is not null :) so we change it toString and parse to int and complete future with this int :${int.tryParse(conditionMapList[0].toString())}');
        // !!!!!! RIDICULOUS RETURN :)
        //return completer.complete(int.tryParse(conditionMapList[0].toString()));
        //completer.complete(int.tryParse(conditionMapList[0].toString()));
        //completer.complete(conditionMapList[0]['id']);
        completer.complete(true);
      }
    } catch (e) {
      // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
      completer.completeError(
          'checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper(key) Predefined error message, rather throw Excepthion custom class, There was a db_error,error $e');
    }

    return completer.future;
  }

  @override
  @protected
  Future<bool> checkOutIfGlobalServerAppKeyIsValid(String key) async {
    Completer<bool> completer = Completer<bool>();

    // the description taken from requestGlobalServerAppKey() it\'s late today not changing it
    // check out if a generated key exists in db cyclically - the app requests
    // the local server, not remote global, if it was a proxy ConditionModelDriver class
    // implementation, proxy like, that constacts remote server via http, it would do it,
    // maybe once not cyclicaly, then te remote server would lauch this cyclical method
    // quite confusing, heh?
    // but with limited number of attempts

    try {
      debugPrint(
          'class [ConditionModelApp], method checkOutIfGlobalServerAppKeyIsValid() now awaiting for up to 10 seconds to create db entry with earlier prepared global server key, inserting to table row. On success we will complete future with the key value ');
      bool canTheKeyBeUsed =
          await _checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper(key);
      completer.complete(canTheKeyBeUsed);
    } catch (e) {
      debugPrint(
          'class [ConditionModelApp], method checkOutIfGlobalServerAppKeyIsValid() error (async ExceptionType: e.runtimetype == ${(e is Exception) ? e.runtimeType.toString() : 'The error object is not an Exception class object.'}): The key couldn\t has been inserted into the db, so will try to insert the key periodically not many times,  Exception thrown: $e');

      int counter = 2;
      // INFO: SOME SOLUTIONS LIKE BELOW MIGHT NEED MORE SOPHISTICATED SOLUTIONS
      Timer.periodic(Duration(seconds: 3), (timer) async {
        counter--;
        try {
          bool canTheKeyBeUsed =
              await _checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper(
                  key);
          timer.cancel();
          completer.complete(canTheKeyBeUsed);
        } catch (e) {
          debugPrint(
              'class [ConditionModelApp], method checkOutIfGlobalServerAppKeyIsValid() trying to periodically get te server_key error (probably timeout, read more, async ExceptionType: e.runtimetype == ${(e is Exception) ? e.runtimeType.toString() : 'The error object is not an Exception class object.'}): After initiation of the model it revealed that server_key property is null, the key is needed to send and receive data (which means synchronize local server data with the remote global server), so setting server_key up failed. Not a big deal it will be set up at a later point in time as needed, and data synchronized. Exception thrown: $e');
        }
        if (counter == 0) {
          timer.cancel();
          completer.completeError(
              'class [ConditionModelApp], method checkOutIfGlobalServerAppKeyIsValid() trying to periodically get The key for the app to connect to the global server couldn\'t has been created, and returned');
        }
      });
    }

    return completer.future;
  }

  @override
  @protected
  Future<int> getModelIdByOneTimeInsertionKey(
      ConditionModelIdAndOneTimeInsertionKeyModel model,
      {String? globalServerRequestKey}) {
    if (model.one_time_insertion_key == null) {
      throw Exception(
          'model with model.one_time_insertion_key == null cannot be used in this method');
    }

    // ??? : Condition should never be used, however some re-implementations can be wrong, this is after any other request is run, so on the first db request an Exception should already has been thrown
    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    }
    Completer<int> completer = Completer<int>();
    //storageOperationsQueue.add(completer);

    readAll(
            model.runtimeType.toString(),
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
              ..add('one_time_insertion_key', model.one_time_insertion_key),
            limit: 1,
            columnNames: {'id'},
            dbTableName: model.appCoreModelClassesCommonDbTableName,
            globalServerRequestKey: globalServerRequestKey)
        .then((List<Map>? conditionMapList) {
      debugPrint(
          'getModelIdByOneTimeInsertionKey(), A result of readAll (that was invoked by getModelIdByOneTimeInsertionKey) has arrived. Here how it looks like:');

      if (conditionMapList == null) {
        debugPrint('It is null :(');
        completer.completeError(
            'error: getModelIdByOneTimeInsertionKey() The id value couldn\'t has been obtained. It normally means a record hasn\'t been inserted during a preceding create()/insert into operation. It requires to insert the model again into the db.');
      } else {
        debugPrint(
            'getModelIdByOneTimeInsertionKey(), It is not null :) so we change it toString and parse to int and complete future with this int :${int.tryParse(conditionMapList[0]['id'].toString())}');
        // !!!!!! RIDICULOUS RETURN :)
        //return completer.complete(int.tryParse(conditionMapList[0].toString()));
        //completer.complete(int.tryParse(conditionMapList[0].toString()));

        dynamic id = int.tryParse(conditionMapList[0]['id'].toString());
        if (null != id && id is int && id > 0) {
          debugPrint(
              'getModelIdByOneTimeInsertionKey id result SUCCESS: it is correnct integer value');
          completer.complete(id);
        } else {
          completer.completeError(
              'getModelIdByOneTimeInsertionKey result exception: is not valid operation and result is: int.tryParse(conditionMapList.toString()) == $conditionMapList');
        }
      }
    }).catchError((e) {
      debugPrint('catchError flag #prg2');
      //here RangeError ???
      //Predefined error message, rather throw Excepthion custom class, There was a db_error : e == RangeError (index): Invalid value: Valid value range is empty: 0
      // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
      String message =
          '\nparam: ${model.runtimeType.toString()}\nparam: model.one_time_insertion_key == ${model.one_time_insertion_key}\nparam: ${(ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()..add('one_time_insertion_key', model.one_time_insertion_key)).queryPart}\nparam: dbTableName: ${model.appCoreModelClassesCommonDbTableName},\nparam: globalServerRequestKey: $globalServerRequestKey);';

      completer.completeError(
          'Predefined error message, rather throw Excepthion custom class, There was a db_error : e == $e  ## But Additionally $message');
    });

    return completer.future;
  }

  /// At first glance, it's ridiculous i cannot understand why i couldn't just set model['one_time_insertion_key'] = null after _inited = true, but also when you have local_id and server_id set up!!! ????? It would also be synchronized with global server automatically i suppose !!!  Would it be that simple? Why i didnt\'t see it earlier? This could be done by model, the key may stay longer. Need to be investigated if i am wrong.
  @override
  @Deprecated(
      'Just setting one_time_insertion_key to null when _inited=true and also when you have local_id and server_id set up!!! Would it be that simple? Why i didnt\'t see it earlier?')
  @protected
  Future<bool> nullifyOneTimeInsertionKey(
      ConditionModelIdAndOneTimeInsertionKeyModel model,
      {String? globalServerRequestKey = null}) {
    // Condition should never be used, however some re-implementations can be wrong, this is after any other request is run, so on the first db request an Exception should already has been thrown
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    Completer<bool> completer = Completer<bool>();
    //storageOperationsQueue.add(completer);

    // No need to create the variable? the variable exists rather for the debugPrint purposes, no need to maintain the object long term
    var query = ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon
        .dbTableNameQuery(
            tableNamePrefix +
                (model.appCoreModelClassesCommonDbTableName ??
                    model.runtimeType.toString()),
            {'one_time_insertion_key': null},
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
              ..add('id', model.id));

    // No need to create the variable? the variable exists rather for the debugPrint purposes, no need to maintain the object long term
    debugPrint(
        'we are now in the ConditionDataManagement object invoking create method. let\' see how the query looks like and then throw exception until it is ok:');
    debugPrint(query.queryPart);
    //throw Exception('The just promised Exception thrown');

    scheduleMicrotask(() {
      dynamic result;
      try {
        result = _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(
            'A result of nullifyOneTimeInsertionKey() exception/future completeError. An exception during third party library operation occured: ${e.toString()}');
        debugPrint(
            'A result of nullifyOneTimeInsertionKey() exception/future An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'A result of nullifyOneTimeInsertionKey has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result);

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(true);
    });

    return completer.future;
  }

  // instead of createAll like readAll, because you create one entry in the db
  @override
  @protected
  Future<bool> createRawer(
      String
          modelClassName, //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
      Map<String, dynamic> noModelColumnNamesWithValues,
      {Set<String>? columnNames,
      String? dbTableName, // see modelClassName double slash comment
      String? globalServerRequestKey,
      String? tableNamePrefix}) {
    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    }

    Completer<bool> completer = Completer<bool>();
    //storageOperationsQueue.add(completer);
    //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);

    if (dbTableName != null) {
      debugPrint(
          'createRawer (createAll or similar: not create()) We are going to iterate enums ConditionModelClasses.values, there is going to be stuff seen here that it iterates or it went a bit wrong.');
      var i = 0;
      for (var enumValue in ConditionModelClasses.values) {
        i++;
        String className =
            enumValue.toString().replaceFirst('ConditionModelClasses.', '');
        if (className == modelClassName) {
          debugPrint(
              'createRawer (createAll or similar: not create()) enum ConditionModelClasses value before:${enumValue.toString()} and the className after: $className');
          noModelColumnNamesWithValues['model_type_id'] = i;

          break;
        }
      }
    }
    var query =
        ConditionDataManagementDriverQueryBuilderPartInsertClauseSqlCommon
            .dbTableNameQuery(
      (tableNamePrefix ?? this.tableNamePrefix) +
          (dbTableName ?? modelClassName),
      noModelColumnNamesWithValues,
      columnNames: columnNames,
    );

    debugPrint(
        'createRawer (createAll or similar: not create()): Not to get lost and to understand where we are we are going to see the development query...');
    debugPrint(query.queryPart);
    /*throw Exception(
        'createRawer (createAll or similar: not create()) And here we have the promised exception :)');
*/
    scheduleMicrotask(() {
      dynamic result;
      try {
        result = _db.select(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'A result of readAll method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(true);
    });

    return completer.future;
  }

  @Deprecated(
      'It is not deprecated, just wanted to notify it must be quickly implemented :) ')
  Future<int> _getAppIdByAGivenGlobalServerKey(String globalServerKey) async {
    Completer<int> completer = Completer<int>();

    // how to implement it?
    //isGlobalRequest: null != globalServerRequestKey ? true : false
    debugPrint(
        '_getAppIdByAGivenGlobalServerKey Not implemented. NOT Throwing fatal error for now. I was kinda thinking it\'s been implemented :)');

//    throw Error();

    try {
      List<Map>? conditionMapList = await readAll(
          'ConditionModelApps',
          ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
            ..add('key', globalServerKey),
          limit: 1,
          columnNames: {'id'});
      debugPrint(
          '_getAppIdByAGivenGlobalServerKey() A result of readAll (that was invoked by requestGlobalServerAppKeyActualDBRequestHelper(key)) has arrived. Here how it looks like: conditionMapList == $conditionMapList and :');

      if (conditionMapList == null || conditionMapList.isEmpty) {
        debugPrint(
            '_getAppIdByAGivenGlobalServerKey() It is null or empty :( but it is NOT a db error! A new key will be obtained in a while or later');
        completer.completeError(
            '_getAppIdByAGivenGlobalServerKey() exception: It is null or empty :( but it is NOT a db error we cannot do anything about! A new key will be obtained in a while or later');
      } else {
        debugPrint(
            '_getAppIdByAGivenGlobalServerKey() result: It is not null :) so we change it toString and parse to int and complete future with this int :${int.tryParse(conditionMapList[0]['id'].toString())}');
        // !!!!!! RIDICULOUS RETURN :)
        //return completer.complete(int.tryParse(conditionMapList[0].toString()));
        //completer.complete(int.tryParse(conditionMapList[0].toString()));
        //completer.complete(conditionMapList[0]['id']);
        dynamic app_id = int.tryParse(conditionMapList[0]['id'].toString());
        if (null != app_id && app_id is int && app_id > 0) {
          debugPrint(
              '_getAppIdByAGivenGlobalServerKey() app_id result SUCCESS: it is correnct integer value');
          completer.complete(app_id);
        } else {
          completer.completeError(
              '_getAppIdByAGivenGlobalServerKey() result exception: is not valid operation and result is: int.tryParse(conditionMapList[0].toString()) == $app_id');
        }
      }
    } catch (e) {
      // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
      completer.completeError(
          '_getAppIdByAGivenGlobalServerKey() overall readAll exception not related to a successfully performed operation with wrong result but possibly some different error, Predefined error/exception message, rather throw Excepthion custom class, There was a db_error,error $e');
    }

    return completer.future;
  }

  /// null means not error - only the user hasn\'t been found
  Future<int?> _getGlobalServerUserId(
      Map<String, dynamic>? globalServerUserCredentials,
      [bool usePassword = true]) async {
    Completer<int?> completer = Completer<int?>();

    if (globalServerUserCredentials == null ||
        globalServerUserCredentials.isEmpty ||
        ((globalServerUserCredentials['e_mail'] == null ||
                globalServerUserCredentials['e_mail'].isEmpty) &&
            (globalServerUserCredentials['phone_number'] == null ||
                globalServerUserCredentials['phone_number'].isEmpty)) ||
        (usePassword &&
            (globalServerUserCredentials['password'] == null ||
                globalServerUserCredentials['password'].isEmpty))) {
      // async syntax so
      debugPrint(
          'DataManagementDriver create() _getGlobalServerUserId() method error (1) method global request user credentials failed because one or more necessary params are null. usePassword == $usePassword , globalServerUserCredentials[\'e_mail\'] == ${globalServerUserCredentials?['e_mail']} || globalServerUserCredentials[\'phone_number\']==${globalServerUserCredentials?['phone_number']}');
      throw Exception(
          'DataManagementDriver create() _getGlobalServerUserId() method error (1) method global request user credentials failed because one or more necessary params are null usePassword == $usePassword , See more data in a very similar debugPrint message preceding this (seen only in the debug mode).');
      //throw Exception('DataManagementDriver create() (1) method global request user credentials failed one or more necessary params are null _getGlobalServerUserId() method error');
    }

    var queryObject =
        ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
          ..addQueryPart(
              ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon(
                  isGroup: true)
                ..add('e_mail', globalServerUserCredentials['e_mail'])
                ..add('phone_number',
                    globalServerUserCredentials['phone_number']));

    if (usePassword) {
      queryObject.add('password', globalServerUserCredentials['password'],
          ConditionDBOperator.equal, false);
    }
    //..add('app_id', globalServerUserCredentials['password'], ConditionDBOperator.equal, false)

    readAll(
      'ConditionModelUser', //model.runtimeType.toString(),
      queryObject,
      limit: 1,
      columnNames: {'id'},
      //dbTableName: model.appCoreModelClassesCommonDbTableName,
      //globalServerRequestKey: globalServerRequestKey
    ).then((List<Map>? conditionMapList) {
      debugPrint(
          ' _getGlobalServerUserId(), A result has arrived. Here how it looks like:');

      if (conditionMapList == null) {
        debugPrint(
            'It is null yet in this case it is not a db engine error - the record in the db just doesn\'t exist :(');
        completer.complete(null);
      } else {
        debugPrint(
            '_getGlobalServerUserId(), It is not null :) so we change it toString and parse to int and complete future with this int :${int.tryParse(conditionMapList[0]['id'].toString())}');

        dynamic id = int.tryParse(conditionMapList[0]['id'].toString());
        if (null != id && id is int && id > 0) {
          debugPrint(
              '_getGlobalServerUserId(), id result SUCCESS: it is correnct integer value');
          completer.complete(id);
        } else {
          completer.completeError(
              '_getGlobalServerUserId(), result exception: is not valid operation and result is: int.tryParse(conditionMapList.toString()) == $conditionMapList');
        }
      }
    }).catchError((e) {
      debugPrint('catchError flag #prg3');

      //here RangeError ???
      //Predefined error message, rather throw Excepthion custom class, There was a db_error : e == RangeError (index): Invalid value: Valid value range is empty: 0
      // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
      String message =
          '\nparam: query looks like:: ${queryObject.queryPart}\nparam: dbTableName: ConditionModelUser,';

      completer.completeError(
          '_getGlobalServerUserId(), Predefined error message, rather throw Excepthion custom class, There was a db_error : e == $e  ## But Additionally: $message');
    });

    return completer.future;
  }

  @override
  @protected
  CreateModelOnServerFutureGroup<int?> create(ConditionModel model,
      {Set<String>? columnNames,
      String? globalServerRequestKey = null,
      // it would be perfect to use ConditionModelUser object, but the development is dragging on and on, so for now something simpler :)
      Map<String, String?>? globalServerUserCredentials}) {
    // ------------------------------------------------------------
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // READ THIS YOU MUST TAKE CARE IF A MODEL
    // HAS PROPERTY: appCoreModelClassesCommonDbTableName SET TO 'ConditionModelWidget'
    // AND MAYBE HERE SOME OTHER STUFF LIKE - IS A MODEL DYNAMIC? ONE ROW MODEL OF ID = 1 ALWAYS?

    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    } else if (null != globalServerRequestKey) {
      if (globalServerRequestKey.isEmpty) {
        throw Exception(
            'DataManagementDriver create() method: exception: the mode cannot be updated on the global aspect of the server, because while the globalServerRequestKey is not null, however it\'s empty.');
      }
      // contact also is ConditionModelBelongingToContact but logically it shouldn't it one day may change
      else if (model is! ConditionModelContact &&
          model is ConditionModelBelongingToContact) {
        if (model.server_owner_contact_id == null ||
            model.server_owner_contact_id! < 1 ||
            // below owner_contact_id not necessary, but to make it more difficult to hack :)
            model.owner_contact_id == null ||
            model.owner_contact_id! < 1) {
          throw Exception(
              'DataManagementDriver create() method: exception:  Invalid value of model.server_owner_contact_id (or possibly model.owner_contact_id)');
        }
      } else if (model is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
        if ((model['parent_id'] != null && model['server_parent_id'] == null) ||
            (model['parent_id'] == null && model['server_parent_id'] != null)) {
          throw Exception(
              'DataManagementDriver create() method: exception: condition == true so exception is thrown : model[\'parent_id\']!=null&&model[\'server_parent_id\']==null || model[\'parent_id\']==null&&model[\'server_parent_id\']!=null');
        }
      }
    }

    Completer<int?> completerCreate = Completer<int?>();
    // notice it is int not int? below:
    Completer<int?> completerModelIdByOneTimeInsertionKey = Completer<int?>();
    //implemented
    Completer<int?>? completerServerCreationDateTimestampGlobalServer;
    // not implemented
    Completer<int?>? completerServerUserIdFuture;
    // not implemented
    // !!!!! we can find must already have it locally, no need for global
    //Completer<int?>? completerServerParentIdFuture;
    // not implemented
    Completer<int?>? completerServerContactUserIdFuture;
    // not implemented
    // !!!!! we can find must already have it locally, no need for global
    //Completer<int?>? completerServerOwnerContactIdFuture;
    // not implemented
    Completer<int?>? completerServerLinkIdFuture;

    CreateModelOnServerFutureGroup<int?> createModelOnServerFutureGroup;
    if (null != globalServerRequestKey) {
      completerServerCreationDateTimestampGlobalServer = Completer<int?>();

      completerServerUserIdFuture = Completer<int?>();
      //read earlier the definition of commented variable:
      //completerServerParentIdFuture = Completer<int?>();
      completerServerContactUserIdFuture = Completer<int?>();
      //read earlier the definition of commented variable:
      //completerServerOwnerContactIdFuture = Completer<int?>();
      completerServerLinkIdFuture = Completer<int?>();

      createModelOnServerFutureGroup = CreateModelOnServerFutureGroup<int?>(
        completerCreate.future,
        completerModelIdByOneTimeInsertionKey.future,
        completerServerCreationDateTimestampGlobalServer.future,
        completerServerUserIdFuture.future,
        //read earlier the definition of commented variable:
        //completerServerParentIdFuture.future,
        completerServerContactUserIdFuture.future,
        //read earlier the definition of commented variable:
        //completerServerOwnerContactIdFuture.future,
        completerServerLinkIdFuture.future,
      );
    } else {
      completerServerCreationDateTimestampGlobalServer = null;
      createModelOnServerFutureGroup = CreateModelOnServerFutureGroup<int?>(
        completerCreate.future,
        completerModelIdByOneTimeInsertionKey.future,
      );
    }
    //storageOperationsQueue.add(completerCreate);
    //storageOperationsQueue.add(completerModelIdByOneTimeInsertionKey);
    // scheduleMicrotask is to run the function asynchronously so that it the later created [CreateModelFutureGroup] can be returned now and the db operations can be done later
    scheduleMicrotask(() async {
      Map<String, dynamic>? overwriteModelProperties = {};
      if (null != globalServerRequestKey) {
        try {
          int app_id =
              await _getAppIdByAGivenGlobalServerKey(globalServerRequestKey);
          // for create we don't need to overwrite id with null value because the query builder
          // will skip the column for the main constructor of the query accepting model object.
          debugPrint(
              'DataManagementDriver create() method we have app_id == $app_id and columnNames = $columnNames');

          if (null != columnNames) {
            columnNames.add('app_id');
            columnNames.add('server_creation_date_timestamp');
          }

          overwriteModelProperties.addAll({
            'app_id': app_id,
            'server_creation_date_timestamp':
                createCreationOrUpdateDateTimestamp()
          });
          completerServerCreationDateTimestampGlobalServer!.complete(
              overwriteModelProperties['server_creation_date_timestamp']);
        } catch (e) {
          debugPrint(
              'DataManagementDriver create() method calling _getAppIdByAGivenGlobalServerKey() error thrown: $e');
          completerCreate.completeError(
              'DataManagementDriver create() method calling _getAppIdByAGivenGlobalServerKey() An operation on the global server (or global aspect of the app storage server) coldn\'t has been performed and the app_id couldn\'t has been obtained, so creating a global server db table row based on model data that was sent from client app to the global server cannot be performed.');
          completerModelIdByOneTimeInsertionKey.completeError(
              'DataManagementDriver create() method calling _getAppIdByAGivenGlobalServerKey() An operation on the global server (or global aspect of the app storage server) coldn\'t has been performed and the app_id couldn\'t has been obtained, so creating a global server db table row based on model data that was sent from client app to the global server cannot be performed.');
          return;
        }
      }

      // we can't do anything without global server user id need to get the global server user_id
      // for this we need users credentials
      // As a general rule on global server we find user first having both e-mail and phone number,
      // if not found first seek e-mail only, then phone.
      // For creating a user you don't need credentials but for creating message, task you do

      // Let's do it this way - we must gather all needed data
      // to perform row creation, so that we return errors
      // !!! but before a new record finds itself in the db because we need
      // !!! all data, not one element missing so create should be the last thing to do
      // !!! we finish some completers as late as possible
      // !!! after we have the row id, creation date also

      // globalServerRequestKey and app_id is ok we can seek what we need
      if (null != globalServerRequestKey) {
        if (model is! ConditionModelUser) {
          try {
            int? server_user_id =
                await _getGlobalServerUserId(globalServerUserCredentials);
            if (server_user_id == null) {
              throw Exception(
                  'DataManagementDriver create() server_user_id couldn\'t has been found. So server_user_id cannot be null');
            }

            if (null != columnNames) {
              columnNames.add('server_user_id');
            }

            overwriteModelProperties['server_user_id'] = server_user_id;

            // we will fishish the future later
            completerServerUserIdFuture!.complete(server_user_id);
          } catch (e) {
            // ! This future group fails, no need to complete more futures createModelOnServerFutureGroup
            completerServerUserIdFuture!.completeError(
                'DataManagementDriver create() (2.5) method global request user credentials failed one or more necessary params are null or the user not found. Exception thrown: $e');
            completerCreate.completeError(
                'DataManagementDriver create() (1) method global request user credentials failed one or more necessary params are null or the user not found. Exception thrown $e');
            completerModelIdByOneTimeInsertionKey.completeError(
                'DataManagementDriver create() (2) method global request user credentials failed one or more necessary params are null or the user not found. Exception thrown $e');
            return;
          }
        } else {
          // it's user model user_id = null but we need to finish the future
          completerServerUserIdFuture!.complete(null);
        }
      }

      // ---------------
      // Now user is ok - a widget belongs to a parent or is a tree top level widget:
      // ---------------
      //!!! read earlier the definition of commented variable:
      // we can have it locally
      // the same as with completerServerOwnerContactIdFuture
      // think over here
      //completerServerParentIdFuture;

      if (null != globalServerRequestKey) {
        if (model is ConditionModelContact) {
          // ---------------
          // if this IS a ConditionModelContact model_type_id == 1
          // we need server user id for interaction between users to start to start
          // to do little later.... contact_accepted_invitation
          // ---------------

          try {
            int? server_contact_user_id = await _getGlobalServerUserId({
              'e_mail': model['contact_e_mail'],
              'phone_number': model['contact_phone_number']
            }, false);
            if (server_contact_user_id == null) {
              throw Exception(
                  'DataManagementDriver create() server_contact_user_id couldn\'t has been found. So server_contact_user_id cannot be null');
            }

            if (null != columnNames) {
              columnNames.add('server_contact_user_id');
            }

            overwriteModelProperties['server_contact_user_id'] =
                server_contact_user_id;

            // we will fishish the future later
            completerServerContactUserIdFuture!
                .complete(server_contact_user_id);
          } catch (e) {
            // ! This future group fails, no need to complete more futures createModelOnServerFutureGroup
            completerServerContactUserIdFuture!.completeError(
                'DataManagementDriver create() (3.5) method global request couldnt find server_contact_user_id which is needed if model is ConditionModelContact. Exception thrown $e model credentials $model');
            completerCreate.completeError(
                'DataManagementDriver create() (3) method global request couldnt find server_contact_user_id which is needed if model is ConditionModelContact. Exception thrown $e');
            completerModelIdByOneTimeInsertionKey.completeError(
                'DataManagementDriver create() (3) method global request couldnt find server_contact_user_id which is needed if model is ConditionModelContact. Exception thrown $e');
            return;
          }
        } else {
          // ---------------
          // if this is NOT a ConditionModelContact, SO model_type_id != 1
          // message belongs to the server_owner_contact_id
          // ---------------
          // not implemented
          // !!!!!!! Ok for now i see that server_owner_contact_id
          // can and must be taken from local server because the contact must have it up to this point
          // the same as with completerServerParentIdFuture
          // completerServerOwnerContactIdFuture;

          completerServerContactUserIdFuture!.complete(null);
        }
      }

      // ---------------
      // !!! DONT FORGET ABOUT IT !!! not implemented
      // FINALLY DON'T FORGET ABOUT IT !!! not implemented
      debugPrint(
          'DataManagementDriver create() method we are going to miss this piece of code: completerServerLinkIdFuture.');
      if (null != globalServerRequestKey) {
        if (model['link_id'] == null) {
          completerServerLinkIdFuture!.complete(null);
        } else {
          // !!! NOT IMPLEMENTED - LINK ID FOR A BIT LATER
          completerServerLinkIdFuture!.completeError(
              'DataManagementDriver create() (4) method global request exception: handling of link_id or server_link_id properties not implemented yet, only null for link_id is accepted now:');
          completerCreate.completeError(
              'DataManagementDriver create() (4) method global request server_contact_user_id future ignored because:  handling of link_id or server_link_id properties not implemented yet, only null for link_id is accepted now:');
          completerModelIdByOneTimeInsertionKey.completeError(
              'DataManagementDriver create() (4)  method global request server_contact_user_id future ignored because:  handling of link_id or server_link_id properties not implemented yet, only null for link_id is accepted now:');
        }
      }
      // ---------------

      //
      //
      //
      //
      //
      //
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      // READ THIS YOU MUST TAKE CARE IF A MODEL
      // HAS PROPERTY: appCoreModelClassesCommonDbTableName SET TO 'ConditionModelWidget'
      // AND MAYBE HERE SOME OTHER STUFF LIKE - IS A MODEL DYNAMIC? ONE ROW MODEL OF ID = 1 ALWAYS?

      //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);
      //var abc = CreateModelFutureGroup();

      //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);

      // to go any further you need to know what db.execute returns on insert - returns id?
      debugPrint('=================================================');
      debugPrint('HOW MANY TIMES ARE WE IN THE CRATE METHOD? LETS SEE ');
      // No need to create the variable? the variable exists rather for the debugPrint purposes, no need to maintain the object long term
      var query =
          ConditionDataManagementDriverQueryBuilderPartInsertClauseSqlCommon(
              model,
              columnNames: columnNames,
              overwriteModelProperties: overwriteModelProperties.isNotEmpty
                  ? overwriteModelProperties
                  : null,
              isGlobalRequest: null != globalServerRequestKey ? true : false);
      // No need to create the variable? the variable exists rather for the debugPrint purposes, no need to maintain the object long term
      var queryPart = query.queryPart;
      debugPrint(
          'we are now in the ConditionDataManagement object invoking create method. let\' see how the query looks like and then throw exception until it is ok:');
      debugPrint(queryPart);

      if (model is! ConditionModelOneDbEntryModel) {
        debugPrint(
            'DataManagementDriver create() method: The model is NOT of ConditionModelOneDbEntryModel class/mixin/whatever');
        //throw Exception('The just promised Exception thrown');
      } else {
        debugPrint(
            'DataManagementDriver create() method: The model IS of ConditionModelOneDbEntryModel class/mixin/whatever');
      }

      if (model is! ConditionModelIdAndOneTimeInsertionKeyModel) {
        debugPrint(
            'DataManagementDriver create() method: The model is NOT of ConditionModelIdAndOneTimeInsertionKeyModel class/mixin/whatever');
      } else {
        debugPrint(
            'DataManagementDriver create() method: The model IS of ConditionModelIdAndOneTimeInsertionKeyModel class/mixin/whatever');
      }

      dynamic result;
      try {
        debugPrint(
            '###################################### 8IE### EXECUTE INSERT INTO NOW OR THROW EXCEPTION');
        result = _db.execute(query.queryPart);
      } catch (e) {
        debugPrint(
            'DataManagementDriver create() method async exception: ## point 1');
        completerCreate.completeError(
            'DataManagementDriver create() method async exception: An object couldn\'t has been created the raw driver error: ${e.toString()}');
        completerModelIdByOneTimeInsertionKey.completeError(
            'DataManagementDriver create() CDV1 method async exception: Getting id by getModelIdByOneTimeInsertionKey() method has failed because an earlier operation of creating db table row had also failed');
        return;
      }

      debugPrint(
          'A result of create has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result);

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      if (model is ConditionModelOneDbEntryModel) {
        debugPrint(
            'DataManagementDriver create() method async exception: ## point 3');
        completerCreate.complete(1);
        completerModelIdByOneTimeInsertionKey.complete(1);
        return;
      } else {
        debugPrint(
            'DataManagementDriver create() method async exception: ## point 4');
        completerCreate.complete(null);
      }

      if (model is ConditionModelIdAndOneTimeInsertionKeyModel) {
        getModelIdByOneTimeInsertionKey(model).then((id) {
          debugPrint(
              'DataManagementDriver create() method A result of getModelIdByOneTimeInsertionKey invoked by create method has arrived and in the debug mode it seems it successfully done and it looks like this:');
          debugPrint(id.toString());

          // we need to set up server_id == id for the global server, then local server
          // will update it to, but local server won\'t synchronize it with the
          // global server because it will has benn set up set up here (that would be twice).

          // global request is checked on more precisely earlier. Now null checking is enough
          if (globalServerRequestKey == null) {
            completerModelIdByOneTimeInsertionKey.complete(id);
          } else {
            // didn't won't to bother myself of using the update() method, rather, chose
            // to make a query based on what is in that method and execute it similarly like there.

            debugPrint(
                'DataManagementDriver create() method global request success but now need to update server_id based on the returned id of an inserted row model == ${model.runtimeType} : the model is supposed to use not the global server id but local_id and app_id instead (just after that typical updates of the model from client app will use the quick server_id number they have, and the data manager of course will automatically will use the server_id to seek in id column) query to be performed looks like this:');
            var query =
                ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon(
                    model,
                    columnNames: {'server_id'},
                    overwriteModelProperties: {'server_id': id},
                    isGlobalRequest: true
                    //null != globalServerRequestKey ? true : false
                    );
            debugPrint(query.queryPart);
            //throw Exception('UPDATE The just promised Exception thrown');

            dynamic result;
            try {
              result = _db.execute(query.queryPart);
              debugPrint(
                  'DataManagementDriver create() method (global server/aspect table row) no exception thrown - there is server_id in the db table row involved. By the way the returned result of the db operation is: $result');
              // no exception thrown - there is server_id in the db table row involved.
              completerModelIdByOneTimeInsertionKey.complete(id);
            } catch (e) {
              completerModelIdByOneTimeInsertionKey.completeError(false);
              debugPrint(
                  'DataManagementDriver create() method (global server/aspect table row) An exception during third party library operation occured: ${e.toString()}');
            }

            debugPrint(
                'DataManagementDriver create() method (global server/aspect table row) A result of update method has arrived and in the debug mode it seems it successfully done and it looks like this:');
            debugPrint(result.toString());
          }
        }).catchError((error) {
          debugPrint('catchError flag #prg4');

          debugPrint(
              'DataManagementDriver create() methodAn !error! result of getModelIdByOneTimeInsertionKey invoked by create method has arrived and in the debug mode it seems it successfully done and it looks like this:');
          debugPrint(error.toString());
          completerModelIdByOneTimeInsertionKey.completeError(
              'DataManagementDriver create() method ABC1 Getting id by getModelIdByOneTimeInsertionKey() method has failed, raw db driver error: ${error.toString()}');
        });
      } else {
        debugPrint(
            'DataManagementDriver create() method A model is not of ConditionModelIdAndOneTimeInsertionKeyModel class so a completer of create method is completed with null ');
        completerModelIdByOneTimeInsertionKey.completeError(
            'DataManagementDriver create() methodIt\'s almost not even an exception, so if you use catchError of the Future object or async programming you can handle it. The message you see is to made you aware of a problem and to be aware you need to conciously approach it not to flood your db with potential garbage. The point: A row in the database has been created, however there is no way to obtain the id of the inserted row, because you hadn\'t used a model compatible with classess [ConditionModelIdAndOneTimeInsertionKeyModel] (read description) or [ConditionModelOneDbEntryModel] where id always = 1. Do you created the model class in a way that allows to find it\'s entry in the db? A method like readAll (maybe renamed to readRaw of somehting allows you to find what you seek in the db in a more flexible, customized way.)');
      }
    });

    return createModelOnServerFutureGroup;
  }

  /// while officially it does return List<int>? containing rows affected, the result is to be ignored and treated as unreliable with only completer.completeError() telling that something went wrong. The result may be null for now - implementation may be difficult for each platform. Checking what rows might has been affected should be done programmatically in a separate request while update data should contain something unique to check what rows might has been affected - f.e. using the same where query but for select query while using readAll method.
  @override
  @protected
  Future<List<int>?> updateAll(
      String
          modelClassName, //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
      Map<String, dynamic> noModelColumnNamesWithValues,
      ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
          whereClause,
      { //some sqlite not handling it int? limit = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
      Set<String>? columnNames,
      String? dbTableName, // see modelClassName double slash comment
      String? globalServerRequestKey,
      String? tableNamePrefix}) {
    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    }

    Completer<List<int>?> completer = Completer<List<int>?>();
    //storageOperationsQueue.add(completer);
    //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);

    if (dbTableName != null) {
      debugPrint(
          'updateAll() We are going to iterate enums ConditionModelClasses.values, there is going to be stuff seen here that it iterates or it went a bit wrong.');
      var i = 0;
      for (var enumValue in ConditionModelClasses.values) {
        i++;
        String className =
            enumValue.toString().replaceFirst('ConditionModelClasses.', '');
        if (className == modelClassName) {
          debugPrint(
              'updateAll() enum ConditionModelClasses value before:${enumValue.toString()} and the className after: $className');
          whereClause?.add(
              'model_type_id',
              i,
              ConditionDBOperator
                  .equal, // in class desc if ommited or null it means equal ConditionDBOperator.equal (not less than, not greater than)
              false);
          break;
        }
      }
    }
    var query =
        ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon
            .dbTableNameQuery(
      (tableNamePrefix ?? this.tableNamePrefix) +
          (dbTableName ?? modelClassName),
      noModelColumnNamesWithValues,
      whereClause,
      columnNames: columnNames,
    );

    debugPrint(
        'updateAll()  Not to get lost and to understand where we are we are going to see the development query and throw an exception to stop and think and repair');
    debugPrint(query.queryPart);
    throw Exception('updateAll() And here we have the promised exception :)');

    scheduleMicrotask(() {
      dynamic result;
      try {
        result = _db.select(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'A result of readAll method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(result);
    });

    return completer.future;
  }

  _checkingModelsCredentialsForOperation(
      ConditionModel model, String methodName) async {
    try {
      throw Exception(
          'DataManagementDriver $methodName() CATCHED EXCEPTION method calling _commonBasicNeccesaryValidation() and it calling _checkingModelsCredentialsForOperation: HANDLED exception NOT IMPLEMENTED: ');
    } catch (e) {
      debugPrint('catched exception: $e');
    }
  }

  _commonBasicNeccesaryValidation(ConditionModel model, String methodName,
      {Set<String>? columnNames,
      String? globalServerRequestKey = null,
      ConditionModelUser? userForGlobalRequest,
      Map? userLoginDataForGlobalRequest}) async {
    //debugPrint('_commonBasicNeccesaryValidation 1');
    //debugPrint(
    //    '_commonBasicNeccesaryValidation 1 : model[\'local_id\'] == ${model['local_id']}');
    //
    //debugPrint('_commonBasicNeccesaryValidation 2');
    //debugPrint(
    //    '_commonBasicNeccesaryValidation 2 : model[\'server_id\'] == ${model['server_id']}');
    //debugPrint('_commonBasicNeccesaryValidation 3');

    // some model properties may havent't been initialized so they throw exceptions
    // so we need apply some remedy to it :).
    bool is_local_id_viable_to_be_used = true;
    bool is_server_id_viable_to_be_used = true;
    try {
      debugPrint('GGGG1');
      if (model['local_id'] == null) {
        is_local_id_viable_to_be_used = false;
      }
      debugPrint('GGGG2');
    } catch (e) {
      is_local_id_viable_to_be_used = false;
    }

    try {
      debugPrint('GGGG3');
      if (model['server_id'] == null) {
        is_server_id_viable_to_be_used = false;
      }
      debugPrint('GGGG4');
    } catch (e) {
      is_server_id_viable_to_be_used = false;
    }

    debugPrint(
        'GGGG5 is_local_id_viable_to_be_used == $is_local_id_viable_to_be_used , is_server_id_viable_to_be_used == $is_server_id_viable_to_be_used');

    // ??? comment from other method??? or invoked method has this validation better:
    // old comment here simple key checking, which is enough, but later more advanced
    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    } else if (null != globalServerRequestKey) {
      if (globalServerRequestKey.isEmpty) {
        throw Exception(
            'DataManagementDriver $methodName() method calling _commonBasicNeccesaryValidation(): exception: the model cannot be updated on the global aspect of the server, because while the globalServerRequestKey is not null, however it\'s empty.');
      } else if (!is_server_id_viable_to_be_used &&
          !is_local_id_viable_to_be_used) {
        // Comments to be updated because now are used for condition: updated !is_server_id_viable_to_be_used && !is_server_id_viable_to_be_used
        // Read also comments, exception of the next condition where null != model['server_id']
        // in this case an app instance (app_id) sends its own model which is indicated by local_id
        // so the other app instances if not designed differently will be using server_id only.
        // The architecture with no using server_id in some cases can make it work faster probably
        throw Exception(
            'DataManagementDriver $methodName() method calling _commonBasicNeccesaryValidation(): exception: the model cannot be updated on the global aspect of the server, because the model[\'local_id\'] is null or the valule is not inited. model = ${model.toString()}}');
      } else if (is_server_id_viable_to_be_used) {
        //read for the previous else if statement with local_id and description
        try {
          throw Exception(
              'DataManagementDriver $methodName() CATCHED EXCEPTION, WHY?! method calling _commonBasicNeccesaryValidation(): exception: the app/library/whatever is in the early stage. A request using server_id (model[\'server_id\'] ) is going to be performed. However there is no checking if a client app has right to perform any operation on the relevant unique row of id == server_id');
        } catch (e) {
          debugPrint(
              'DataManagementDriver $methodName() CATCHED EXCEPTION, WHY?! method calling _commonBasicNeccesaryValidation(): exception: catched exception, pointing to an vitally important security checking implementation, error thrown: $e');
        }
        if (model['server_id'] < 1) {
          throw Exception(
              'DataManagementDriver $methodName() method calling _commonBasicNeccesaryValidation(): exception: the model cannot be updated on the global aspect of the server, because the model[\'server_id\'] < 1. model[\'server_id\'] == ${model['server_id']}');
        }
      }
    } else {
      if (model is! ConditionModelOneDbEntryModel &&
          (model['id'] == null || model['id'] is! int || model['id'] < 1)) {
        Exception(
            'DataManagementDriver $methodName() method calling _commonBasicNeccesaryValidation(): exception: Because globalServerRequestKey == null then: model with no defined model.id or model[\'id\'] or null, or less than 1 cannot be used');
      }
    }

    await _checkingModelsCredentialsForOperation(model, methodName);
  }

  @override
  @protected
  Future<int?> update(ConditionModel model,
      {Set<String>? columnNames,
      String? globalServerRequestKey,
      ConditionModelUser? userForGlobalRequest,
      Map? userLoginDataForGlobalRequest}) {
    //return Future.value();
    Completer<int?> completer = Completer<int?>();
    //storageOperationsQueue.add(completer);

    scheduleMicrotask(() async {
      try {
        await _commonBasicNeccesaryValidation(model, 'update',
            globalServerRequestKey: globalServerRequestKey,
            userForGlobalRequest: userForGlobalRequest,
            userLoginDataForGlobalRequest: userLoginDataForGlobalRequest);
      } catch (e) {
        completer.completeError(
            'DataManagementDriver update() method calling _getAppIdByAGivenGlobalServerKey() error: _commonBasicNeccesaryValidation() failed. error thrown: $e');
        rethrow;
      }

      Map<String, dynamic>? overwriteModelProperties;
      if (null != globalServerRequestKey) {
        // more careful checking
        if (model['server_id'] != null) {
          // Remidner if you use just server id you must check out if a client making
          // the update request has right to make the changes see all the method body with
          // comments
          if (null != columnNames) {
            columnNames.add('server_update_date_timestamp');
          }
          overwriteModelProperties = {
            'server_update_date_timestamp':
                createCreationOrUpdateDateTimestamp()
          };
        } else {
          try {
            int app_id =
                await _getAppIdByAGivenGlobalServerKey(globalServerRequestKey);
            if (null != columnNames) {
              columnNames.add('app_id');
              columnNames.add('server_update_date_timestamp');
            }
            overwriteModelProperties = {
              'app_id': app_id,
              'server_update_date_timestamp':
                  createCreationOrUpdateDateTimestamp()
            };
          } catch (e) {
            debugPrint(
                'DataManagementDriver update() method calling _getAppIdByAGivenGlobalServerKey() error thrown: $e');
            completer.completeError(
                'DataManagementDriver update() method calling _getAppIdByAGivenGlobalServerKey() An operation on the global server (or global aspect of the app storage server) coldn\'t has been performed and the app_id couldn\'t has been obtained, so updating of model data that was sent from client app to the global server cannot be performed.');
          }
        }
      }

      // No need to create the variable? the variable exists rather for the debugPrint purposes, no need to maintain the object long term
      var query =
          ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon(
        model,
        columnNames: columnNames,
        overwriteModelProperties: overwriteModelProperties,
        // earlier more thorough key checking or exception up there
        isGlobalRequest: null != globalServerRequestKey ? true : false,
      );
      debugPrint(
          'UPDATE model == ${model.runtimeType} we are now in the ConditionDataManagement object invoking UPDATE method. let\' see how the query looks like and then throw exception until it is ok:');
      debugPrint(query.queryPart);
      //throw Exception('UPDATE The just promised Exception thrown');

      dynamic result;
      try {
        result = _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(
            'DataManagementDriver update() method An exception during third party library operation occured: ${e.toString()}');
        debugPrint(
            'DataManagementDriver update() method An exception during third party library operation occured: ${e.toString()}');
      }

      debugPrint(
          'DataManagementDriver update() method A result of update method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(null != overwriteModelProperties
          ? overwriteModelProperties['server_update_date_timestamp']
          : null);
    });

    return completer.future;
  }

  /// while officially it does return int? containing rows affected, the result is to be ignored and treated as unreliable with only completer.completeError() telling that something went wrong. The result may be null for now - implementation may be difficult for each platform. Checking what rows might has been affected should be done programmatically in a separate request while update data should contain something unique to check what rows might has been affected - f.e. using the same where query but for select query while using readAll method.
  @override
  @protected
  Future<List<int>?> deleteAll(
      String
          modelClassName, //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
      ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
          whereClause,
      { // some sqlite implementation not handling limit int? limit = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
      String? dbTableName, // see modelClassName double slash comment
      String? globalServerRequestKey,
      String? tableNamePrefix}) {
    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    }

    Completer<List<int>?> completer = Completer<List<int>?>();
    //storageOperationsQueue.add(completer);
    //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);

    if (dbTableName != null) {
      debugPrint(
          'deleteAll() We are going to iterate enums ConditionModelClasses.values, there is going to be stuff seen here that it iterates or it went a bit wrong.');
      var i = 0;
      for (var enumValue in ConditionModelClasses.values) {
        i++;
        String className =
            enumValue.toString().replaceFirst('ConditionModelClasses.', '');
        if (className == modelClassName) {
          debugPrint(
              'deleteAll() enum ConditionModelClasses value before:${enumValue.toString()} and the className after: $className');
          whereClause?.add(
              'model_type_id',
              i,
              ConditionDBOperator
                  .equal, // in class desc if ommited or null it means equal ConditionDBOperator.equal (not less than, not greater than)
              false);
          break;
        }
      }
    }
    var query =
        ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlCommon
            .dbTableNameQuery(
      (tableNamePrefix ?? this.tableNamePrefix) +
          (dbTableName ?? modelClassName),
      whereClause,
      //maxNumberOfReturnedResults: limit
    );

    debugPrint(
        'deleteAll()   Not to get lost and to understand where we are we are going to see the development query and throw an exception to stop and think and repair');
    debugPrint(query.queryPart);
    throw Exception('deleteAll()  And here we have the promised exception :)');

    scheduleMicrotask(() {
      dynamic result;
      try {
        result = _db.select(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'A result of readAll method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(result);
    });

    return completer.future;
  }

  @override
  @protected
  Future<bool> delete(ConditionModel model,
      {String? globalServerRequestKey = null,
      ConditionModelUser? userForGlobalRequest,
      Map? userLoginDataForGlobalRequest}) {
    Completer<bool> completer = new Completer<bool>();

    scheduleMicrotask(() async {
      try {
        await _commonBasicNeccesaryValidation(model, 'delete',
            globalServerRequestKey: globalServerRequestKey,
            userForGlobalRequest: userForGlobalRequest,
            userLoginDataForGlobalRequest: userLoginDataForGlobalRequest);
      } catch (e) {
        completer.completeError(
            'DataManagementDriver delete() method calling _getAppIdByAGivenGlobalServerKey() error: _commonBasicNeccesaryValidation() failed. error thrown: $e');
        rethrow;
      }

      Map<String, dynamic>? overwriteModelProperties;
      if (null != globalServerRequestKey) {
        // more careful checking
        if (model['server_id'] != null) {
          // Remidner if you use just server id you must check out if a client making
          // the update request has right to make the changes see all the method body with
          // comments
        } else {
          try {
            int app_id =
                await _getAppIdByAGivenGlobalServerKey(globalServerRequestKey);
            //if (null != columnNames) {
            //  columnNames.add('app_id');
            //}
            overwriteModelProperties = {'app_id': app_id};
          } catch (e) {
            debugPrint(
                'DataManagementDriver delete() method calling _getAppIdByAGivenGlobalServerKey() error thrown: $e');
            completer.completeError(
                'DataManagementDriver delete() method calling _getAppIdByAGivenGlobalServerKey() An operation on the global server (or global aspect of the app storage server) coldn\'t has been performed and the app_id couldn\'t has been obtained, so updating of model data that was sent from client app to the global server cannot be performed.');
          }
        }
      }

      //storageOperationsQueue.add(completer);
      var query =
          ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlCommon(
              model,
              overwriteModelProperties: overwriteModelProperties,
              // earlier more thorough key checking or exception up there
              isGlobalRequest: null != globalServerRequestKey ? true : false);

      debugPrint(
          'delete(): Not to get lost and to understand where we are we are going to see the development query and throw an exception to stop and think and repair');
      debugPrint(query.queryPart);
      throw Exception('And here we have the promised exception :)');

      dynamic result;
      try {
        result = _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'delete(): An exception during third party library operation occured: ${e.toString()}');
      }

      debugPrint(
          'delete(): A result of delete method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());
      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(null);
    });
    return completer.future;
  }

  @override
  @protected
  Future<Map?> read(ConditionModel model,
      {Set<String>? columnNames,
      String? globalServerRequestKey = null,
      ConditionModelUser? userForGlobalRequest,
      Map? userLoginDataForGlobalRequest}
      /*ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
          whereClause*/
      ) {
    debugPrint('Model debug print: ${model['id']}');

    debugPrint(model.toString());

    debugPrint(
        'read() We are now in the read method of native platform ConditionDataManagementDriverSql driver.:');
    //debugPrint(whereClause.queryPart);
    Completer<Map?> completer = Completer<Map?>();

    //storageOperationsQueue.add(completer);

    /*var query =
        ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
          ..add('id', model['id']);

    readAll(
            model,
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
              ..add('id', model['id']),
            limit: 1,
            columnNames: columnNames,
            dbTableName: model.appCoreModelClassesCommonDbTableName,
            globalServerRequestKey: globalServerRequestKey)
        .then((List<ConditionMap>? conditionMapList) {
      if (conditionMapList == null) {
        completer.complete(null);
      } else {
        return completer.complete(conditionMapList[0]);
      }
    }).catchError((e) {
      // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
      completer.completeError(
          'Predefined error message, rather throw Excepthion custom class, There was a db_error');
    });


    */

    scheduleMicrotask(() async {
      try {
        await _commonBasicNeccesaryValidation(model, 'read',
            globalServerRequestKey: globalServerRequestKey,
            userForGlobalRequest: userForGlobalRequest,
            userLoginDataForGlobalRequest: userLoginDataForGlobalRequest);
      } catch (e) {
        completer.completeError(
            'DataManagementDriver read() method calling _getAppIdByAGivenGlobalServerKey() error: _commonBasicNeccesaryValidation() failed. error thrown: $e');
        rethrow;
      }

      Map<String, dynamic>? overwriteModelProperties;
      if (null != globalServerRequestKey) {
        // more careful checking
        if (model['server_id'] != null) {
          // Remidner if you use just server id you must check out if a client making
          // the update request has right to make the changes see all the method body with
          // comments
        } else {
          try {
            int app_id =
                await _getAppIdByAGivenGlobalServerKey(globalServerRequestKey);
            if (null != columnNames) {
              columnNames.add('app_id');
            }
            overwriteModelProperties = {'app_id': app_id};
          } catch (e) {
            debugPrint(
                'DataManagementDriver read() method calling _getAppIdByAGivenGlobalServerKey() error thrown: $e');
            completer.completeError(
                'DataManagementDriver read() method calling _getAppIdByAGivenGlobalServerKey() An operation on the global server (or global aspect of the app storage server) coldn\'t has been performed and the app_id couldn\'t has been obtained, so updating of model data that was sent from client app to the global server cannot be performed.');
          }
        }
      }

      var query =
          ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon(
              model,
              columnNames: columnNames,
              overwriteModelProperties: overwriteModelProperties,
              // earlier more thorough key checking or exception up there
              isGlobalRequest: null != globalServerRequestKey ? true : false);

      debugPrint(
          'read() Not to get lost and to understand where we are we are going to see the development query and throw an exception to stop and think and repair');
      debugPrint(query.queryPart);
      // throw Exception('And here we have the promised exception :)');

      dynamic result;
      try {
        result = _db.select(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'read() An exception during third party library operation occured: ${e.toString()}');
      }

      debugPrint(
          'read() A result of read method has arrived and in the debug mode it seems it successfully done, the query was ${query.queryPart} and the result it looks like this:');
      debugPrint(result.toString());
      if (result != null && !result.isEmpty) {
        debugPrint(
            "read() Result is not null nor empty ant it looks like this:${result.first.toString()}");
      } else {
        debugPrint('read() Result is null or empty which is technically fine.');
      }

      completer
          .complete(result != null && !result.isEmpty ? result.first : null);
    });
    return completer.future;
  }

  @override
  @protected
  Future<List<Map>?> readAll(
      String
          modelClassName, //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
      ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
          whereClause,
      {int? limit = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
      Set<String>? columnNames,
      String? dbTableName, // see modelClassName double slash comment
      String? globalServerRequestKey,
      String? tableNamePrefix}) {
    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    }

    if (globalServerRequestKey != null && globalServerRequestKey.isEmpty) {
      throw Exception(
          'DataManagementDriver readAll() method calling exception: method cannot start processing the read all request on the global aspect of the server, because while (or if you prefer although, or because interchangebly) the globalServerRequestKey is not null, however it\'s empty.');
    }

    if (globalServerRequestKey != null) {
      debugPrint(
          'readAll() we are at the beginning of the method with globalServerRequestKey != null');
    } else {
      debugPrint(
          'readAll() we are at the beginning of the method with globalServerRequestKey == null');
    }

    Completer<List<Map>?> completer = Completer<List<Map>?>();
    //storageOperationsQueue.add(completer);
    //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);

    if (dbTableName != null) {
      debugPrint(
          'globalServerRequestKey == $globalServerRequestKey, readAll()  We are going to iterate enums ConditionModelClasses.values, there is going to be stuff seen here that it iterates or it went a bit wrong.');
      var i = 0;
      for (var enumValue in ConditionModelClasses.values) {
        i++;
        String className =
            enumValue.toString().replaceFirst('ConditionModelClasses.', '');
        if (className == modelClassName) {
          debugPrint(
              'globalServerRequestKey == $globalServerRequestKey, readAll() enum ConditionModelClasses value before:${enumValue.toString()} and the className after: $className');
          whereClause?.add(
              'model_type_id',
              i,
              ConditionDBOperator
                  .equal, // in class desc if ommited or null it means equal ConditionDBOperator.equal (not less than, not greater than)
              false);
          break;
        }
      }
    }

    // globalServerRequestKey is checked better above with an exception possible,
    //  now is used null checking:
    if (null != globalServerRequestKey)
      debugPrint(
          'globalServerRequestKey == $globalServerRequestKey, readAll(), debug flag: 1');
    bool isGlobalRequest = null == globalServerRequestKey ? false : true;
    if (null != globalServerRequestKey)
      debugPrint(
          'globalServerRequestKey == $globalServerRequestKey, readAll(), debug flag: 2 this.driverGlobal == ${this.driverGlobal}, but this.tableNamePrefix == ${this.tableNamePrefix}, but ConditionConfiguration.isClientApp == ${ConditionConfiguration.isClientApp}');

    //+ (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}

    ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon query;
    try {
      query = ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon
          .dbTableNameQuery(
              (tableNamePrefix ?? this.tableNamePrefix) +
                  //older solutions, but this condition is for crud operations
                  //using models like read (not readAll), delete (not deleteRawer), etc.
                  //(!isGlobalRequest
                  //        ? this
                  //        : ConditionConfiguration.isClientApp
                  //            ? driverGlobal
                  //                as ConditionDataManagementDriver
                  //            : this)
                  //    .tableNamePrefix) +
                  (dbTableName ?? modelClassName),
              whereClause,
              columnNames: columnNames,
              maxNumberOfReturnedResults: limit);
    } catch (e) {
      if (null != globalServerRequestKey)
        debugPrint(
            'globalServerRequestKey == $globalServerRequestKey, readAll(), debug flag: 2!A! ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon exception: $e');
      rethrow;
    }

    if (null != globalServerRequestKey)
      debugPrint(
          'globalServerRequestKey == $globalServerRequestKey, readAll(), debug flag: 3');

    if (null != globalServerRequestKey)
      debugPrint(
          'K] globalServerRequestKey == $globalServerRequestKey, readAll() Not to get lost and to understand where we are we are going to see the development query: query.queryPart == ${query.queryPart}');

    debugPrint(query.queryPart);
    //throw Exception('And here we have the promised exception :)');

    scheduleMicrotask(() {
      dynamic result;
      try {
        if (null != globalServerRequestKey)
          debugPrint(
              'globalServerRequestKey == $globalServerRequestKey, readAll(), debug flag: 4');
        result = _db.select(query.queryPart);
        if (null != globalServerRequestKey)
          debugPrint(
              'globalServerRequestKey == $globalServerRequestKey, readAll(), debug flag: 5');
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'K] globalServerRequestKey == $globalServerRequestKey, readAll() An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'K] globalServerRequestKey == $globalServerRequestKey, readAll() A result of readAll method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());
      if (result == null) {
        debugPrint(
            'K] readAll() : seeking result[0][\'id\'] BUT result == null');
      } else if (result.isEmpty) {
        debugPrint(
            'K] readAll() : seeking result[0][\'id\'] BUT result.isEmpty == true');
      } else {
        debugPrint('K] readAll() : result[0][\'id\'] == ${result[0]['id']}');
        debugPrint(
            'K] readAll() : result[0][\'id\'].runtimeType == ${result[0]['id'].runtimeType}');
      }
      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      // And if exception wasn\'t thrown
      if (!completer.isCompleted) {
        debugPrint(
            'K] COMPLETEING WITH THE RESULT readAll() : result == ${result} ');
        completer.complete(result);
      }
    });

    return completer.future;
  }
}
