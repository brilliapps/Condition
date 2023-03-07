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

  @override
  bool _initiated = false;

  ConditionDataManagementDriverSql({
    Completer<ConditionDataManagementDriver>? initCompleter,
    String? dbNamePrefix,
    String? tableNamePrefix,
    bool isGlobalDriver = false,
    bool hasGlobalDriver = false,
    ConditionDataManagementDriver? driverGlobal,
    Completer<ConditionDataManagementDriver>? initCompleterGlobal,
    ConditionDataManagementDriverSqlSettings? settings,
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
        // a method local variable not to confuse with [_initiated] this private property
        bool isAppDbInitiated = true;
        try {
          debugPrint(
              'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;');
          // In this case We can only fully rely on exception thrown when a table doesn't exist
          dynamic select_is_deb_initiated = _db.select('''
          SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;
        ''');
          // when table exists this one will always return result of type int from 0 to more than 0
          debugPrint(
              'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;' +
                  select_is_deb_initiated[0]['count(*)'].toString());
        } catch (e) {
          debugPrint(
              'table doesn\'t exist, so no relevant table with initial data exists');
          isAppDbInitiated = false;
        }

        if (!isAppDbInitiated) {
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

            _initiated = true;
            initCompleter.complete(this);
          }).catchError((error) {
            initCompleter.completeError(false);
          });
        } else {
          _initiated = true;
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
  Future<int> getModelIdByOneTimeInsertionKey(
      ConditionModelIdAndOneTimeInsertionKeyModel model,
      {String? globalServerRequestKey}) {
    if (model.one_time_insertion_key == null)
      Exception(
          'model with model.one_time_insertion_key == null cannot be used in this method');

    // ??? : Condition should never be used, however some re-implementations can be wrong, this is after any other request is run, so on the first db request an Exception should already has been thrown
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }
    Completer<int> completer = Completer<int>();
    storageOperationsQueue.add(completer);

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

  @override
  Future<bool> nullifyOneTimeInsertionKey(
      ConditionModelIdAndOneTimeInsertionKeyModel model,
      {String? globalServerRequestKey = null}) {
    // Condition should never be used, however some re-implementations can be wrong, this is after any other request is run, so on the first db request an Exception should already has been thrown
    if (!_initiated)
      throw const ConditionDataManagementDriverNotInitiatedException();
    Completer<bool> completer = Completer<bool>();
    storageOperationsQueue.add(completer);

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
  Future<bool> createRawer(
      String
          modelClassName, //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
      Map<String, dynamic> noModelColumnNamesWithValues,
      {Set<String>? columnNames,
      String? dbTableName, // see modelClassName double slash comment
      String? globalServerRequestKey,
      String? tableNamePrefix}) {
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }

    Completer<bool> completer = Completer<bool>();
    storageOperationsQueue.add(completer);
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
        'createRawer (createAll or similar: not create()): Not to get lost and to understand where we are we are going to see the development query and throw an exception to stop and think and repair');
    debugPrint(query.queryPart);
    throw Exception(
        'createRawer (createAll or similar: not create()) And here we have the promised exception :)');

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
  CreateModelOnServerFutureGroup<int?> create(ConditionModel model,
      {Set<String>? columnNames, String? globalServerRequestKey = null}) {
    // ------------------------------------------------------------
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // READ THIS YOU MUST TAKE CARE IF A MODEL
    // HAS PROPERTY: appCoreModelClassesCommonDbTableName SET TO 'ConditionModelWidget'
    // AND MAYBE HERE SOME OTHER STUFF LIKE - IS A MODEL DYNAMIC? ONE ROW MODEL OF ID = 1 ALWAYS?

    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }
    Completer<int?> completerCreate = Completer<int?>();
    // notice it is int not int? below:
    Completer<int> completerModelIdByOneTimeInsertionKey = Completer<int>();
    CreateModelOnServerFutureGroup<int?> createModelOnServerFutureGroup =
        CreateModelOnServerFutureGroup<int?>(completerCreate.future,
            completerModelIdByOneTimeInsertionKey.future);

    storageOperationsQueue.add(completerCreate);
    storageOperationsQueue.add(completerModelIdByOneTimeInsertionKey);
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
            columnNames: columnNames);

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

    // scheduleMicrotask is to run the function asynchronously so that it the later created [CreateModelFutureGroup] can be returned now and the db operations can be done later
    scheduleMicrotask(() {
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
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }

    Completer<List<int>?> completer = Completer<List<int>?>();
    storageOperationsQueue.add(completer);
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

  @override
  Future<bool> update(ConditionModel model,
      {Set<String>? columnNames, String? globalServerRequestKey = null}) {
    if (model['id'] == null || model['id'] < 1) {
      Exception(
          'model with no defined model.id or model[\'id\'] or null, or less than 1 cannot be used');
    }
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }
    //return Future.value();
    Completer<bool> completer = Completer<bool>();
    storageOperationsQueue.add(completer);

    // No need to create the variable? the variable exists rather for the debugPrint purposes, no need to maintain the object long term
    var query =
        ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon(
            model,
            columnNames: columnNames);
    debugPrint(
        'UPDATE model == ${model.runtimeType} we are now in the ConditionDataManagement object invoking UPDATE method. let\' see how the query looks like and then throw exception until it is ok:');
    debugPrint(query.queryPart);
    //throw Exception('UPDATE The just promised Exception thrown');

    scheduleMicrotask(() {
      dynamic result;
      try {
        result = _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'An exception during third party library operation occured: ${e.toString()}');
      }

      debugPrint(
          'A result of update method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(true);
    });

    return completer.future;
  }

  /// while officially it does return int? containing rows affected, the result is to be ignored and treated as unreliable with only completer.completeError() telling that something went wrong. The result may be null for now - implementation may be difficult for each platform. Checking what rows might has been affected should be done programmatically in a separate request while update data should contain something unique to check what rows might has been affected - f.e. using the same where query but for select query while using readAll method.
  @override
  Future<List<int>?> deleteAll(
      String
          modelClassName, //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
      ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
          whereClause,
      { // some sqlite implementation not handling limit int? limit = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
      String? dbTableName, // see modelClassName double slash comment
      String? globalServerRequestKey,
      String? tableNamePrefix}) {
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }

    Completer<List<int>?> completer = Completer<List<int>?>();
    storageOperationsQueue.add(completer);
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
  Future<bool> delete(ConditionModel model,
      {String? globalServerRequestKey = null}) {
    if (model['id'] == null || model['id'] < 1) {
      Exception(
          'delete(): model with no defined model.id or model[\'id\'] or null, or less than 1 cannot be used');
    }
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }
    //return Future.value();
    Completer<bool> completer = new Completer<bool>();
    storageOperationsQueue.add(completer);
    var query =
        ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlCommon(
            model);

    debugPrint(
        'delete(): Not to get lost and to understand where we are we are going to see the development query and throw an exception to stop and think and repair');
    debugPrint(query.queryPart);
    throw Exception('And here we have the promised exception :)');

    scheduleMicrotask(() {
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
  Future<Map?> read(ConditionModel model,
      {String? globalServerRequestKey, Set<String>? columnNames}
      /*ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
          whereClause*/
      ) {
    debugPrint('Model debug print: ${model['id']}');

    debugPrint(model.toString());
    if (model is! ConditionModelOneDbEntryModel &&
        (model['id'] == null || model['id'] < 1)) {
      Exception(
          'model with expected but not defined model.id or model[\'id\'] or null, or less than 1 cannot be used');
    }

    debugPrint(
        'read() We are now in the read method of native platform ConditionDataManagementDriverSql driver.:');
    //debugPrint(whereClause.queryPart);
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }
    Completer<Map?> completer = Completer<Map?>();

    storageOperationsQueue.add(completer);

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
    var query =
        ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon(
            model,
            columnNames: columnNames);

    debugPrint(
        'read() Not to get lost and to understand where we are we are going to see the development query and throw an exception to stop and think and repair');
    debugPrint(query.queryPart);
    // throw Exception('And here we have the promised exception :)');

    scheduleMicrotask(() {
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
    if (!_initiated) {
      throw const ConditionDataManagementDriverNotInitiatedException();
    }

    Completer<List<Map>?> completer = Completer<List<Map>?>();
    storageOperationsQueue.add(completer);
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
      debugPrint('K] readAll() : result[0][\'id\'] == ${result[0]['id']}');
      debugPrint(
          'K] readAll() : result[0][\'id\'].runtimeType == ${result[0]['id'].runtimeType}');

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      completer.complete(result);
    });

    return completer.future;
  }
}