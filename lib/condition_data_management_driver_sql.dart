import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:async/async.dart' show FutureGroup;
import 'dart:ffi';
import 'dart:io';
import 'condition_data_managging.dart';

import 'condition_custom_annotations.dart';
import 'condition_configuration.dart';
import 'condition_data_management_driver_sql_settings.dart';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

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
    _initStorage();
  }

  @override
  void _initStorage() {
    debugPrint('1We are here aren\'t we?');
    // ! Take note that this code is based on synchronous nature of the pub.dev sqlite3 package
    // To not to block the main layout thread more sophisticated
    // implementation based on isolates should be implemented (the best)
    // for now it is achieved in limited scope using asynchronous scheduleMicrotask()
    scheduleMicrotask(() {
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

        if (Platform.isWindows) {
          // now windows only
          DynamicLibrary.open(ConditionConfiguration
              .paths_to_sqlite_core_library[ConditionPlatforms.Windows]);
          _db = sqlite3.open(settings_sqlite3
              .native_platform_sqlite3_db_paths[ConditionPlatforms.Windows]!);
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

          final file = File(ConditionConfiguration.fullSQLDbInitPath)
              .readAsString()
              .then((String contents) {
            // ?? commented unused variable declaration: this shouldn't be used for native, indexes are to be created, this line was probably for test and preparation for sqlweb github web plugin:  const String create_index_regex_string =   r'CREATE[\r\n\t\s]*INDEX[^;]*[;]*';

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
          }).catchError((error) {
            initCompleter.completeError(false);
          });
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
  @Deprecated(
      'This was (still is?) used only in very early development stages and for testing purposes')
  static Future /*DatabaseImpl*/ getDbEngine() {
    return Future/*<DatabaseImpl>*/(() {
      DynamicLibrary.open('./sqlite3.dll');
      return sqlite3.open('./condition_data_management_driver_sql.sqlite');
    });

    // Create a table and insert some data
    //db.execute('''
    //CREATE TABLE artists (
    //  id INTEGER NOT NULL PRIMARY KEY,
    //  name TEXT NOT NULL
    //);
    //''');
  }

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

    try {
      List<Map>? conditionMapList = await readAll(
          'ConditionModelApps',
          ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
            ..add('key', key),
          limit: 1,
          columnNames: {'id'});

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
    if (model.one_time_insertion_key == null)
      Exception(
          'model with model.one_time_insertion_key == null cannot be used in this method');

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
          'A result of readAll (that was invoked by getModelIdByOneTimeInsertionKey) has arrived. Here how it looks like:');

      if (conditionMapList == null) {
        debugPrint('It is null :(');
        completer.completeError(
            'error: getModelIdByOneTimeInsertionKey() The id value couldn\'t has been obtained. It normally means a record hasn\'t been inserted during a preceding create()/insert into operation. It requires to insert the model again into the db.');
      } else {
        debugPrint(
            'It is not null :) so we change it toString and parse to int and complete future with this int :${int.tryParse(conditionMapList[0].toString())}');
        // !!!!!! RIDICULOUS RETURN :)
        //return completer.complete(int.tryParse(conditionMapList[0].toString()));
        //completer.complete(int.tryParse(conditionMapList[0].toString()));
        completer.complete(conditionMapList[0]['id']);
      }
    }).catchError((e) {
      // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
      completer.completeError(
          'Predefined error message, rather throw Excepthion custom class, There was a db_error');
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

  Future<int> _getAppIdByAGivenGlobalServerKey(String globalServerKey) async {
    Completer<int> completer = Completer<int>();

    return completer.future;
  }

  @override
  @protected
  CreateModelOnServerFutureGroup<int?> create(ConditionModel model,
      {Set<String>? columnNames, String? globalServerRequestKey = null}) {
    // ------------------------------------------------------------
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // READ THIS YOU MUST TAKE CARE IF A MODEL
    // HAS PROPERTY: appCoreModelClassesCommonDbTableName SET TO 'ConditionModelWidget'
    // AND MAYBE HERE SOME OTHER STUFF LIKE - IS A MODEL DYNAMIC? ONE ROW MODEL OF ID = 1 ALWAYS?

    if (!inited) {
      throw const ConditionDataManagementDriverNotinitedException();
    } else if (null != globalServerRequestKey &&
        globalServerRequestKey.isEmpty) {
      throw Exception(
          'DataManagementDriver create() method: exception: the mode cannot be updated on the global aspect of the server, because while the globalServerRequestKey is not null, however it\'s empty.');
    }

    Completer<int?> completerCreate = Completer<int?>();
    // notice it is int not int? below:
    Completer<int> completerModelIdByOneTimeInsertionKey = Completer<int>();
    CreateModelOnServerFutureGroup<int?> createModelOnServerFutureGroup =
        CreateModelOnServerFutureGroup<int?>(completerCreate.future,
            completerModelIdByOneTimeInsertionKey.future);

    //storageOperationsQueue.add(completerCreate);
    //storageOperationsQueue.add(completerModelIdByOneTimeInsertionKey);
    // scheduleMicrotask is to run the function asynchronously so that it the later created [CreateModelFutureGroup] can be returned now and the db operations can be done later
    scheduleMicrotask(() async {
      Map<String, dynamic>? overwriteModelProperties;
      if (null != globalServerRequestKey) {
        try {
          int app_id =
              await _getAppIdByAGivenGlobalServerKey(globalServerRequestKey);
          // for create we don't need to overwrite id with null value because the query builder
          // will skip the column for the main constructor of the query accepting model object.
          if (null != columnNames) columnNames.add('app_id');
          overwriteModelProperties = {'app_id': app_id};
        } catch (e) {
          debugPrint(
              'DataManagementDriver create() method calling _getAppIdByAGivenGlobalServerKey() error thrown: $e');
          completerCreate.completeError(
              'DataManagementDriver create() method calling _getAppIdByAGivenGlobalServerKey() An operation on the global server (or global aspect of the app storage server) coldn\'t has been performed and the app_id couldn\'t has been obtained, so creating a global server db table row based on model data that was sent from client app to the global server cannot be performed.');
          completerModelIdByOneTimeInsertionKey.completeError(
              'DataManagementDriver create() method calling _getAppIdByAGivenGlobalServerKey() An operation on the global server (or global aspect of the app storage server) coldn\'t has been performed and the app_id couldn\'t has been obtained, so creating a global server db table row based on model data that was sent from client app to the global server cannot be performed.');
        }
      }

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
              overwriteModelProperties: overwriteModelProperties);

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
        completerCreate.completeError(
            'An object couldn\'t has been created the raw driver error: ${e.toString()}');
        completerModelIdByOneTimeInsertionKey.completeError(
            'Getting id by getModelIdByOneTimeInsertionKey() method has failed because an earlier operation of creating db table row had also failed');
      }

      debugPrint(
          'A result of create has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result);

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      if (model is ConditionModelOneDbEntryModel) {
        completerCreate.complete(1);
        completerModelIdByOneTimeInsertionKey.complete(1);
        return;
      } else {
        completerCreate.complete(null);
      }

      if (model is ConditionModelIdAndOneTimeInsertionKeyModel) {
        getModelIdByOneTimeInsertionKey(model).then((id) {
          debugPrint(
              'A result of getModelIdByOneTimeInsertionKey invoked by create method has arrived and in the debug mode it seems it successfully done and it looks like this:');
          debugPrint(id.toString());
          completerModelIdByOneTimeInsertionKey.complete(id);
        }).catchError((error) {
          debugPrint(
              'An !error! result of getModelIdByOneTimeInsertionKey invoked by create method has arrived and in the debug mode it seems it successfully done and it looks like this:');
          debugPrint(error.toString());
          completerModelIdByOneTimeInsertionKey.completeError(
              'Getting id by getModelIdByOneTimeInsertionKey() method has failed, raw db driver error: ${error.toString()}');
        });
      } else {
        debugPrint(
            'A model is not of ConditionModelIdAndOneTimeInsertionKeyModel class so a completer of create method is completed with null ');
        completerModelIdByOneTimeInsertionKey.completeError(
            'It\'s almost not even an exception, so if you use catchError of the Future object or async programming you can handle it. The message you see is to made you aware of a problem and to be aware you need to conciously approach it not to flood your db with potential garbage. The point: A row in the database has been created, however there is no way to obtain the id of the inserted row, because you hadn\'t used a model compatible with classess [ConditionModelIdAndOneTimeInsertionKeyModel] (read description) or [ConditionModelOneDbEntryModel] where id always = 1. Do you created the model class in a way that allows to find it\'s entry in the db? A method like readAll (maybe renamed to readRaw of somehting allows you to find what you seek in the db in a more flexible, customized way.)');
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
  Future<bool> update(ConditionModel model,
      {Set<String>? columnNames,
      String? globalServerRequestKey = null,
      ConditionModelUser? userForGlobalRequest,
      Map? userLoginDataForGlobalRequest}) {
    //return Future.value();
    Completer<bool> completer = Completer<bool>();
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
              isGlobalServerAspectUpdate:
                  null != globalServerRequestKey ? true : false);
      debugPrint(
          'UPDATE model == ${model.runtimeType} we are now in the ConditionDataManagement object invoking UPDATE method. let\' see how the query looks like and then throw exception until it is ok:');
      debugPrint(query.queryPart);
      //throw Exception('UPDATE The just promised Exception thrown');

      dynamic result;
      try {
        result = _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'DataManagementDriver update() method An exception during third party library operation occured: ${e.toString()}');
      }

      debugPrint(
          'DataManagementDriver update() method A result of update method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(true);
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
              isGlobalServerAspectUpdate:
                  null != globalServerRequestKey ? true : false);

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
              isGlobalServerAspectUpdate:
                  null != globalServerRequestKey ? true : false);

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
      }

      completer.complete(result.first);
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

    Completer<List<Map>?> completer = Completer<List<Map>?>();
    //storageOperationsQueue.add(completer);
    //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);

    if (dbTableName != null) {
      debugPrint(
          'readAll() We are going to iterate enums ConditionModelClasses.values, there is going to be stuff seen here that it iterates or it went a bit wrong.');
      var i = 0;
      for (var enumValue in ConditionModelClasses.values) {
        i++;
        String className =
            enumValue.toString().replaceFirst('ConditionModelClasses.', '');
        if (className == modelClassName) {
          debugPrint(
              'readAll() enum ConditionModelClasses value before:${enumValue.toString()} and the className after: $className');
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
        ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon
            .dbTableNameQuery(
                (tableNamePrefix ?? this.tableNamePrefix) +
                    (dbTableName ?? modelClassName),
                whereClause,
                columnNames: columnNames,
                maxNumberOfReturnedResults: limit);

    debugPrint(
        'K] readAll() Not to get lost and to understand where we are we are going to see the development query:');
    debugPrint(query.queryPart);
    //throw Exception('And here we have the promised exception :)');

    scheduleMicrotask(() {
      dynamic result;
      try {
        result = _db.select(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'K] readAll() An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'K] readAll() A result of readAll method has arrived and in the debug mode it seems it successfully done and it looks like this:');
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
        completer.complete(result);
      }
    });

    return completer.future;
  }
}
