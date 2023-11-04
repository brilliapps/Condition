import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'condition_platform.dart'
    if (dart.library.html) 'condition_platform_web.dart'; // especially for web localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later
//    if (dart.library.io) 'condition_platform_non_web.dart'; // especially for web localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later
import 'package:collection/collection.dart'; // for extending map class with added functionality not overriding the existing stuff it should later be replaced with not importing this library not to give too much overhead (optimisation) like f.e. MapBase class alternative //https://stackoverflow.com/questions/21081210/dart-extends-map-to-facilitate-lazy-loading class LazyMap implements Map {
//import 'package:flutter/material.dart';
import 'dart:convert';
import 'condition_multi_types.dart';
// probably to remove or to change data format to sql to test on native platform, not waisting the time on web
import 'example_data.dart';
import 'dart:async';
import 'package:async/async.dart';
//import 'package:meta/meta.dart';
import 'condition_app_base.dart'; //empty informational and later etended class used by server and frontend/native/web
import 'condition_custom_annotations.dart';
import 'condition_configuration.dart';
//import 'condition_storage_drag_and_drop_box.dart';

// to be removed and replaced entirely
//import 'package:hive/hive.dart'; // to be removed

//import 'condition_db.dart'
//    if (dart.library.html) 'condition_db_web.dart'; // especially for web localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later
//import 'condition_data_management_driver_sql.dart';
//    if (dart.library.html) 'condition_data_management_driver_sql.web.dart'; // especially for web (!now indexedDB) localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later

//import 'condition_data_management_driver_server.fallback.dart'; // condition_data_management_driver_server.web.dart probably in extended unchanged form uses it but when condition_data_management_driver_server.dart is not working properly this fallback one is to be used
//import 'condition_data_management_driver_server.dart' // only dart or native like windows, android (not web)    if (dart.library.html) 'condition_data_management_driver_server.web.dart'; // uses condition_data_management_driver_server.fallback.dart in a not changed form or as an extenstion of the class - yet to see.

//import 'condition_data_management_driver_sql_settings.dart';
import 'condition_data_management_sqlite3_db_object.dart'
    if (dart.library.html) 'condition_data_management_sqlite3_db_object.web.dart';

/// Non-standard engine compatible with sqlite3 other than sqlite3 is passed via driver constructor and used if not null. For web mysql won't ever be used directly and it will be automatically switched what to use and when but web will get stub class/methods not to throw any exceptions, while mysql is normally remote connection stuff a remote standard ConditionDataManagementDriver for proxy-like http connection will be used.
//import 'condition_data_management_mysql_db_object.dart'    if (dart.library.html) 'condition_data_management_mysql_db_object.web.dart';

//import 'condition_data_management_driver_SQLDBCommonRawDriverSqlite3CompatibilityInterface.dart';

import 'condition_data_management_sqlite3_db_object.dart'
    if (dart.library.html) 'condition_data_management_sqlite3_db_object.web.dart'; // especially for web localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later

class TestPrivateProtected {
  String rrrrrrrr = 'abc1';
  String _rrrr = 'abc2';
  @protected
  String rrrr = 'abc3';
  @protected
  String _wwww = 'abc4';
}

class TestPrivateProtectedChild extends TestPrivateProtected {
  TestPrivateProtectedChild() {
    debugPrint(
        rrrr); // ok - in the same file no errors for protected but also no error when in another file there is an extending class but error for accessing from outside the class abc.rrrr no-error info or error if you change linter rules in analysys options yaml
    debugPrint(
        _rrrr); // ok - in the same file no errors for privates in the other file always errors
    debugPrint(_wwww); // ok - in the same file
  }
}

// Avoid especially regex (maybe like too) until it is fully implemented and all major db engines (like mysql) compatible
enum ConditionDataManagementDriverQueryBuilderPartWhereClauseConditionOperator {
  equal,
  not_equal,
  less,
  less_or_equal,
  greater,
  greater_or_equal,
  is_null,
  is_not_null,
  //not,
  between,
  not_between,
  in_,
  not_in,
  like,
  not_like,
  regex, // regex may not be quickly implemented
  not_regex // regex may not be quickly implemented
}

/// shorthand of more readable and understandable long named type
typedef ConditionDBOperator
    = ConditionDataManagementDriverQueryBuilderPartWhereClauseConditionOperator;

/// Important ideas how it all works (development in progress) may currently be in the [ConditionDataManagementDriverQueryBuilderWhereClause] class. Any class implementing this interface will need to use lesser building blocks like f.e. [ConditionDataManagementDriverQueryBuilderWhereClause] instance. Some methods, f.e. of the [ConditionDataManagementDriver] class may take as param not a full query but such a building block as param, but must build full query internally using this block/part of a query. This interface represents full db query, with logic that works best with sql like queries, but wchich not it is restricted to. This abstract class in an educational way tells you how implementing it real-world query builders are to look like. Character of this class implies to use it as an interface not something to extend, which is different to [ConditionDataManagementDriver] class that can contain some all db engine common solutions - f.e. results of a read query are the same for all extending classess, so you can use common methods to operate on a predictable standarised results.
abstract class ConditionDataManagementDriverQueryBuilder {
  ConditionDataManagementDriverQueryBuilder();
}

/// Used by [ConditionDataManagementDriverSql] this class represents full query, and not everywhere there will be need of using full query, sometimes [ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon] may be enough.
/// The aim is that the query build by this class should work on all SQL engines like sqlite3, sqlweb github plugin, mysql, postgres, etc.
class ConditionDataManagementDriverQueryBuilderSqlCommon
    implements ConditionDataManagementDriverQueryBuilder {
  ConditionDataManagementDriverQueryBuilderSqlCommon();
}

mixin ConditionDataManagementDriverQueryBuilderPartColumnNamesAndValuesSqlCommon {
  /// Method needed because some SQL dialects need (or once needed) name surrounded with quotes  ' " ` some not, some allow or not allow some kind of quotes
  String getColumnName(String name) {
    return name; // Sqlite3 like syntax as starting point - more in overall readme file
  }

  String getValuePart(value) => value is String
      ? '\'${value.replaceAll("'", "''")}\''
      : value.toString().replaceAll("'", "''");
}

/// Some ideas described in [ConditionDataManagementDriverQueryBuilderPartWhereClause] class
class ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon
    with
        ConditionDataManagementDriverQueryBuilderPartColumnNamesAndValuesSqlCommon {
  /// If null, all columns will be red (wildcard SELECT *). If not nUll this means column Names that will be selected.
  Set<String>? columnNames;

  /// Model to be updated. Depending on the constructor used the model is used or [dbTableName] property Instead
  final ConditionModel? model;
  int? maxNumberOfReturnedResults;
  ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
      whereClause;

  /// See [model] property description first. There are methods of [ConditionDataManagementDriver] class like [read](), that receive a [ConditionModel] object, but there is [readModelType]() method reading based on class name toString, and in such a case in not all but some cases a custom dbTableName to be used can be passed. This value is more important than [model].[appCoreModelClassesCommonDbTableName] and the latter is more important thant default [model].[runtimeType].[toString]() table name.
  final String? dbTableName;
  Map<String, dynamic>? overwriteModelProperties;
  final bool isGlobalRequest;

  ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon(
    ConditionModel
        this.model, // not accidentallyy is not null in the constructor
    {
    this.columnNames,
    //this.dbTableName,
    this.overwriteModelProperties,
    this.maxNumberOfReturnedResults =
        ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    this.isGlobalRequest = false,
  })  : dbTableName = null,
        whereClause =
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
                .add(
                    !isGlobalRequest
                        ? 'id'
                        : model['server_id'] != null
                            ? 'server_id'
                            : 'local_id',
                    !isGlobalRequest
                        ? model is ConditionModelOneDbEntryModel
                            ? 1
                            : model['id']
                        : model['server_id'] ?? model['local_id'])
                .add(
                    // if null, this method call will be ignored but the query object will be returned
                    !isGlobalRequest
                        ? null
                        : model['server_id'] != null
                            ? null
                            : 'app_id',
                    !isGlobalRequest
                        ? null
                        : model['server_id'] != null
                            ? null
                            : overwriteModelProperties!['app_id']);

  ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon.dbTableNameQuery(
    String this.dbTableName, // not null in this constructor
    this.whereClause, {
    this.columnNames,
    this.maxNumberOfReturnedResults =
        ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    this.isGlobalRequest = false,
  }) : model = null;

  String get queryPart {
    // dont need to cache anything - the select part is short, but the whereClause part may return a casched whereClause.queryPart String
    //model.appCoreModelClassesCommonDbTableName
    String queryPart = '';

    queryPart += 'SELECT ';
    if (null == columnNames || columnNames!.isEmpty) {
      queryPart += '* ';
    } else {
      for (int i = 0; i < columnNames!.length; i++) {
        if (i != 0) {
          queryPart += ', ';
        }
        queryPart += getColumnName(columnNames!.elementAt(i));
      }
    }

    //queryPart += ' FROM "${dbTableName ?? model!.driver.tableNamePrefix + (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}" ';

    queryPart +=
        ' FROM "${dbTableName ?? (!isGlobalRequest ? model!.driver : ConditionConfiguration.isClientApp ? model!.driver.driverGlobal : model!.driver)!.tableNamePrefix + (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}" ';

    if (null != whereClause) {
      queryPart += whereClause!.queryPart;
    }

    if (maxNumberOfReturnedResults != null && maxNumberOfReturnedResults! > 0)
      queryPart += ' LIMIT $maxNumberOfReturnedResults';

    return '$queryPart;';
  }
}

class ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlite3
    extends ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlCommon {
  ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlite3(
    super.model, // not accidentallyy is not null in the constructor
    {
    super.columnNames,
    //this.dbTableName,
    super.maxNumberOfReturnedResults =
        ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    super.isGlobalRequest = false,
  });

  ConditionDataManagementDriverQueryBuilderPartSelectClauseSqlite3.dbTableNameQuery(
    dbTableName, // not null in this constructor
    whereClause, {
    columnNames,
    maxNumberOfReturnedResults =
        ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    isGlobalRequest = false,
  }) : super.dbTableNameQuery(
          dbTableName, // not null in this constructor
          whereClause,
          columnNames: columnNames,
          maxNumberOfReturnedResults: maxNumberOfReturnedResults,
          isGlobalRequest: isGlobalRequest,
        );
}

/// For now the one update version updates models only with all or chosen columns
class ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon
    with
        ConditionDataManagementDriverQueryBuilderPartColumnNamesAndValuesSqlCommon {
  /// If true (default) it may prevents from using a malfunctioning query from updating all rows.
  bool dontUpdateOnEmptyWhereClause;

  /// If null, all columns will be red (wildcard SELECT *). If not nUll this means column Names that will be selected.
  Set<String>? columnNames;
  Map<String, dynamic>? overwriteModelProperties;

  /// Model to be updated. Depending on the constructor used the model is used or [dbTableName] property Instead
  final ConditionModel? model;
  final Map<String, dynamic>? noModelColumnNamesWithValues;

  int? maxNumberOfReturnedResults;
  ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon whereClause;

  /// See [model] property description first. There are methods of [ConditionDataManagementDriver] class like [read](), that receive a [ConditionModel] object, but there is [readModelType]() method reading based on class name toString, and in such a case in not all but some cases a custom dbTableName to be used can be passed. This value is more important than [model].[appCoreModelClassesCommonDbTableName] and the latter is more important thant default [model].[runtimeType].[toString]() table name.
  final String? dbTableName;
  final bool isGlobalRequest;

  ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon(
    ConditionModel
        this.model, // not accidentallyy is not null in the constructor
    {
    this.columnNames,
    this.overwriteModelProperties,
    //this.dbTableName,
    // below removed maxNumberOfReturnedResults https://stackoverflow.com/questions/29071169/update-query-with-limit-cause-sqlite
    // this.maxNumberOfReturnedResults = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    this.dontUpdateOnEmptyWhereClause = true,
    this.isGlobalRequest = false,
  })  : dbTableName = null,
        noModelColumnNamesWithValues = null,
        whereClause =
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
                .add(
                    !isGlobalRequest
                        ? 'id'
                        : model['server_id'] != null
                            ? 'server_id'
                            : 'local_id',
                    !isGlobalRequest
                        ? model is ConditionModelOneDbEntryModel
                            ? 1
                            : model['id']
                        : model['server_id'] ?? model['local_id'])
                .add(
                    // if null, this method call will be ignored but the query object will be returned
                    !isGlobalRequest
                        ? null
                        : model['server_id'] != null
                            ? null
                            : 'app_id',
                    !isGlobalRequest
                        ? null
                        : model['server_id'] != null
                            ? null
                            : overwriteModelProperties!['app_id']);

  ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon.dbTableNameQuery(
    String this.dbTableName, // not null in this constructor
    Map<String, dynamic>
        this.noModelColumnNamesWithValues, // not null in this constructor
    whereClause, {
    this.columnNames,
    // below removed maxNumberOfReturnedResults https://stackoverflow.com/questions/29071169/update-query-with-limit-cause-sqlite
    // this.maxNumberOfReturnedResults = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    this.dontUpdateOnEmptyWhereClause = true,
    this.isGlobalRequest = false,
  })  : this.model = null,
        this.whereClause = whereClause ??
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
                .add('id', noModelColumnNamesWithValues['id']);

  String get queryPart {
    // dont need to cache anything - the select part is short, but the whereClause part may return a casched whereClause.queryPart String
    //model.appCoreModelClassesCommonDbTableName
    String queryPart = '';

    //queryPart +='UPDATE "${dbTableName ?? model!.driver.tableNamePrefix + (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}" SET ';

    queryPart +=
        'UPDATE "${dbTableName ?? (!isGlobalRequest ? model!.driver : ConditionConfiguration.isClientApp ? model!.driver.driverGlobal : model!.driver)!.tableNamePrefix + (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}" SET ';

//    if (null == columnNames || columnNames!.isEmpty) {
    //queryPart += '* ';

    // depending on the constructor used as seen above we use condition to pickup the db name: ${dbTableName ?? model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString()}
    // And now and ine the else {} part:
    // model and as you see above
    // or the pair:
    //String this.dbTableName, // not null in this constructor
    //Map<String, dynamic> this.noModelColumnNamesWithValues, // not null in this constructor

    bool isNotFirstIteration = false;
    if (model != null) {
      for (String key in model!.keys) {
        if (columnNames != null && !columnNames!.contains(key)) {
          continue;
        }
        if (isNotFirstIteration) queryPart += ', ';
        try {
          if (null != overwriteModelProperties &&
              overwriteModelProperties!.keys.contains(key)) {
            queryPart +=
                '${getColumnName(key)} = ${getValuePart(overwriteModelProperties![key])}';
          } else {
            queryPart += '${getColumnName(key)} = ${getValuePart(model![key])}';
          }
        } catch (e) {
          debugPrint(
              'ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon error, probably not initialized field key: $key of a model of class ${model.runtimeType.toString()}');
          rethrow;
        }
        isNotFirstIteration = true; // this has meaning in the next iteration
      }
    } else {
      for (String key in noModelColumnNamesWithValues!.keys) {
        if (columnNames != null && !columnNames!.contains(key)) {
          // may be not necessary but lets be 100% flexible
          continue;
        }
        if (isNotFirstIteration) queryPart += ', ';
        queryPart +=
            '${getColumnName(key)} = ${getValuePart(noModelColumnNamesWithValues![key])}';
        isNotFirstIteration = true; // this has meaning in the next iteration
      }
    }
//    } else {
//      bool isNotFirstIteration = false;
//      if (model != null) {
//        for (String key in columnNames!) {
//          if (columnNames != null && !columnNames!.contains(key)) {
//            continue;
//          }
//          if (isNotFirstIteration) queryPart += ', ';
//          if (!model!.containsKey(key)) {
//            throw Exception(
//                'ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon a ColumnName (of columnNames property) supplied doesn\'t belong to the model');
//          }
//          queryPart += '${getColumnName(key)} = ${getValuePart(model![key])}';
//          isNotFirstIteration = true; // this has meaning in the next iteration
//        }
//      } else {
//        for (String key in columnNames!) {
//          if (isNotFirstIteration) queryPart += ', ';
//          queryPart +=
//              '${getColumnName(key)} = ${getValuePart(noModelColumnNamesWithValues![key])}';
//          isNotFirstIteration = true; // this has meaning in the next iteration
//        }
//      }
//    }
//
    //if (null != whereClause) {
    queryPart += whereClause.queryPart;
    //}

    // limit for update delete not handled by all sqlite3 compilations
    //if (maxNumberOfReturnedResults != null && maxNumberOfReturnedResults! > 0) queryPart += ' LIMIT $maxNumberOfReturnedResults';

    return '$queryPart;';
  }
}

class ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlite3
    extends ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon {
  ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlite3(
    super.model, // not accidentallyy is not null in the constructor
    {
    super.columnNames,
    super.overwriteModelProperties,
    super.dontUpdateOnEmptyWhereClause = true,
  });

  ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlite3.dbTableNameQuery(
    dbTableName, // not null in this constructor
    noModelColumnNamesWithValues, // not null in this constructor
    whereClause, {
    columnNames,
    dontUpdateOnEmptyWhereClause = true,
    isGlobalRequest = false,
  }) : super.dbTableNameQuery(
          dbTableName, // not null in this constructor
          noModelColumnNamesWithValues, // not null in this constructor
          whereClause,
          columnNames: columnNames,
          dontUpdateOnEmptyWhereClause: dontUpdateOnEmptyWhereClause,
          isGlobalRequest: isGlobalRequest,
        );
}

///
class ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlCommon {
  /// Model to be updated. Depending on the constructor used the model is used or [dbTableName] property Instead
  final ConditionModel? model;
  int? maxNumberOfReturnedResults;
  ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
      whereClause;

  /// See [model] property description first. There are methods of [ConditionDataManagementDriver] class like [read](), that receive a [ConditionModel] object, but there is [readModelType]() method reading based on class name toString, and in such a case in not all but some cases a custom dbTableName to be used can be passed. This value is more important than [model].[appCoreModelClassesCommonDbTableName] and the latter is more important thant default [model].[runtimeType].[toString]() table name.
  final String? dbTableName;

  Map<String, dynamic>? overwriteModelProperties;
  final bool isGlobalRequest;

  ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlCommon(
    ConditionModel
        this.model, // not accidentallyy is not null in the constructor
    {
    this.overwriteModelProperties,
    //this.dbTableName,
    // below removed maxNumberOfReturnedResults https://stackoverflow.com/questions/29071169/update-query-with-limit-cause-sqlite
    // this.maxNumberOfReturnedResults = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    bool isGlobalServerAspectUpdate = false,

    //this.dbTableName,
    // below removed maxNumberOfReturnedResults https://stackoverflow.com/questions/29071169/update-query-with-limit-cause-sqlite
    // this.maxNumberOfReturnedResults = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    this.isGlobalRequest = false,
  })  : dbTableName = null,
        whereClause =
            ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
                .add(
                    !isGlobalServerAspectUpdate
                        ? 'id'
                        : model['server_id'] != null
                            ? 'server_id'
                            : 'local_id',
                    !isGlobalServerAspectUpdate
                        ? model is ConditionModelOneDbEntryModel
                            ? 1
                            : model['id']
                        : model['server_id'] != null
                            ? model['server_id']
                            : model['local_id'])
                .add(
                    // if null, this method call will be ignored but the query object will be returned
                    !isGlobalServerAspectUpdate
                        ? null
                        : model['server_id'] != null
                            ? null
                            : 'app_id',
                    !isGlobalServerAspectUpdate
                        ? null
                        : model['server_id'] != null
                            ? null
                            : overwriteModelProperties!['app_id']);

  ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlCommon.dbTableNameQuery(
    String this.dbTableName, // not null in this constructor
    this.whereClause, {
    this.isGlobalRequest = false,
    // below removed maxNumberOfReturnedResults https://stackoverflow.com/questions/29071169/update-query-with-limit-cause-sqlite
    // this.maxNumberOfReturnedResults = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
  }) : model = null;

  String get queryPart {
    // dont need to cache anything - the select part is short, but the whereClause part may return a casched whereClause.queryPart String
    //model.appCoreModelClassesCommonDbTableName
    String queryPart = '';

    //queryPart += 'DELETE FROM "${dbTableName ?? model!.driver.tableNamePrefix + (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}" ';

    queryPart +=
        'DELETE FROM "${dbTableName ?? (!isGlobalRequest ? model!.driver : ConditionConfiguration.isClientApp ? model!.driver.driverGlobal : model!.driver)!.tableNamePrefix + (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}" ';

    if (null != whereClause) {
      queryPart += whereClause!.queryPart;
    }

    //if (maxNumberOfReturnedResults != null && maxNumberOfReturnedResults! > 0)  queryPart += ' LIMIT $maxNumberOfReturnedResults';

    return '$queryPart;';
  }
}

class ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlite3
    extends ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlCommon {
  ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlite3(
    super.model, {
    super.isGlobalRequest = false,
  });

  ConditionDataManagementDriverQueryBuilderPartDeleteClauseSqlite3.dbTableNameQuery(
    dbTableName, // not null in this constructor
    whereClause, {
    maxNumberOfReturnedResults =
        ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
    isGlobalRequest = false,
  }) : super.dbTableNameQuery(
            dbTableName, // not null in this constructor
            whereClause,
            isGlobalRequest: isGlobalRequest);
}

/// A callback function. If passed to a contstructor of a class like [ConditionDataManagementDriverQueryBuilderWhereClause] it is invoked each time a query part is to be used in a buildig a full query string. If returns true a query part is to be used. If you not pass this argument a query string buildging proces might be faster which is important only in big data apps, which seems not to be the case. These solutions is to give you more control over parts of a full query - f.e. right now some services of your app are available but some not, you can turn off some parts of the query, to speed up the app, save resources like memory, bandwidth, procesor. Again this means anyghing in big data.
typedef ConditionDataManagementDriverQueryBuilderIsQueryPartActive<bool>
    = Function;

/// Edit: This class is already full implementation in hopes it work f.e. sqlite3, mysql, postgress, etc. This class in an educational way tells you how implementing it real-world query builders are to look like.
/// See also [query_parts] desc and more properties to get the idea how the SQL string query is builded (other non sql implementations can be created of course)
/// Not now, not neccessary but for informational purposes: Is this needed? : Complete Query part removal is predicted (or not necessary) here and on the full query [ConditionDataManagementDriverQueryBuilder] class level which among others contains this optional [ConditionDataManagementDriverQueryBuilderPartWhereClause] query part
class ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
    with
        ConditionDataManagementDriverQueryBuilderPartColumnNamesAndValuesSqlCommon {
  /// The list will be translated in case of SQl to abc = 10 OR cde = 'ttt' like string surrounded with parentheses ( ) if isGroup is set to true and that group preceded with "OR" if isOr is set to true but "AND" if false. F.e. AND (abc = 10 OR cde = 'ttt')
  List<List> queryParts = [];

  // WARNING. I dont see It is necessary. if the constructor "[isMainQuery]" named param - if set up or set up to true (by default) means that object of this class in case of sql implementation will precede query string with " WHERE " prefix.
  // bool isMainQuery;

  /// if the constructor "[isGroup]" named param is set to true (false by default) - it is a group of conditions, at the same time part of where query which in sql means that it is surrounded by () parenthesis (column = 10 or column = 20)
  bool isGroup;

  /// Will be made invalid when [isActiveCallback] set. For your app to be more scallable, to have more control over query you can switch it off on:
  bool isActive;

  /// if the constructor "[isOr]" param is ommited or null it means equal ConditionDBOperator.equal (not less than, not greater than)
  bool isOr;

  /// See more the [_queryCashed] and [hasQueryChanged] description. This is important to cashe query in the form of a String if it hasn't been changed since the last real-life use, creating query string from heavy query_parts fancy [List] can be resource consuming, it is better to get the not-that-long query string from a cashe if it was not changed in the meantime, the cashe is returned or re-created each time query_part getter is invoked (kind of lazy cashing). if true, query will be stored in a property [queryCashed] and updated when [hasQueryChanged] is set to true (this happens when you add a new condition to a query like, speaking in sql syntax: "or a = 20")
  bool isQueryCashed;

  /// See more the [isQueryCashed] description. If true, it tells this class to create cashed query String ([queryCashed] property) when [isQueryCashed] == true each time the query changed, but only at the moment when the string-query version is needed (lazy cashing). All that to not to create the string version of the query each time it is needed.
  bool hasQueryChanged = true;

  /// See more the [hasQueryChanged] description.
  late String _queryCashed;

  /// Overrides the behaviour of [isActive] property See up to date [ConditionDataManagementDriverQueryBuilderIsQueryPartActive] function type description. Older version: of If passed to a contstructor of a class like [ConditionDataManagementDriverQueryBuilderPartWhereClause] it is invoked each time a query part is to be used in a buildig a full query string. If returns true a query part is to be used. If you not pass this argument a query string buildging proces might be faster which is important only in big data apps, which seems not to be the case. These solutions is to give you more control over parts of a full query - f.e. right now some services of your app are available but some not, you can turn off some parts of the query, to speed up the app, save resources like memory, bandwidth, procesor. Again this means anyghing in big data.
  ConditionDataManagementDriverQueryBuilderIsQueryPartActive<bool>?
      isActiveCallback;

  ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon({
    // check if it is removed entirely: this.isMainQuery = true, // in class desc
    this.isOr = true,
    this.isGroup = false, // in class desc
    this.isActive = true, // in class desc
    this.isActiveCallback,
    this.isQueryCashed = true,
  });

  ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon add(
      String? fieldName, dynamic value,
      [ConditionDBOperator operator = ConditionDBOperator
          .equal, // in class desc if ommited or null it means equal ConditionDBOperator.equal (not less than, not greater than)
      isOr = true // OR for true, false if AND
      ]) {
    if (null == fieldName) return this;
    hasQueryChanged = true;
    queryParts.add([fieldName, value, operator, isOr]);

    return this;
  }

  ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
      addQueryPart(
          ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
              queryPart) {
    hasQueryChanged = true;

    queryParts.add([queryPart]);

    return this;
  }

  /// The value is needed for IS NULL, where a SQL implementation might allow for using == null (don't know if there is any) Method needed because some SQL dialects may need f.e "<>" or "!=" for not equal, etc.
  String getOpearatorWithValue(ConditionDBOperator operator, dynamic value) {
    switch (operator) {
      case ConditionDBOperator.equal:
        return '= ${getValuePart(value)}';
      case ConditionDBOperator.not_equal:
        return '<> ${getValuePart(value)}';
      case ConditionDBOperator.less:
        return '< ${getValuePart(value)}';
      case ConditionDBOperator.less_or_equal:
        return '<= ${getValuePart(value)}';
      case ConditionDBOperator.greater:
        return '> ${getValuePart(value)}';
      case ConditionDBOperator.greater_or_equal:
        return '>= ${getValuePart(value)}';
      case ConditionDBOperator.between:
      case ConditionDBOperator.not_between:
        return '${operator == ConditionDBOperator.not_between ? 'NOT ' : ''}BETWEEN ${getValuePart(value[0])} AND ${getValuePart(value[1])}';
      case ConditionDBOperator.in_:
      case ConditionDBOperator.not_in:
        String values = '';
        for (int i = 0; i < value.length; i++) {
          if (i > 0 && i + 1 < value.length) values += ',';
          values += getValuePart(value);
        }
        return '${operator == ConditionDBOperator.not_in ? 'NOT ' : ''}IN ($values)';
      case ConditionDBOperator.is_null:
        return 'IS NULL';
      case ConditionDBOperator.is_not_null:
        return 'IS NOT NULL';
      case ConditionDBOperator.like:
      case ConditionDBOperator.not_like:
        return '${operator == ConditionDBOperator.not_like ? 'NOT ' : ''}LIKE ${getValuePart(value)}';
      // regex may not be quickly implemented
      case ConditionDBOperator.regex:
      case ConditionDBOperator.not_regex:
        UnimplementedError(
            ConditionCustomAnnotationsMessages.MustBeImplemented);
        return '';
    }
  }

  /// Recursively invoked, on recursion [subQueryParts] param is not null. Some technical aspects: the object which this method was invoked on cares for returning "where" keyword, decides whether or not to put some part of query into parenthesis, precede it with or/and keyword etc. It is important because this object is part of query, but some elements of [queryParts] List are just arrays of strings representing a single contition, but some elements are instances of [ConditionDataManagementDriverQueryBuilderPartWhereClause] class, which means we don't call their [prepareQueryPartString] method but we are still in the first method called in the conditions tree - it is so, because by this we can avoid situations like there is couple of where clauses, we put or condition where it should be bacause it is the only condition in parentheses if you know wha'e meen.  In Readme is the question is it a reference to the same object? subQueryParts=queryParts . as far as i knot for int it would be a different object, but i quess not for the list
  String prepareQueryPart([List<List>? subQueryParts]) {
    String queryPart = '';

    // the method invoked for the first time, not recursively
    if (subQueryParts == null) {
      queryPart += ' WHERE ';
      subQueryParts = queryParts;
    }

    for (int i = 0; i < subQueryParts.length; i++) {
      // First condition never is preceded with OR or AND if it is main condition or a child group or non-group condition. Again: parent query-part object puts the OR, AND.
      if (subQueryParts[i][0] is String) {
        if (i != 0) {
          if (subQueryParts[i][3] == true) {
            queryPart += ' OR ';
          } else {
            queryPart += ' AND ';
          }
        }
        queryPart +=
            "${getColumnName(subQueryParts[i][0])} ${getOpearatorWithValue(subQueryParts[i][2], subQueryParts[i][1])}";

        /*
        dynamic value,
        ConditionDBOperator operator = ConditionDBOperator
            .equal, // in class desc if ommited or null it means equal ConditionDBOperator.equal (not less than, not greater than)
        isOr = true // OR for true, false if AND */
        //[fieldName, value, operator, isOr]

        //if (false) {}
        //queryPart+=subQueryParts[];
      } else {
        //this one property is removed probably: this.isMainQuery = true, // in class desc
        //child.isOr = true,
        //child.isGroup = false, // in class desc
        //child.isActive = true, // in class desc
        //child.isActiveCallback,y
        ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
            subQueryPart = subQueryParts[i][0];
        bool isActive = false;
        dynamic isActiveCallbackResult = '';
        if (subQueryPart.isActiveCallback is Function) {
          isActiveCallbackResult = subQueryPart.isActiveCallback!();
          if (isActiveCallbackResult == true) isActive == true;
        } else {
          isActive = subQueryPart.isActive == true ? true : false;
        }
        if (!isActive) continue;
        if (i != 0) {
          if (subQueryPart.isOr == true) {
            queryPart += ' OR ';
          } else {
            queryPart += ' AND ';
          }
        }

        if (subQueryPart.isGroup) queryPart += '(';
        queryPart += prepareQueryPart(subQueryPart.queryParts);
        if (subQueryPart.isGroup) queryPart += ')';
      }
    }

    return queryPart;
  }

  String get queryPart {
    //implement it with those properties in mind.
    if (!isQueryCashed) return prepareQueryPart();
    if (hasQueryChanged) {
      _queryCashed = prepareQueryPart();
      hasQueryChanged = false;
    }
    return _queryCashed;
  }

  //ConditionDataManagementDriverQueryBuilderWhereClause.createFromMap() {}

  /*ConditionDataManagementDriverQueryBuilderPartWhereClause addCondition() {
    return this;
  }*/
}

/// NO NEED TO USE OR DEVELOP THE CLASS FOR NOW (BY DESIGN), USE [ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon] INSTEAD for sqlite3 or sqlweb github web plugin. By "...Common" Part of the class name it is to be understood sql query string is universal and 100% compatible and should work the same on all major sql db engines or syntaxes sql92 (?), sqlite3/websql, sqlweb (github plugin - currently sqlite query is transformed by some js script where necessary), mysql, postgres, hopefully mssql and so on. As was once said in the READ.me file when the app and code is well established then, without removing any earlier achievement the code can be optimised by some class extensions
class ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlite3
    extends ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon {
  ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlite3({
    // check if it is removed entirely: this.isMainQuery = true, // in class desc
    super.isOr,
    super.isGroup, // in class desc
    super.isActive, // in class desc
    super.isActiveCallback,
    super.isQueryCashed,
  });
}

/// No need to cashe for now - it seems the class is kind of one time
/// a base for the syntax of the query produced by the class is the following INSERT command - might be changed to conform to sqlweb github plugin (platform web).
/// INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (1,	'ConditionModelContact');
class ConditionDataManagementDriverQueryBuilderPartInsertClauseSqlCommon
    with
        ConditionDataManagementDriverQueryBuilderPartColumnNamesAndValuesSqlCommon {
  /// If null, all columns will be red (wildcard SELECT *). If not nUll this means column Names that will be selected.
  final Set<String>? columnNames;
  Map<String, dynamic>? overwriteModelProperties;
  final bool isGlobalRequest;

  /// Model to be updated. Depending on the constructor used the model is used or [dbTableName] property Instead
  final ConditionModel? model;
  final Map<String, dynamic>? noModelColumnNamesWithValues;

  /// See [model] property description first. There are methods of [ConditionDataManagementDriver] class like [read](), that receive a [ConditionModel] object, but there is [readModelType]() method reading based on class name toString, and in such a case in not all but some cases a custom dbTableName to be used can be passed. This value is more important than [model].[appCoreModelClassesCommonDbTableName] and the latter is more important thant default [model].[runtimeType].[toString]() table name.
  final String? dbTableName;

  ConditionDataManagementDriverQueryBuilderPartInsertClauseSqlCommon(
    ConditionModel
        this.model, // not accidentallyy is not null in the constructor
    {
    this.columnNames,
    this.overwriteModelProperties,
    this.isGlobalRequest = false,
  })  : dbTableName = null,
        noModelColumnNamesWithValues = null;

  ConditionDataManagementDriverQueryBuilderPartInsertClauseSqlCommon.dbTableNameQuery(
    String this.dbTableName, // not null in this constructor
    Map<String, dynamic>
        this.noModelColumnNamesWithValues, // not null in this constructor
    {
    this.columnNames,
    this.isGlobalRequest = false,
  }) : model = null;

  /// No need to cashe for now - it seems the class is kind of one time, if it was cashed and big, it might be permanent memory consuming
  String get queryPart {
    //implement it with those properties in mind.
    String queryPart =
        'INSERT INTO "${dbTableName ?? (!isGlobalRequest ? model!.driver : ConditionConfiguration.isClientApp ? model!.driver.driverGlobal : model!.driver)!.tableNamePrefix + (model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString())}" (';

//    if (null == columnNames || columnNames!.isEmpty) {
    //queryPart += '* ';

    // depending on the constructor used as seen above we use condition to pickup the db name: ${dbTableName ?? model!.appCoreModelClassesCommonDbTableName ?? model.runtimeType.toString()}
    // And now and ine the else {} part:
    // model and as you see above
    // or the pair:
    //String this.dbTableName, // not null in this constructor
    //Map<String, dynamic> this.noModelColumnNamesWithValues, // not null in this constructor

    bool isNotFirstIteration = false;
    if (model != null) {
      for (String key in model!.keys) {
        if (key == 'id') {
          continue;
        }
        if (columnNames != null && !columnNames!.contains(key)) {
          continue;
        }
        if (isNotFirstIteration) {
          queryPart += ', ';
        } else {
          if (model is ConditionModelOneDbEntryModel) {
            queryPart += '${getColumnName('id')}, ';
          }
        }
        queryPart += getColumnName(key);
        isNotFirstIteration = true; // this has meaning in the next iteration
      }
    } else {
      for (String key in noModelColumnNamesWithValues!.keys) {
        if (columnNames != null && !columnNames!.contains(key)) {
          continue;
        }
        if (key == 'id') {
          continue;
        }
        if (isNotFirstIteration) queryPart += ', ';
        queryPart += getColumnName(key);
        isNotFirstIteration = true; // this has meaning in the next iteration
      }
    }
//    } else {
//      bool isNotFirstIteration = false;
//      if (model != null) {
//        for (String key in columnNames!) {
//          if (key == 'id') {
//            continue;
//          }
//          if (isNotFirstIteration) {
//            queryPart += ', ';
//          } else {
//            if (model is ConditionModelOneDbEntryModel) {
//              queryPart += '${getColumnName('id')}, ';
//            }
//          }
//
//          if (!model!.containsKey(key)) {
//            throw Exception(
//                'ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon a ColumnName (of columnNames property) supplied doesn\'t belong to the model');
//          }
//          queryPart += getColumnName(key);
//          isNotFirstIteration = true; // this has meaning in the next iteration
//        }
//      } else {
//        for (String key in columnNames!) {
//          if (key == 'id') {
//            continue;
//          }
//          if (isNotFirstIteration) queryPart += ', ';
//          queryPart += getColumnName(key);
//          isNotFirstIteration = true; // this has meaning in the next iteration
//        }
//      }
//    }

    queryPart += ') VALUES (';
//    if (null == columnNames || columnNames!.isEmpty) {
    isNotFirstIteration = false;
    if (model != null) {
      for (String key in model!.keys) {
        if (key == 'id') {
          continue;
        }
        if (columnNames != null && !columnNames!.contains(key)) {
          continue;
        }
        if (isNotFirstIteration) {
          queryPart += ', ';
        } else {
          if (model is ConditionModelOneDbEntryModel) {
            queryPart += '${getValuePart(1)}, ';
          }
        }
        try {
          debugPrint(
              'key $key of ${model.runtimeType.toString()} will be assigned to query');
          if (null != overwriteModelProperties &&
              overwriteModelProperties!.keys.contains(key)) {
            queryPart += getValuePart(overwriteModelProperties![key]);
          } else {
            queryPart += getValuePart(model![key]);
          }
          debugPrint(
              'key $key of ${model.runtimeType.toString()} has been assigned successfully');
        } catch (e) {
          debugPrint(
              'key $key of ${model.runtimeType.toString()} exceptinog - not be assigned to query');
          queryPart += getValuePart(null);
          //rethrow;
        }
        isNotFirstIteration = true; // this has meaning in the next iteration
      }
    } else {
      for (String key in noModelColumnNamesWithValues!.keys) {
        if (key == 'id') {
          continue;
        }
        if (columnNames != null && !columnNames!.contains(key)) {
          continue;
        }
        if (isNotFirstIteration) queryPart += ', ';
        queryPart += getValuePart(noModelColumnNamesWithValues![key]);
        isNotFirstIteration = true; // this has meaning in the next iteration
      }
    }
//    } else {
//      bool isNotFirstIteration = false;
//      if (model != null) {
//        for (String key in columnNames!) {
//          if (key == 'id') {
//            continue;
//          }
//          if (!model!.containsKey(key)) {
//            throw Exception(
//                'ConditionDataManagementDriverQueryBuilderPartUpdateClauseSqlCommon a ColumnName (of columnNames property) supplied doesn\'t belong to the model');
//          }
//          if (isNotFirstIteration) queryPart += ', ';
//          if (isNotFirstIteration) {
//            queryPart += ', ';
//          } else {
//            if (model is ConditionModelOneDbEntryModel) {
//              queryPart += '${getValuePart(1)}, ';
//            }
//          }
//          queryPart += getValuePart(model![key]);
//          isNotFirstIteration = true; // this has meaning in the next iteration
//        }
//      } else {
//        for (String key in columnNames!) {
//          if (key == 'id') {
//            continue;
//          }
//          if (isNotFirstIteration) queryPart += ', ';
//          queryPart += getValuePart(noModelColumnNamesWithValues![key]);
//          isNotFirstIteration = true; // this has meaning in the next iteration
//        }
//      }
//    }

    queryPart += ');';

    debugPrint(
        'INSERT INTO query that is going to be performed looks like this:');
    debugPrint(queryPart);
    return queryPart;
  }
}

/// Normally web is designed can and is prepared to use [ConditionRawSQLDBDriverWrapperSqlite3] only. But if you really, really want to have a custom raw driver ([conditionRawDBDriverWrapper] propertt of [ConditionDataManagementDriverSql]) for web a class implementing [ConditionRawSQLDBDriverWrapperCommon] must be mixed [ConditionRawSQLDBDriverWrapperCommonWebOrWebProxy]. If not mixed the non-null [conditionRawDBDriverWrapper] will be ignored for web.
mixin class ConditionRawSQLDBDriverWrapperCommonWebOrWebProxy {}

/// Read [ConditionDataManagementDriver] overall desc (things related to drivers comparison). For a custom web wrapper additionally read [ConditionRawSQLDBDriverWrapperCommonWebOrWebProxy] The interface is to ensure all methods and return results from db are standarised probably patterned on what sqlite3 package returns for methods like select, execute. It is good to remember that the db connection have rights to do all common sql queries like using create table, select, insert which may will be translated from f.e. sqlite to mysql syntax if really necessary. See particular implementations. But any raw SQL driver gets sqlite3/sql92 syntax or similar as input. The original engine for sql db was sqlite3, and all - queriy syntax, methods are sqlite3 compatible and translated to other packages like packages for mysql, postgresql, so you need to use a wrapper/interface for those engines to be compatible with sqlite3 methods. While sqlite3 doesn't need the wrapper it uses it to so that proper types are used for example in the ConditionDataManagementDriverSql constructor optional param [SQLDBCommonRawDriverSqlite3CompatibilityInterface] [SQLDBCommonRawDriverSqlite3CompatibilityWrapper]
interface class ConditionRawSQLDBDriverWrapperCommon {
  /// This is helping in creating a unique [hashcode], may be used in autodetecting SQL syntax in some cases, and ofcoursee this fullfills informative role because there might be two completely separate SQL-like engine implementations (sqlite3 f.e.). It is used for counting the [hashcode]
  final ConditionAppDataManagementEnginesEnum type;

  /// Static, fully funcitonal you can call it now as is. Like in some classes f.e. [ConditionDataManagementDriver] there is fully useful method like the getDefaultWrapper which in not needed to be implemented or overriden just you do class your class .... with ConditionRawSQLDBDriverWrapperCommonGetDefaultWrapper, etc.
  static ConditionRawSQLDBDriverWrapperCommon getDefaultWrapper(
      [bool isGlobalDriver = false]) {
    return ConditionRawSQLDBDriverWrapperSqlite3(
        ConditionDataManagementDriverSqlSettings.getDefaultSettings(
            isGlobalDriver));
  }

  /// Different databases may need different settings and maybe even a class implementing this interface may not need the settings at all and they could be any [Type] so it is declared here as dynamic is left for now. The type of the object requires that the object is useful in operator == comparison, also in counding the hashcode, see the type description and this class description.
  @protected
  final ConditionDataManagementDriverSqlSettings dbSettings;

  /// Wrapper is used as final but this object can be replaced during the wrapper lifetime so it is not final and some freedom of implementation is given. This is object you directly all your sql commands on like db.select(), execute(), etc. We don't know what kind of dynamic Object it will be - some misterious c++ one, maybe..., wasm, pure js under the hood for web, maybe... This variable stores the real object allowing for performing SQL queries. The object can have defined different methods to achieve that. For example sqlite3 package defines db.select() method for the SELECT clause, but db.execute() method for the remaining clauses like INSERT, DELETE, CREATE TABLE. Now you may see why it is a good idea to make a common wrapper so you don't use the [db] object but common this object implementing this class/interface. This doesn't take part in calculating hashcode and in == operator overriding, because we assume we do not know anything about the object and what to use from it to get unique info to know whether or not such an object equals to any other or not.
  @protected
  late dynamic db;

  /// If true this driver has already been inited and ready to work with
  @protected
  late final bool inited;

  /// see the [inited] description
  bool get isInited {
    try {
      return inited;
    } catch (e) {
      return false;
    }
  }

  /// This stores information whether or not the triver has already been inited and ready to work with, returns [this] object itself
  @protected
  final Completer<ConditionRawSQLDBDriverWrapperCommon> initCompleter =
      Completer<ConditionRawSQLDBDriverWrapperCommon>();

  /// Any override of should be a copy of this method.
  Future<ConditionRawSQLDBDriverWrapperCommon> getDriverWhenInited() =>
      initCompleter.future;

  ConditionRawSQLDBDriverWrapperCommon(this.dbSettings, this.type);

  /// this method is used only for web so no need to implement it anywhere, it is properly implemented in C:\flutterprojects\condition\lib\condition_data_management_sqlite3_db_object.web.dart, the method is left for not throwing possible error during compilaition time.
  Future<String>? httpGetFileContents(String path) => null;

  /// As of now for db wraper objects due to different low level sql connection implementations execute does all the stuff including update (returned updated int or List<int> ids are implemented by [ConditionDataManagementDriver] object corresponging update, updateAll methods) except for select method which does SELECT column FROM table. Only this.[select] can return something. But this method throws exception on failure or completes completer with error which is async exception. Older description: If success this future just finishes or an exception is thrown, no need for bool return. Be ready for handling exceptions (no internet connection, etc).
  Future<void> execute(String query) => Future(() => db.execute(query));

  /// The return for wrapper needs to be standarized. This is not counter-intuitive expected result. Be ready for handling exceptions (no internet connection, etc).
  Future<List<Map<String, dynamic>>?> select(String query) =>
      Future(() => db.select(query));

  //Future<List<Map<String, dynamic>>?> select(String query) {
  //  Completer<List<Map<String, dynamic>>?> completer =
  //      Completer<List<Map<String, dynamic>>?>();
  //  scheduleMicrotask(() {
  //    // in this case db.select returns value synchronously, if not await should be before db.select and this code block {...}, nor this entire method itself, should be async {}
  //    debugPrint(
  //        'wrapper select method() 1: here we are, the query is $query the possible result in a while');
  //    var result = db.select(query);
  //    debugPrint(
  //        'wrapper select method() 2: here we are, the result is: $result');
  //    completer.complete(db.select(query));
  //  });
  //  return completer.future;
  //}

  /// Warning! Don't use it, not required to be implemented! But it is for you to have such an option... And use the async [execute] method instead. the method is always success or exception is thrown like with the [execute]. Most probably only for sqlite3 here it could throw exception. Be ready for handling exceptions (no internet connection, etc).
  executeSynchronous(String query) => db.execute(
      query); // We can implement only if we know that the db.execute returns result synchronously.

  /// Warning! Don't use it, not required to be implemented! But it is for you to have such an option... And use the async [select] method instead. Be ready for handling exceptions (no internet connection, etc).
  List<Map<String, dynamic>>? selectSynchronous(String query) => db.select(
      query); // Only implement if db.select returns value synchronously, if not await should be before db.select and this code block {...}, nor this entire method itself, should be async {}

  /// Used by == operator and hashCode. Used elsewhere as sort of informal standart.
  List<dynamic> equalityComparisonProperties() =>
      <dynamic>[type] + dbSettings.equalityComparisonProperties();

  /// This method contains example approximate implementation code. Description copied from [ConditionDataManagementDriverSqlSettings] class - the same rule. Overall it is described up-to-date in the [ConditionDataManagementDriver] class what uses what and for what. Needed to be overriden in non-abstract class. If == true the two objects refer to the same database/dbfile/dbname but not involves checking for the same prefixes for tables/dbname, they are defined and used by [ConditionDataManagement] instance and this uses db wrapper [ConditionRawSQLDBDriverWrapperCommon].
  /// Caution about @mustBeOverriden annotation here, read all carefully! By default dart won't require you to override operators and hashCode so this annotation enfoces that but it will require to implement it in each class extending class that already implemented interface with this method. So you must in first implementation of this method add @mustCallSuper and in a class extending the class just return only what super.overriden method returns like return super == object; for == operator or return super.hashCode; for hashCode method  @override
  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (identical(other, this) ||
        (other is ConditionRawSQLDBDriverWrapperSqlite3Base &&
            other.equalityComparisonProperties() ==
                equalityComparisonProperties())) {
      return true;
    }
    //if (!(super == (other))) return false;
    return false;
  }

  /// This method contains example approximate implementation code. See operator == description for this class - this shouldn't return 10 like here (it is possible but don't do that), but you should understand what hashcode is for, etc. so go to this class == operator description
  /// Caution about @mustBeOverriden annotation here, read all carefully! By default dart won't require you to override operators and hashCode so this annotation enfoces that but it will require to implement it in each class extending class that already implemented interface with this method. So you must in first implementation of this method add @mustCallSuper and in a class extending the class just return only what super.overriden method returns like return super == object; for == operator or return super.hashCode; for hashCode method  @override
  @override
  @mustBeOverridden
  int get hashCode => Object.hashAll(equalityComparisonProperties());
}

/// Shared part for the Sqlite3 implementation, sqlite3 is sort of core and default. Descrption taken from windows version of the class [To do: at the time of writing only windows sqlite3 library could be loaded and windows tested db file name] This class is an implementation of native version of the [ConditionRawSQLDBDriverWrapperCommon] interface.
abstract class ConditionRawSQLDBDriverWrapperSqlite3Base
    extends ConditionRawSQLDBDriverWrapperCommon {
  ConditionRawSQLDBDriverWrapperSqlite3Base(
    ConditionDataManagementDriverSqlSettingsSqlite3 dbSettings,
  ) : super(dbSettings, ConditionAppDataManagementEnginesEnum.sqlite3);

  /// You must override this method exactly this way: bool operator ==(Object other) => super == other;
  /// Read description this about this operator in the interface which has to do with @mustCallSuper annotation
  @override
  @mustCallSuper
  bool operator ==(Object other) {
    if (identical(other, this) ||
        (other is ConditionRawSQLDBDriverWrapperSqlite3Base &&
            other.equalityComparisonProperties() ==
                equalityComparisonProperties())) {
      return true;
    }
    //if (!(super == (other))) return false;
    return false;
  }

  /// You must override this method exactly this way: int get hashCode => super.hashCode;
  /// Read description this about this operator in the interface which has to do with @mustCallSuper annotation
  @override
  @mustCallSuper
  int get hashCode => Object.hashAll(equalityComparisonProperties());
}

/// Used by [ConditionDataManagementDriverSql] class. Read all this desc for compatibility SQL syntax f.e. sqlite3, in the future f.e. mysql - see condition_configuration.dart, also implementation in [getDefaultSettings] constructor for real configuration examples
/// As you can see there is a fallback getDefaultSettings that assumes that there is always [ConditionDataManagementDriverSqlSettingsSqlite3] correctly working original class awailable.
/// Additionally for sqlite3: the web will use a smart alternative - don't care about it. Watch out! requests compatible both with sqlite3 and js indexdb "sqlweb" (on github, it is based on jsstore by the same author)
/// http_proxy_sqlite value - sql via http protocol, maybe implemented in the future - don't think how - it is not a [ConditionDataManagementDriverServer] server it is to be dummy sql driver via http protocol - some outside http server just cruds - by this you could - some encryption may be needed?
/// Let me remind you sqlite3, sql92, websql, and sqlweb (github indexedDB sql plugin) common syntax is required. For mysql, postgres and other drivers sql syntax must be universal and compatible - if not some translation is needed from this app common sql syntax.
/// Important! Each extension to this class must add properties allowing to tell that an instance of such a class with its unique combination of settings always points to a unique database. If it happens that f.e. two settings objects of the same class (probably important operator "is" not necessarily runtimeType) differ slightly between two settings objects and yet it points to the same database it is considered wrong class extension. However it may works well depending on circumstances like handling many connections to a database, which even may be allowed on [ConditionRawSQLDBDriverWrapperCommon] level if not even higher on [ConditionDataManagementDriver] (a developing story :)
abstract interface class ConditionDataManagementDriverSqlSettings {
  /// Two important roles. 1: This fullfills informative role because there might be two completely separate sqlite3 implementations. 2: It is used for counting the [hashcode]
  final ConditionAppDataManagementEnginesEnum type;

  const ConditionDataManagementDriverSqlSettings({
    required this.type, // the web will use a smart alternative - don't care about it. Watch out! requests compatible both with sqlite3 and js indexdb "sqlweb" (on github, it is based on jsstore by the same author)
  });

  /// sqlite3 implementation (return value is sort of intrinsic to the whole condition library) [to do:] This method for now takes paths for windows only // at the time of writing it was suspected that the Windows path might work anywhere (linux only?)
  static ConditionDataManagementDriverSqlSettingsSqlite3 getDefaultSettings(
      [bool is_global_server = false]) {
    if (is_global_server) {
      return ConditionDataManagementDriverSqlSettingsSqlite3(
          dbPath: ConditionConfiguration
                  .global_http_server_settings['db_settings']
              ['native_platform_sqlite3_db_paths'][ConditionConfiguration
                  .isWeb
              ? ConditionPlatforms.Web
              : ConditionPlatforms
                  .Windows], // at the time of writing it was suspected that the Windows path might work anywhere (linux only?)
          login: ConditionConfiguration.isWeb
              ? null
              : ConditionConfiguration.global_http_server_settings['login'],
          password: ConditionConfiguration.isWeb
              ? null
              : ConditionConfiguration.global_http_server_settings['password']);
    } else {
      return ConditionDataManagementDriverSqlSettingsSqlite3(
          dbPath: ConditionConfiguration
                  .local_http_server_settings['db_settings']
              ['native_platform_sqlite3_db_paths'][ConditionConfiguration
                  .isWeb
              ? ConditionPlatforms.Web
              : ConditionPlatforms
                  .Windows], // at the time of writing it was suspected that the Windows path might work anywhere (linux only?)
          login: ConditionConfiguration.isWeb
              ? null
              : ConditionConfiguration.local_http_server_settings['login'],
          password: ConditionConfiguration.isWeb
              ? null
              : ConditionConfiguration.local_http_server_settings['password']);
    }
  }

  /// Get wrapper for [this] object. Normally you use just return likeConditionRawSQLDBDriverWrapperCommon(this); Warning: of course [ConditionRawSQLDBDriverWrapperCommon] is noninstantiable. It means instsantiable class implementing the [ConditionRawSQLDBDriverWrapperCommon] interface.
  /// Not to confuse with static methods like getDefaultWrapper() in [ConditionRawSQLDBDriverWrapperCommon] which creates working default library wrapper and creates default settings. This method here is for this settings instance.
  ConditionRawSQLDBDriverWrapperCommon getWrapper();

  /// This or similar method as for now appears also for ConditionDataManagementDriver as an informal pattern
  @mustCallSuper
  List<dynamic> equalityComparisonProperties() => [type];

  /// Overall it is described up-to-date in the [ConditionDataManagementDriver] class what uses what and for what. Needed to be overriden in non-abstract class. If == true the two objects refer to the same database/dbfile/dbname but not involves checking for the same prefixes for tables/dbname, they are defined and used by [ConditionDataManagement] instance and this uses db wrapper [ConditionRawSQLDBDriverWrapperCommon].
  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (identical(other, this) ||
        (other is ConditionDataManagementDriverSqlSettingsSqlite3 &&
            const ListEquality().equals(equalityComparisonProperties(),
                other.equalityComparisonProperties()))) {
      return true;
    }
    //if (!(super == (other))) return false;
    return false;
  }

  /// See operator == description for this class - this shouldn't return 10 like here (it is possible but don't do that), but you should understand what hashcode is for, etc. so go to this class == operator description
  @override
  @mustBeOverridden
  int get hashCode => Object.hashAll(equalityComparisonProperties());
}

/// This nterface is implemented by automatically loaded either Web or Native non-Base suffix classes. The sqlite3 is sort of easyli available standard that is to work out-of-the-box in the code whenever nothing else extending [ConditionDataManagementDriverSqlSettings] class was suplied. No need to override here's == operator or hashcode. Later make sure what to do if any param in the constructor is missing - f.e if you leave login and password but give some path to a sqlite3 file the default password may not work
class ConditionDataManagementDriverSqlSettingsSqlite3
    extends ConditionDataManagementDriverSqlSettings {
  // was: final Map<ConditionPlatforms, String>? native_platform_sqlite3_db_paths; and in the constructor something like this {this.native_platform_sqlite3_db_paths = const {ConditionPlatforms.Windows:            './condition_data_management_driver_sql_default.sqlite', // the web will use something else      },
  // now is:
  /// Web and native. Used in == operator and counting the hashcode. For web you can use some unique name of the db.
  final String dbPath;

  /// Native only, web doesn't use it. Used in == operator and  counting the hashcode, no need to override it
  final String? login;

  /// Native only, web doesn't use it. Used in == operator and  counting the hashcode
  final String? password;

  /// read class description and constructor must be const because it is passed as param in [ConditionDataManagementDriverServerSettings] class which requires creating const objects withoug constructor body
  const ConditionDataManagementDriverSqlSettingsSqlite3({
    required this.dbPath,
    this.login,
    this.password,
  }) : super(type: ConditionAppDataManagementEnginesEnum.sqlite3);

  @override
  ConditionRawSQLDBDriverWrapperCommon getWrapper() =>
      ConditionRawSQLDBDriverWrapperSqlite3(this);

  /// This or similar method as for now appears also for ConditionDataManagementDriver as an informal pattern
  @override
  List<dynamic> equalityComparisonProperties() =>
      super.equalityComparisonProperties() + [dbPath, login, password];

  @override
  bool operator ==(Object other) {
    if (identical(other, this) ||
        (other is ConditionDataManagementDriverSqlSettingsSqlite3 &&
            const ListEquality().equals(equalityComparisonProperties(),
                other.equalityComparisonProperties()))) {
      return true;
    }
    //if (!(super == (other))) return false;
    return false;
  }

  @override
  int get hashCode => Object.hashAll(equalityComparisonProperties());
}

/// Exception thrown when validate method doesn't allow for setting a value in a model setter. Models extend [ConditionModel] class
@Stub()
class ConditionDataManagementDriverNotinitedException implements Exception {
  final String msg;
  const ConditionDataManagementDriverNotinitedException(
      [this.msg =
          'Cannot perform any operation on a db, because the driver hasn\'t been inited. It is possible, that there were some errors dution initiation process, like lack of access to a remode db via internet (offline), or file system error or malformed/damaged sqlite3 database file, etc.']);

  @MustBeImplemented()
  String toString() => '${runtimeType}: $msg';
}

/*abstract class CreateModelTwoFuturesFutureGroup<V, U> extends FutureGroup {
  final Future<V> t;
  final Future<U> u;
  CreateModelTwoFuturesFutureGroup(this.t, this.u) : super() {
    super.add(t);
    super.add(u);

  };
}*/

/// ??? This class uses constructor only for adding all neccessary Future objects in the right order to enforce proper working
class CreateModelOnServerFutureGroup<V> extends FutureGroup<V> {
  // -- both local and global server aspects
  final Future<V> completerCreateFuture;
  final Future<V> completerModelIdByOneTimeInsertionKeyFuture;
  // -- global server aspect
  final Future<V>? completerServerCreationDateTimestampGlobalServerFuture;
  final Future<V>? completerServerUserIdFuture;
  // we have it on local server db record this.completerServerParentIdFuture,
  //final Future<V>? completerServerParentIdFuture;
  final Future<V>? completerServerContactUserIdFuture;
  // we have it on local server db record this.completerServerParentIdFuture,
  //final Future<V>? completerServerOwnerContactIdFuture;
  final Future<V>? completerServerLinkIdFuture;

  CreateModelOnServerFutureGroup(
    this.completerCreateFuture,
    this.completerModelIdByOneTimeInsertionKeyFuture, [
    this.completerServerCreationDateTimestampGlobalServerFuture,
    this.completerServerUserIdFuture,
    // we have it on local server db record this.completerServerParentIdFuture,
    this.completerServerContactUserIdFuture,
    // we have it on local server db record this.completerServerOwnerContactIdFuture,
    this.completerServerLinkIdFuture,
  ]) : super() {
    super.add(completerCreateFuture);
    super.add(completerModelIdByOneTimeInsertionKeyFuture);
    if (this.completerServerCreationDateTimestampGlobalServerFuture != null) {
      super.add(this.completerServerCreationDateTimestampGlobalServerFuture
          as Future<V>);
    }

    if (this.completerServerUserIdFuture != null) {
      super.add(this.completerServerUserIdFuture as Future<V>);
    }

    // we have it on local server db record this.completerServerParentIdFuture,
    //if (this.completerServerParentIdFuture != null) {
    //  super.add(this.completerServerParentIdFuture as Future<V>);
    //}
    if (this.completerServerContactUserIdFuture != null) {
      super.add(this.completerServerContactUserIdFuture as Future<V>);
    }
    // we have it on local server db
    //if (this.completerServerOwnerContactIdFuture != null) {
    //  super.add(this.completerServerOwnerContactIdFuture as Future<V>);
    //}
    if (this.completerServerLinkIdFuture != null) {
      super.add(this.completerServerLinkIdFuture as Future<V>);
    }

    super.close();
  }
}

///
///class CreateModelOnServerFutureGroupGlobalServer<V>
///    extends CreateModelOnServerFutureGroup<V> {
///  CreateModelOnServerFutureGroupGlobalServer(super.completerCreateFuture,
///      super.completerModelIdByOneTimeInsertionKeyFuture);
///}
///
///class CreateModelOnLocalAndGlobalServersFutureGroup<V>
///    extends FutureGroup<List<V>> {
///  final CreateModelOnServerFutureGroup<V> futureGroupLocalServer;
///  final CreateModelOnServerFutureGroupGlobalServer<V> futureGroupGlobalServer;
///
///  CreateModelOnLocalAndGlobalServersFutureGroup(
///      this.futureGroupLocalServer, this.futureGroupGlobalServer)
///      : super() {
///    super.add(futureGroupLocalServer.future);
///    super.add(futureGroupGlobalServer.future);
///    //super.add(this.futureGroupGlobalServer)
///  }
///}

typedef ConditionDataManagementDriverListenerFunction<Future> = bool Function(
    Future future);

enum ConditionDataManagementDriverDbOperationType {
  create,
  read,
  update,
  delete,
  read_all
}

/// See also [ConditionDataManagementDriverQueryBuilder] interface description. For now the main goal is to perform crud operations using models for [update] and [delete], we get a map or list of maps for read operatons (this class is not expected to create models but to work directly on the db, models are created by the app, the two layers are separated from each other). You can perform more advanced searches using [readAll] method. Deleting should be done in a transaction with all children objects (return of List of all removed objects) - the way to do that should be simple and universal for now, some further versions may be more complex, but simplicity is necessary for this thing to be easy to implement and use. Important: if a db engine like sql engine doesn't support transactions, then for cascade descentant models removal you must implement transaction, by using special table with ids that must be removed - such table must be checked at leas each [read], [readAll] request - it is reasonable assumed reading that "delete transaction table" won't require much time, it always will be very small and simple. This class gives you a layer for data operation on db engines, most conveniently based on sql like sqlite3, websql, sqlweb (github library), mysql, etc. This layer along with [ConditionDataManagementDriverQueryBuilder] class separates you from initiating or starting db engines - you don't have to care about it, lets you not care about a platform currently running (Android, Windows, Web, etc., event dart commandline), and event should let's you do db operations on proxy http servers (planned). Initial plan for it all is to use standart query builder based on a standard sql syntaxes closer to sql92 and sql engines just mentioned (f.e. sqlite3). Some syntax is automatically translated to sqlweb (seek relevant information elsewhere)
/// Good to remember that [ConditionModelApps] managing [ConditionModelApp] and some "standalone" [ConditionDataManagementDriver] objects uses comparison between two drivers not to allow existing two different apps and read/writing using the same driver. Read the [ConditionModelapp] description and the following details:
/// [To do? implement [operator ==] and [hashcode] stub here and probably in the mentioned here interfaces/abstract classes, see my makeshift tests simply improving basic understanding how ==/hashcode work here, https://github.com/brilliapps/darthascodeequalsandmapstest]. As for now [ConditionDataManagementDriver] implementations as a unrequired (for now and not in this class now probably good to do) rule uses [ConditionRawSQLDBDriverWrapperCommon] [_db] and optionally [ConditionDataManagementDriverSqlSettings] settings. With this operator == and getter hascode must be overwritten in all of those classes operator so that when two [ConditionDataManagementDriver] drivers are compared they return true if driver point to the same db/remodedb, have the same [dbNamePrefix] prefix and [tableNamePrefix]. If f.e. only [tableNamePrefix] is different, == false so drivers are different and you can in generall treat as if two drivers write/read from two completely different databases. If two drivers are compared like this driver1 == driver2, then most probably cascadingly typical implementations of [ConditionDataManagementDriver] checks first its [ConditionRawSQLDBDriverWrapperCommon] db object for equality and the latter ([ConditionRawSQLDBDriverWrapperCommon]) for its part possibly checks its [ConditionDataManagementDriverSqlSettings] object for equality - it the class was used as a choice. If the possibly optional two settings objects of the same runtimeType class are equal then if also two db wrapper instances are equal (classes may be different but settings the same - to decide if equal or not, probably still equal) so in such a case two [ConditionDataManagementDriver] are checked = they contain the dbname prefixes probably not wrapper but driver - if wrappers equal and db and table prefixes are eual two drivers are the same. Also good to remember that the some of the initial drivers, db wrappers, settings might have been supplied with some "overflow" data to make such instances unique in terms of comparison. At the moment of writing this description it was noticed that web version of [ConditionDataManagementDriverSql] driver (automatic loading native or web version of the class) seemed to need less initial configuration to work properly so not needed db name or table prefixes might has been loaded to make them unique or some other measures finally were applied (OR NOT !). It maybe that a wrapper or driver class may has gotten an option to allow or not using the driver/wrapper if f.e. sqlite3 settings are the same but name prefixes are different.
@Stub()
interface class ConditionDataManagementDriver {
  /// Not used Remove as quickly as possible, replaced by [db_name_prefix] and [table_name_prefix]. To solve some possible problems including security and possible naming conflicts, for overall compatibility reasons [ConditionDataManagementDriverServer] and [ConditionDataManagementDriverSql] like classess need the two replacing properties instead of this one. Kind of namespace prefix allowing you to store couple of separate databases in one overall database - you don't need to create two or five databases using this prefix all tables will be creaated from scratch with this prefix. !!! With this set up to not null and not empty, there would b two prefixes Prefix is only in development mode for simulating backend data storage and loading, see constructor desc. , see method [getNewDefaultDriver] code for backend driver
  //@Deprecated('Replaced by dbNamePrefix, tableNamePrefix')
  //final String prefix = '';

  // NOT TO BE SUCH A VARIABLE, because of [ConditionModelApps] applications management. When last pointer is lost to the conditionModelApp, this would mean that this app still have a pointer to itself here
  // late final ConditionModelApp conditionModelApp;

  /// (If not used [tableNamePrefix] value should be assigned) like 'iZf832_' this must be set but if you don't there is no error - by this you can use couple of applications with independent not conflicting db names in one db. Also it might prevent some sql attacks. Setting this up might prevent error when you forget to assign db name then prefix could became the full db name
  /// For comparison old property _prefix description: Kind of namespace prefix allowing you to store couple of separate databases in one overall database - you don't need to create two or five databases using this prefix all tables will be creaated from scratch with this prefix. !!! With this set up to not null and not empty, there would b two prefixes Prefix is only in development mode for simulating backend data storage and loading, see constructor desc. , see method [getNewDefaultDriver] code for backend driver
  final String dbNamePrefix;

  /// like 'te2xTa_' this must be set but if you don't there is no error - by this you can use couple of applications with independent not conflicting table names in one db. Also it might prevent some sql attacks.
  final String tableNamePrefix;

  /// if true and global_driver is null, the default global driver will be created, See [driverGlobal] description. If driverGlobal was not supplied and this property is true a default global driver (global server driver object is created)
  final bool hasGlobalDriver;

  /// see also [hasGlobalDriver] desc. if this is set a driver cares for synchronizing it's data with the backend server, also to checkout for new incoming messages or other stuff from other users and downloading it to the local server.
  @protected
  final ConditionDataManagementDriver? driverGlobal;

  // using normal constructor you get the ConditionDataManagementDriver object and when the driver asynchronously gets ready (f.e. connects to a remote database) it completes the completer with the driver which you already have because you used the regular constructor. Why the same driver not just to pass true? Because a static method createDriver uses the contstuctor, before that the method creates a [Completer]<[ConditionDataManagementDriver]> internaly, the method returnes the completers future ([Future]<[ConditionDataManagementDriver]>), and finishes the Future using the completer.complete() method. So the static method createDriver is more prefable and convinient that the regular constructor
  final Completer<ConditionDataManagementDriver> initCompleter;
  // i assume this is used only in by the local driver, global driver cares only for it's [initCompleter]
  final Completer<ConditionDataManagementDriver>? initCompleterGlobal;

  @protected
  bool inited = false;

  /// The form of this property may change but you need a list of pending completers/futures finish them with an error after to much time operations. It's existence in this unpolished form hints you about chalenges may appear.
  List<Completer> _storageOperationsQueue = [];
  List<ConditionModelListenerFunction> _changesListeners = [];

  /// Some ideas of the purpose of this property is in [uniqueId] of [ConditionModel] class and [appUniqueId] of [ConditionModelApp]. Shortly, by having this id you can associate [Finalizer] objects to this driver object when last pointer to it is lost. It is related to global management of [ConditionModelApp] objects existing in the entire application scope. It can be better understood when reading [ConditionModelApps] class description with description of some proerties of it.
  final int driverUniqueId =
      ConditionModelApps._increaseByOneDriverUniqueIdCounterAndGetItsValue();

  /// !!! Prefix is only in development mode for simulating backend data storage and loading, see the [_prefix] property desc, see method [getNewDefaultDriver] code for backend driver
  ConditionDataManagementDriver({
    Completer<ConditionDataManagementDriver>? initCompleter,
    Completer<ConditionDataManagementDriver>? initCompleterGlobal,
    String? dbNamePrefix,
    String? tableNamePrefix,
    bool isGlobalDriver = false,
    bool hasGlobalDriver = false,
    ConditionDataManagementDriver? driverGlobal,
    //ConditionModelApp? conditionModelApp // because of [ConditionModelApps] applications management. When last pointer is lost to the conditionModelApp, this would mean that this app still have a pointer to itself here
  })  : initCompleter =
            initCompleter ?? Completer<ConditionDataManagementDriver>(),
        // WARNING THE FOLLOWING CONDITION REPEATED LATER IN THE CONSTRUCTOR MUST BE BOTH THE SAME
        hasGlobalDriver = !isGlobalDriver &&
                (hasGlobalDriver == true ||
                    (hasGlobalDriver == false && driverGlobal != null))
            ? true
            : false,
        dbNamePrefix = dbNamePrefix ??
            ConditionConfiguration.local_http_server_settings['db_name_prefix'],
        tableNamePrefix = tableNamePrefix ??
            ConditionConfiguration
                .local_http_server_settings['table_name_prefix'],
        this.driverGlobal = driverGlobal ??
            // WARNING THE FOLLOWING CONDITION REPEATED EARLIER IN THE CONSTRUCTOR MUST BE BOTH THE SAME
            (!(!isGlobalDriver &&
                    (hasGlobalDriver == true ||
                        (hasGlobalDriver == false && driverGlobal != null)))
                ? null
                : getNewDefaultDriver(
                    //conditionModelApp: conditionModelApp,
                    //Completer<ConditionDataManagementDriver>? initCompleter,
                    hasGlobalDriver:
                        false, // ! because you want a default driver that will be the backend driver, not a local driver with backend driver inside
                    isGlobalDriver: true,
                    dbNamePrefix: ConditionConfiguration
                        .global_http_server_settings['db_name_prefix'],
                    tableNamePrefix: ConditionConfiguration
                        .global_http_server_settings['table_name_prefix'])),
        initCompleterGlobal = (!(!isGlobalDriver &&
                (hasGlobalDriver == true ||
                    (hasGlobalDriver == false && driverGlobal != null)))
            ? null
            : initCompleterGlobal ??
                Completer<ConditionDataManagementDriver>()) {
    // In the extending class we call initStorage function - see description - the function must be overriden it is left in this class definition for learning purposes only
    // _initStorage(prefix, onInitialised);
    debugPrint('We are in the constructor of the ConditionModelApp');

    //if (null != conditionModelApp) {
    //  this.conditionModelApp = conditionModelApp;
    //}

    this.driverGlobal?.getDriverOnDriverInited().then((driver) {
      this.initCompleterGlobal!.complete(driver);
    }).catchError((error) {
      debugPrint('catchError flag #cef1');
      debugPrint(
          'global driver couldn\'t has been inited the error message is:${error.toString()}');
      this.initCompleterGlobal!.completeError(false);
    });
  }

  ConditionTimeNowMillisecondsSinceEpoch
      createCreationOrUpdateDateTimestamp() =>
          ConditionModelApp.getTimeNowMillisecondsSinceEpoch();

  Future<ConditionDataManagementDriver> getDriverOnDriverInited() {
    return initCompleter.future;
  }

  Future<ConditionDataManagementDriver>? getDriverOnDriverInitedGlobalDriver() {
    return initCompleterGlobal?.future;
  }

  @protected
  get storageOperationsQueue => _storageOperationsQueue;

  @protected
  get changesListeners => _changesListeners;

  //@protected
  //get inited => inited;

  /// It is called in the constructor see comments there. This synchronous metnod do some asynchronous stuff fully starting/initiating a database driver - the object of a class extending this [ConditionDataManagementDriver]. Now it is ready for adding, removing data. So the [onInitialised] callback [Function] is called with bool type value of true. We can use our driver normally

  /// Some copy paste from the body of the function: In the class extending this class When you finish initialising the driver
  /// extending [ConditionDataManagementDriver] class you must complete it's future with this driver object we are now in
  /// if f.e. after (one attempt at the beginning of developing the app) several inner attempts to init the driver you throw error in the completer and it will be [catchError]()'ed somewhere else where probably the last resort memory driver ([ConditionDataManagementDriverMemoryFallback]) will be used

  @MustBeImplemented()
  @EducationalImplementation()
  void _initStorage() {
    //this metod utilises such constructor key params as
    //{String db_name_prefix = '',
    //String table_name_prefix = '',
    //Completer<ConditionDataManagementDriver> init_completer}

    try {
      // synchronous example for simplicity - if all the stuff with creating tables and inserting initial data
      // the [initCompleter] [Completer] object is to be completed with [this] driver
      inited = true;
      // completer might has been added via constructor or later via addInitCompleter() which is completed automatically immediately with if this.inited = true; already was earlier set to true
      initCompleter.complete(this);
    } catch (e) {
      // Or in case of error:
      inited =
          false; // !!! it was set false from the beginning - educational example
      // completer might has been added via constructor or later via addInitCompleter() which is completed automatically immediately with if this.inited = true; already was earlier set to true
      initCompleter.completeError(
          false); // for CRUD operations an more, a [ConditionDataManagementDriverNotinitedException] is thrown, here it can happen smoothely if a function is not async/await
    }

    // deprecated and maybe already removed: if (prefix == null) prefix = '';

    // You don't uncomment these comments. In the class extending this class When you finish initialising the driver
    // extending [ConditionDataManagementDriver] class you must complete it's future with this driver object we are now in
    // if f.e. after (one attempt at the beginning of developing the app) several inner attempts to init the driver you throw error in the completer and it will be [catchError]()'ed somewhere else where probably the last resort memory driver ([ConditionDataManagementDriverMemoryFallback]) will be used
    // init_completer.complete(this);
    UnimplementedError(ConditionCustomAnnotationsMessages.MustBeImplemented);
  }

  ////// As an alternative to passing [initCompleter] in a constructor param, in some cases (extending this class) you need to add the init completer [Completer] later like in constructor body. So it may be that a driver is already inited so the completer is completed immediately after it is added here.
  ///void addInitCompleter(
  ///    Completer<ConditionDataManagementDriver> driver_init_completer) {
  ///  // the order is important in case of isolates and initCompleter should be final, so that it couldn't be accidentally removed, but cannot be final with this necessary method here - completers should be added to a private array.
  ///  // now this
  ///  initCompleter = driver_init_completer;
  ///  // then this
  ///  if (inited) {
  ///    driver_init_completer.complete(this);
  ///    return;
  ///  }
  ///}

  /// IS IT STILL NEEDED? 'Is it depreciated or not necessary? Will ConditionModelListenerFunction be removed too?' WE USE FUTURES see [ConditionModelListenerFunction] description. F.e. a widget get a future each time the listener is invoked indicating an long backend operation is in progress, and you can show in the widget a loader informing that f.e. the widget is being updated on the server.
  @deprecated
  void addListener(ConditionModelListenerFunction changesListener) {
    _changesListeners.add(changesListener);
  }

  /// Warning! At the time of writing a [ConditionDataManagement] extending class called [ConditionDataManagementDriverSql] (as far as i can recall) for convenience was to handle not only sqlite3 as designed but it started being prepared to handle mysql connections when needed. This would make a bit more sophisticated checking for duplicate local drivers. However the rule is simple. You don't want to have a two working local drivers in the entire code so that no f.e. two the same id models made updates on the same sql db row at the same time. This public method is used in especially connection with [ConditionModelApps], [ConditionModelApp] in the constructor where [isThisAppUniqueAndCanBeUsed]. The whys there and possibly in more related places.
  bool isDriverDuplicate(ConditionDataManagementDriver driver) {
    // it doesn't mean that identical(driver, driver2) but object may be different but with the same settings
    throw Exception(
        'class\'s [ConditionDataManagement] method isDriverDuplicate() not implemented');
    //return false;
  }

  /// Check also the [checkOutIfGlobalServerAppKeyIsValid]() description. Each ConditionDataManagement driver object is both local and global server. Each driver has its local driver which has or not global server driver [driverGlobal]? if you want to save data of the app object model object (with the app model itself) you need to get and use this key in the [ConditionModelApp] app [server_key] with the global server driver or in other words global server aspect of any driver.
  @protected
  Future<String> requestGlobalServerAppKey() {
    Completer<String> completer = Completer<String>();
    completer.completeError(
        'class\'s [ConditionDataManagement] method requestGlobalServerAppKey() not implemented');
    return completer.future;
  }

  /// Check also the [requestGlobalServerAppKey]() description. The point of this method is that if you cannot synchronize your local server with the global server [driverGlobal] property of local server driver object, if it happens f.e. after a restart, some longer time of unusing the app, it might be that the data of your app has been removed in the meantime, because of the global server implementation policy or the db has been damaged and replaced with new one or whatever. In such a case you check if the key is valid/handled, and if not (not error but anwser false) there is need to request a new key using the mentioned [requestGlobalServerAppKey](), and synchronize/send data from your app to the global server from scratch. All done automatically and possibly tricky.
  @protected
  Future<bool> checkOutIfGlobalServerAppKeyIsValid(String key) {
    Completer<bool> completer = Completer<bool>();
    completer.completeError(
        'class\'s [ConditionDataManagement] method checkOutIfGlobalServerAppKeyIsValid() not implemented');

    return completer.future;
  }

  /// [Edit:] Not up to date desc (prefix only in development mode for backend until [ConditioDataManagementDriverBackend] (OBSOLETE NO CLASS LIKE ...BACKEND - ONE CLASS FOR ALL) is impleented !!! see more on that in [ConditionDataManagementDriver]) It's the best option to call ConditionDataManagementDriver.getNewDefaultDriver() returning SQL... storage driver, because it can be used in the commandline also - so used elsewhere. But it can be later used for storing data in a file for example.
  @Stub()
  @Makeshift()
  static ConditionDataManagementDriver getNewDefaultDriver(
      {
      //ConditionModelApp? conditionModelApp,
      Completer<ConditionDataManagementDriver>? initCompleter,
      bool isGlobalDriver = false,
      bool hasGlobalDriver =
          false, // !!! the meaning of this changes if true a driver has global server property _global_driver set INSIDE IT
      String? dbNamePrefix,
      String? tableNamePrefix}) {
    //
    //
    // BEFORE YOU REIMPLEMENT ALL HERE
    // !!!!! bool backend = false, !!! the meaning of this changes if true a driver has global server property _global_driver set INSIDE IT
    // So you always returns one default driver but with or without global backend server driver  inside. See more properties [ConditioDataManagementDriver]

    //if (!ConditionConfiguration.isWeb) {}

    if (ConditionConfiguration.defaultAppDataEngine ==
        ConditionAppDataManagementEnginesEnum.sqlite3) {
      return ConditionDataManagementDriverSql(
        // conditionModelApp: conditionModelApp,
        initCompleter: initCompleter,
        dbNamePrefix: dbNamePrefix,
        tableNamePrefix: tableNamePrefix,
        isGlobalDriver: isGlobalDriver,
        hasGlobalDriver: hasGlobalDriver,
        //of course not used param - default values: ConditionDataManagementDriver? global_driver,
      );
    } else {
      throw Exception('A frontend data engine is not available or implemented');
      throw Error();
    }
  }

  /// Together with [nullifyOneTimeInsertionKey], In some rare cases or sql implementation (might be sqlweb github plugin impelmeentation) after a db-table record of a completely new [ConditionModelWidget] model is created you sometimes cannot opbtain it's id in the db (local app storage sql db). The model cares for itself to make sure it has it's own id from the db, for this it creates the [one_time_insertion_key] key, finds it's record in the db by the key and gets it's own id. After it has it, the key is nullified and not neccessary anymore.
  @MustBeImplemented()
  @EducationalImplementation()
  Future<int?> getModelIdByOneTimeInsertionKey(
      ConditionModelIdAndOneTimeInsertionKeyModel model,
      {String? globalServerRequestKey = null}) {
    // Condition should never be used, however some re-implementations can be wrong, this is after any other request is run, so on the first db request an Exception should already has been thrown
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    Completer<int> completer = Completer<int>();
    storageOperationsQueue[storageOperationsQueue.length] = completer;

    return completer.future;
  }

  /// See [getModelIdByOneTimeInsertionKey] description.
  @MustBeImplemented()
  @EducationalImplementation()
  Future<bool?> nullifyOneTimeInsertionKey(
      ConditionModelIdAndOneTimeInsertionKeyModel model,
      {String? globalServerRequestKey = null}) {
    // Condition should never be used, however some re-implementations can be wrong, this is after any other request is run, so on the first db request an Exception should already has been thrown
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    Completer<bool> completer = Completer<bool>();
    storageOperationsQueue[storageOperationsQueue.length] = completer;

    return completer.future;
  }

  /// Rethink but: Impementing this you try not to throw Exceptions and you better not use async try catch! The returned [CreateModelOnLocalAndGlobalServersFutureGroup] [FutureGroup] object. The future of the object contains a List of two lists each list containing two elements of int? values representing for the first int? element an id of the model or null (which is not error because a db system has right not to return inserted id), and for the second element also int? which also is not an error if null was received (the second element contains the result of an attempt of achieveing the id value by invoking [getModelIdByOneTimeInsertionKey] method, it can be null, because an error caused by lack of access to the internet might have occured). The two different lists contains first: the results performed on the local server and the second list: on the global server if the server is managed by the [ConditionMoelDataManagementDriver] driver object, if not then the second list has their two results set to null. If successfully finishes, it does so with list of three elements containing values as hinted with generic Type (int?) first is null or inserted row id ([int?]), second the result of future finding inserted row id (some db system like f.e. sqlweb non-dart but js web github plugin want give you the inserted id immediately a table record was set, the last future value informs you if a column containing the one time key has been set to null and never will be necessary or used again). The return result will be null if is not extending or implementing [ConditionModelIdAndOneTimeInsertionKeyModel] class, which means an operation of checking was not performed and no completeError/async Exception is thrown, The same with the last parameter - it will be null if model is not [ConditionModelIdAndOneTimeInsertionKeyModel] ... . if null is returned (not error) a row has been inserted but there was a problem with internet connection and the id couldn't have been received, and then based on __one_time_key... or like that property model itself tries to get it's own id on the server. (? some broken sentence:) occured during, however on row creation the server side puts more of it's own variables, they need to be read in the second request or [read] method with its chosen columns - such operation doesn't seem to be much more resources consuming. The model might be updated with inserted id (or id + some_other_key_id - compound keys) in the db - models have unique
  @MustBeImplemented()
  @EducationalImplementation()
  CreateModelOnServerFutureGroup<int?> create(ConditionModel model,
      {String? globalServerRequestKey = null,
      Map<String, String?>? globalServerUserCredentials}) {
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    Completer<int?> completerCreate = Completer<int?>();
    Completer<int?> completerModelIdByOneTimeInsertionKey = Completer<int?>();
    CreateModelOnServerFutureGroup<int?> localServersFutureGroup =
        CreateModelOnServerFutureGroup<int?>(completerCreate.future,
            completerModelIdByOneTimeInsertionKey.future);

    storageOperationsQueue[storageOperationsQueue.length] = completerCreate;
    storageOperationsQueue[storageOperationsQueue.length] =
        completerModelIdByOneTimeInsertionKey;
    //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);
    //var abc = CreateModelFutureGroup();

    return localServersFutureGroup;
  }

  /// Update a data model or just some fields of it not to strain network or processor by sending all model to a server (if a class extending this one uses some server)
  @MustBeImplemented()
  @EducationalImplementation()
  Future<int?> update(ConditionModel model,
      {Set<String>? columnNames, String? globalServerRequestKey = null}) {
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    //return Future.value();
    Completer<int?> completer = new Completer<int?>();
    storageOperationsQueue[storageOperationsQueue.length] = completer;

    return completer.future;
  }

  /// Remove casdadingly a model and it's descendants, returns a List of ids, first is the id of the removed model, and the rest of the list is descendants of the model, see the class description, In the future the may be more sophisticated relations for the removal, but for now parent_id like rule is key thing.
  @MustBeImplemented()
  @EducationalImplementation()
  Future<List<int>> _____________________________delete(ConditionModel model) {
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    //return Future.value();
    Completer<List<int>> completer = new Completer<List<int>>();
    storageOperationsQueue[storageOperationsQueue.length] = completer;

    return completer.future;
  }

  /// Read also [update](). Returns first element in the form of [ConditionMap] (a [Map]) object belonging to the type [Type] - returned data are enough to recreate [ConditionModel] class object
  @MustBeImplemented(
      'This one doesn\'t need to be implemented if you read carefully')
  @EducationalImplementation()
  Future<Map?> read(ConditionModel model,
      {String? globalServerRequestKey, Set<String>? columnNames}
      /*ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
          whereClause*/
      ) {
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    Completer<ConditionMap?> completer = Completer<ConditionMap?>();

    ///_____________________________readAll(
    ///        model.runtimeType.toString(), whereClause,
    ///        limit: 1)
    ///    .then((List<ConditionMap>? conditionMapList) {
    ///  if (conditionMapList == null) {
    ///    completer.complete(null);
    ///  } else {
    ///    return completer.complete(conditionMapList[0]);
    ///  }
    ///}).catchError((e) {
    ///  // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
    ///  completer.completeError(
    ///      'Predefined error message, rather throw Excepthion custom class, There was a db_error');
    ///});
    return completer.future;
  }

  /// Read also [update](). like [read]() but returns List of all - not just first element.
  @MustBeImplemented()
  @EducationalImplementation()
  Future<List<Map<String, dynamic>>?> readAll(
      String
          modelClassName, //the table name and model id (some models like ConditionModelMessage only) is taken from this or for name not model id dbTableName property is used
      ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
          whereClause,
      {int? limit = ConditionConfiguration.maxNumberOfReturnedResultsFromDb,
      Set<String>? columnNames,
      String? dbTableName, // see modelClassName double slash comment
      String? globalServerRequestKey,
      String? tableNamePrefix}) {
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    Completer<List<Map<String, dynamic>>?> completer =
        Completer<List<Map<String, dynamic>>?>();
    storageOperationsQueue[storageOperationsQueue.length] = completer;
    //const Future result=_dbTaskReadAll(completer, ConditionDataManagementDriverDbOperationType.read_all, modelType: modelType, whereClause: whereClause);

    return completer.future;
  }

  /// A method suggestion - it could be here _db_task_update() ..._read, etc. The idea is that this example function separates you from ugly and probably asynchronous stuff you have to perform on db, you get a completer as a param which you are to complete after success. However in the function body you may do many inner handled exceptions, you may try 5 or 10 times to perform an operation until you are successful, whatever, but when you are finally successful you just correctly complete the param [Completer] completer object or throw Error/Exception for this particular Completer. You do all your inner tasks on the db so method is private. you don't have to use this method, but if you do you have to override it. It does the actual storing/updating the data. this method you must override while implementing/extending the [ConditionDataManager] class/interface
  ///
  /// Old text, up to date?: With [update] there are two methods for one task. This is because f.e. requesting data using a flutter plugin may involve [Future] but also [Stream], but the function update returnes a [Future] only, so dbTask method allows you to return Future and supply it with value when in your implementation a [Stream] has just finished an operation.
  /*@MustBeImplemented()
  Future<bool> _dbTaskReadAll(Completer completer,
      ConditionDataManagementDriverDbOperationType operationType,
      {

      // ------ update //
      ConditionModel? model,
      Set<String>? listOfFields,

      // ------ read, and read_all operation_type determines what to receive //
      // ------ also model_type mostly just tells you f.e. for sql, which sql table to perform operation on.
      ConditionModelType? modelType,
      ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon?
          whereClause}) {
    // here you register a callback when the operation is over, and error_callback
    UnimplementedError(ConditionCustomAnnotationsMessages.MustBeImplemented);
    return Completer<bool>().future;
  }
*/
  /// Method had been added before some concepts changed
  @deprecated
  Future<String?> getValue(String key) {
    UnimplementedError(ConditionCustomAnnotationsMessages.MustBeImplemented);
    return Completer<String?>().future;
  }

  /// Example implementation - this is used by the == operator and hashCode overrides, and version with more items in the list
  List equalityComparisonProperties() {
    return [dbNamePrefix, tableNamePrefix];
  }

  /// Example implementation - this is used by the == operator and hashCode overrides, and version with more items in the list
  /// This method contains example approximate implementation code. Description copied from [ConditionDataManagementDriverSqlSettings] class - the same rule. Overall it is described up-to-date in the [ConditionDataManagementDriver] class what uses what and for what. Needed to be overriden in non-abstract class. If == true the two objects refer to the same database/dbfile/dbname but not involves checking for the same prefixes for tables/dbname, they are defined and used by [ConditionDataManagement] instance and this uses db wrapper [ConditionRawSQLDBDriverWrapperCommon].
  /// Caution about @mustBeOverriden annotation here, read all carefully! By default dart won't require you to override operators and hashCode so this annotation enfoces that but it will require to implement it in each class extending class that already implemented interface with this method. So you must in first implementation of this method add @mustCallSuper and in a class extending the class just return only what super.overriden method returns like return super == object; for == operator or return super.hashCode; for hashCode method  @override
  @override
  @mustBeOverridden
  bool operator ==(Object other) {
    if (identical(other, this) ||
        (other is ConditionDataManagementDriver &&
            const ListEquality().equals(equalityComparisonProperties(),
                other.equalityComparisonProperties()))) {
      return true;
    }
    //if (!(super == (other))) return false;
    return false;
  }

  /// This method contains example approximate implementation code. See operator == description for this class - this shouldn't return 10 like here (it is possible but don't do that), but you should understand what hashcode is for, etc. so go to this class == operator description
  /// Caution about @mustBeOverriden annotation here, read all carefully! By default dart won't require you to override operators and hashCode so this annotation enfoces that but it will require to implement it in each class extending class that already implemented interface with this method. So you must in first implementation of this method add @mustCallSuper and in a class extending the class just return only what super.overriden method returns like return super == object; for == operator or return super.hashCode; for hashCode method  @override
  @override
  @mustBeOverridden
  int get hashCode => Object.hashAll(equalityComparisonProperties());
}

/// Most important descripion is in [ConditionDataManagementDriver] class. This class almost should be made abstract, but it is contstructed in a way to work by default out of the box if not extended using sqlite3 engines, settings, and classess, which is for the app (or system) a default option, while it works on a sqlite3 file database not internet connection. Such an option for an easy start for new developers.
/// Caution! [To do:] More sophisticated db integrity check on initiation, f.e. a ConditionModelClassess table must contain about 10 records (at the time of writing). An work out some rules not to perform integrity check each request or application start or whatever.
class ConditionDataManagementDriverSql extends ConditionDataManagementDriver
    implements
        ConditionDataManagementDriverSqlInitPatternsAndMatchesReplacementMethods {
  @protected
  final ConditionRawSQLDBDriverWrapperCommon _db;

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
    super.initCompleter,
    super.initCompleterGlobal,
    super.dbNamePrefix,
    super.tableNamePrefix,
    super.isGlobalDriver = false,
    super.hasGlobalDriver = false,
    super.driverGlobal,
    ConditionRawSQLDBDriverWrapperSqlite3?
        db, // if db is null non-null settings will be used to create db if settings == null default db will be created or exception will be thrown if equal driver exists.
    ConditionDataManagementDriverSqlSettings?
        settings, // if db is null non-null settings will be used to create db if settings == null default db will be created or exception will be thrown if equal driver exists.
    //ConditionModelApp? conditionModelApp, // not used because an app won't be removed when a pointer here was still left see [ConditionModelApps] description [ConditionModelApps] manages all apps and in some cases when last link to the app model is lost it as expected triggers Finalizer. But if this constructor param/property was left untouched there still might has been last pointer to the app model left here and the finalizer wouldn't be activated when it would be expected so and an app still would be in memory. Read much more in [ConditionModelApps] stuff and descriptions
  }) : _db = db ??
            (settings == null
                ? ConditionRawSQLDBDriverWrapperCommon.getDefaultWrapper(
                    isGlobalDriver)
                : settings!.getWrapper()) {
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
        // Some comments may not be up do date:
        // =============================
        // to do you better make it all const (cannot now)
        // as not confusing any developers pattern for extending the class [settings] property is not of the extending [ConditionDataManagementDriverSqlSettingsSqlite3] class
        // but in the constructor [ConditionDataManagementDriverSqlSettingsSqlite3] object is passed which is allowed as it extends the type allowed for the [settings] property
        // so that it is fully available it must be [settings] must be cast into the [ConditionDataManagementDriverSqlSettingsSqlite3]
        //ConditionDataManagementDriverSqlSettingsSqlite3 settings_sqlite3 =
        //    (settings as ConditionDataManagementDriverSqlSettingsSqlite3);
        //
        //dbNamePrefix use for opening an sqlite3, i think db the file name stands for db name here
        //again you will need some regex string replace for that ./*/*/file.sqlite or .sqlite3 - whatever
        //the outcome would be '.../${dbNamePrefixfile}.sqlite'
        //this is also needed: tableNamePrefix,
        //work out for this: condition_full_db_init.sql a regex replaceAll or something to replace table names to those with prefixex

        //enum: ConditionPlatforms

        debugPrint('Checking out some paths');

        await _db.getDriverWhenInited();

        // a method local variable not to confuse with [inited] this private property
        bool isAppDbinited = true;

        try {
          debugPrint(
              'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;');
          // In this case We can only fully rely on exception thrown when a table doesn't exist
          var select_is_debinited = await _db.select('''
          SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;
          ''');
          // when table exists this one will always return result of type int from 0 to more than 0
          debugPrint(
              'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses; ${select_is_debinited?[0]['count(*)']}');
        } catch (e) {
          debugPrint(
              'table doesn\'t exist, so no relevant table with initial data exists, db wrapper exception thrown: $e');
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
              contents = await _db.httpGetFileContents(
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

            await _db.execute(contents);

            try {
              debugPrint(
                  '### ! So now the tables should be ready. so let\'s check if it\'s true. For now repeat of that simple command again.');
              debugPrint(
                  'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;');
              // In this case We can only fully rely on exception thrown when a table doesn't exist
              var select_is_debinited = await _db.select('''
              SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses;
              ''');
              // when table exists this one will always return result of type int from 0 to more than 0
              debugPrint(
                  '### ! Whith no exception thrown the app is ready, some debug info again:');
              debugPrint(
                  'SELECT count(*) FROM ${tableNamePrefix}ConditionModelClasses; ${select_is_debinited?[0]['count(*)']}');
            } catch (e) {
              debugPrint(
                  'table doesn\'t exist while this time it should be ready!, the app won t work. $e');
              rethrow;
            }

            debugPrint(
                'db_init result: no result is expected, only exception on problems');

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
      List<Map<String, dynamic>>? conditionMapList = await readAll(
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

    scheduleMicrotask(() async {
      try {
        await _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(
            'A result of nullifyOneTimeInsertionKey() exception/future completeError. An exception during third party library operation occured: ${e.toString()}');
        debugPrint(
            'A result of nullifyOneTimeInsertionKey() exception/future An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'A result of nullifyOneTimeInsertionKey has arrived and in the debug mode it seems it successfully done and it looks like this:');
      //debugPrint(result);

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
    scheduleMicrotask(() async {
      List<Map<String, dynamic>>? result;
      try {
        await _db.execute(query.queryPart);
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
                createCreationOrUpdateDateTimestamp().time
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

      //dynamic result;
      try {
        debugPrint(
            '###################################### 8IE### EXECUTE INSERT INTO NOW OR THROW EXCEPTION');
        await _db.execute(query.queryPart);
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
      //debugPrint(result);

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
        getModelIdByOneTimeInsertionKey(model).then((id) async {
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

            try {
              await _db.execute(query.queryPart);
              debugPrint(
                  'DataManagementDriver create() method (global server/aspect table row) no exception thrown - there is server_id in the db table row involved. By the way the returned result of the db operation is: no result is expected for _db.execute method as of today.');
              // no exception thrown - there is server_id in the db table row involved.
              completerModelIdByOneTimeInsertionKey.complete(id);
            } catch (e) {
              completerModelIdByOneTimeInsertionKey.completeError(false);
              debugPrint(
                  'DataManagementDriver create() method (global server/aspect table row) An exception during third party library operation occured: ${e.toString()}');
            }

            debugPrint(
                'DataManagementDriver create() method (global server/aspect table row) A result of update method has arrived and in the debug mode it seems it successfully done and it looks like this:');
            //debugPrint(result.toString());
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

    scheduleMicrotask(() async {
      List<Map<String, dynamic>>? result;
      try {
        result = await _db.select(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'A result of readAll method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      // FIXME: Similar situations are here. It was not used code at the time of writing this.Here there should be no dynamic result list of int consisting of affected rows should be given
      completer.complete(result as dynamic);
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
                createCreationOrUpdateDateTimestamp().time
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
                  createCreationOrUpdateDateTimestamp().time
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

      try {
        await _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(
            'DataManagementDriver update() method An exception during third party library operation occured: ${e.toString()}');
        debugPrint(
            'DataManagementDriver update() method An exception during third party library operation occured: ${e.toString()}');
      }

      debugPrint(
          'DataManagementDriver update() method A result of update method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      //debugPrint(result.toString());

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

    scheduleMicrotask(() async {
      List<Map<String, dynamic>>? result;
      try {
        result = await _db.select(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'An exception during third party library operation occured: ${e.toString()}');
      }
      debugPrint(
          'A result of readAll method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      debugPrint(result.toString());

      // Complete with null In assynchronous operations i cannot 100% assume it will return it id, as in the meantime another insert might has happened and it would returned the second insert id
      // FIXME: Similar situations are here. It was not used code at the time of writing this.Here there should be no dynamic result list of int consisting of affected rows should be given
      completer.complete(result as dynamic);
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

      //dynamic result;
      try {
        await _db.execute(query.queryPart);
      } catch (e) {
        completer.completeError(false);
        debugPrint(
            'delete(): An exception during third party library operation occured: ${e.toString()}');
      }

      debugPrint(
          'delete(): A result of delete method has arrived and in the debug mode it seems it successfully done and it looks like this:');
      //debugPrint(result.toString());
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

      List<Map<String, dynamic>>? result;
      try {
        result = await _db.select(query.queryPart);
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
  Future<List<Map<String, dynamic>>?> readAll(
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

    Completer<List<Map<String, dynamic>>?> completer =
        Completer<List<Map<String, dynamic>>?>();
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

    scheduleMicrotask(() async {
      List<Map<String, dynamic>>? result;
      try {
        if (null != globalServerRequestKey)
          debugPrint(
              'globalServerRequestKey == $globalServerRequestKey, readAll(), debug flag: 4');
        result = await _db.select(query.queryPart);
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

  /// Example implementation - this is used by the == operator and hashCode overrides, and version with more items in the list
  @override
  List<dynamic> equalityComparisonProperties() =>
      <dynamic>[dbNamePrefix, tableNamePrefix] +
      _db.equalityComparisonProperties();

  /// Example implementation - this is used by the == operator and hashCode overrides, and version with more items in the list
  /// This method contains example approximate implementation code. Description copied from [ConditionDataManagementDriverSqlSettings] class - the same rule. Overall it is described up-to-date in the [ConditionDataManagementDriver] class what uses what and for what. Needed to be overriden in non-abstract class. If == true the two objects refer to the same database/dbfile/dbname but not involves checking for the same prefixes for tables/dbname, they are defined and used by [ConditionDataManagement] instance and this uses db wrapper [ConditionRawSQLDBDriverWrapperCommon].
  /// Caution about @mustBeOverriden annotation here, read all carefully! By default dart won't require you to override operators and hashCode so this annotation enfoces that but it will require to implement it in each class extending class that already implemented interface with this method. So you must in first implementation of this method add @mustCallSuper and in a class extending the class just return only what super.overriden method returns like return super == object; for == operator or return super.hashCode; for hashCode method  @override
  @override
  bool operator ==(Object other) {
    if (identical(other, this) ||
        (other is ConditionDataManagementDriverSql &&
            const ListEquality().equals(equalityComparisonProperties(),
                other.equalityComparisonProperties()))) {
      return true;
    }
    //if (!(super == (other))) return false;
    return false;
  }

  /// This method contains example approximate implementation code. See operator == description for this class - this shouldn't return 10 like here (it is possible but don't do that), but you should understand what hashcode is for, etc. so go to this class == operator description
  /// Caution about @mustBeOverriden annotation here, read all carefully! By default dart won't require you to override operators and hashCode so this annotation enfoces that but it will require to implement it in each class extending class that already implemented interface with this method. So you must in first implementation of this method add @mustCallSuper and in a class extending the class just return only what super.overriden method returns like return super == object; for == operator or return super.hashCode; for hashCode method  @override
  @override
  int get hashCode => Object.hashAll(equalityComparisonProperties());
}

abstract class ConditionDataManagementDriverSqlInitPatternsAndMatchesReplacementMethods {
  final ConditionDataManagementDriverSqlite3RegexPatterns patterns =
      ConditionDataManagementDriverSqlite3RegexPatternsSqlite3();
  // To get to static propertis you will need to use runtimeType.property
  late final ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethods
      replacementMethods =
      ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethodsSqlite3(
          patterns);
}

abstract class ConditionDataManagementDriverSqlite3RegexPatterns {
  final String s = r'\r\n\t\s';

  /// column list with surrounding parentheses (in dart language before string r'' var s = r'A string with only \ and $';)
  final String c = r'\(([^\)]*)\)';

  /// overall values part with surrounding parentheses - in nested checking values will be extracted using more detailed regex into array and assign properly to column names according to sqlweb syntax
  final String v =
      r'''\((([^\)]*?[']((?<=')[']|['](?=')|[^'])*['])*|[^\)]*)\)''';
  late final String t = '''['"]?([^"'$s]*)['"]?''';
  late final String sqlite3InsertIntoRegexString =
      '''INSERT[$s]*INTO[$s]*$t([$s]*$c[$s]*VALUES[$s]*$v[$s]*[;]*)''';
  late final RegExp sqlite3InsertIntoRegex =
      RegExp(sqlite3InsertIntoRegexString, caseSensitive: false);
  late final RegExp sqlite2websqlInsertIntoRegex =
      RegExp("($sqlite3InsertIntoRegexString)", caseSensitive: false);
  late final String sqlite3DropTableRegexString =
      '''[$s]*DROP[$s]*?TABLE[$s]*?IF[$s]*?EXISTS[$s]*$t[$s]*[;]*''';
  late final RegExp sqlite3DropTableRegex =
      RegExp(sqlite3DropTableRegexString, caseSensitive: false);
  late final String sqlite3CreateTableRegexString =
      '''CREATE[$s]*TABLE[$s]*$t[$s]*\(([^\)]*)\)[$s]*[;]*''';
  late final RegExp sqlite3CreateTableRegex =
      RegExp(sqlite3CreateTableRegexString, caseSensitive: false);
  late final RegExp sqlite2websqlCreateTableRegex =
      RegExp('($sqlite3CreateTableRegexString)', caseSensitive: false);
  late final String sqlite3CreateIndexRegexString =
      '''CREATE[$s]*INDEX[$s]*$t[$s]*ON[$s]*$t[$s]*([^;]*[;]*)''';
  late final RegExp sqlite3CreateIndexRegex =
      RegExp(sqlite3CreateIndexRegexString, caseSensitive: false);

  /// only one select in one string, and select is pretty much sqlite compatible so this is pretty enough and very simple and prone to errors regex for now - only for "select * from tablename" - where can be compatible on its own - this doesn't detect the whole statement for now
  late final RegExp sqlite3SelectAllRegex = RegExp(
      '''[$s]*SELECT[s]*\*[$s]*from[s]*([^$s]*)''',
      caseSensitive: false);

  ///Splitting part like, we are extracting values to an array:
  ///so "VALUES (#####this part inside split, but it done correctly#####)"
  late final RegExp sqlite3ExtentedSplit = RegExp(
      '''(?=(?:[$s]*(?:\d+|['](?:(?<=')[']|['](?=')|[^'])*['])*))[$s]*[,][$s]*''',
      caseSensitive: false);
}

/// not mixin. Normally should be used by all [ConditionDataManagementDriver] sql implementations. Here there are patterns originally designed to manipulate full init sqlite db sql generated by a php script called adminer which creates at once all database with it's tables, columns and initial data. (sqlite3 syntax and probably sql92). The patterns allow to automatically change accommodate different parts of sql commands to different sql syntaxes. F.e you can change all creaate table abc sql command to create table prefixabc. The same with commands like select, insert, update, where clause, etc. Work in progress.
class ConditionDataManagementDriverSqlite3RegexPatternsSqlite3
    extends ConditionDataManagementDriverSqlite3RegexPatterns {}

abstract class ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethods {
  /// To get to static propertis you will need to use runtimeType.property

  final String dbNamePrefix;
  final String tableNamePrefix;

  final ConditionDataManagementDriverSqlite3RegexPatterns patterns;
  const ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethods(
    this.patterns, [
    this.dbNamePrefix = '',
    this.tableNamePrefix = '',
  ]);

  String replaceAllDropTable(String contents) {
    return contents.replaceAll(patterns.sqlite3DropTableRegex, '');
  }

  String replaceAllCreateTable(String contents) {
    debugPrint(
        'sqlite3CreateTableRegexString ${patterns.sqlite3CreateTableRegexString}');

    return contents.replaceAllMapped(patterns.sqlite3CreateTableRegex, (m) {
      return '\nCREATE TABLE IF NOT EXISTS $tableNamePrefix${m[1]} ${m[2]}';
    });
  }

  String replaceAllCreateIndex(String contents) {
    debugPrint(
        'sqlite3CreateIndexRegexString ${patterns.sqlite3CreateIndexRegexString}');

    return contents.replaceAllMapped(patterns.sqlite3CreateIndexRegex, (m) {
      return '\nCREATE INDEX $tableNamePrefix${m[1]} ON $tableNamePrefix${m[2]} ${m[3]}';
    });
  }

  String replaceAllInsertInto(String contents) {
    debugPrint(
        'sqlite3InsertIntoRegexString ${patterns.sqlite3InsertIntoRegexString}');

    return contents.replaceAllMapped(patterns.sqlite3InsertIntoRegex, (m) {
      return '\nINSERT INTO $tableNamePrefix${m[1]} ${m[2]}';
    });
  }
}

/// not mixin. Convenience mixin along with [ConditionDataManagementDriverSqlite3RegexPatterns] (read the class's description). This part may not be going to be used by each sql [ConditionDataManagementDriver] class extension, because the methods here are meant for sqlite3 syntax (hopefully compatible with sql92). You may or may not need to implement similar mixin for mysql, postgres, etc. But the incoming sql strings are sqlite3 compatible, the outpu may be as you implement similar mixins. Here there are
class ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethodsSqlite3
    extends ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethods {
  ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethodsSqlite3(
    super.patterns, [
    super.dbNamePrefix = '',
    super.tableNamePrefix = '',
  ]);
}

class ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethodsSqlweb
    extends ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethods {
  ConditionDataManagementDriverSqlite3RegexMatchesReplacementMethodsSqlweb(
    super.patterns, [
    super.dbNamePrefix = '',
    super.tableNamePrefix = '',
  ]);
}

// Extending DelegatingMap ror tree cascading serializising objects to json string. for extending map class with added functionality not overriding the existing stuff it should later be replaced with not importing this library not to give too much overhead (optimisation) like f.e. MapBase class alternative https://stackoverflow.com/questions/21081210/dart-extends-map-to-facilitate-lazy-loading class LazyMap implements Map {
@ToDo(
    "Extending [DelegatingMap] class was the easiest but requires importing a package. Try importing part of a package or you better extend other available Map is, or remove this to do",
    '')
class ConditionMap<K, V> extends DelegatingMap<K, V> {
  //final delegate = {};
  //late V defValue;
  final Map<K, V> defValue;

  ConditionMap(this.defValue)
      : super(defValue); // don't know why only this notation worked

  @override
  V? operator [](Object? key) => defValue[key] ?? defValue[key];
  //V? operator [](Object? key) => delegate[key] ?? defValue;

  //@override
  //operator [](key) => _inner.putIfAbsent(key, () => key.length);
}

/// self describing names yet "app_only" means a variable is saved on the server side but server wont change it, "from_server_and_read_only" means f.e. you created a user in the app and it gets id in the app but you have different id on the server backend side - you cannot decide for server which id to assign to your user, the same is with the app's data models of the widgts. "both_app_and_server_synchronized" when you write a message, task, etc, its "description" property is on the server as it was first in the app. However a task description might have been changed by another user you allowed to then you app updates the property from the server and both are the same.
enum ConditionModelFieldDatabaseSynchronisationType {
  app_only, // see desc - except for "id" field app sets it and send to the global server
  from_server_and_read_only,
  both_app_and_server_synchronized
}

/// Base for a field configuration of any [ConditionModel] f.e. [ConditionModelMessage], any model has fields representing one property of a model and most often a corresponding column in a DB table in the backend. Very important is the method validate of the field which can be overriden when you extend basic types extending the [ConditionModelField] f.e you can extend [ConditionModelFieldInt] class to override it's default validate method to limit or expand integer values that can be used and this is important when you simply cannot use greater integer value in the backend because your database doesn't alow for that.
@Stub()
@Makeshift()
abstract class ConditionModelField {
  /// To make some database operations easier especially in the debug mode because the related model with its own user [ConditionModelUser] model and data driver (update name class) is attached is at hand
  ConditionModel model;
  String columnName;

  final ConditionModelFieldDatabaseSynchronisationType propertySynchronisation;

  /// See especially [_value] property. If true the [columnName] field  value stored in the db can be set once and is stored stored either in a non-final [_value] property or a final [_valueFinal] property.
  final bool isFinal;

  /// [There is performed an attempt of using the 'final' keyword of a 'value' property to get compile time or text editor errors in advance] See also [isFinal] and [validate] method it is assumed that if validation using validate is passed _isAlreadyinited is set to true and a value is set up. so make sure any validating apart from this validate function is made before its invokation!
  @Deprecated(
      'The solution is with isFinal, _value, _valueFinal fields . There is performed an attempt of using the \'final\' keyword of a \'value\' property  to get compile time or text editor errors in advance')
  bool _isAlreadyinited = false;

  // There should be a class extending Map fo this property. A default config must be done if no config is suplied in the constructor. There is simply empty Map for the moment by default.
  //@Stub()
  //final Map? config;

  /// value taken from the config property
  late final bool? indexed;

  /// Do not remember what was meant by tis property. Old description: Value taken from the config property
  @deprecated
  late final bool? key;

  /// If true the value of the model\'s property hasn't not yet been assigned at all, f.e. this yet not happened at all: model['id'] = 50;
  bool _isThisFirstValueAssignement = true;

  // done differently via a model's _changesStreamController;
  //late final valueFirstSetUp = Completer<dynamic>();

  @MustBeImplemented()
  late String _validation_exception_message = '';

  ConditionModelField(this.model, this.columnName,
      {required this.propertySynchronisation,
      this.isFinal = false}) /* : this.config = config*/ {
    //also properties like this.key and this.indexed should be updated if necessary

    //if (null == this.config) this.config = {};
  }

  /// There are two points of using this method. 1. Initial values passed to the model's constructor are already set and just need to be validated (throwing Exceptions if necessary). 2. By validating them a lazily initialized [ConditionModelField] is created and it gets "this" object as an argument which is possible only on lazy initialization (a fully defined class property extending [ConditionModelField] class gets this object which is not available if the property is not lazily inited).
  void init() {
    // for consistency let it be this way, yet for information calling model[columnName] is possible would trigger getter but couldn't trigger setter []= which would call a sepparete validation so probably two times validation
    model.defValue[columnName] = this;
    model.addDefinedKeyAndItsModelField(this);
  }
}

/// Exception thrown when validate method doesn't allow for setting a value in a model setter. Models extend [ConditionModel] class
@Stub()
abstract class ConditionModelFieldException<ConditionModelField>
    implements Exception {
  final String msg;
  const ConditionModelFieldException(
      [this.msg =
          'There was an exception related to your ConditionModelField field settings of ConditionModel model object']);

  @MustBeImplemented()
  String toString() => '${runtimeType}: $msg';
}

/// real implementation of [ConditionModelFieldException] for a field of [ConditionModelFieldInt] class
@Stub()
@Deprecated(
    'Is to be replaced by non-final _value and final _valueFinal one of them used depending on isFinal property')
class ConditionModelFieldExceptionIsFinal<ConditionModelField>
    extends ConditionModelFieldException<ConditionModelField> {
  const ConditionModelFieldExceptionIsFinal(
      [super.msg =
          "A field is marked final, and it's value cannot be changed"]);

  @override
  @Stub()
  String toString() => '${runtimeType}: $msg';
}

/// real implementation of [ConditionModelFieldException] for a field of [ConditionModelFieldInt] class
@Stub()
class ConditionModelFieldIntException<ConditionModelFieldInt>
    extends ConditionModelFieldException<ConditionModelField> {
  const ConditionModelFieldIntException(super.msg);

  @override
  @Stub()
  String toString() =>
      'ConditionModelFieldIntException<ConditionModelFieldInt>: $msg';
}

/// real implementation of [ConditionModelFieldException] for a field of [ConditionModelFieldInt] class
@Stub()
class ConditionModelFieldIntOrNullException<ConditionModelFieldInt>
    extends ConditionModelFieldException<ConditionModelField> {
  const ConditionModelFieldIntOrNullException(super.msg);

  @override
  @Stub()
  String toString() =>
      'ConditionModelFieldIntOrNullException<ConditionModelFieldInt>: $msg';
}

/// real implementation of [ConditionModelFieldException] for a field of [ConditionModelFieldStringOrNull] class
@Stub()
class ConditionModelFieldStringException<ConditionModelFieldString>
    extends ConditionModelFieldException<ConditionModelField> {
  const ConditionModelFieldStringException(super.msg);

  @override
  @Stub()
  String toString() =>
      'ConditionModelFieldStringException<ConditionModelFieldString>: $msg';
}

/// real implementation of [ConditionModelFieldException] for a field of [ConditionModelFieldStringOrNull] class
@Stub()
class ConditionModelFieldStringOrNullException<ConditionModelFieldString>
    extends ConditionModelFieldException<ConditionModelField> {
  const ConditionModelFieldStringOrNullException(super.msg);

  @override
  @Stub()
  String toString() =>
      'ConditionModelFieldStringOrNullException<ConditionModelFieldString>: $msg';
}

@Stub()
class ConditionModelModelNotInitedException implements Exception {
  final String? msg;
  const ConditionModelModelNotInitedException([this.msg]);

  @override
  @Stub()
  String toString() =>
      'There has been an attempt to change a property of a not inited model (_inited like property/setters/getters == false) f.e. model[\'id\']=1 or model.id = 1; You need to wait until it is asynchronously inited, which you can now any time by invoking  " Future<ConditionModel> getModelOnModelInitComplete() " of the model object model.getModelOnModelInitComplete(); additional optional message: ${msg.toString()}';
}

/// Although abstract this is a full implementation for the data field type [ConditionModelFieldInt] class. [ConditionModelFieldInt] is to, in the future, add some new features by a random programmer in different circumstances, f.e. to make the code work faster in the app or in the backend when a db engine is not compatible with the [ConditionModelFieldIntUniversal] class.
@Stub()
abstract class ConditionModelFieldIntUniversal extends ConditionModelField {
  /// !!! while not implemented yet remember: Remember that user_id of ConditionModelUser requires value to be 0 (zero) but for the rest of cases id > 0
  int minValue =
      0; // !!! Remember that user_id of ConditionModelUser requires value to be 0 (zero) but for the rest of cases id > 0
  int maxValue = 100000000;
  @override
  late final String _validation_exception_message =
      'The Integer value ConditionModelFieldInt must be in the range between $minValue and $maxValue';

  ConditionModelFieldIntUniversal(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});
}

/// See the description of the extended class
@Stub()
class ConditionModelFieldInt extends ConditionModelFieldIntUniversal {
  ConditionModelFieldInt(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});

  @override
  init() {
    super.init();
    model.addFullyFeaturedValidateAndSetValue(
        this, _fullyFeaturedValidateAndSetValue);
  }

  /// To be tested (hopes, should comes from: not tested):. Because i cannot override fields in extending classess, the setter of this dynamic type field is to be overriden by extending classess in a way that you can set not dynamic but stricter types values, especially int, int?, String, String? and then calling supper setter if proper. If [isFinal] property is set false (default) in the constructor _value property is used for getting/setting model.value (setter, getter), if [isFinal] == true [_valueFinal] is used in hopes that if you try to set a property like final model property model.id model['id'] for the second time you will get a compilation time error, not runtime. if no "dynamic" type set like int, int? or String, String? it also should throw the early "desired" editor or compilation time errors.
  late int _value;

  /// See [_value] property description.
  late final int _valueFinal;

  /// Some async methods may somewhere in the middle of their body suspend performing their code until the value of a property is set up for the first time. However for first and second and more changes there is [_changesStreamController] event stream. However to get first change to a property value you need to pass your own [_changesStreamController] completer to the model constructor. But this [_onFirstValueAssignement] here gives you always proper reaction to the first property value change.
  Completer<int> _firstValueAssignementCompleter = Completer<int>();

  Future<int> get firstValueAssignement =>
      _firstValueAssignementCompleter.future;

  @override
  _fullyFeaturedValidateAndSetValue(int value,
      [bool isToBeSet = true,
      isToBeSynchronized = true,
      isToBeSynchronizedLocallyOnly = false]) {
    //!!!!! READ: you have model property here - you need it to finally validate the field

    //if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
    //  we // should allow for setting the value regardles of inite?
    //  throw ConditionModelModelNotInitedException('A field of columnName/key: $columnName cannot be set');
    //}

    /*if (isFinal && _isAlreadyinited) {
      throw const ConditionModelFieldExceptionIsFinal<ConditionModelField>();
    } else {
      _isAlreadyinited = true;
    }*/
    if (isToBeSet) {
      //model.defValue[columnName] = value;
      // setter decides which property containing value to use _value or _valueFinal - see the properties description
      if (isFinal) {
        _valueFinal = value;
      } else {
        _value = value;
      }

      if (_isThisFirstValueAssignement == true) {
        _isThisFirstValueAssignement = false;
        _firstValueAssignementCompleter.complete(value);
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChangeFirstChange(
                columnName, this));
      } else {
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChange(
                columnName, this));
      }

      if (isToBeSynchronized) {
        model.changed = true;
        model.triggerLocalAndGlobalServerUpdatingProcess(
            columnName, isToBeSynchronizedLocallyOnly);
      }
    }
    // here we are doing the ConditionModelFieldInt validation
    // must be called at the end
    //super.validateAndSet(value, isToBeSet);
  }

  /// There are two points of using this method. 1. Initial values passed to the model's constructor are already set and just need to be validated (throwing Exceptions if necessary). 2. By validating them a lazily initialized [ConditionModelField] is created and it gets "this" object as an argument which is possible only on lazy initialization (a fully defined class property extending [ConditionModelField] class gets this object which is not available if the property is not lazily inited).
  void validate() {
    // for consistency let it be this way, yet for information calling model[columnName] is possible would trigger getter but couldn't trigger setter []= which would call a sepparete validation so probably two times validation
    validateAndSet(model.defValue[columnName], false);
  }

  @Stub()
  @MustBeImplemented()
  void validateAndSet(int value, [bool isToBeSet = true]) {
    _fullyFeaturedValidateAndSetValue(value, isToBeSet);
  }

  /// See the desription of the value property - stricter typing for classess extending, optional final keyword, etc.
  set value(int value) => validateAndSet(value);

  int get value => (isFinal) ? _valueFinal : _value;

  bool get inited {
    try {
      if (value is int) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  String toString() {
    try {
      return (isFinal) ? _valueFinal.toString() : _value.toString();
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return 'null';
      rethrow;
    }
  }

  ///It must be overriden for integers it must have return type int.
  @override
  dynamic toJson() {
    try {
      return (isFinal) ? _valueFinal : _value;
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return null;
      rethrow;
    }
  }
}

/// seet description of the extended class
@Stub()
abstract class ConditionModelFieldIntOrNullUniversal
    extends ConditionModelFieldIntUniversal {
  ConditionModelFieldIntOrNullUniversal(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});
}

/// See the description of the extended class
@Stub()
class ConditionModelFieldIntOrNull
    extends ConditionModelFieldIntOrNullUniversal {
  /// To be tested (hopes, should comes from: not tested):. Because i cannot override fields in extending classess, the setter of this dynamic type field is to be overriden by extending classess in a way that you can set not dynamic but stricter types values, especially int, int?, String, String? and then calling supper setter if proper. If [isFinal] property is set false (default) in the constructor _value property is used for getting/setting model.value (setter, getter), if [isFinal] == true [_valueFinal] is used in hopes that if you try to set a property like final model property model.id model['id'] for the second time you will get a compilation time error, not runtime. if no "dynamic" type set like int, int? or String, String? it also should throw the early "desired" editor or compilation time errors.
  late int? _value;

  /// See [_value] property description.
  late final int? _valueFinal;

  /// Some async methods may somewhere in the middle of their body suspend performing their code until the value of a property is set up for the first time. However for first and second and more changes there is [_changesStreamController] event stream. However to get first change to a property value you need to pass your own [_changesStreamController] completer to the model constructor. But this [_onFirstValueAssignement] here gives you always proper reaction to the first property value change.
  Completer<int?> _firstValueAssignementCompleter = Completer<int?>();

  Future<int?> get firstValueAssignement =>
      _firstValueAssignementCompleter.future;

  ConditionModelFieldIntOrNull(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});

  @override
  init() {
    super.init();
    model.addFullyFeaturedValidateAndSetValue(
        this, _fullyFeaturedValidateAndSetValue);
  }

  @override
  _fullyFeaturedValidateAndSetValue(int? value,
      [bool isToBeSet = true,
      isToBeSynchronized = true,
      isToBeSynchronizedLocallyOnly = false]) {
    //!!!!! READ: you have model property here - you need it to finally validate the field
    //if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
    //  throw ConditionModelModelNotInitedException();
    //}

    // here we are doing the ConditionModelFieldInt validation
    if (true) {
    } else {
      throw ConditionModelFieldIntOrNullException(
          _validation_exception_message);
    }

    if (isToBeSet) {
      //model.defValue[columnName] = value;
      // setter decides which property containing value to use _value or _valueFinal - see the properties description
      if (isFinal) {
        _valueFinal = value;
      } else {
        _value = value;
      }

      if (_isThisFirstValueAssignement == true) {
        _isThisFirstValueAssignement = false;
        _firstValueAssignementCompleter.complete(value);
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChangeFirstChange(
                columnName, this));
      } else {
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChange(
                columnName, this));
      }

      if (isToBeSynchronized) {
        model.changed = true;
        model.triggerLocalAndGlobalServerUpdatingProcess(
            columnName, isToBeSynchronizedLocallyOnly);
      }
    }
    // here we are doing the ConditionModelFieldInt validation
    // must be called at the end
    //super.validateAndSet(value, isToBeSet);
  }

  /// There are two points of using this method. 1. Initial values passed to the model's constructor are already set and just need to be validated (throwing Exceptions if necessary). 2. By validating them a lazily initialized [ConditionModelField] is created and it gets "this" object as an argument which is possible only on lazy initialization (a fully defined class property extending [ConditionModelField] class gets this object which is not available if the property is not lazily inited).
  void validate() {
    // for consistency let it be this way, yet for information calling model[columnName] is possible would trigger getter but couldn't trigger setter []= which would call a sepparete validation so probably two times validation
    validateAndSet(model.defValue[columnName], false);
  }

  @Stub()
  @MustBeImplemented()
  @override
  void validateAndSet(int? value, [bool isToBeSet = true]) {
    _fullyFeaturedValidateAndSetValue(value, isToBeSet);
  }

  /// See the desription of the value property - stricter typing for classess extending, optional final keyword, etc.
  set value(int? value) => validateAndSet(value);

  int? get value => (isFinal) ? _valueFinal : _value;

  bool get inited {
    try {
      if (value is int?) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  String toString() {
    try {
      return (isFinal) ? _valueFinal.toString() : _value.toString();
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return 'null';
      rethrow;
    }
  }

  ///It must be overriden for integers it must have return type int.
  @override
  dynamic toJson() {
    try {
      return (isFinal) ? _valueFinal : _value;
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return null;
      rethrow;
    }
  }
}

/// Although abstract this is a full implementation for the data field type [ConditionModelFieldString] class. [ConditionModelFieldString] is to, in the future, add some new features by a random programmer in different circumstances, f.e. to make the code work faster in the app or in the backend when a db engine is not compatible with the [ConditionModelFieldStringUniversal] class.
@Stub()
abstract class ConditionModelFieldStringUniversal<String>
    extends ConditionModelField {
  ConditionModelFieldStringUniversal(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});
}

/// See the description of the extended class
@Stub()
class ConditionModelFieldString extends ConditionModelFieldStringUniversal {
  /// To be tested (hopes, should comes from: not tested):. Because i cannot override fields in extending classess, the setter of this dynamic type field is to be overriden by extending classess in a way that you can set not dynamic but stricter types values, especially int, int?, String, String? and then calling supper setter if proper. If [isFinal] property is set false (default) in the constructor _value property is used for getting/setting model.value (setter, getter), if [isFinal] == true [_valueFinal] is used in hopes that if you try to set a property like final model property model.id model['id'] for the second time you will get a compilation time error, not runtime. if no "dynamic" type set like int, int? or String, String? it also should throw the early "desired" editor or compilation time errors.
  late String _value;

  /// See [_value] property description.
  late final String _valueFinal;

  /// Some async methods may somewhere in the middle of their body suspend performing their code until the value of a property is set up for the first time. However for first and second and more changes there is [_changesStreamController] event stream. However to get first change to a property value you need to pass your own [_changesStreamController] completer to the model constructor. But this [_onFirstValueAssignement] here gives you always proper reaction to the first property value change.
  Completer<String> _firstValueAssignementCompleter = Completer<String>();

  Future<String> get firstValueAssignement =>
      _firstValueAssignementCompleter.future;

  ConditionModelFieldString(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});

  @override
  init() {
    super.init();
    model.addFullyFeaturedValidateAndSetValue(
        this, _fullyFeaturedValidateAndSetValue);
  }

  @override
  _fullyFeaturedValidateAndSetValue(String value,
      [bool isToBeSet = true,
      isToBeSynchronized = true,
      isToBeSynchronizedLocallyOnly = false]) {
    //!!!!! READ: you have model property here - you need it to finally validate the field

    //if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
    //  throw ConditionModelModelNotInitedException();
    //}
    // here we are doing the ConditionModelFieldInt validation
    if (true) {
    } else {
      throw ConditionModelFieldStringException(_validation_exception_message);
    }
    if (isToBeSet) {
      //model.defValue[columnName] = value;
      // setter decides which property containing value to use _value or _valueFinal - see the properties description
      if (isFinal) {
        _valueFinal = value;
      } else {
        _value = value;
      }

      if (_isThisFirstValueAssignement == true) {
        _isThisFirstValueAssignement = false;
        _firstValueAssignementCompleter.complete(value);
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChangeFirstChange(
                columnName, this));
      } else {
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChange(
                columnName, this));
      }

      if (isToBeSynchronized) {
        model.changed = true;
        model.triggerLocalAndGlobalServerUpdatingProcess(
            columnName, isToBeSynchronizedLocallyOnly);
      }
    }
    // here we are doing the ConditionModelFieldInt validation
    // must be called at the end
    //super.validateAndSet(value, isToBeSet);
  }

  /// There are two points of using this method. 1. Initial values passed to the model's constructor are already set and just need to be validated (throwing Exceptions if necessary). 2. By validating them a lazily initialized [ConditionModelField] is created and it gets "this" object as an argument which is possible only on lazy initialization (a fully defined class property extending [ConditionModelField] class gets this object which is not available if the property is not lazily inited).
  void validate() {
    // for consistency let it be this way, yet for information calling model[columnName] is possible would trigger getter but couldn't trigger setter []= which would call a sepparete validation so probably two times validation
    validateAndSet(model.defValue[columnName], false);
  }

  @Stub()
  @MustBeImplemented()
  @override
  void validateAndSet(String value, [bool isToBeSet = true]) {
    _fullyFeaturedValidateAndSetValue(value, isToBeSet);
  }

  /// See the desription of the value property - stricter typing for classess extending, optional final keyword, etc.
  set value(String value) => validateAndSet(value);

  String get value => (isFinal) ? _valueFinal : _value;

  bool get inited {
    try {
      if (value is String) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  String toString() {
    try {
      return (isFinal) ? _valueFinal : _value;
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return 'null';
      rethrow;
    }
  }

  ///It must be overriden for integers it must have return type int.
  @override
  dynamic toJson() {
    try {
      return (isFinal) ? _valueFinal : _value;
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return null;
      rethrow;
    }
  }
}

/// Although abstract this is a full implementation for the data field type [ConditionModelFieldStringOrNull] class. [ConditionModelFieldStringOrNull] is to, in the future, add some new features by a random programmer in different circumstances, f.e. to make the code work faster in the app or in the backend when a db engine is not compatible with the [ConditionModelFieldStringOrNullUniversal] class.
@Stub()
abstract class ConditionModelFieldStringOrNullUniversal
    extends ConditionModelFieldStringUniversal {
  ConditionModelFieldStringOrNullUniversal(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});
}

/// See the description of the extended class
@Stub()
class ConditionModelFieldStringOrNull
    extends ConditionModelFieldStringUniversal {
  /// To be tested (hopes, should comes from: not tested):. Because i cannot override fields in extending classess, the setter of this dynamic type field is to be overriden by extending classess in a way that you can set not dynamic but stricter types values, especially int, int?, String, String? and then calling supper setter if proper. If [isFinal] property is set false (default) in the constructor _value property is used for getting/setting model.value (setter, getter), if [isFinal] == true [_valueFinal] is used in hopes that if you try to set a property like final model property model.id model['id'] for the second time you will get a compilation time error, not runtime. if no "dynamic" type set like int, int? or String, String? it also should throw the early "desired" editor or compilation time errors.
  late String? _value;

  /// See [_value] property description.
  late final String? _valueFinal;

  /// Some async methods may somewhere in the middle of their body suspend performing their code until the value of a property is set up for the first time. However for first and second and more changes there is [_changesStreamController] event stream. However to get first change to a property value you need to pass your own [_changesStreamController] completer to the model constructor. But this [_onFirstValueAssignement] here gives you always proper reaction to the first property value change.
  Completer<String?> _firstValueAssignementCompleter = Completer<String?>();

  Future<String?> get firstValueAssignement =>
      _firstValueAssignementCompleter.future;

  ConditionModelFieldStringOrNull(super.model, super.columnName,
      {required super.propertySynchronisation, super.isFinal});

  @override
  init() {
    super.init();
    model.addFullyFeaturedValidateAndSetValue(
        this, _fullyFeaturedValidateAndSetValue);
  }

  @override
  _fullyFeaturedValidateAndSetValue(String? value,
      [bool isToBeSet = true,
      isToBeSynchronized = true,
      isToBeSynchronizedLocallyOnly = false]) {
    //!!!!! READ: you have model property here - you need it to finally validate the field

    //if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
    //  throw ConditionModelModelNotInitedException();
    //}

    // here we are doing the ConditionModelFieldInt validation
    if (true) {
    } else {
      throw ConditionModelFieldStringOrNullException(
          _validation_exception_message);
    }
    // defValue should be protected or something, because this allows to circumvent the validation process
    if (isToBeSet) {
      //model.defValue[columnName] = value;
      // setter decides which property containing value to use _value or _valueFinal - see the properties description
      debugPrint('B]B]A new value is going to be set - datetime: $value');
      if (isFinal) {
        _valueFinal = value;
      } else {
        _value = value;
      }

      if (_isThisFirstValueAssignement == true) {
        _isThisFirstValueAssignement = false;
        _firstValueAssignementCompleter.complete(value);
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChangeFirstChange(
                columnName, this));
      } else {
        model._changesStreamController.add(
            ConditionModelInfoEventPropertyChangeRegularChange(
                columnName, this));
      }
      if (isToBeSynchronized) {
        model.changed = true;
        model.triggerLocalAndGlobalServerUpdatingProcess(
            columnName, isToBeSynchronizedLocallyOnly);
      }
    }
    // here we are doing the ConditionModelFieldInt validation
    // must be called at the end
    //super.validateAndSet(value, isToBeSet);
  }

  /// There are two points of using this method. 1. Initial values passed to the model's constructor are already set and just need to be validated (throwing Exceptions if necessary). 2. By validating them a lazily initialized [ConditionModelField] is created and it gets "this" object as an argument which is possible only on lazy initialization (a fully defined class property extending [ConditionModelField] class gets this object which is not available if the property is not lazily inited).
  void validate() {
    // for consistency let it be this way, yet for information calling model[columnName] is possible would trigger getter but couldn't trigger setter []= which would call a sepparete validation so probably two times validation

    validateAndSet(model.defValue[columnName], false);
  }

  @Stub()
  @MustBeImplemented()
  @override
  void validateAndSet(String? value, [bool isToBeSet = true]) {
    _fullyFeaturedValidateAndSetValue(value, isToBeSet);
  }

  /// See the desription of the value property - stricter typing for classess extending, optional final keyword, etc.
  set value(String? value) => validateAndSet(value);

  String? get value => (isFinal) ? _valueFinal : _value;

  bool get inited {
    try {
      if (value is String?) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  String toString() {
    try {
      return (isFinal)
          ? _valueFinal == null
              ? 'null'
              : _valueFinal as String
          : _value == null
              ? 'null'
              : _value as String;
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return 'null';
      rethrow;
    }
  }

  ///It must be overriden for integers it must have return type int.
  @override
  dynamic toJson() {
    try {
      return (isFinal) ? _valueFinal : _value;
    } catch (e) {
      if (e.runtimeType.toString() == 'LateError') return null;
      rethrow;
    }
  }
}

//[To do: some draft description of ideas to be  implemented (or not or are already implemented different way as for now)]
//We might need streams:
//all relevant events related a particular model
//But This is not needed and too much resource-consuming for now:
//it is a good question if we need a all model tree stream with id and properties changed, also changes to none existing models - why should you bother?
//1 layer: The rule is that a model is independent when working, yeah it may contact any model in the tree through parent models and their child why not - but it is not
//A 2-like system independent layer whould be for this what was described in the 1 layer something like layers in the tcp/ip protocol
//
//Also to learn streams in different aspects (the main devloper of this stuff needs to learn a lot :( ) this is the way to implement the following feature:
//The following ideas are made from a model perspective - this is about what a model needs:
//We have two situations and must simplify them. Any sofistication must be done on different layer (f.e. any sorts of timestamps of update to a property or something like that)
//Let's try to start with an overall one broadcast stream of objects of a class ConditionModelUpdateInfo (or anything else)
//abstract ? ConditionModelPropertyChangeInfo has a name, and is probably implemented
//MUST BE!: The main overall stream must start working before any property value is set on a model, so that i can
//listen and catch first change to a property-  if i miss the moment an app can stop working waiting for a second change that
//for example will never occur.
//Because you always have updated value for the property name, so name is enough
//ConditionModelPropertyChangeInfoRegularChange - ignoring all server stuff - model property changed - it fires
//    subclass ConditionModelPropertyChangeRegularChangeFirstChange - ignoring all server stuff
//ConditionModelPropertyChangeInfoModelToLocalServerStart
//ConditionModelPropertyChangeInfoModelToLocalServerSuccess
//ConditionModelPropertyChangeInfoModelToGlobalServerStart
//ConditionModelPropertyChangeInfoModelToGlobalServerSuccess
//Below probably to separate the model from stuff going on behind the scenes, it is enough to do just this:
//ConditionModelPropertyChangeInfoGlobalServerToLocalServerToModelSuccess
//Async package if needed could merge all such streams from all currently working models. Cache results. LazyStream - useful?
//for async* (sync* counterpart) generators
//yield value
//yield* generator function which is stream or any compatible stream that would better end;
//print('BEFORE');
//await for(String s in stream) { print(s); }
//print('AFTER');
//void main() async {
//  final items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
//  Iterable inReverse = items.reversed;
//  await Future.forEach(inReverse, (item) async {
//    print(item);
//    await Future.delayed(const Duration(seconds: 1));
//    // wait for 1 second before next iteration
//  });
//}
//void main() async {
//  final items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
//   Iterable inReverse = items.reversed;
//  for (int item in inReverse) {
//    print(item);
//    await Future.delayed(const Duration(seconds: 1));
//  }
//}
//########################################################################################

/// For now this is the base of all extending classes for events used by the [_changesStreamController] property (a controller object)
abstract class ConditionModelInfoStreamEvent {
  ConditionModelInfoStreamEvent();
}

/// Precaution! It is really good to read [ConditionModelPropertyChangeInfoModelToLocalServerStart] class description and other related classess before doing some customizations on your own. Some stuff described here may be implemented in a extending class (name property f.e.) so read the extending classess contents and descriptions. Your need to pass into the constructor of a [ConditionModel] extended class a Broadcast [StreamController] class's reqular object ([StreamController.broadcast](...) constructor) for the _changesStreamController property IF YOU NEED the very, very first event of the Stream and you cannot afford to missing any event. Normal description: This class is used with stream in [ConditionModel] class's protected property [_changesStreamController] stream controller ([getChangesStreamSubscription] public getter returns a broadcast stream). The stream returns this abstract class events (all dart streams send "events" by definition). However based on my or your as a developer interests you can listen to this stream an create different streams sending events extending the [ConditionModelPropertyChangeInfo] class like f.e. [ConditionModelPropertyChangeInfoModelToLocalServerStart]. Why these features are so needed? F.e. A child model may need a global server server_parent_id or server_contact_owner_id before it starts doing some important stuff, it is waiting for the first change to the value of the property. In the meantime however all other properties of the model can change or any code can be executed. But in some asynchronous method we wait for the mentioned server properties to be set up first. For this we can wait until a first element of a class [ConditionModelPropertyChangeRegularChangeFirstChange] arrives which is child of [ConditionModelPropertyChangeInfoRegularChange] and this one is also this lowest level basic class [ConditionModelPropertyChangeInfo] child. The name of the extending classes are pretty long and self describing not at the expense of naming convention so that you know what class belong to the broader Condition... or ConditionModel... recognizable prefixes.
abstract class ConditionModelInfoEventPropertyChange
    extends ConditionModelInfoStreamEvent {
  ConditionModelInfoEventPropertyChange();
}

class ConditionModelInfoEventModelTreeOperation
    extends ConditionModelInfoStreamEvent {
  /// Most extending classess have non-null requirement for this property with a reason. it also involves a variable of [_addParentLinkModel] method, the [parentLinkModel] param of the method,
  final ConditionModel? parentModel;

  /// it also involves a variable's property of [_addParentLinkModel] method, the [parentLinkModel].[_childLinkModel] param of the method,
  final ConditionModelParentIdModel
      childModel; // ? ConditionModelUser is ConditionModelParentIdModel, ConditionModelApp is not so it is fine.

  ConditionModelInfoEventModelTreeOperation(this.parentModel, this.childModel);
}

/// Each [ConditionModelApp] has the probably three following properties [Sets]: [_allAppModelsNewModelsWaitingRoom], [_allAppModels], [_allAppModelsScheduledForUnlinking] so this category is related to managing models in these variables, but not directly (indirectly yes, definitely) related to adding child to the model tree via methods like [addChild] [removeChild], addParentLink (?), remove... or so.
class ConditionModelInfoEventConditionModelAppModelSetsManagement
    extends ConditionModelInfoStreamEvent {
  /// Most extending classess have non-null requirement for this property with a reason. it also involves a variable of [_addParentLinkModel] method, the [parentLinkModel] param of the method,
  final ConditionModelParentIdModel model;
  ConditionModelInfoEventConditionModelAppModelSetsManagement(this.model);
}

/// May something changed but the desc is: model but is childModel used instead. The point is each NEW model in the [ConditionModelParentIdModel] at the beginning of the constructor body (-important, also with id or no id) through _changesStreamController synchronous (important) stream event goes to the [_allAppModelsNewModelsWaitingRoom] and from there elsewhere if necessary see the property description to understand the "whole" process.
class ConditionModelInfoEventModelAcceptModelToTheConditionModelAppWaitingRoomSet
    extends ConditionModelInfoEventConditionModelAppModelSetsManagement {
  int? id;
  ConditionModelInfoEventModelAcceptModelToTheConditionModelAppWaitingRoomSet(
      super.model, this.id);
}

/// Around here in the code there sould be two or more similar synchronously important events like marking start of the real retire body code execution. Very important issued synchronously when in retire() method isRetired is set (or similar name), by the way [_lastRetireMethodCall] is updated before the event is issued - it was so when this piece of code was written
class ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel
    extends ConditionModelInfoEventConditionModelAppModelSetsManagement {
  ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel(
      super.model);
}

/// Why this is key event? The first and only planned receipient of this synchronous event in the [ConditionModelApp] class can do anything with the model if no async retirement process is still pending. If f.e. the model is not retired right now it can be attached/reattached to the model tree with addChild() method. See similar events here related to the retire method. the event is issued in the [retire] method the best used in synchronous handling. It tells you that after a call of retire method (another event) its synchronous aspect of its body has just started being executed. If another call of the retire method occurs when the previous synchronous aspect hasn't finished yet it returns false; and this event isn't issued again. However when the body finishes [ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled] event is sent and the retire method synchronous aspect of the method body may be called again. Some other properties related are involved in the [retire] method area in the code. Caution! It was designed to work on the event loop with major blocks executed synchronously. Also see related events desc like [ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired], [ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired]
/// For around three events review.
/// THE MOST UP-DO-DATE SHOULD BE IN retire() method body, but it is copied also to the [ConditionModelApp] class these events hadling
/// =====================================================================
/// Review event, timestamps, some other, not all stuff in the right order of occuring:
/// Important, again and again all related to reaction to synchronous aspect of retire call
/// ---------------
/// _lastRetireMethodCall
/// ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel
/// ---------------
///
/// _retireMethodItsBodyCodeExecutionLastStart
/// _isRetireMethodBodyAlreadyBeingExecuted == true;
/// ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled
/// --------------------
/// _retireMethodItsBodyCodeExecutionLastFinish // important - always updated when _retireMethodItsBodyCodeExecutionLastStart updated, even when synchronous body exception is thrown
/// _isRetireMethodBodyAlreadyBeingExecuted == false;
/// ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution
class ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution
    extends ConditionModelInfoEventConditionModelAppModelSetsManagement {
  ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution(
      super.model);
}

/// See [ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution]
class ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled
    extends ConditionModelInfoEventConditionModelAppModelSetsManagement {
  ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled(
      super.model);
}

/// See also [ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel] Very important issued synchronously when in retire() method isRetired is set (or similar name) for the information about combination of three related events.
class ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired
    extends ConditionModelInfoEventConditionModelAppModelSetsManagement {
  ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired(
      super.model);
}

/// Issued only when the model in all ways is not in the main model tree already. Only child model is passed which his [_retireModelWhenWhenRemovedFromTheModelTree] (USE SETTER/GETTER NOT THE PROPERTY) property has just changed. Whenever the always boolean value is changed (so no constructor init involved) [_retireModelWhenWhenRemovedFromTheModelTree] (@protected/public setter/getter) property is changed from false to true the model itself emits this event and [ConditionModelApp] check out if the model is in the tree and if not it schedules removal of the model from its list of mantained models so that there is no link to the model and ALL RESOURCES RELATED TO THE MODEL OBJECT ARE RELEASED (THATS THE MAIN POINT);
class ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree
    extends ConditionModelInfoEventModelTreeOperation {
  ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree(
      childModel)
      : super(null, childModel);
}

class ConditionModelInfoEventModelTreeOperationAddingModelToTheTree
    extends ConditionModelInfoEventModelTreeOperation {
  ConditionModelInfoEventModelTreeOperationAddingModelToTheTree(
      ConditionModel super.parentModel, super.childModel);
}

class ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree
    extends ConditionModelInfoEventModelTreeOperationAddingModelToTheTree {
  ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree(
      super.parentModel, super.childModel);
}

/// event issued after _children has this new child and it's parentNode is set up. So fully operational in both directions
class ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel
    extends ConditionModelInfoEventModelTreeOperationAddingModelToTheTree {
  ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel(
      super.parentModel, super.childModel);
}

class ConditionModelInfoEventModelTreeOperationRemovingModelFromTheModelTree
    extends ConditionModelInfoEventModelTreeOperation {
  ConditionModelInfoEventModelTreeOperationRemovingModelFromTheModelTree(
      ConditionModel super.parentModel, super.childModel);
}

class ConditionModelInfoEventModelTreeOperationModelHasJustBeenRemovedFromTheModelTree
    extends ConditionModelInfoEventModelTreeOperationRemovingModelFromTheModelTree {
  ConditionModelInfoEventModelTreeOperationModelHasJustBeenRemovedFromTheModelTree(
      super.parentModel, super.childModel);
}

/// event issued after _children dont have this child and it's parentNode null. So fully operational in both directions
class ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved
    extends ConditionModelInfoEventModelTreeOperationRemovingModelFromTheModelTree {
  ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved(
      super.parentModel, super.childModel);
}

//-------------

class ConditionModelInfoEventModelTreeOperationModelLinking
    extends ConditionModelInfoEventModelTreeOperation {
  ConditionModelInfoEventModelTreeOperationModelLinking(
      ConditionModel super.parentModel, super.childModel);
}

/// Child will have it's parentLinkModel [_parentLinkModels] removed when the parentLinkModel is scheduled to be retired (no dart language tool for that, need to bypass that :) )
class ConditionModelInfoEventModelTreeOperationAddingChildModelToParentLinkModel
    extends ConditionModelInfoEventModelTreeOperationModelLinking {
  ConditionModelInfoEventModelTreeOperationAddingChildModelToParentLinkModel(
      super.parentModel, super.childModel);
}

/// Child will have it's parentLinkModel [_parentLinkModels] removed when the parentLinkModel is scheduled to be retired (no dart language tool for that, need to bypass that :) )
class ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel
    extends ConditionModelInfoEventModelTreeOperationAddingChildModelToParentLinkModel {
  ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel(
      super.parentModel, super.childModel);
}

/// Parent link model will never have its child removed, so no removal class
class ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustReceviedChildModel
    extends ConditionModelInfoEventModelTreeOperationAddingChildModelToParentLinkModel {
  ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustReceviedChildModel(
      super.parentModel, super.childModel);
}

/// Child will have it's parentLinkModel [_parentLinkModels] removed when the parentLinkModel is scheduled to be retired (no dart language tool for that, need to bypass that :) )
class ConditionModelInfoEventModelTreeOperationRemovingChildModelFromParentLinkModel
    extends ConditionModelInfoEventModelTreeOperationModelLinking {
  ConditionModelInfoEventModelTreeOperationRemovingChildModelFromParentLinkModel(
      super.parentModel, super.childModel);
}

/// Child will have it's parentLinkModel [_parentLinkModels] removed when the parentLinkModel is scheduled to be retired (no dart language tool for that, need to bypass that :) )
class ConditionModelInfoEventModelTreeOperationChildModelHasJustHadHisParentLinkModelRemoved
    extends ConditionModelInfoEventModelTreeOperationRemovingChildModelFromParentLinkModel {
  ConditionModelInfoEventModelTreeOperationChildModelHasJustHadHisParentLinkModelRemoved(
      super.parentModel, super.childModel);
}

/// Parent link model will never have its child removed, so no removal class
class ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustHadHisChildModelRemoved
    extends ConditionModelInfoEventModelTreeOperationRemovingChildModelFromParentLinkModel {
  ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustHadHisChildModelRemoved(
      super.parentModel, super.childModel);
}

//-----------------------

class ConditionModelInfoEventModelInitingAndReadiness
    extends ConditionModelInfoStreamEvent {
  final ConditionModel model;
  ConditionModelInfoEventModelInitingAndReadiness(this.model);
}

class ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInited
    extends ConditionModelInfoEventModelInitingAndReadiness {
  ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInited(
      super.model);
}

class ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInitedLocalServer
    extends ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInited {
  ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInitedLocalServer(
      super.model);
}

class ConditionModelInfoEventModelInitingAndReadinessModelLockingUnlocking
    extends ConditionModelInfoEventModelInitingAndReadiness {
  ConditionModelInfoEventModelInitingAndReadinessModelLockingUnlocking(
      super.model);
}

class ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenLockedAndWaitingForParentModelToUnlockIt
    extends ConditionModelInfoEventModelInitingAndReadinessModelLockingUnlocking {
  ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenLockedAndWaitingForParentModelToUnlockIt(
      super.model);
}

class ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenUnlockedByParentModel
    extends ConditionModelInfoEventModelInitingAndReadinessModelLockingUnlocking {
  ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenUnlockedByParentModel(
      super.model);
}

class ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInitedGlobalServer
    extends ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInited {
  ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInitedGlobalServer(
      super.model);
}

/// See parent class desc. Often seen as an instance of [ConditionModelInfoEventPropertyChangeRegularChangeFirstChange] name is needed f.e. when you cannot do some global server related stuff on a newly created sub contact when you have no server_id (or more properties) of its parent contact set up. Field property takes into account possible future overall application stream (or not) when a model or some other part of the app for some now "unimaginable" reason wants to listen to changes of a model of a particular id (for what??? and why not???) when it appears in the model tree. Based on this you can do some actions on the model taken from the field.model property (as far as i remember) you can create some substreams based on some criteria and so on, and so on... This would be good because it increased the flexibility of this overall app/library the /devoloper(s?)/ was aiming at.
class ConditionModelInfoEventPropertyChangeRegularChange
    extends ConditionModelInfoEventPropertyChange {
  final String name;
  final ConditionModelField field;
  ConditionModelInfoEventPropertyChangeRegularChange(this.name, this.field);
}

/// See the parent (the parent's parent class exactly) class description
class ConditionModelInfoEventPropertyChangeRegularChangeFirstChange
    extends ConditionModelInfoEventPropertyChangeRegularChange {
  ConditionModelInfoEventPropertyChangeRegularChangeFirstChange(
      super.name, super.field);
}

/// [!!!!!! Don't miss implementing this] See the parent (the parent's parent's parent :) class exactly) class description
class ConditionModelInfoEventPropertyChangeRegularChangeGlobalServerInducedFirstChange
    extends ConditionModelInfoEventPropertyChangeRegularChangeFirstChange {
  ConditionModelInfoEventPropertyChangeRegularChangeGlobalServerInducedFirstChange(
      super.name, super.field);
}

/// The update system is constructed in a way that consecutively each [ConditionModelPropertyChangeInfoModelToLocalServerStart] event is followed by a [ConditionModelPropertyChangeInfoModelToLocalServerSuccess] or [ConditionModelPropertyChangeInfoModelToLocalServerError] event. There is no two or more consecutive [ConditionModelPropertyChangeInfoModelToLocalServerStart] objects for the model. But it may happen that when f.e. [ConditionModelPropertyChangeInfoModelToLocalServerSuccess] event fired to the stream you may want do a piece of code when in the meantime a property change happened asynchronously elsewhere in the app code for example and a new event [ConditionModelPropertyChangeInfoModelToLocalServerStart] yet has not fired (very rare situation?), but the code executes anyway. So if you must know that something is yet updating you have the following model properties to check it out public properties [modelIsBeingUpdated], [modelIsBeingUpdatedGlobalServer]. So any time [modelIsBeingUpdated] == true (very rare) you could do return and wait again until another [ConditionModelPropertyChangeInfoModelToLocalServerSuccess] arrives. Additionally important about [ConditionModelPropertyChangeInfoModelToLocalServerError] event. Apart from that error event should never happen except for the application not being able to operate on data permantently, not because of temporary lost of internet connection if it is not sqlite3 but f.e. remote mysql server, etc. (yet to be fully determined). And additionally the global events [ConditionModelPropertyChangeInfoModelToGlobalServerSuccess] or [ConditionModelPropertyChangeInfoModelToLocalServerError] may appear with a long delay, f.e. 1 minute, one day, etc. until the internet connection is restored. The app will determine if we need to wait or an error occured. So you need to bear in mind that global server updates may take a lot of time and you need to plan your apps not depending entirely on quick global server updates.
class ConditionModelInfoEventPropertyChangeModelToLocalServerStart
    extends ConditionModelInfoEventPropertyChange {
  ConditionModelInfoEventPropertyChangeModelToLocalServerStart();
}

/// Read ConditionModelPropertyChangeInfoModelToLocalServerStart description
class ConditionModelInfoEventPropertyChangeModelToLocalServerSuccess
    extends ConditionModelInfoEventPropertyChange {
  ConditionModelInfoEventPropertyChangeModelToLocalServerSuccess();
}

/// Read ConditionModelPropertyChangeInfoModelToLocalServerStart description. Apart from that errors should never happen except for the application not being able to operate on data permantently (yet to be fully determined). Read more there.
class ConditionModelInfoEventPropertyChangeModelToLocalServerError
    extends ConditionModelInfoEventPropertyChange {
  ConditionModelInfoEventPropertyChangeModelToLocalServerError();
}

/// [!] See the local server aspect corresponding classess descriptions, especially [ConditionModelPropertyChangeInfoModelToLocalServerStart].
class ConditionModelInfoEventPropertyChangeModelToGlobalServerStart
    extends ConditionModelInfoEventPropertyChange {
  ConditionModelInfoEventPropertyChangeModelToGlobalServerStart();
}

/// See the local server aspect corresponding classess descriptions, especially [ConditionModelPropertyChangeInfoModelToLocalServerStart].
class ConditionModelInfoEventPropertyChangeModelToGlobalServerSuccess
    extends ConditionModelInfoEventPropertyChange {
  ConditionModelInfoEventPropertyChangeModelToGlobalServerSuccess();
}

/// See the local server aspect corresponding classess descriptions, especially [ConditionModelPropertyChangeInfoModelToLocalServerStart].
class ConditionModelInfoEventPropertyChangeModelToGlobalServerError
    extends ConditionModelInfoEventPropertyChange {
  ConditionModelInfoEventPropertyChangeModelToGlobalServerError();
}

/// [!!!!!! Don't miss implementing this] See also more overall and detailed ideas contained in [ConditionModelPropertyChangeInfoModelToLocalServerStart] and [ConditionModelPropertyChangeInfo] classes but also all core such-like classes descriptions. Also This one is simple, because any updates are done by the framework behind the scenes. No errors, no start just the successful result if somehing really happened to the model data on the global server side.
class ConditionModelInfoEventPropertyChangeGlobalServerToLocalServerToModelSuccess
    extends ConditionModelInfoEventPropertyChange {
  /// For now this could be the base for notifying a model object that is already in a tree of model objects of changes that arrived. A model especially some custom version might decide what to do before assigning the arriving values. For whatever reason. Also any change to the model property triggers it's own stream event [ConditionModelPropertyChangeInfoRegularChange] so first go this [ConditionModelPropertyChangeInfoGlobalServerToLocalServerToModelSuccess] then goes these [ConditionModelPropertyChangeInfoRegularChangeGlobalServerInduced] or [ConditionModelPropertyChangeInfoRegularChangeGlobalServerInducedFirstChange]
  Map<String, dynamic> updatedProperties;
  ConditionModelInfoEventPropertyChangeGlobalServerToLocalServerToModelSuccess(
      this.updatedProperties);
}

/// See also more comprehensive description of similar [ConditionDataManagementDriverFunction] function. This function type used in [ConditionModel] class in the method addListener(). After a listener is registered it is invoked any time asynchronous operation producing Futures starts. It is useful when a model [ConditionModel] starts saving data on the server and widget attached to this model registered the listener and until the models operation is in progress the widget shows a visual loader informing user that the operation is in progress.
typedef ConditionModelListenerFunction<Future> = bool Function(Future future);

/// Needed for a method param to make clear what type is needed, f.e. you can pass a name like [ConditionModelMessage] or someMessage.runtimeType which is again [ConditionModelMessage] type, not object of a type, you expect as param - f.e. from a child type you get the name string and use it to find an sql table name.
typedef ConditionModelType = ConditionModel;

///Read all description: See [ConditionModelCompleteModelException] class too, If you have a complete finished model (Extending ConditionModel class and probably some major important classes) that is directly stored into the db it must implement this interface [ConditionModelCompleteModel]. The class provides a method that automatically inits the model which involves it's interation with the database (also done automatically). You just must call the imported method initCompleteModel() in the model\'s constructor body at the end of the body!. If you don\'t object of the non-extendable complete final model class will not work properly. You cannot extend such a complete/final model class.
abstract class ConditionModelCompleteModel {
  ///See the mixin description
  initCompleteModel() {
    // call init function
    //initModel(); // cannot uncomment because it is not implemented in this class
  }

  /// Uses [ConditionConfiguration].notLazyModelTreeRestorationLevel value. This is most probably called at first in initCompleteModel() body of any class habing it. It can be called also when a model is cleared from it's children (lazy loading, dynamic updates, etc.) but then they are back again.To remind first: The general rule and architecture is that each model in a sense cares for itself. So you basically cannot or at least should add _children of a your child model, you can add children of you your self. If you ignore the rule of quite an independence of a model in "all" aspects there maybe damage to the data integrity or so - simplified rule may not be that sometimes obvious looking at the code, but it is the rule applied wherever possible. This method recreates from the db children of the current model and the children are added to the _children property and should be rendered at the proper moment, especially if the currentTreeLevel property allows for that, how? The currentTreeLevel param tells you what level it is in the tree, and is respected at the start of the app. Each model class implements it's own version of the method. F.e. if grandfather currentTreeLevel == 1 ([ConditionModelApp]) then father currentTreeLevel == 2, child == 3, and so on. If in the global or maybe other settings the max current level is 3 the standard version of the app will restore its models from the db in such a way that [ConditionModelApp] (grandfather currentTreeLevel == 1) object will be restored and rendered also father [ConditionModelUser] and finally all first level [ConditionModelContact] users/groups, subcontacts and subgroups won't be rendered. Good to remember f.e. [ConditionModelMessage] messages may not be rendered, because of the nature of displaying such stuff. So this is the rule and also an example that like messages there maybe some different implementation of the rule related to currentTreeLevel param. So why is the ignoreCurrentTreeLevel param? When you want to lazy loading the next level of models this will enable you doing so.
  @protected
  restoreMyChildren(
      /*int currentTreeLevel, [bool ignoreCurrentTreeLevel = false]*/) {
    try {
      throw Exception(
          '''    ConditionConfiguration.maxNotLazyModelTreeRestorationLevel    
    ConditionConfiguration.maxNotLazyModelTreeRestorationLevelForStandaloneModels
    currenTreeLevel++;''');
    } catch (e) {
      debugPrint('$e');
    }
    // Any time you impelment the method check out for this:
    //if (!this._children.isEmpty) {
    //  throw Exception('ConditionModelParentIdModel, restoreMyChildren() method: To restore this model\'s children models the _children property must be empty - must be this._children.isEmpty == true');
    //}
  }
}

@Stub()
class ConditionModelCompleteModelException implements Exception {
  final String msg;
  const ConditionModelCompleteModelException(
      [this.msg =
          'Read all: This Exception mean that if you have a complete finished model (Extending ConditionModel class and probably some major important classes) that is directly stored into the db it must implement this interface class [ConditionModelCompleteModel]. You just must call the imported method initCompleteModel() in the model\'s constructor body at the end of the body!. If you don\'t the model will not work properly. You cannot extend such a complete/final model class. See it\'s description form more information']);

  @MustBeImplemented()
  String toString() => '${runtimeType}: $msg';
}

/// If a [ConditionModel] class mixes with this mixin it informes [ConditionModel] class, which is at the root of any model class, that a model is dynamic, there is need to create automatically a corresponding db table. The rule is that all extendable classes leading to a complete model classes that allow creating real-life model is ready to use, like [ConditionModelContact], [ConditionModelMessage], [ConditionModelApp] - so each one of the mentioned classess in between are ready to be extended to be a complete ready-to-use model classess from which can be created working models (such complete model classes implement [ConditionModelCompleteModel] interface). So again if you mix any such non-standard class with this here [ConditionModelDynamic] interface, [ConditionModel] class has tools to automatically handle the class depending on what class it extended (those classess in between)  (standard class example again ConditionModelMessage)
mixin ConditionModelDynamic {}

/// TODO: some classes are probably now one entry - if accidentally mixed with this one, should be exception thrown. If a [ConditionModel] class mixes with this mixin it informes [ConditionModel] class, which is at the root of any model class, that a model have one entry in the database, it has always id =] 1, no id == 2 or 3 or null can be. This is useful for example when you store the entire app setting in one place which is the case with ConditionModelApp model object corresponding to entire right now working app.
mixin ConditionModelOneDbEntryModel {}

/// Really see [ConditionModelDynamic] class too. [!READ and see for "[To do]""] Important rules: all tables must have id column, if a newly created model object has only 'id' (so with .id) property set-up, the data is fetched and only the validated and the all model's properties are set up. If a newly created model has some or all properties set up except for id property - the model completely new, it doesn't have it's row in the sql db (speaking in sql language terms), so the models properties except for id are validated and send into db, if all is successful, the db returns inserted id. Then updates of single or more properties are done automatically when they are changed. Seek for more properties related to automatic or less automatic changes. You could even do the id stuff automatically even if a model doesn't have the id column defined - rethink it well.
/// Important. if f.e. this.id throws exception then this['id'] == null. This is because id hasn't been initialized yet (the "late" keyword before the corresponding a_id property) and hasn't gotten it's value from the db. The same rule for all the rest of properties of model classes. this['id'] cannot throw any exception because a the map specs requires that. It includes a not defined 'nonidsomefield' key of using a a_nonidsomefield field that hasn't been defined too for a given [ConditionModel] extending class.
abstract class ConditionModel extends ConditionMap {
  /// it is always set up in the constructor body properly or exception is thrown that something went wrong
  late final ConditionModelApp conditionModelApp;

  /// Assigned immediately in the constructor body. Also necessary to read [_appUniqueId] desc of [ConditionModelApp] class. Each model object has uniqueId in the app object not in the entire application scope. The ids and minId, maxId is described better in [ConditionModelApps] and [ConditionModelApp]. In short it is for [Finazlizer] of this model to start working when last reference to this particular model is lost. When some object of some class can't have a reference to this model instance so that the model's finaliser is able to start working the other object has the model's id to associate some other object with the model and on model's the removal it can remove the related objects based on the id or perform other finishing/finalizing actions.
  late final int uniqueId;

  /// Only for local server. Read the description of [_fieldsToBeUpdated].
  bool _modelIsBeingUpdated = false;

  /// See [_modelIsBeingUpdated] description
  bool _modelIsBeingUpdatedGlobalServer = false;

  /// Related to [_fieldsToBeUpdated] property description. After invoking triggerLocalAndGlobalServerUpdatingProcess and finishing the update process there is need to check for changes to the model and trigger the update process again once - it will be performed if the [_fieldsToBeUpdated] set is not empty
  bool _triggerServerUpdatingProcessRetrigerAfterFinish = false;

  /// See [_triggerServerUpdatingProcessRetrigerAfterFinish] desc, that corresponds to this but here global server update
  bool _triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer = false;

  /// For now the simplified explanation of the architecture is that [_fieldsToBeUpdated] when start being updated are moved, not copied to [_fieldsNowBeingInTheProcessOfUpdate], then after the update from there to [_fieldsToBeUpdatedGlobalServer] which is handled by an independent handler ( :) ) so then to [_fieldsNowBeingInTheProcessOfUpdateGlobalServer] like we earlier said. Read more: Shortly the architecture for it is model updates itself on the local and global server but the [ConditionDataManagementDriver] object it uses do the cyclical updates on the global server which. The probability that the model does the updates very quickly is very high, so you don\'t bother the driver to do it most quickly and efficiently if in some case the app restarts itself after turning the device off or an accidental crash. And in 99,5 % of cases local server is not going to be jammed by data of it's global server aspect (each app is local and global server as you should already now) so searching for updates is not a big deal, so model can essentially do the stuff. The fields [_fieldsToBeUpdatedGlobalServer] and [_fieldsNowBeingInTheProcessOfUpdateGlobalServer] for global server should work similarly to the following description of local server updates (BUT FOR NOW ALL ROW WILL BE UPDATED, A TABLE WITH PROPERTIES LIST SHOULD BE CREATED THE GLOBAL VERSION PROPERTIES PROBABLY WON'T BE USED AT ALL), and there may be no need for the now non-existing _modelIsBeingUpdatedGlobalServer property that would be an equivalent of the actual [_modelIsBeingUpdated] property: When model is inited (__init and _init setter?) and so ready, on each property update a property is added to this main list. When assynchronous update starts with maybe some delay (maybe global settings and in the way of feeling of immediateness like 40 ms max) we lock ([_modelIsBeingUpdated] == true - for local server no need for the global probably) the ability to trigger some other simultanous update (it will be check on independently at the end of the process now being described, also maybe timestamp of last update and if a time passed when no update was set up a db update is about to be performed) to enable several more properties to be updated in the meantime. The changed properties are moved (not just copied) to the [_fieldsNowBeingInTheProcessOfUpdate] and this [_fieldsToBeUpdated] is empty. We update the changed properties in the db and synchronize them on the global server. If we are successful with the local server update the properties of [_fieldsNowBeingInTheProcessOfUpdate] are emptied but we check-out if in the meantime another bunch of [_fieldsToBeUpdated] properties hasn't appeared, if so we again trigger the update operation, but if after it all finishes we have [_fieldsNowBeingInTheProcessOfUpdate] empty and can unlock the update mechanism ([_modelIsBeingUpdated] == false) and we start it all over again: when a first property has changed ...
  final Set<String> _fieldsToBeUpdated = {};

  /// Read the description of [_fieldsToBeUpdated].
  final Set<String> _fieldsNowBeingInTheProcessOfUpdate = {};

  /// Read the description of [_fieldsToBeUpdated].
  //@Deprecated('Depreciated on start :) . Read all related descriptions. This property probably is going to be replaced by the db for global server synchronization')
  final Set<String> _fieldsToBeUpdatedGlobalServer = {};

  /// Read the description of [_fieldsToBeUpdated].
  //@Deprecated('Depreciated on start :) . Read all related descriptions. This property probably is going to be replaced by the db for global server synchronization')
  final Set<String> _fieldsNowBeingInTheProcessOfUpdateGlobalServer = {};

  //end properties db update system --------------------------------------
  //----------------------------------------------------------
  //----------------------------------------------------------

  // --------------------------------------------
  // ??? BELOW ARE SOME PROPERTIES WHICH WORKING should be implemented

  /// Each [ConditionModel] table has to have int id column even if it has one row (id always is equal to 1), If true it uses "where id=1" or so, then speaking in SQL db terms an SQL table, containing the model's data, is one row table and is read using SELECT *, then one. Also as in the class description:
  @Deprecated(
      'mixin [ConditionModelOneDbEntryModel] to be used - if (model is ConditionModelDynamic) {}')
  final bool isOneDbEntryModel = false;

  /// !!! NO - USE 1 (or later MORE INTERFACES when core functionality is implemented INSTEAD OF THIS PROPERTY (maybe later like interface for local id, and global server_id, and more), ,THIS CLASS WILL DETECT THIS IS TYPE OF THE INTERFACE This could dramatically speed-up increase development productivity. However There is need to check-out if a table of a "suprising" model class exists in the db in the form of a table, which is a one time operation during the apps life cycle (not a problem for the local server of the app, but solving global server issues may be needed - flood or rougue tables? - [Edit:] it could be done by a brand new :) static ConditionModelApp.introduceConditionModelClass(Type conditionModelType) - if technically posssible it will call the second constructor conditionModelType.createSchemaModel(), based on this local and global server will create corresponding table if not exists, and accept the class). Such information must be stored in a separate class with a static list List<ConditionModel> accepting ConditionModel extended types You could even do the id stuff automatically even if a model doesn't have the id column defined - rethink it well.
  @Deprecated(
      'mixin [ConditionModelDynamic] to be used - if (model is ConditionModelDynamic) {}')
  bool autoCreateModelTable = false;
  // --------------------------------------------
  // --------------------------------------------
  // --------------------------------------------
  // --------------------------------------------

  bool get modelIsBeingUpdated => _modelIsBeingUpdated;

  bool get modelIsBeingUpdatedGlobalServer => _modelIsBeingUpdatedGlobalServer;

  /// In this app/library version Not the best way to handle it but the core app model classess for now use one db table 'ConditionModelClasses', f.e. [ConditionModelMessage], [ConditionModelContact], but not [ConditionModelApp], [ConditionModelUser] and any model class implementing [ConditionModelDynamic]. The existence and usage of this property solves some issues that otherwhise would prolong initial release of the app.
  final String? appCoreModelClassesCommonDbTableName;

  final Map<String, ConditionModelField> columnNamesAndTheirModelFields = {};

  final Map<String, Function>
      columnNamesAndFullyFeaturedValidateAndSetValueMethods = {};

  /// After rethinking the matter each lolal server driver (for all locally stored data) can containe [_driver_backend] driver and the local server driver if (no if not) will synchronize data with the global server [_driver_backend]. For now local server driver (among others the app local storage but http server at the same time see the read.me) - this must be set up. Read to the end!!! about caching webpage and reload! Drivers are simply String key, String? value - no other types, but strings are json encoded and they have integers, strings, etc. and [ConditionModel] models help to validate variables as to their type, range of values, etc. [_driver] gives you all widgets, and tree structure info when you start the app or reload the page, when all data is synchronized with the backend, for web there will be another driver for this - read only - technically reading data from javascript variable after full page reload. For all platforms all new data, new widgets, moving a model/widget elsewhere, model removal, whatever goes first to [_driver_temp]. For all platforms except web it will be a reference the exact same object as _driver (don't be worrying about namaspace stuff), but for web it will be the localStorage driver which can only contain up to 5MB (yet to confirm if encoding can increase the amount of data). 5MB - now you understand the reason of the two variables architecture. It is not bad anyway [_driver_temp] keeps clearly separaged data before it is updated in the backend. Simplifying: After the update for all platform except for web we update the main data managed by the [_driver] and clear the data [_driver_temp] manages but in case of the web only reload updates the data managed by [_driver] in a way that full data is loaded to the js variable (or html tag whatever), and only now localStorage can be cleared of temporary data. The idea is and important thing: if you f.e. lost internet connection but you created a div with data of _driver_temp - you could possibly exceed localStorage 5MB capacity, and if you next turn of the browser and turn on and the page loads from casche with the just mentioned div or something like that it should work, it would be wonderfull if it worked. Abandoned idea altarnatively you could read with AJAX all data for the [_driver] put it to a div for example and a page after reading from cashe would read it from the div. Also some browsers allow for saving page to the disk offline if the div with data from ajax was saved correctly you can pretty much work offline for some time. The point is can you store data to div or the app to disk so that it is loaded from cashe always ALSO I JUST RECALLED: when server ordered you to casche the page. YOU COULD also STORE files like IMAGES in the div!!! Finally: initially in the initial development period all drivers also for temp form browsers, probably for backend too are instances of the same class using [Hive] key-value database.
  @protected
  final ConditionDataManagementDriver driver;

  /// See the type [ConditionWidgetBase] class' description. In reality ConditionWidget object will be used for frontend app not on the server
  late final ConditionWidgetBase widget;

  /// Needs to be private (or protected), so that setter "change" also triggers possible db update if conditions are met (maybe simple or highly sofisticated update). When you've updated any property related to model changed is set to true. it may indicate whether or not the widget should be updated in localStorage. Some architectural idesa has changed in the meantime i don't remember exactly if this property is necessary even for localStorage changes storage when went offline.
  @protected
  bool changed = false;

  //final Completer<ConditionModel> _initedCompleter =
  //    Completer<ConditionModel>();
  //
  ///// The meaning of the property is the model is not considered inited globally when it doesn\'t have set up proper 'server_id' for all models
  //late final bool __initedGlobalServer;
  //final Completer<ConditionModel> _initedCompleterGlobalServer =
  //    Completer<ConditionModel>();

  /// Also see the [_completerInitModel] property description. You don't use it on your own at all use the one underscore [_inited] as setter and the @protected [inited] as getter. The setter and getter do additional neccessary stuff.
  late final bool __inited;

  /// When the property [__inited] (See it's description) is set to true using the setter [_inited] (one underscore) the completer completes, the future of the completer you can get using [getModelOnModelInitComplete] method.
  final Completer<ConditionModel> _completerInitModel =
      Completer<ConditionModel>();

  get initModelFuture => _completerInitModel.future;

  /// Also see the [_completerInitModelGlobalServer] property description. You don't use it on your own at all use the one underscore [_initedGlobalServer] as setter and the @protected [initedGlobalServer] as getter. The setter and getter do additional neccessary stuff.
  late final bool __initedGlobalServer;

  /// When the property [__inited] (See it's description) is set to true using the setter [_inited] (one underscore) the completer completes, the future of the completer you can get using [getModelOnModelInitCompleteGlobalServer] method.
  final Completer<ConditionModel> _completerInitModelGlobalServer =
      Completer<ConditionModel>();

  /// Warning, to not assign the property to another variable! When the model is retire()d ther should be no link to it so that the model's properties are properly removed and memory released. As some outside (don't know proper word) developer never use the private synchronous version [_changesStreamController], see why it it's description. It is well described in the [ConditionModelPropertyChangeInfo] class description - see the docs also all extending classess, especially [ConditionModelPropertyChangeInfoRegularChange], [ConditionModelPropertyChangeInfoModelToLocalServerStart]. To remember: Assuming that a streamcontroller and its stream, sink closes after the object is no more pointed to by a variable/pointer, programmer should alway remember of closing its f.e. stream subscrptions.
  @protected
  final StreamController<ConditionModelInfoStreamEvent> changesStreamController;

  /// Warning 1! See Warning of [changesStreamController] property. Warning 2!  This is private synchronous version of the [changesStreamController] stream controller. Whatever goes into it (the private version) goes into asynchronous stream. This private [_changesStreamController] can be use in time/procesor non-expensive cases, when you need to do changes synchronously. This property was created when an idea came up to synchronously checking by the conditionModelApp if after some model removal from the conditionModelApp model tree there is another instance of the model in the tree (only one instance allowed but in a parent link (link_id property) model, there may be several link models with the model just was removed), etc. So the developer of the app saw it better to do such stuff synchronously for some reason. In Readme or this file there may be more information on that, and if the idea was abandoned in the meantime.
  final SynchronousStreamController<ConditionModelInfoStreamEvent>
      _changesStreamController =
      StreamController<ConditionModelInfoStreamEvent>.broadcast(sync: true)
          as SynchronousStreamController<ConditionModelInfoStreamEvent>;

  @Deprecated(
      'Probably changesStreamController does what was initially expected of this property. Old of the "deprecated" info: All stuff will be managed differently i guess - ConditionDataManager is going to some changes like global server updates')
  List<ConditionModelListenerFunction> changesListeners = [];

  /// The data here will be distributed to the coresponding [ConditionModelField] objects and then set to null. Each [ConditionModelField] object has a final 'columnName' property (keys of the map below, and generally String or int/num value). After distributing the content of the map the data will be automatically validated. For example if a [temporaryInitialData] value should be notNull but is or is not set, an exception will be thrown. Later some other exceptions or errors can be thrown if f.e. there is an attempt of setting a value on a final columnName key.
  @protected
  Map<String, dynamic> temporaryInitialData = {};

  /// Read all (it is assumed that all data from temporaryInitialData is a full record from local database so all data is correct), read further: read about what you should bear in mind when changing the default value of this prop and how, however, the library prevents from problems related to the prop. Set up in a simple way in the constructor initializer. If true, on initing the model, it is not restored from the db and not sent into db or globally synchronized, because it has it's data already provided in the temporaryInitialData. Not recommended because you as programmer could f.e. provide a different data than it is in the db, or pass an id that referes to an object that doesn't exist in the db. So you could expose the entire app to malfunction. So it is important that the app doesn't expose unawares any api to outside applications like in case in javascript code on web platform, which is provided by default, but you could enable some code to interact with your app, then you should bear in mind the possible vulnerability. Assuming that you as a programmer don't expose api of this app f.e. on webplatform so no third-party programmer has access to the code, but let's say you made as a programmer a little mistake when excercising benefits of this property set to true passed not correct data of some property, you can do it, it's "fine" you don't want to hack the app :) : The model is validated, then immediatelly inited locally and globally, any property that is different than a value in the corresponding column in the db in the local server will not be updated/sent to the db. Any change in the db will be made only after you change the value of the property. So the model may have at the moment some wrong property values but nothing is changed in the db until... as just said. And also when such a model is added via addChild to the app model tree it is validated and checked if it can be added, and no seeking the childModel's data is then needed. So remembering all these things it is not recommended to use this property isAllModelDataProvidedViaConstructor outside the library by a secondary programmer. But it is allowed ...
  final bool isAllModelDataProvidedViaConstructor;

  ConditionModel(ConditionModelApp? conditionModelApp,
      this.temporaryInitialData, this.driver,
      {this.appCoreModelClassesCommonDbTableName,
      StreamController<ConditionModelInfoStreamEvent>? changesStreamController,
      this.isAllModelDataProvidedViaConstructor =
          false // see property desc for some info about worries that are not necessary
      })
      : changesStreamController = changesStreamController ??
            StreamController<ConditionModelInfoStreamEvent>.broadcast(),
        super({}) {
    if (this is ConditionModelApp) {
      if (conditionModelApp != null) {
        throw Exception(
            'ConditionModel constructor exception: this is ConditionModelApp and conditionModelApp!=null');
      } else {
        this.conditionModelApp = this as ConditionModelApp;
        uniqueId = ConditionModelApps.minId;
      }
    } else {
      if (conditionModelApp == null) {
        throw Exception(
            'ConditionModel constructor exception: this is! ConditionModelApp && conditionModelApp==null');
      } else {
        this.conditionModelApp = conditionModelApp;
        uniqueId = conditionModelApp
            ._increaseByOneModelUniqueIdCounterAndGetItsValue();
      }
    }

    // id is nullchecked earlier it is not null if isAll... == true
    if (isAllModelDataProvidedViaConstructor &&
        (temporaryInitialData['id'] == null ||
            temporaryInitialData['id'] is! int ||
            temporaryInitialData['id'] < 1 ||
            temporaryInitialData.length < 2)) {
      throw Exception(
          'ConditionModel constructor exception: isAllModelDataProvidedViaConstructor == true, id is not null but is not int or is less than 0, or id i ok but only id property is set.');
    }

    if (this is! ConditionModelCompleteModel) {
      throw const ConditionModelCompleteModelException();
    }
    if (!this.changesStreamController.stream.isBroadcast) {
      throw Exception(
          '[ConditionModel] constructor: changesStreamController passed as an argument ot the class costructor has a stream that is not a broadcast stream as required');
    }

    // !!!!!!!!!!!!!!!!!! if this is ConditionModel App !!!!!!!!!!!!!!!!!!!!!!
    // Quite not sure if ConditionModelApp should have these changes stuff, maybe why not? To rethink:
    // --------
    // https://stackoverflow.com/questions/68314268/flutter-dart-bad-state-errors-when-trying-to-close-down-a-stream-pipeline
    // The point probably addStream works like adding one element via add and the hosting stream
    // waits until the stream added via addStream finisthes (that why addStream() returns Future)
    // So we must add one by one events not via addStream
    // So there is exception and we must change the code below to something more low level
    // this
    //    .conditionModelApp
    //    ._changesStreamControllerAllAppModelsChangesControllers
    //    .addStream(_changesStreamController.stream);
    //
    // The replacement would looke like this

    // I assume that when a model has not variable pointer the changes variable also is unlinked
    // so streams may be closed, subscription may be cancelled automatically
    // changes streams are private or @protected so they shouldn't be missused or passed to
    // outside the api properties.
    _changesStreamController.stream.listen((event) {
      this
          .conditionModelApp
          ._changesStreamControllerAllAppModelsChangesControllers
          .add(event);
    });

    //The code below will be replaced as just above issue was solvd
    //this
    //    .conditionModelApp
    //    .changesStreamControllerAllAppModelsChangesControllers
    //    .addStream(this.changesStreamController.stream);

    this.changesStreamController.stream.listen((event) {
      this
          .conditionModelApp
          .changesStreamControllerAllAppModelsChangesControllers
          .add(event);
    });

    // as above solutions in the constructor body show we cannot addStream, only event one by one
    _changesStreamController.stream.listen((event) {
      this.changesStreamController.add(event);
    });
  }

  StreamSubscription<ConditionModelInfoStreamEvent>
      getChangesBroadcastStreamStreamSubscription() =>
          changesStreamController.stream.listen(null);

  /// This method allows to enable the model to call a private function _fullyFeaturedValidateAndSetValue() of the models registered fields (properties starting from a_ like a_id) allowing for fully featured validataing and setting values or not setting, triggering updating on the local and/or global server process like outside-visible validateAndSet does or preventing from triggering the mentioned update process, which validateAndSet cannot do.
  addFullyFeaturedValidateAndSetValue(
      ConditionModelField field, Function fullyFeaturedValidateAndSetValue) {
    if (!columnNamesAndTheirModelFields.containsKey(field.columnName) ||
        columnNamesAndFullyFeaturedValidateAndSetValueMethods
            .containsKey(field.columnName) ||
        !identical(field, columnNamesAndTheirModelFields[field.columnName])) {
      throw Exception(
          'addFullyFeaturedValidateAndSetValue() exception: a private unaccessible to outside validating and setting value method for a given column name has been defined already. It cannot be defined twice. Optionally a method of not allowed property cannot be added. See the method definition');
    } else {
      columnNamesAndFullyFeaturedValidateAndSetValueMethods[field.columnName] =
          fullyFeaturedValidateAndSetValue;
    }
  }

  /// more description is in [autoCreateModelTable] property description
  //desc rewritebool autoCreateModelTable = false;
  //desc rewrite This could dramatically speed-up increase development productivity. However There is need to check-out if a table of a "suprising" model class exists in the db in the form of a table, which is a one time operation during the apps life cycle (not a problem for the local server of the app, but solving global server issues may be needed - flood or rougue tables? - [Edit:] it could be done by a brand new :) static ConditionModelApp.introduceConditionModelClass(Type conditionModelType) - if technically posssible it will call the second constructor conditionModelType.createSchemaModel(), based on this local and global server will create corresponding table if not exists, and accept the class). Such information must be stored in a separate class with a static list List<ConditionModel> accepting ConditionModel extended types You could even do the id stuff automatically even if a model doesn't have the id column defined - rethink it well.
  //desc rewritebool autoCreateModelTable = false;
  static introduceConditionModelClass(Type conditionModelType) {
    //conditionModelType.createSchemaModel();
  }

  addDefinedKeyAndItsModelField(ConditionModelField modelField) {
    columnNamesAndTheirModelFields[modelField.columnName] = modelField;
  }

  _validateAndSetAllAllowedModelDataProperties() {
    for (final String key in columnNamesAndTheirModelFields.keys) {
      //if (temporaryInitialData!=null&&temporaryInitialData![key] != null)
      dynamic field;
      if (columnNamesAndTheirModelFields[key] is ConditionModelFieldInt) {
        field = columnNamesAndTheirModelFields[key] as ConditionModelFieldInt;
      } else if (columnNamesAndTheirModelFields[key]
          is ConditionModelFieldIntOrNull) {
        field =
            columnNamesAndTheirModelFields[key] as ConditionModelFieldIntOrNull;
      } else if (columnNamesAndTheirModelFields[key]
          is ConditionModelFieldString) {
        field =
            columnNamesAndTheirModelFields[key] as ConditionModelFieldString;
      } else if (columnNamesAndTheirModelFields[key]
          is ConditionModelFieldStringOrNull) {
        field = columnNamesAndTheirModelFields[key]
            as ConditionModelFieldStringOrNull;
      }

      debugPrint('to be assigned runtimeType == $runtimeType');
      if (temporaryInitialData.containsKey(key)) {
        debugPrint(
            'to be assigned: columnNamesAndTheirModelFields[$key].value with value ${temporaryInitialData[key]} the value is of type ${temporaryInitialData[key].runtimeType}');
        //field.value = temporaryInitialData[key];
        columnNamesAndFullyFeaturedValidateAndSetValueMethods[key]!(
            temporaryInitialData[key], true, false);

        debugPrint(
            'just assigned: columnNamesAndTheirModelFields[$key].value == ${field.value}');
      }
    }
  }

  /// If the getter is to be compatible with map it MUST return null on a not found value of key, so it is the case if a helper property used to return the value is not initialised (marked with the "late" keyword for a late initialization)
  @override
  operator [](key) {
    try {
      return defValue[key]?.value;
    } catch (e) {
      debugPrint(
          'ConditionModel [] getter CATCHED exception: key == $key, error: $e');
      return null;
    }
  }

  nullifyOneTimeInsertionKey(ConditionDataManagementDriver workingDriver) {
    if (this is ConditionModelIdAndOneTimeInsertionKeyModel) {
      workingDriver
          .nullifyOneTimeInsertionKey(
              this as ConditionModelIdAndOneTimeInsertionKeyModel)
          .then((isSuccess) {
        debugPrint(
            '2:initModel() success The key column or the model\'s row has just been nullified');
      }).catchError((error) {
        debugPrint('catchError flag #cef2');
        debugPrint(
            '2:initModel() !error The key column or the model\'s row hasn\'t been nullified. It is not a big deal. When the model will be recreated during f.e. another app restart/lauch another nullifying attempt will be performed. However this message shouldn\t have had occured for local server especially. This might point to an underlying problem to be watched closer to. An ConditionDataManagementDriver or db engine original error: ${error.toString()}');
      });
    }
  }

  // Used by (non private now with no uderscore? : ) [_triggerLocalAndGlobalServerUpdatingProcess]
  Future<int?> _performTheModelUpdateUsingDriverGlobalServer(
      ConditionModelApp conditionModelApp) {
    debugPrint(
        'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() inside _fieldsNowBeingInTheProcessOfUpdateGlobalServer == ${_fieldsNowBeingInTheProcessOfUpdateGlobalServer.toString()}');
    var completer = Completer<int?>();
    if (_fieldsNowBeingInTheProcessOfUpdateGlobalServer.isEmpty) {
      completer.completeError(
          'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() inside _fieldsNowBeingInTheProcessOfUpdateGlobalServer async completer.completeError because _fieldsNowBeingInTheProcessOfUpdate.isEmpty');
    } else {
      // conditionModelApp.server_key is check if not empty or null in the _triggerLocalAndGlobalServerUpdatingProcessGlobalServer()
      driver.driverGlobal!
          .update(this,
              columnNames: _fieldsNowBeingInTheProcessOfUpdateGlobalServer,
              globalServerRequestKey: conditionModelApp.server_key)
          .then((int? result) {
        debugPrint(
            'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() a Timer invoked the update(), updated SUCCESSFULLY, result: ${result.toString()}');
        completer.complete(result);
        _fieldsNowBeingInTheProcessOfUpdateGlobalServer.clear();
        _triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer = true;
        _triggerLocalAndGlobalServerUpdatingProcessGlobalServer();
      }).catchError((error) {
        debugPrint('catchError flag #cef3');
        debugPrint(
            'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() a Timer invoked the update(), NOT updated, result error: ${error.toString()}');
        if (!completer.isCompleted) {
          // as you can see above it might be completed
          // but _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(); might have
          // triggered exception after the completer is completed which would trigger
          // another async exception where it not the condition above
          completer.completeError(error);
        }
      });
    }
    return completer.future;
  }

  bool _waitingForGlobalServerServerId = false;

  /// Do the method private and pass to the [ConditionModelFields] fields as callback this cannot be called from outside, the fields themselves also pass something safaly as callback (_valueAndSet or something like that).  This is called from ConditionModelField object [validateAndSet](...) method. See mostly the [_fieldsToBeUpdated] property description
  @protected
  Future<void> _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(
      [bool isFirstLevelMethodTrigger = false] /*[String? columnName]*/) async {
    // Especially In the early process of development all these conditions may be needed but later after you make sure all is well designed and implemented you will know what to remove;
    if (this is! ConditionModelIdAndOneTimeInsertionKeyModelServer) {
      throw Exception(
          'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): exception: the mode cannot be updated on the global server because it is not an instance of ConditionModelIdAndOneTimeInsertionKeyModelServer class (doesn\'t have to be immediate parent it can be far anchestor).');
    } else if (null == driver.driverGlobal) {
      throw Exception(
          'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): exception: global driver isn\'t defined for the model and by extention for the entire ConditionModelApp app the model cannot be synchronized with the global server');
    } else if (!driver.driverGlobal!.inited) {
      debugPrint(
          'C]!!!!3 _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): model.runtimeType == ${runtimeType} driver.inited == ${driver.inited}, driver.inited == ${driver.inited}');
      debugPrint(
          'C]!!!!3 _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): driver == ${driver}');
      debugPrint(
          'C]!!!!4 _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): driver.driverGlobal!.inited == ${driver.driverGlobal!.inited}, driver.driverGlobal!.inited == ${driver.driverGlobal!.inited}');
      debugPrint(
          'C]!!!!4 _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): driver.driverGlobal == ${driver.driverGlobal}');

      throw Exception(
          'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): exception: global driver is defined but isn\'t inited (is being initialized now). The model cannot be synchronized now with the global server it is supposed to be synchronized later (check out if implemented already).');
    }

    ConditionModelIdAndOneTimeInsertionKeyModelServer
        thisConditionModelIdAndOneTimeInsertionKeyModelServer =
        this as ConditionModelIdAndOneTimeInsertionKeyModelServer;
    var completer = Completer<void>();

    // ---------------------------------------
    // NEED TO REVISIT THE SOLUTION BELOW ONE DAY, LOOKS LIKE IT IS WATER PROOF
    // the problem is there may be many such updates pending for just one model if there is no internet connection so too much memory or other resources can be allocated while the heap keeps growing
    // it is for global server only because local server is expected to work always or your device/smartphone is damaged
    // SO WE NEED TO HAVE ONE GLOBAL SERVES UPDATING PROCESS WORKING, NOT MANY
    // SO LET'S SOLVE IT:
    // one thing more: //[To do 4#sf9q!!!gh49hsg9374:] should it be taken into account?
    if (isFirstLevelMethodTrigger &&
        (_waitingForGlobalServerServerId ||
            (
                // checks if this is not the last retriger of the current method, and
                // which makes sure that in the async simultanous processing the code of the method
                // those values below won't change so we can finish performing the method
                // and complete the future
                _modelIsBeingUpdatedGlobalServer == true
                    // below this is not the last finishing sort of recursive invokation of this method (the current method)
                    &&
                    _triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer ==
                        false))) {
      completer.complete();
      return completer.future;
    }
    if (thisConditionModelIdAndOneTimeInsertionKeyModelServer['a_server_id'] ==
        null) {
      _waitingForGlobalServerServerId = true;
      // [To revisit:] The value can be set to null so we throw an exception if it is so (probably it is solved elsewhere, it finally must be, but let's add another condition)
      int? server_id =
          await thisConditionModelIdAndOneTimeInsertionKeyModelServer
              .a_server_id.firstValueAssignement;
      if (server_id == null) {
        throw Exception(
            '_triggerLocalAndGlobalServerUpdatingProcessGlobalServer, this exception rather shouldn\'t never be triggered. However on this stage of development the exception is here: exception message: The server_id property has been set up but it is null and it cannot be null.');
      }
      _waitingForGlobalServerServerId = false;
    }

    // But it is for creaating new models, but for the existing and to be updated we need to have
    // an "await" too

    // ---------------------------------------

    ConditionModelApp conditionModelApp =
        thisConditionModelIdAndOneTimeInsertionKeyModelServer.conditionModelApp;

    debugPrint(
        'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): a columnName == no columnName in globalServer update - all in queue at once\'}\' value change is attempting to treigger updating process or related stuff is going to be performed (if param columnName == null then the method invokation is related to just earlier setting up _triggerServerUpdatingProcessRetrigerAfterFinish = true to again perform checking on any new changes on the model\'s properties. Adding single columns to the queue is done using triggerLocalAndGlobalServerUpdatingProcess()), model == $this');

    debugPrint(
        'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): model _modelIsBeingUpdatedGlobalServer == $_modelIsBeingUpdatedGlobalServer and _fieldsToBeUpdatedGlobalServer.toString() == ${_fieldsToBeUpdatedGlobalServer.toString()}');
    scheduleMicrotask(() {
      // TODO: REVIEW:
      // also there is similar situation in _triggerLocalAndGlobalServerUpdatingProcessGlobalServer
      // while the below if should work well it was done quickly and not sure if create on global server must require ConditionModelParentIdModel object
      // so this is to catch situations when anybody tried to use the library using his/her outside-the-box thinking
      if (this is! ConditionModelParentIdModel) {
        throw Exception(
            '_triggerLocalAndGlobalServerUpdatingProcessGlobalServer: if statement causing exceptoin: this is! ConditionModelParentIdModel, it mayb be that in _triggerLocalAndGlobalServerUpdatingProcessGlobalServer similar situation is to be in agreement with any changes code here _doDirectCreateOnGlobalServer');
      }

      if ((_triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer &&
              _fieldsToBeUpdatedGlobalServer.isEmpty) ||
          (_fieldsToBeUpdatedGlobalServer.isEmpty &&
              _fieldsNowBeingInTheProcessOfUpdateGlobalServer.isEmpty)) {
        _triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer = false;
        _modelIsBeingUpdatedGlobalServer = false;
        _changesStreamController.add(
            ConditionModelInfoEventPropertyChangeModelToGlobalServerSuccess());

        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!! This is the moment we can trigger the global server update (granted the [ConditionModelApp] object has its global server enabled)
        debugPrint(
            '?????????????? C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer()');
        completer.complete();
        return;
      }

      // Fot Timer: https://stackoverflow.com/questions/34140488/dart-timer-periodic-not-honoring-granularity-of-duration-in-vm
      //    a: The minimal resolution of the timer is 1ms. When asking for a 500ns duration is rounded to 0ms, aka: as fast as possible. The code is:
      //    b: !!! Note: If Dart code using Timer is compiled to JavaScript, the finest
      //       granularity available in the browser is !!!!4 milliseconds.
      // The delay is needed so that to lessen the risk of starting to performe the update
      // before all changes to the models properties were performed
      // f.e this['title']='abc' and then this['description']=cde;
      // By this you have to update the model at once not in two or more stages
      // the granularity chosen is as little as possible and as neglectible in terms of
      // real time operations, possibly video conference (in distant unpredictable future :) )
      if (!_modelIsBeingUpdatedGlobalServer ||
          _triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer) {
        debugPrint(
            'C]V Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): model _modelIsBeingUpdatedGlobalServer == $_modelIsBeingUpdatedGlobalServer and _triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer == $_triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer');
        // this should be set up now not in event loop asynchronous method read just below Timer() comments:
        _modelIsBeingUpdatedGlobalServer = true;
        _changesStreamController.add(
            ConditionModelInfoEventPropertyChangeModelToGlobalServerStart());

        // one time operation not Timer.periodic:
        Timer(const Duration(milliseconds: 8), () async {
          // this should be set up now in the event loop asynchronous method:
          _fieldsNowBeingInTheProcessOfUpdateGlobalServer
              .addAll(_fieldsToBeUpdatedGlobalServer);

          debugPrint(
              'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): START OF: await conditionModelApp.getServerKeyWhenReady(); ');
          // the below may even never end, but it's ok, any invoking of this method
          // will cause that the code will not reach this Timer() invokation which is ok.
          // if the future completes (should never throw exception) it will allow the code
          // beneath it to execute which means an attempt to update the data on the global server
          // The next time the code alway resolves quickly, not waiting because it is already true
          try {
            await conditionModelApp.getServerKeyWhenReady();
          } catch (e) {
            debugPrint(
                'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): await conditionModelApp.getServerKeyWhenReady(); error: $e');
          }
          debugPrint(
              'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): SUCCESSFUL END OF: await conditionModelApp.getServerKeyWhenReady(); ');
          // Especially In the early process of development all these conditions may be needed but later after you make sure all is well designed and implemented you will know what to remove;
          // above doeas the job: await conditionModelApp.getServerKeyWhenReady();
          //if (conditionModelApp.server_key == null ||
          //    conditionModelApp.server_key!.isEmpty) {
          //  throw Exception(
          //      'C] _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(): exception: conditionModelApp is defined but its server key is null or otherwhise empty string, just check for null: (conditionModelApp.server_key == null) == ${conditionModelApp.server_key == null}');
          //}
          //
          // before you do anything here see a fragment like this below in this method
          // with it's description:
          //scheduleMicrotask(
          //    _fieldsToBeUpdated.add(columnName);
          //);
          // this should be set up now in the event loop asynchronous method:
          _fieldsToBeUpdatedGlobalServer.clear();
          await conditionModelApp
              .hangOnModelOperationIfNeeded(
                  this as ConditionModelParentIdModel,
                  ConditionModelClassesTypeOfSucpendableOperation
                      .globalServerUpdate)
              .future;
          _performTheModelUpdateUsingDriverGlobalServer(conditionModelApp)
              .then((int? result) {
            //result won't be null for global server request - always int
            //this will update on local server only what was returned from global server
            debugPrint(
                'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() we did a successful update on global server and if this is ConditionModelCreationDateModel then we will set up only on local server (already set up  on the global server and just now received) this model property this[\'server_update_date_timestamp\'] = $result');
            if (this is ConditionModelCreationDateModel) {
              columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                  'server_update_date_timestamp']!(result, true, true, true);
            }
          }).catchError((error) {
            debugPrint('catchError flag #cef4');

            debugPrint(
                'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() a Timer invoked the performTheModelUpdateUsingDriver() which invoked update() and returned error, NOT updated, result error, depending on the type of error (two processess accessed the same db file (if sqlite3) at the same time, internet connection lost, etc) !!!we now are trying to update the model doing it once per some longer time!!!: ${error.toString()}');
            // For the local server there is no attemptsLimitCountDownCounter localServer is supposed to work always in all circumstances, but for global server you can loose the internet connection, the server bandwitdh may be too much congested, etc.
            int attemptsLimitCountDownCounter = 12;
            Timer.periodic(
                const Duration(
                    seconds:
                        ConditionConfiguration.max_global_server_request_time +
                            10), (timer) async {
              if ((attemptsLimitCountDownCounter <= 10 &&
                      attemptsLimitCountDownCounter > 6 &&
                      attemptsLimitCountDownCounter % 2 != 0) ||
                  (attemptsLimitCountDownCounter <= 6 &&
                      attemptsLimitCountDownCounter >= 0 &&
                      attemptsLimitCountDownCounter % 3 != 0)) {
                attemptsLimitCountDownCounter--;
                return;
              }
              debugPrint(
                  'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer update attempt: A cyclical attempts to update the model of class [${runtimeType.toString()}] on the local server are being performed. This is invokation');
              await conditionModelApp
                  .hangOnModelOperationIfNeeded(
                      this as ConditionModelParentIdModel,
                      ConditionModelClassesTypeOfSucpendableOperation
                          .globalServerUpdate)
                  .future;
              _performTheModelUpdateUsingDriverGlobalServer(conditionModelApp)
                  .then((result) {
                // result must be always true or throw error (catch error of future)
                // you dont need to do anything special here _performTheModelUpdateUsingDriver() does the job.
                timer.cancel();
                //result won't be null for global server request - always int
                //this will update on local server only what was returned from global server
                debugPrint(
                    'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer, we did a successful update on global server and if this is ConditionModelCreationDateModel then we will set up only on local server (already set up  on the global server and just now received) this model property this[\'server_update_date_timestamp\'] = $result');
                if (this is ConditionModelCreationDateModel) {
                  columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                          'server_update_date_timestamp']!(
                      result, true, true, true);
                }
              }).catchError((error) {
                debugPrint('catchError flag #cef5');

                debugPrint(
                    'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer update attempt _fieldsNowBeingInTheProcessOfUpdateGlobalServer == $_fieldsNowBeingInTheProcessOfUpdateGlobalServer , _fieldsToBeUpdatedGlobalServer == $_fieldsToBeUpdatedGlobalServer : error: ${error.toString()}');
                // !!!!! Even if it works not much sure if something elsevhere was designed worse
                // than it should be - find out one day why the condition below shouldn't be here
                if (_fieldsNowBeingInTheProcessOfUpdateGlobalServer.isEmpty &&
                    _fieldsToBeUpdatedGlobalServer.isEmpty) {
                  timer.cancel();
                  completer.completeError(
                      'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer update _fieldsNowBeingInTheProcessOfUpdateGlobalServer.isEmpty && _fieldsToBeUpdatedGlobalServer.isEmpty. Not sure if it is an error but at best it may be not a well designed piece of code somewhere.');
                }
              });
              if (attemptsLimitCountDownCounter-- == 0) {
                timer.cancel();
                completer.completeError(
                    'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer updateattemptsLimitCountDownCounter-- == 0, we cannot update the model quickly and directly from the currently updated model. Probably, if already implemented, by design the model will be updated from local server db record in a cyclical slower way.');
              }
            });
          });
        });
      }
    });

    return completer.future;
  }

  // Used by (non private now with no uderscore? : ) [_triggerLocalAndGlobalServerUpdatingProcess]
  Future<bool> _performTheModelUpdateUsingDriver(
      [bool isToBeSynchronizedLocallyOnly = false]) {
    debugPrint(
        'C] Inside triggerLocalAndGlobalServerUpdatingProcess(), inside _performTheModelUpdateUsingDriver() inside _fieldsNowBeingInTheProcessOfUpdate == ${_fieldsNowBeingInTheProcessOfUpdate.toString()}');
    var completer = Completer<bool>();
    if (_fieldsNowBeingInTheProcessOfUpdate.isEmpty) {
      completer.completeError(
          'C] Inside triggerLocalAndGlobalServerUpdatingProcess(), inside _performTheModelUpdateUsingDriver() async completer.completeError because _fieldsNowBeingInTheProcessOfUpdate.isEmpty');
    } else {
      driver
          .update(
        this,
        columnNames:
            _fieldsNowBeingInTheProcessOfUpdate, /*globalServerRequestKey: null*/
      )
          .then((int? result) {
        debugPrint(
            'C] Inside triggerLocalAndGlobalServerUpdatingProcess(), inside _performTheModelUpdateUsingDriver() a Timer invoked the update(), updated SUCCESSFULLY, result: ${result.toString()}');
        completer.complete(true);
        _fieldsNowBeingInTheProcessOfUpdate.clear();
        _triggerServerUpdatingProcessRetrigerAfterFinish = true;
        triggerLocalAndGlobalServerUpdatingProcess(
            null, isToBeSynchronizedLocallyOnly);
      }).catchError((error) {
        debugPrint('catchError flag #cef6');
        debugPrint(
            'C] Inside triggerLocalAndGlobalServerUpdatingProcess(), inside _performTheModelUpdateUsingDriver() a Timer invoked the update(), NOT updated, result error: ${error.toString()}');
        completer.completeError(error);
      });
    }
    return completer.future;
  }

  /// Do the method private and pass to the [ConditionModelFields] fields as callback this cannot be called from outside, the fields themselves also pass something safaly as callback (_valueAndSet or something like that).  This is called from ConditionModelField object [validateAndSet](...) method. See mostly the [_fieldsToBeUpdated] property description
  @protected
  triggerLocalAndGlobalServerUpdatingProcess(
      [String? columnName, bool isToBeSynchronizedLocallyOnly = false]) async {
    debugPrint(
        'C] triggerLocalAndGlobalServerUpdatingProcess(): a columnName \'$columnName\' value change is attempting to treigger updating process or related stuff is going to be performed (if param columnName == null then the method invokation is related to just earlier setting up _triggerServerUpdatingProcessRetrigerAfterFinish = true to again perform checking on any new changes on the model\'s properties)');

    // model.changed was just set to true
    // model.inited must be true or exception is to be thrown
    // NOW WATCH OUT as i understand it is needed to do the next scheduleMicrotask method
    // because it is on the event loop like some later operations called with Timer()
    // it MAY BE (or not) not entirely impossible to add a columnName before
    // _fieldsToBeUpdated.clear(); is invoked but after
    // _fieldsNowBeingInTheProcessOfUpdate.addAll(_fieldsToBeUpdated); is invoked
    // if that would happen a property would dissapear from the queue of columnNames to be updated
    // and wouldn't be updated
    //scheduleMicrotask(() async {
    if (columnName != null) {
      // The App Policy changed - model doesn't need wait until it is inited. You can
      // do the changes to the model properties at any time. However the changes will be stored
      // or synchrnonized after it is inited, and it maybe that all the properties values are the same
      // on update (maybe except the updatedate probably - need to checkout)
      if (!inited) await getModelOnModelInitComplete();
      _fieldsToBeUpdated.add(columnName);
      // we set-up the property only - no need to invoke triggerLocalAndGlobalServerUpdatingProcess()
      // as we are just in it and can make kinda manual setting stuff up
      // avoding possible asynchronous delays and not just one but possibly one or two request
      // !!! IMPORTANT READ as you see update_date_timestamp on local server may differ from that on global server (OK!)
      // !!! IMPORTANT READ but after synchronizing the rest of timestamps must be the same on both servers
      // !!! IMPORTANT READ So if you want to implement searching elsewhere for id of something
      // !!! IMPORTANT READ on the global server based on timestamp (not recommended) don't use update_date_timestamp
      if (this is ConditionModelCreationDateModel) {
        columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                'update_date_timestamp']!(
            driver.createCreationOrUpdateDateTimestamp().time, true, false);
        // and we are adding the field to list of fields to be updated which in case the global
        // server is defined it will send the local server update date to the global server
        _fieldsToBeUpdated.add('update_date_timestamp');

        if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer &&
            !isToBeSynchronizedLocallyOnly) {
          _fieldsToBeUpdatedGlobalServer.add(columnName);
          _fieldsToBeUpdatedGlobalServer.add('update_date_timestamp');
        }
      }
    }

    debugPrint(
        'C] Inside triggerLocalAndGlobalServerUpdatingProcess(): model _modelIsBeingUpdated == $_modelIsBeingUpdated and right now at the beginning of the current method body: _fieldsToBeUpdated.toString() == ${_fieldsToBeUpdated.toString()}, _fieldsToBeUpdatedGlobalServer.toString() == $_fieldsToBeUpdatedGlobalServer');

    debugPrint('C]2:1!!!');

    if (_triggerServerUpdatingProcessRetrigerAfterFinish &&
        _fieldsToBeUpdated.isEmpty) {
      debugPrint('C]2:2!!!');
      _triggerServerUpdatingProcessRetrigerAfterFinish = false;
      _modelIsBeingUpdated = false;
      _changesStreamController.add(
          ConditionModelInfoEventPropertyChangeModelToLocalServerSuccess());
      if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer &&
          !isToBeSynchronizedLocallyOnly) {
        _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(true);
      }
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      // !!!!! This is the moment we can trigger the global server update (granted the [ConditionModelApp] object has its global server enabled)
      debugPrint('C]2:3!!!');
      return;
    }
    //});

    // Fot Timer: https://stackoverflow.com/questions/34140488/dart-timer-periodic-not-honoring-granularity-of-duration-in-vm
    //    a: The minimal resolution of the timer is 1ms. When asking for a 500ns duration is rounded to 0ms, aka: as fast as possible. The code is:
    //    b: !!! Note: If Dart code using Timer is compiled to JavaScript, the finest
    //       granularity available in the browser is !!!!4 milliseconds.
    // The delay is needed so that to lessen the risk of starting to performe the update
    // before all changes to the models properties were performed
    // f.e this['title']='abc' and then this['description']=cde;
    // By this you have to update the model at once not in two or more stages
    // the granularity chosen is as little as possible and as neglectible in terms of
    // real time operations, possibly video conference (in distant unpredictable future :) )
    if (!_modelIsBeingUpdated ||
        _triggerServerUpdatingProcessRetrigerAfterFinish) {
      debugPrint(
          'C]V Inside triggerLocalAndGlobalServerUpdatingProcess(): model _modelIsBeingUpdated == $_modelIsBeingUpdated and _triggerServerUpdatingProcessRetrigerAfterFinish == $_triggerServerUpdatingProcessRetrigerAfterFinish, _fieldsNowBeingInTheProcessOfUpdate == $_fieldsNowBeingInTheProcessOfUpdate, _fieldsToBeUpdated == $_fieldsToBeUpdated');
      // this should be set up now not in event loop asynchronous method read just below Timer() comments:
      _modelIsBeingUpdated = true;
      _changesStreamController
          .add(ConditionModelInfoEventPropertyChangeModelToLocalServerStart());

      scheduleMicrotask(() async {
        // There is earlier explanation why this await is added here and there - both
        // need to exist or both to be removed (which is not going to happen of course)
        // If you removed this await this Timer would be invoked before
        // that earlier getModelOnModelInitComplete() invokation in the code
        if (!inited) await getModelOnModelInitComplete();

        // this should be set up now in the event loop asynchronous method:
        _fieldsNowBeingInTheProcessOfUpdate.addAll(_fieldsToBeUpdated);
        // earlier in code: if (!isToBeSynchronizedLocallyOnly) {_fieldsToBeUpdatedGlobalServer.addAll(_fieldsToBeUpdated);}
        // before you do anything here see a fragment like this below in this method
        // with it's description:
        //scheduleMicrotask(
        //    _fieldsToBeUpdated.add(columnName);
        //);
        // this should be set up now in the event loop asynchronous method:
        _fieldsToBeUpdated.clear();
        //if (_fieldsNowBeingInTheProcessOfUpdate.isEmpty&&_triggerServerUpdatingProcessRetrigerAfterFinish) {
        //  return;
        //}
        _performTheModelUpdateUsingDriver(isToBeSynchronizedLocallyOnly)
            .catchError((error) {
          debugPrint('catchError flag #cef7 $isToBeSynchronizedLocallyOnly');
          debugPrint(
              'C] Inside triggerLocalAndGlobalServerUpdatingProcess() a Timer invoked the performTheModelUpdateUsingDriver() which invoked update() and returned error, NOT updated, result error, depending on the type of error (two processess accessed the same db file (if sqlite3) at the same time, internet connection lost, etc) !!!we now are trying to update the model doing it once per some longer time!!!: ${error.toString()}');
          Timer.periodic(const Duration(seconds: 3), (timer) {
            debugPrint(
                'C] Inside triggerLocalAndGlobalServerUpdatingProcess() cyclical timer update attempt: A cyclical attempts to update the model of class [${this.runtimeType.toString()}] on the local server are being performed. This is invokation');
            _performTheModelUpdateUsingDriver(isToBeSynchronizedLocallyOnly)
                .then((result) {
              // result must be always true or throw error (catch error of future)
              // you dont need to do anything special here _performTheModelUpdateUsingDriver() does the job.
              timer.cancel();
            }).catchError((error) {
              debugPrint(
                  'catchError flag #cef8 $isToBeSynchronizedLocallyOnly');

              debugPrint(
                  'C] Inside triggerLocalAndGlobalServerUpdatingProcess() cyclical timer update attempt _fieldsNowBeingInTheProcessOfUpdate == $_fieldsNowBeingInTheProcessOfUpdate , _fieldsToBeUpdated == $_fieldsToBeUpdated: error: ${error.toString()}');
              // !!!!! Even if it works not much sure if something elsevhere was designed worse
              // than it should be - find out one day why the condition below shouldn't be here
              if (_fieldsNowBeingInTheProcessOfUpdate.isEmpty &&
                  _fieldsToBeUpdated.isEmpty) {
                timer.cancel();
              }
            });
          });
          return false;
        });
      });
    }

    //_fieldsToBeUpdated;
    //_fieldsNowBeingInTheProcessOfUpdate = [];
    //_fieldsToBeUpdatedGlobalServer = [];
    //_fieldsNowBeingInTheProcessOfUpdateGlobalServer = [];

    // It is ok now but model must have the ability to set a value on a field without _inited checking.
    // without triggering update on any server, you just validate and set-up properties
    // But!!! with posibility that two processess attempted to set-up the value at the same time
    // but only model initModel stuff is allowed to perform and set up the value,
    // and the rest to cause to throw exceptions
    // look like a certain callback could do the stuff but only model field of the model could do this
    // and if modelfield registering callback is not exactly the same object (key property or something)
    // then something is not going to be allowed.
    // how to do it.
    // The only way is to validate any data
  }

  _doDirectCreateOnGlobalServer(ConditionDataManagementDriver working_driver,
      ConditionModelApp conditionModelAppInstance) async {
    // it seem that it should be put here because there are some awaits below,
    // and if this await stops code execution conditionModelApp knows it can retire the model if there is need to do it
    // but if the below awaits are stoping the code - the model cannot be retired because conditionModelApp doesn't know what is happening
    // TODO: REVIEW:
    // also there is similar situation in _triggerLocalAndGlobalServerUpdatingProcessGlobalServer
    // while the below if should work well it was done quickly and not sure if create on global server must require ConditionModelParentIdModel object
    // so this is to catch situations when anybody tried to use the library using his/her outside-the-box thinking
    if (this is! ConditionModelParentIdModel) {
      throw Exception(
          '_doDirectCreateOnGlobalServer: if statement causing exceptoin: this is! ConditionModelParentIdModel, it mayb be that in _triggerLocalAndGlobalServerUpdatingProcessGlobalServer similar situation is to be in agreement with any changes code here');
    }
    await conditionModelApp
        .hangOnModelOperationIfNeeded(this as ConditionModelParentIdModel,
            ConditionModelClassesTypeOfSucpendableOperation.globalServerUpdate)
        .future;

    // ?asynchronous and we don't wait for it to finish
    // ?not vary sure very much if mixed future and async/await syntax
    // ?will always produce the expected results
    debugPrint(
        '2:2:initModel() in _doDirectCreateOnGlobalServer() working_driver.driverGlobal.create()');
    if (null == conditionModelAppInstance.server_key) {
      _completerInitModelGlobalServer.completeError(
          '2:2:initModel() in _doDirectCreateOnGlobalServer() working_driver.driverGlobal.create() async exception: server_key of ConditionModelApp is null, we cannot immediately and directly (this is not non-cyclical synchronization) synchroznize local server model with the global server now waiting for the key and for synchronizing later (if already implemented)');
    } else if (!working_driver.driverGlobal!.inited) {
      _completerInitModelGlobalServer.completeError(
          '2:2:initModel() in _doDirectCreateOnGlobalServer() working_driver.driverGlobal.create() async exception: !working_driver.driverGlobal!.inited is not inited so it cannot be used now. Depending on how it is designed so far the model may be synchronized later with the global server');
    } else {
      debugPrint(
          '2:2:initModel() in _doDirectCreateOnGlobalServer() WE CAN CRETAE NOW IN GLOBAL SERVER working_driver.driverGlobal.create()');

      //if (this is ConditionModelParentIdModel) {await (this as ConditionModelParentIdModel).hangOnWithServerCreateUntilParentAllowsFuture;}
      //before we creaate anything

      // For ConditionModelBelongingToContact to be CREATED on the global server
      // it needs to have it's server_owner_contact_id != null or wait until it's parent
      // has this property set up (for new) - if the parent added this model via addChild
      // the child uses parentModel.a_server_id.firstValueAssignement future which always work
      // So this is the fastest way to do this.
      // To remind me a completely new model can be added to the tree by addChild only if it has
      // option == childModel.hangOnWithServerCreateUntilParentAllows == true:
      // and for false or true in addChild properties parent_id, id, owner_contact_id are checked
      // maybe more
      // if not already in the tree the child must have the server_owner_contact_id != null
      // or read server_owner_contact_id from the local server finding a record in the db
      // looking up owner_contact_id which it already has checking it's server_id
      // if not null it can set it up child.server_owner_contact_id = parentModel.server_id
      // OR SOMETHING LIKE THAT
      // And this is also true when a model will be added to the tree and removed before it
      // receives server_owner_contact_id, but is standalone and works anywhay (cannot imagine
      // scenario for that but it is possible)
      // WARNING ConditionModelContact IS ConditionModelBelongingToContact BUT IT SHOULDN'T BUT IT WILL STAY THIS WAY
      if (this is! ConditionModelContact &&
          this is ConditionModelBelongingToContact) {
        debugPrint(
            "2:2:initModel() in _doDirectCreateOnGlobalServer() - this is ConditionModelBelongingToContact so we are waiting until a_server_owner_contact_id is set up to non null int value");
        // whether or not it is already completed the below future always does the job suspending the code execution or not
        ConditionModelBelongingToContact
            thisAsConditionModelBelongingToContact =
            (this as ConditionModelBelongingToContact);
        await thisAsConditionModelBelongingToContact
            .a_server_owner_contact_id.firstValueAssignement;
        if (thisAsConditionModelBelongingToContact
                .a_server_owner_contact_id.value ==
            null) {
          throw Exception(
              '2:2:initModel() in _doDirectCreateOnGlobalServer() a_server_owner_contact_id cannot have null value at the moment when it is going to be created on the global server');
        }
        debugPrint(
            "2:2:initModel() in _doDirectCreateOnGlobalServer() - this is ConditionModelBelongingToContact a_server_owner_contact_id has just been set up to non null int value");
        //.a_server_owner_contact_id.firstValueAssignement();
      }

      //rethink // contact_user_id - is it needed? only server_contact_user_id makes sense QUITE TRICKY and only to make serching the db faster you need contact_email or contact_phone_number if you don't have yet the server_contact_user_id
      // !!! ConditionDriver does this, it is to ensure that you can write all offline
      //if (this is ConditionModelContact) {
      //  try {
      //    throw Exception('_doDirectCreateOnGlobalServer method : catched exception: i need to postpone implementing it a contact to be created on the global server must have the server_contact_user_id already');
      //  } catch (e) {
      //    debugPrint("$e");
      //  }
      //  debugPrint("2:2:initModel() in _doDirectCreateOnGlobalServer() - this is ConditionModelContact so we are waiting until a_server_contact_user_id is set up to non null int value");
      //  // whether or not it is already completed the below future always does the job suspending the code execution or not
      //  ConditionModelContact thisAsConditionModelContact = (this as ConditionModelContact);
      //  await thisAsConditionModelContact.a_server_contact_user_id.firstValueAssignement;
      //  if (thisAsConditionModelContact.a_server_contact_user_id.value == null) {
      //    throw Exception('2:2:initModel() in _doDirectCreateOnGlobalServer() a_server_contact_user_id cannot have null value at the moment when it is going to be created on the global server');
      //  }
      //  debugPrint("2:2:initModel() in _doDirectCreateOnGlobalServer() - this is ConditionModelContact a_server_owner_contact_id has just been set up to non null int value");
      //  //.a_server_owner_contact_id.firstValueAssignement();
      //}

      if (this
          is ConditionModelIdAndOneTimeInsertionKeyModelServer /*ConditionModelParentIdModel*/) {
        debugPrint(
            "2:2:initModel() in _doDirectCreateOnGlobalServer() - this is ConditionModelIdAndOneTimeInsertionKeyModelServer so we are waiting until a_server_parent_id is set up to null or non null int value");
        // whether or not it is already completed the below future always does the job suspending the code execution or not
        ConditionModelIdAndOneTimeInsertionKeyModelServer
            thisAsConditionModelParentIdModel =
            (this as ConditionModelIdAndOneTimeInsertionKeyModelServer);
        await thisAsConditionModelParentIdModel
            .a_server_parent_id.firstValueAssignement;
        debugPrint(
            '2:2:initModel() in _doDirectCreateOnGlobalServer() : server_parent_id has been set up (at least once to null or non-null but set up). we can go ahead with the create on the global server');
        //!! below it can be null but must be assigned (await above) on purpose
        //if (thisAsConditionModelParentIdModel.a_server_parent_id.value == null) {
        //  throw Exception('2:2:initModel() in _doDirectCreateOnGlobalServer() a_server_parent_id must be set up');
        //}

        //---------------
        // !!!!!!!!!! not needed Server user id is assigned on create.
        //debugPrint("2:2:initModel() in _doDirectCreateOnGlobalServer() - this is ConditionModelIdAndOneTimeInsertionKeyModelServer a_server_user_id has just been set up to non-null value");
        //.a_server_owner_contact_id.firstValueAssignement();
        // !!!!!!!!!! not needed Server user id is assigned on create.
        //try {
        //  throw Exception('_doDirectCreateOnGlobalServer method : catched exception: i need to postpone implementing it a contact to be created on the global server must have the server_user_id already');
        //} catch (e) {
        //  debugPrint("$e");
        //}
        //await thisAsConditionModelParentIdModel.a_server_user_id.firstValueAssignement;
        //if (thisAsConditionModelParentIdModel.a_server_user_id.value == null) {
        //  throw Exception('2:2:initModel() in _doDirectCreateOnGlobalServer() a_server_user_id must be set up');
        //}
      }

      if (this is ConditionModelIdAndOneTimeInsertionKeyModel) {
        final modelsUser = (this as ConditionModelIdAndOneTimeInsertionKeyModel)
            .conditionModelUser;
        //thisAsConditionModelIdAndOneTimeInsertionKeyModel
        /// we use this variable to get some convenient properties (futures) and make code clearer
        CreateModelOnServerFutureGroup<int?> createGlobalServerFutureGroup =
            working_driver.driverGlobal!.create(this,
                globalServerRequestKey: conditionModelAppInstance.server_key,
                globalServerUserCredentials: {
              'e_mail': modelsUser!.e_mail,
              'phone_number': modelsUser.phone_number,
              'password': modelsUser.password,
            });

        try {
          List<int?> result = await createGlobalServerFutureGroup.future;
          bool nullifyTheKey = false;

          debugPrint(
              'result 2:initModel() in _doDirectCreateOnGlobalServer() runtimeType == $runtimeType and result is $result');

          //hej!
          //HERESTOPPED // all the rest of the properties yet not set up based on the class of model
          // contact, nont contact but non user, and global init future finish,
          // if server_id != null in initModel() (it has the rest of the proerties) global init finish now
          // REMEMBER ALREADY SOME PLACES RELY ON THE PROPER INIT GLOBAL SERVER FUTURE,
          // ALSO SEE IF LOCALLY A LOCAL SERVER SENDS CHANGE STREAM EVENT THAT A MODEL IS INITED - THE GLOBAL SHOULD TOO?

          //Now // situation is that the result has the id but
          // we are to have server_id,
          // server_owner_contact_id for non contact and non user and non ConditionModelApp
          // there are similar type checking conditions used for this in this file
          // WHEN WE HAVE IT (SEE IF SOMETHING ELSE)
          // WE CAN _initedGlobalServer = true - which is a setter of __initedGlobalServer (double
          // underscore)
          // and the setter will finish t he completer "_completerInitModelGlobalServer.complete(this);"
          // Then in the ConditionModelUser restoreMyChildren you don't need to listen to
          // events where you have the 'server_id' or 'server_owner_contact_id' if necessary
          // but you will have it here already checked.
          // if A result is success and it doesn't have for local server_id always but
          // also the 'server_owner_contact_id' for non-contact... models
          // then we throw a fatal error for now because it means an application general error
          // or there might be later third-party ConditoinModelDriver wrong implementation
          // or a hacker attack - but for this later no error but exception will be thrown

          // In this comment section the following await createGlobalServerFutureGroup. means the future is already completed, you don't wait for the result you get it immediately. It is of course for you to get the value not the future.
          // --> "int result[0]" should be the same as "await createGlobalServerFutureGroup.completerCreateFuture"
          // But "int result[1]" should be the same as "await createGlobalServerFutureGroup.completerModelIdByOneTimeInsertionKey"
          int? serverId = result[0] != null && result[0]! > 0
              ? result[0]
              : result[1] != null && result[1]! > 0
                  ? result[1]
                  : -1;
          if (serverId == -1) {
            _completerInitModelGlobalServer.completeError(
                '2:initModel() in _doDirectCreateOnGlobalServer() working_driver.driverGlobal.create() error: With a list of one or two possible integers ${result.toString()} containing no int id a model initiation could\'t has been finished');
          }

          if (serverId != null && serverId > 0) {
            // contact also is ConditionModelBelongingToContact but logically it shouldn't it one day may change
            if (this is ConditionModelContact ||
                this is ConditionModelBelongingToContact) {
              // required:

              // the future already is finished so it immediately resolves to the returned value
              columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                      'server_user_id']!(
                  await createGlobalServerFutureGroup
                      .completerServerUserIdFuture,
                  true,
                  true,
                  true);
            }
            // if serverId valid is ok we need to validate more for some classess
            if (this
                    is ConditionModelContact // this is ConditionModelBelongingToContact
                ) {
              // required:

              // the future already is finished so it immediately resolves to the returned value
              columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                      'server_contact_user_id']!(
                  await createGlobalServerFutureGroup
                      .completerServerContactUserIdFuture,
                  true,
                  true,
                  true);

              //not required ignored if null, the implementation/testing left for later, but the cond should work anyway
              // the future already is finished so it immediately resolves to the returned value
              if (createGlobalServerFutureGroup.completerServerLinkIdFuture !=
                  null) {
                columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                        'server_link_id']!(
                    await createGlobalServerFutureGroup
                        .completerServerLinkIdFuture,
                    true,
                    true,
                    true);
              }
            }
            //if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer/*ConditionModelParentIdModel*/) {
            // }

            //this['id'] = result[0];
            //to do NOW
            //First no server_id set up on the server side (should be set up when record is created)
            //Second we need to then update the received id (is correct for now)
            //on local server with no update to the global server this should solve the problems
            //why there is no server_id both on local and global server
            debugPrint(
                '2:2:initModel() in _doDirectCreateOnGlobalServer() setting up server_id with no to global server update serverId = ${serverId}');
            columnNamesAndFullyFeaturedValidateAndSetValueMethods['server_id']!(
                serverId, true, true, true);

            debugPrint(
                '2:2:initModel() in _doDirectCreateOnGlobalServer() we did a successful create on global server and we will set up only on local server (already set up  on the global server and just now received) this model property this[\'server_creation_date_timestamp\'] = ${result[2]}');
            columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                'server_creation_date_timestamp']!(result[2], true, true, true);

            nullifyTheKey = true;

            debugPrint(
                '2:2:initModel() in _doDirectCreateOnGlobalServer() NOW SUCCESS, THE MODEL IS GOING TO BE INITED GLOBALLY _completerInitModelGlobalServer.complete(this);');
            _completerInitModelGlobalServer.complete(this);
          } else {
            _completerInitModelGlobalServer.completeError(
                '2:initModel() in _doDirectCreateOnGlobalServer() _completerInitModelGlobalServer.completeError working_driver.driverGlobal.create() error: With a list of one or two possible integers ${result.toString()} containing no int id a model initiation could\'t has been finished');
          }

          // this will trigger nullifying the key on local and the global server
          // finishing it with any error is not a big deal, it should be later
          // checked - is it already implemented for both servers?
          if (nullifyTheKey == true) {
            this['one_time_insertion_key'] = null;
          }
          /*
                    try {
                      // probably we dont need the method
                      // it should be enough to just set model['one_time_insertion_key'] to null
                      nullifyOneTimeInsertionKey(working_driver);
                    } catch (e) {
                      debugPrint(
                          '1:initModel() nullifyOneTimeInsertionKey error - at this state it may fail will be done later [to do]: error: e == $e');
                    }
                    */
        } catch (error) {
          debugPrint('catchError flag #cef9');
          // here the error?
          debugPrint(
              'Debugprint: 2:initModel() working_driver.driverGlobal.create() error: With a list of one or two possible integers containing no int id a model initiation could\'t has been finished. Exception thrown: error == $error');
          //Here // exactly this line below is causeing the second excepton all catchError and async try catch need to be checke
          _completerInitModelGlobalServer.completeError(
              '2:initModel() working_driver.driverGlobal.create() error: With a list of one or two possible integers containing no int id a model initiation could\'t has been finished. Exception thrown: error == $error');
        }
      }
    }
  }

  /// A funny method.
  giveTheAlreadyRetiredModelPensionerSomePartTimeJobOrLetItSpendTimeWithItsGrandChildrenModel() {}

  /// FIXME: Is this future always finished? In a ConditionApp widget state initModel had no finished future from this _initedCompleter was used instead. See [ConditionModelCompleteModel] class desc. This method must be called in a complete model class that is not extended by other classess but is an object that is stored in the db
  @nonVirtual
  Future<ConditionModel> initModel() {
    // as far as i remember this method shouldn't be async.
    if (this is! ConditionModelCompleteModel) {
      throw Exception(
          'the $runtimeType model object extending ConditionModel class is not mixed with ConditionModelCompleteModel class marking, that the object is a complete ready to use model');
    }

    // Below there is "if (isAllModelDataProvidedViaConstructor)" which helps initing the model with noe contact to the db, see the isAllModelDataProvidedViaConstructor description with reasons and warnings related to using this property.
    if (!isAllModelDataProvidedViaConstructor) {
      for (final String key in temporaryInitialData.keys) {
        if (!columnNamesAndTheirModelFields.containsKey(key)) {
          throw Exception(
              'A model of [$runtimeType] class tries to set up a key (columnName) named ${key.toString()} that is not allowed - no ConditionModelField object has been defined or defined & inited for the model to handle the columnName with its value.');
        }
      }
    } else {
      // By design when isAllModelDataProvidedViaConstructor == true a full record from the db might has been passed in temporaryInitialData
      // if so there may be some column names from the db that a model class is not allowed to use, so we can remove them now
      // which is reasonable, it then enables the model to pass validation and the model will set those values as properties like f.e. model['user_id'] = '1'
      debugPrint('flag #ndntxhwhgkgid23 - 1 runtimetype == $runtimeType');
      try {
        for (final String key in
            // cannot use temporaryInitialData because when uring temporaryInitialData.remove it throws excetion that trying to remove on a iterated now elements. It somehow disrupts so lets use a new independent list of keys
            List.from(temporaryInitialData.keys)) {
          if (!columnNamesAndTheirModelFields.containsKey(key)) {
            temporaryInitialData.remove(key);
          }
        }
      } catch (e) {
        debugPrint('what is going on here $e');
        rethrow;
      }

      debugPrint('flag #ndntxhwhgkgid23 - 2 runtimetype == $runtimeType');
    }

    // this is to be removed when it is listened somewhere else and options for listening are added.
    // not that initModel returns just _completerInitModel.future
    // but nothing like that for the global server model initModelGlobal server or something
    scheduleMicrotask(() async {
      try {
        await _completerInitModelGlobalServer.future;
      } catch (error) {
        debugPrint('catchError flag #cef10');
        debugPrint(
            'initModel() _completerInitModelGlobalServer.future exception catched see code of initModel seek the debugPrint, and the async exception thrown is: $error');

        /// !!! Rethrow?
        rethrow;
      }
    });

    // coulnd\t use conditionModelApp property, it may be that it would be overlapping
    // with the property name of ConditionModelIdAndOneTimeInsertionKeyModelServer
    ConditionModelApp? conditionModelAppInstance;
    if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
      conditionModelAppInstance =
          (this as ConditionModelIdAndOneTimeInsertionKeyModelServer)
              .conditionModelApp;
      if (null == driver.driverGlobal) {
        _completerInitModelGlobalServer.completeError(
            'initModel global driver is null so no data can be synchronized');
      }
    }

    bool dontInitIdValueAgain = false;
    bool dontInitUserIdValueAgain = false;

    debugPrint(
        'flag #;vnpr1pwpiutw: 3 this is $runtimeType and isAllModelDataProvidedViaConstructor == $isAllModelDataProvidedViaConstructor');
    if (isAllModelDataProvidedViaConstructor) {
      // there was a little check in the constructor for id and now all:
      debugPrint('flag #;vnpr1pwpiutw: 1 this is $runtimeType');
      _validateAndSetAllAllowedModelDataProperties();

      // If this library gives "too much" freedom to the developer: but we have a problem that when a model has by mistake some properties changed it is not valid so there are couple of issues involved about data integrity.
      try {
        throw Exception(
            'Exception message update: The problem mentioned in the original exception message is less important or it can be seen now that it is ok but see the description of isAllModelDataProvidedViaConstructor where it is explained why you can even pass to the constructor as a non-third-party programmer some changed properties different from those in the local server db record corresponding to the model. Original exception message: The autor is aware of the overall problem. If this library gives "too much" freedom to the developer: but we have a problem that when a model has by mistake some initial properties changed (properties passsed to the constructor) it is not valid so there are couple of issues involved about data integrity, and adding such a model as child via addChild method.');
      } catch (e) {
        debugPrint(
            'Catched exception isAllModelDataProvidedViaConstructor, exception message: $e');
      }
      debugPrint('flag #;vnpr1pwpiutw: 2');

      if (this is ConditionModelParentIdModel) {
        debugPrint('flag #;vnpr1pwpiutw: 3');

        var thisAsConditionModelParentIdModel =
            this as ConditionModelParentIdModel;

        if (thisAsConditionModelParentIdModel
            .hangOnWithServerCreateUntilParentAllows) {
          scheduleMicrotask(() async {
            await thisAsConditionModelParentIdModel
                .hangOnWithServerCreateUntilParentAllowsFuture;
            _inited = true;
            // this is done in _init setter: _completerInitModel.complete(this);
            _completerInitModelGlobalServer.complete(this);
          });
        } else {
          debugPrint('flag #;vnpr1pwpiutw: 4');
          _inited = true;
          debugPrint('flag #;vnpr1pwpiutw: 5');
          // this is done in _init setter: _completerInitModel.complete(this);
          debugPrint('flag #;vnpr1pwpiutw: 6');
          _completerInitModelGlobalServer.complete(this);
          debugPrint('flag #;vnpr1pwpiutw: 7');
        }
      } else {
        debugPrint('flag #;vnpr1pwpiutw: 8');
        _inited = true;
        debugPrint('flag #;vnpr1pwpiutw: 9');
        // this is done in _init setter: _completerInitModel.complete(this);
        debugPrint('flag #;vnpr1pwpiutw: 10');
        _completerInitModelGlobalServer.complete(this);
        debugPrint('flag #;vnpr1pwpiutw: 11');
      }

      debugPrint('flag #;vnpr1pwpiutw: 12');
      debugPrint(
          '2:initModel() A model which has all initial data properties set from a constructor and constructor param isAllModelDataProvidedViaConstructor == true has just been inited.');
    } else {
      if (temporaryInitialData['id'] != null &&
          temporaryInitialData['id'] is int &&
          temporaryInitialData['id'] > 0) {
        //this['id'] = temporaryInitialData['id'];
        columnNamesAndFullyFeaturedValidateAndSetValueMethods['id']!(
            temporaryInitialData['id'], true, false);
        dontInitIdValueAgain = true;
        if (this is ConditionModelUser &&
            temporaryInitialData['user_id'] == null) {
          temporaryInitialData['user_id'] = 0;
          dontInitUserIdValueAgain = true;
        }
      } else if (temporaryInitialData['id'] != null) {
        throw Exception(
            'The id of a model is not null but is not int or less than 1. An initial value of a model if set must be a real id reflecting a record id in the sql db.');
      }

      driver.getDriverOnDriverInited().then((working_driver) {
        debugPrint(
            'Now we have the Map of the defined columnNames with their ConditionModelField objects - of the newly created model:');
        debugPrint(
            'The column names alone are: ${columnNamesAndTheirModelFields.keys.toString()}');
        debugPrint(
            'all the columnNamesAndTheirModelFields map is like this:${columnNamesAndTheirModelFields.toString()}');
        debugPrint('The current model looks like this:');
        debugPrint('this.runtimeType==$runtimeType');
        debugPrint('this.toString()==${toString()}');
        debugPrint('jsonEncode==${jsonEncode(this)}');
        debugPrint('And it is fully iterable first for(var i...):');
        for (var key in keys) {
          try {
            debugPrint('key==$key, value==${this[key]}');
          } catch (e) {
            debugPrint('Handled debug Exception $key: ${e.toString()}');
          }
        }

        debugPrint(
            'let\' distribute initial map data to proper ConditionModelField objects');

        //Let's distribute initial map data to proper ConditionModelField objects

        //!! First but i do it later :) : Checking two things: No model can have keys (model['id']) that are not allowed - each model has id for example
        //!! The second thing: validating and setting values for now it's better to assume that when a value is not set it is the same as it is null.
        //temporaryInitialData ??= <String, dynamic>{};

        // As already known thanks to then method, the driver is ready to be used
        // ???? If a model on the local server is one entry it can be read first from db
        // if a model is read from the db all its values will be validated when each property like
        // 'id' is set (the same for the one db entry models when id =1 - it is treated the same way)
        debugPrint(
            'Some more distant future implementation: Don\'t forget in the future of comparing driver with working_driver - this should be the same object. If not a fallback driver like in memory has been created for the app to work in the emergency mode.');

        if (this is ConditionModelOneDbEntryModel ||
            (temporaryInitialData['id'] != null &&
                temporaryInitialData['id'] is int &&
                temporaryInitialData['id'] > 0)) {
          working_driver.read(this).then((result) {
            debugPrint(
                'initModel() working_driver.read() success result: ${result.toString()}');

            if (null == result) {
              debugPrint(
                  'initModel() result is null so let\'s put model into database');

              _validateAndSetAllAllowedModelDataProperties();

              scheduleMicrotask(() async {
                // See ! addChild() of ConditionModelParentIdModel which unlocks a new model
                // of ConditionModelParentIdModel which with not having it's 'id', is not in the db yet.
                // It unlocks the child when it set up properly the parent_id (using a_parent_id object)
                // All of it is related also to the hangOnWithServerCreateUntilParentAllows,
                // _hangOnWithServerCreateUntilParentAllowsCompleter props. of ConditionModelParentIdModel)

                if (this is ConditionModelParentIdModel) {
                  await (this as ConditionModelParentIdModel)
                      .hangOnWithServerCreateUntilParentAllowsFuture;
                }

                working_driver.create(this).future.then((result) async {
                  debugPrint(
                      '2:initModel() working_driver.create() success result: $result');
                  debugPrint(
                      '2:initModel() rrggttrrrr#1 working_driver.create() error: ');

                  if (this is! ConditionModelApp) {
                    if (result[0] != null && result[0]! > 0) {
                      debugPrint(
                          '2:initModel() rrggttrrrr#2 working_driver.create() error: ${columnNamesAndFullyFeaturedValidateAndSetValueMethods['id']}');
                      //this['id'] = result[0];
                      columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                          'id']!(result[0], true, false);
                      debugPrint(
                          '2:initModel() rrggttrrrr#2B working_driver.create() error: ');
                    } else if (result[1] != null && result[1]! > 0) {
                      //this['id'] = result[1];
                      debugPrint(
                          '2:initModel() rrggttrrrr#3 working_driver.create() error: ');
                      columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                          'id']!(result[1], true, false);
                      debugPrint(
                          '2:initModel() rrggttrrrr#3B working_driver.create() error: ');
                    } else {
                      _completerInitModel.completeError(
                          '2:initModel() working_driver.create() error: With a list of one or two possible integers ${result.toString()} containing no int id a model initiation could\'t has been finished');
                      return;
                    }

                    debugPrint(
                        '2:initModel() afewrt#1 working_driver.create() error: ');
                    if (this is ConditionModelIdAndOneTimeInsertionKeyModel) {
                      debugPrint(
                          '2:initModel() afewrt#2 working_driver.create() error: ');
                      // this one must work, even with timers to try again
                      columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                          'local_id']!(this['id'], true, false);

                      debugPrint(
                          '2:initModel() afewrt#3 working_driver.create() error: ');
                      // this will local_id on a local - if fails it will do it until it will success that the conde will execute further
                      await _updateLocalId(working_driver);
                      debugPrint(
                          '2:initModel() afewrt#4 working_driver.create() error: ');

                      if (this
                          is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
                        debugPrint(
                            '2:initModel() afewrt#5 working_driver.create() error: ');
                        _doDirectCreateOnGlobalServer(working_driver,
                            conditionModelAppInstance as ConditionModelApp);
                        debugPrint(
                            '2:initModel() afewrt#6 working_driver.create() error: ');
                      }
                    }
                  }

                  // setter for _inited in the right order does
                  // temporaryInitialData = {};
                  // _completerInitModel.complete(this);
                  // and _changesStreamController.add(ConditionModelPropertyChangeInfoModelHasJustBeenInited(this));
                  _inited = true;

                  debugPrint(
                      '2:initModel() working_driver.create() also the created Model has just been inited it\'s id of ${this['id']} has been set. _inited==true and the model looks like this');
                  debugPrint(toString());
                }).catchError((error) {
                  debugPrint('catchError flag #cef11');

                  debugPrint(
                      '2:initModel() working_driver.create() error result: $error');
                  _completerInitModel.completeError(
                      'T1 The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure creating a db record: $error');
                });
              });
            } else {
              debugPrint(
                  'initModel() working_driver.read() is a Map so a model is not new and existed in the db now let\'s validate and set each value to the model: ${result.toString()}');

              try {
                // server_key of ConditionModelApp from !!!read() only!!! will be set up differently
                // because it's final and cannot be changed but the global server may has removed
                // it or db was damaged - see the relevant properties of ConditiomModelApp
                // also methods like initModelComplete()
                // application only really starts working when there the attempts to get it
                // correctly and make to work are performed fully, if failed the job is
                // done in the background again and the app works for some time without the key.
                bool skipSettingUpLocalServerKey = false;
                if (this is ConditionModelApp) {
                  var conditionModelApp = (this as ConditionModelApp);
                  // it is assumed the result absolutely cannot and is not null;
                  conditionModelApp._serverKeyHelperContainer =
                      result['server_key'];
                  skipSettingUpLocalServerKey = true;
                }
                debugPrint(
                    '50A1initModel() validate and set key: columnNamesAndTheirModelFields.keys == ${columnNamesAndTheirModelFields.keys}');

                for (final String key in columnNamesAndTheirModelFields.keys) {
                  debugPrint('50A1initModel() validate and set key: $key');
                  if (skipSettingUpLocalServerKey && key == 'server_key') {
                    continue;
                  }
                  debugPrint(
                      '50A1initModel() validate and set key: $key and value ${result[key].toString()}');
                  // each value read from the db is to be validated and set up, or will be thrown exception if a value is not valid. Possible rather only in case of manually changing values in the db or in a malicious attempt.
                  //this[key].value = result[key];
                  if (dontInitIdValueAgain == true && key == 'id') {
                    continue;
                  }
                  if (dontInitUserIdValueAgain == true && key == 'user_id') {
                    continue;
                  }

                  try {
                    debugPrint('50A1 setup value');
                    //this[key] = result[key];
                    columnNamesAndFullyFeaturedValidateAndSetValueMethods[key]!(
                        result[key], true, false);
                    debugPrint('50A1 after setup value');
                  } catch (e) {
                    debugPrint('Before 50A2nitModel() error e == $e');
                    rethrow;
                  }
                  debugPrint(
                      '50A2nitModel() validate and set key: $key and value ${result[key].toString()}');
                }

                debugPrint(
                    'With no exception thrown model\'s values has been restored from the db and the model look like this:');

                debugPrint(toString());

                // setter for _inited in the right order does
                // temporaryInitialData = {};
                // _completerInitModel.complete(this);
                // and _changesStreamController.add(ConditionModelPropertyChangeInfoModelHasJustBeenInited(this));
                _inited = true;

                if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
                  if (this['server_id'] == null) {
                    _doDirectCreateOnGlobalServer(working_driver,
                        conditionModelAppInstance as ConditionModelApp);
                  } else {
                    _completerInitModelGlobalServer.complete(this);
                  }
                }
              } catch (e) {
                debugPrint(
                    'The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure during validating and setting each field received from a db record. One field failed not passing validation or setting it\'s value');
                _completerInitModel.completeError(
                    'The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure during validating and setting each field received from a db record. One field failed not passing validation or setting it\'s value');
                rethrow;
              }

              //_completerInitModel.complete(true);
            }
          }).catchError((error) {
            debugPrint('catchError flag #cef12');

            debugPrint(
                'initModel() of [${runtimeType.toString()}] working_driver.read() error result: ${error.toString()}');
            debugPrint(
                '====================================================================================');
            debugPrint(
                '====================================================================================');
            debugPrint(
                '!!!!!!!!!! Is the future complete? ${_completerInitModel.isCompleted.toString()}');
            _completerInitModel.completeError(
                'The model of class ${runtimeType.toString()} couldn\'t has been read from the db - an db engine error occured. The error result: ${error.toString()}');
          });
        } else {
          _validateAndSetAllAllowedModelDataProperties();

          scheduleMicrotask(() async {
            // See ! addChild() of ConditionModelParentIdModel which unlocks a new model
            // of ConditionModelParentIdModel which with not having it's 'id', is not in the db yet.
            // It unlocks the child when it set up properly the parent_id (using a_parent_id object)
            // All of it is related also to the hangOnWithServerCreateUntilParentAllows,
            // _hangOnWithServerCreateUntilParentAllowsCompleter props. of ConditionModelParentIdModel)
            if (this is ConditionModelParentIdModel) {
              await (this as ConditionModelParentIdModel)
                  .hangOnWithServerCreateUntilParentAllowsFuture;
            }

            working_driver.create(this).future.then((result) async {
              debugPrint(
                  '1:initModel() working_driver.create() success result: ${result.toString()}');

              if (this is! ConditionModelApp) {
                if (result[0] != null && result[0]! > 0) {
                  //this['id'] = result[0];
                  columnNamesAndFullyFeaturedValidateAndSetValueMethods['id']!(
                      result[0], true, false);
                } else if (result[1] != null && result[1]! > 0) {
                  //this['id'] = result[1];
                  columnNamesAndFullyFeaturedValidateAndSetValueMethods['id']!(
                      result[1], true, false);
                } else {
                  _completerInitModel.completeError(
                      '1:initModel() working_driver.create() error: With a list of one or two possible integers ${result.toString()} containing no int id a model initiation could\'t has been finished');
                  return;
                }
              }
              if (this is ConditionModelIdAndOneTimeInsertionKeyModel) {
                // this one must work, even with timers to try again
                columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                    'local_id']!(this['id'], true, false);

                // this will local_id on a local - if fails it will do it until it will success that the conde will execute further
                await _updateLocalId(working_driver);

                if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
                  _doDirectCreateOnGlobalServer(working_driver,
                      conditionModelAppInstance as ConditionModelApp);
                }
              }

              // setter for _inited in the right order does
              // temporaryInitialData = {};
              // _completerInitModel.complete(this);
              // and _changesStreamController.add(ConditionModelPropertyChangeInfoModelHasJustBeenInited(this));
              _inited = true;
              // If during validation process no Exception was thrown:

              // -----------------------------------
              // ??? So at the moment we have no exception
              // ??? So we can play with the db. But first some debugPrint
              debugPrint(
                  '1:initModel() working_driver.create() also the created Model has just been inited it\'s id of ${this['id']} has been set. _inited==true and the model looks like this');
              debugPrint(toString());
            }).catchError((error) {
              debugPrint('catchError flag #cef13');

              debugPrint(
                  '1:initModel() working_driver.create() error result: ${error.toString()}');
              _completerInitModel.completeError(
                  'T2 The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure creating a db record. The error result: ${error.toString()}');
            });
          });
        }

        debugPrint('=================================');
        debugPrint(
            'Let\'s repeat all the debug prints for the same model after the changes that has just been performed');

        debugPrint(
            'Now we have the Map of the defined columnNames with their ConditionModelField objects - of the newly created model:');
        debugPrint(
            'The column names alone are: ${columnNamesAndTheirModelFields.keys.toString()}');
        debugPrint(
            'all the columnNamesAndTheirModelFields map is like this:${columnNamesAndTheirModelFields.toString()}');
        debugPrint('The current model looks like this:');
        debugPrint('this.runtimeType==$runtimeType');
        debugPrint('this.toString()==${toString()}');
        debugPrint('jsonEncode==${jsonEncode(this)}');
        debugPrint('And it is fully iterable first for(var i...):');
        for (var key in keys) {
          try {
            debugPrint('key==$key, value==${this[key]}');
          } catch (e) {
            debugPrint('Handled debug Exception $key: ${e.toString()}');
          }
        }

        // here you do the automatic stuff related to storing a newly created model into db.
        // if id is not set an object must be created in the local storage db.
        // when id is present from the beginning a model is taken from the db and doesn't need to be stored

        // -----------------------------------
        // So at the moment we have no exception
        // So we can play with the db. But first some debugPrint
      });
    }

    return _completerInitModel.future;
  }

  _updateLocalId(ConditionDataManagementDriver working_driver) async {
    try {
      debugPrint(
          '2:initModel() working_driver.update() Before the new model is inited (_inited=true) we need to set up the property local_id = id (or server_id in global server context (TO DO !!!!)) async/await waiting... :');
      await working_driver.update(this, columnNames: {'local_id'});
      debugPrint(
          '2:initModel() the property of a new model has been updated successfully');
    } catch (e) {
      debugPrint(
          '2:initModel() ERROR the property local_id (or server_id in global server context [To do!!!]) of a new model hasn\'t been updated the model cannot be used in synchronizing in both directions using local and global server let\'s try to update the property cyclically using Timer.preriodic error thrown: e = $e');
      var synchronizingIdUpdateCompleter = Completer<bool>();
      Timer.periodic(Duration(seconds: 3), (timer) async {
        try {
          debugPrint(
              '2:initModel() cyclical working_driver.update() Before the new model is inited (_inited=true) we need to set up the property local_id = id (or server_id in global server context (TO DO !!!!)) async/await waiting... :');
          await working_driver.update(this, columnNames: {'local_id'});
          debugPrint(
              '2:initModel() cyclical the property of a new model has been updated successfully');
          // it probably might be that the method will be called one time too much
          if (timer.isActive) {
            timer.cancel();
            synchronizingIdUpdateCompleter.complete(true);
          }
        } catch (e) {
          debugPrint(
              '2:initModel() ERROR of cyclical invokation the property local_id (or server_id in global server context [To do!!!]) of a new model hasn\'t been updated the model cannot be used in synchronizing in both directions using local and global server error thrown: e = $e');
        }
      });

      await synchronizingIdUpdateCompleter.future;
    }
  }

  /// see [ConditionModelListenerFunction] description. F.e. a widget get a future each time the listener is invoked indicating an long backend operation is in progress, and you can show in the widget a loader informing that f.e. the widget is being updated on the server.
  @Deprecated('See [changesListeners] description')
  void addListener(ConditionModelListenerFunction changesListener) {
    changesListeners.add(changesListener);
  }

  @protected
  set _inited(bool value) {
    // ?????Is this still important?: Whenever // model is _inited and probably 'server_id' (the to-non-null-value-change you
    // must listen to already in the constructor of ConditionModel class not to init something
    // too early or too late) OR MAYBE NOT: THINK IT OVER AGAIN
    // then (if for some classes more conditions are not necessary)
    // you can use _initedGlobalServer() setter
    // the value should be always true or nothing else should happen _completerInitModel
    // additionally should complete with completeError() on errors along the road causing
    // it never to complete or being _inited == true properly.
    // WE HAVE ALSO THIS ONE hangOnWithServerCreateUntilParentAllows = true by default
    debugPrint(
        '_inited setter of this.runtimetype == $runtimeType and value == $value');
    __inited = value;

    // THE ORDER OF THIS STUFF BELOW MATTERS:
    temporaryInitialData = {};
    _completerInitModel.complete(this);
    // If during validation process no Exception was thrown:

    // -----------------------------------
    // ??? So at the moment we have no exception
    // ??? So we can play with the db. But first some debugPrint
    debugPrint(
        '1:initModel() "set _inited()" setter also the read or created Model has just been inited it\'s id of ${this['id']} has been set. _inited==true');
    debugPrint(toString());
    _changesStreamController.add(
        ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInitedLocalServer(
            this));

    //if (value) {
    //  _initedCompleter.complete(this);
    //} else {
    //  var message =
    //      'A model of ${runtimeType.toString()} couldn\'t has been inited (_init=false just has been performed). Several attempts might have been performed. By convention the model cannot be used in the app and should be removed, and all depending data and variables.';
    //  _initedCompleter.completeError(message);
    //  throw Exception(message);
    //}
  }

  @protected
  bool get inited {
    debugPrint('_inited getter of this.runtimetype == $runtimeType');
    try {
      return __inited; // of course exception will be thrown if the property hasn't been inited yet thetn catch will return "false" value;
    } catch (e) {
      debugPrint(
          '_inited error error getter of this.runtimetype == $runtimeType');
      return false;
    }
  }

  /// See the [__init] property description
  Future<ConditionModel> getModelOnModelInitComplete() =>
      _completerInitModel.future;

  @protected
  set _initedGlobalServer(bool value) {
    // the value should be always true or nothing else should happen _completerInitModelGlobalServer additionally should complete with completeError() on errors along the road causing it never complete or being _inited == true properly.
    debugPrint(
        '_initedGlobalServer setter of this.runtimetype == $runtimeType and value == $value');
    __initedGlobalServer = value;

    // THE ORDER OF THIS STUFF BELOW MATTERS:
    // not needed temporaryInitialData = {};
    _completerInitModelGlobalServer.complete(this);
    // If during validation process no Exception was thrown:

    // -----------------------------------
    // ??? So at the moment we have no exception
    // ??? So we can play with the db. But first some debugPrint
    debugPrint(
        '1:initModel() "set _initedGlobalServer()" setter. _initedGlobalServer==true');
    debugPrint(toString());
    _changesStreamController.add(
        ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInitedGlobalServer(
            this));

    //if (value) {
    //  _initedCompleter.complete(this);
    //} else {
    //  var message =
    //      'A model of ${runtimeType.toString()} couldn\'t has been inited (_init=false just has been performed). Several attempts might have been performed. By convention the model cannot be used in the app and should be removed, and all depending data and variables.';
    //  _initedCompleter.completeError(message);
    //  throw Exception(message);
    //}
  }

  @protected
  bool get initedGlobalServer {
    debugPrint(
        '_initedGlobalServer getter of this.runtimetype == $runtimeType');
    try {
      return __initedGlobalServer;
    } catch (e) {
      debugPrint(
          '_inited error error getter of this.runtimetype == $runtimeType');
      return false;
    }
  }

  /// See the [__initGlobalServer] property description
  Future<ConditionModel> getModelOnModelInitCompleteGlobalServer() =>
      _completerInitModelGlobalServer.future;

  @override
  void operator []=(key, value) {
    debugPrint('yerttttt1____' + key);

    // To remind you: DON'T REMOVE THE SWITCH, it throws exception which means children who
    // implemented the operator haven't found any property on the list and it shouldn't
    // reach here. if it didn the exception is thrown.
    switch (key) {
      /*case 'children':
        ???!!! addChild/removeChild insead of this:
        children = value;
        break;*/
      default:
        throw Exception(
            'a property \'$key\' (with value $value) hasn\'t been found on the properlist of the model. Use special exception extended class with good description');
    }

    //this.defValue[key] = value;
  }

  /*/// see the [_changed] property desc. setter is for this that you can trigger additional actions - this variable with future in mind.
  @Stub()
  set changed(bool value) {
    changed = value;
  }*/

  /// see the [_changed] property desc. readonly see desc of the class more in the description of the [ConditionModelId] class
  /*@Stub()
  bool get changed {
    return _changed;
  }*/

  /*/// see the variable description [_children] expecially about it's getter
  set children(List<ConditionModelEachWidgetModel> value) {
    this.defValue['children'] = value;
    changed = true;
  }

  /// see the variable description [_children] expecially about it's getter (in short: the "[]" operator may render different json string (jsonEncode(modeltree)) depending on on the mode setting of "[ConditionModelApp] [conditionModelApp]" defined in [ConditionModelWidget] class property - again: see the [_children] property)
  List<ConditionModelEachWidgetModel> get children {
    return this.defValue['children'];
  }*/

/*
  // Probably fully implemented but not tested. If not belonging to model an unexpected model map key is found it triggers exception, also when a property that is on the list of allowed properties has wrong value it triggers proper exception.
  // See more comments in this function body
  void validateInitialData(ConditionModel model) {
    throw Exception('here we go exception: validateInitialData method');
    for (String key in model.keys) {
      if (key == 'children') continue;
      // not tested but causing all the thing to be set up again would trigger validation. Not neccessary energy efficient but effective and this one time operation on model object creation only should still not be slow.
      model[key] = model[
          key]; // this calls a proper setter for each property see operator []= override
    }
  }
  */

  /// While immidiate properties like this['id'] update happens synchronously all the local and global server are done aysnchronously probably on  the event loop only.
  addEvent(ConditionModelEvents event, Map? data) async {
    //
  }
}

enum ConditionModelEvents {
  synchronizingStarted,
  synchronizingFinished,
  synchronizingFinishedError,
  synchronizingScheduledForLater,
  updateFromGlobalServerArrived,
}

/// Each ConditionModel that has in it's local server (not global) db table id column id and has a one_time_insertion_key column that let's to obtain freshly inserted id into the db, such ConditionModel uses this class. Some db engines might make it not a 100% sure you get the right id from the db of a inserted row id. The key is automatically set to null when id is known
abstract class ConditionModelIdAndOneTimeInsertionKeyModel
    extends ConditionModel {
  /// It must be implemented - precisely initialized or overriden or delivered in the constructors of extending classess or by lazy assigning this like in the class ConditionModelUser definition. Only ConditionModelUser is initialised by this (it receives the model himself with delay - imidietly it is impossible) so the property requires "late" keyword, the rest of the models would get the user model in the constructor and wouldn't require the late keyword.
  final ConditionModelUser? conditionModelUser;

  /// User id as you can see. It's application's user id, it's different on the server. You don't need server_user_id property, because when you are logged in - server already nows you id. Different is the need for server_id but not or server_contact_id properties - see their descriptions - for educational purposes server_contact_id left not having been removed
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldInt a_user_id = ConditionModelFieldInt(
      this, 'user_id',
      propertySynchronisation:
          ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// [Edit:] no setter, only getter for [id] because it is taken from server after model record to db insertion (typically sql record). If defValue is null, a model is completely new and initialises itself- its local db record in the sql db is created it tries to receive its id in the db, then if allowed local db server synchronizes automatically with the global db server and tries to obtain [server_id] id from the global server - more in READ.me and not only there. id of the model/widget in the application, it is the same on the server but server_id is not null if it is a link to another user's widget like message from him/her.
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldInt a_id = ConditionModelFieldInt(this, 'id',
      propertySynchronisation:
          ConditionModelFieldDatabaseSynchronisationType.app_only,
      isFinal: true);

  /// Cannot be final, because there may be a duplicate in the sql backend server (almost impossible, but almost). Warning, whether or not you use the key a message is received by the destination second user anyway and immediately. Also the model itself cares to remove the key if for some reason a record was created but the model was not able to get it's own id, after a year internally by the backend system - we say about completely rare situations. In 99.9% cases or more you get the key and remove the key after less than a second model was sent to be inserted into sql db. It can be reasonalby assumed that if let's say you sent a [ConditionModelMessage] message it will be received by the destination user without the model trying to get to know the id that was inserted into the db. So even in critical situations this shouldn't have impact on speed in crucial tasks. If video, audio transmission is ever implemented it might be done differently without using [__one_time_insertion_key] solutions like this.
  /// Special sql db property for id retrieving in some more complicated situations. See also [__one_time_insertion_key] and [getModelIdByOneTimeInsertionKey] method of [ConditionDataManagementDriver] class. Only a driver assigned to the object can change the value of this property (when two rows has the same unique key). You as user don't use it up on your own (except for a getter, no need for a setter). On a completely new model creation this unique key is set up automatically and internally to obtain the id of the model after it has been crated. After the id was obtained the key on the db is to be nullified.
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_one_time_insertion_key =
      ConditionModelFieldStringOrNull(this, 'one_time_insertion_key',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only,
          isFinal: false);

  ConditionModelIdAndOneTimeInsertionKeyModel(
    ConditionModelApp
        conditionModelApp, // the type is not to be null for a reason, ConditionModelApp doesn't extend this class so the ConditionModelApp object has this param set to null, analyse ConditionModel class constructor and constructor body for more.
    this.conditionModelUser,
    defValue, {
    super.appCoreModelClassesCommonDbTableName,
    super.changesStreamController,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, defValue, conditionModelApp.driver) {
    if (null == temporaryInitialData['id']) {
      // this is called on top: f.e ConditionModelMessage: validateInitialData(this); // not implemented, maybe done with little delay
      _createAndSetOneTimeInsertionKey(temporaryInitialData);
      debugPrint(
          '%%%%%55555 IS NULL ${temporaryInitialData['id'].runtimeType.toString()}');
    } else {
      debugPrint(
          '%%%%%55555 IS NOT NULL ${temporaryInitialData['id'].runtimeType.toString()}');
    }
    if (this is ConditionModelContact) {
      debugPrint('%%%%%55555Letsee what we have');
      debugPrint(temporaryInitialData.toString());
    }
    a_user_id.init();
    a_id.init();
    a_one_time_insertion_key.init();
  }

  /// used by a subclass too
  String getInsertionKey() => (UniqueKey().toString() +
          UniqueKey().toString() +
          UniqueKey().toString() +
          UniqueKey().toString() +
          UniqueKey().toString())
      .replaceAll(RegExp(r'[\[\]#]'), '');

  void _createAndSetOneTimeInsertionKey(defValue) {
    // as an exception at least for now, there is no need to invoke validateAndSet for now because the key is kind of universal and done internally, and created by the Condition app developer
    // and defValue the real map allows you avoiding second validation of the key - no need to validate, this is not a user set value but application internal value so it should always be correct.
    defValue['one_time_insertion_key'] = getInsertionKey();
  }

  @override
  void operator []=(key, value) {
    debugPrint('yerttttt1____' + key);

    switch (key) {
      case 'user_id':
        user_id = value;
        break;
      case 'one_time_insertion_key': // this is set internally but the property must be enlisted so that no exception can be thrown.
        one_time_insertion_key = value;
        break;
      case 'id': // see [id_protected] setter, this is set internally but the property must be enlisted so that no exception can be thrown.
        id = value;
        break;
      default:
        super[key] = value;
        break;
    }
  }

  @protected
  set user_id(int value) => a_user_id.validateAndSet(value);
  int get user_id => defValue['user_id'].value;

  @protected
  set one_time_insertion_key(String? value) =>
      a_one_time_insertion_key.validateAndSet(value);

  /// see more [_one_time_insertion_key]
  String? get one_time_insertion_key =>
      defValue['one_time_insertion_key'].value;

  /// Corresponding to the model's 'id' key, Check if it works as expected - private may not be accessible from an extenging class - it can be only set internally by the model (this) itself
  @protected
  set id(int value) => a_id.validateAndSet(value);

  /// no public setter, only getter ro id this is set up internally by the model and id is always taken from db while the id automatically increased on each new db record (speaking in sql terms).
  int get id => defValue['id'].value;

  /// Universal use but initially for removal purpose (some methods, properties elsewhere involved, not going into details here), now i assume that removing
  List<ConditionModelParentIdModel>
      _getModelDescendantsFlatListInTheOrderOfTraversing(
          [ConditionModelParentIdModel? parentModel,
          List<ConditionModelParentIdModel>? modelList]) {
    if ((parentModel == null && modelList == null) ||
        (parentModel != null && modelList != null)) {
      throw Exception(
          '_getDescendantsFlatListInTheOrderOfTraversing() method parentModel and modelList must at the same time either both be null or both not null.');
    } else if (parentModel == null &&
        this is! ConditionModelApp &&
        this is! ConditionModelParentIdModel) {
      throw Exception(
          '_getDescendantsFlatListInTheOrderOfTraversing() method in case parentModel param was not supplied, "this" object must be (and it isn\'t) [ConditionModelApp] or [ConditionModelParentIdModel] object and it will be used as parentModelFinal local variable');
    }

    // ! The method normally should have params in recursive invokation, not the very first one.
    // using different approaches/syntaxes wasn't able to do type hinting, slower dynamic is used instead
    dynamic parentModelFinal = parentModel ?? this;
    modelList ??= [];
    for (final model in parentModelFinal._children) {
      modelList.add(model);
      if (model._children.isNotEmpty) {
        modelList.addAll(_getModelDescendantsFlatListInTheOrderOfTraversing(
            parentModel, modelList));
      }
    }

    return modelList;
  }
}

/// Important: the below stream may throw exception if model already exist so a custom code programmer could do one of the following: 1. He could use conditionModelApp.getModelIfItIsAlreadyInTheAppInstance(int id) which returns model of having the id or null if it ws not found. 2. He could catch the exception of class [ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance], the exception has a property with the model found and you use the model instead you tried to create
abstract class ConditionModelParentIdModel
    extends ConditionModelIdAndOneTimeInsertionKeyModel {
  // I DO NOT REMEMEMBER THE STUFF BELOW
  // The property is treated in special way by setter/getter, "[]" operator, etc., all depending on the mode setting of "[ConditionModelApp] [conditionModelApp]" defined in [ConditionModelWidget] class property (the mode property changes the way all the deep tree of [ConditionModel] models which is also a [Map] ([Map] tree) is [jsonEncoded]/serialized), List of [ConditionModelEachWidgetModel] objects which are also [Map]s for easily jsonEncode and traversing the data and widget tree. F.e. maybe in some cases for LocalStorage this variable should return not list of objets but string of children ids "['5', '3', '20']" but in a away with their children "['5': ['8', ''40], '3', '20']" in effect ho   When widgets' layout order is changed this list also must be updated correspondingly, and vice versa when elements are changed here setState() is invoked to relayout the widgets in this list. This is all done down the widget tree.
  // Below may is to do with initModel() method much.
  // We are here:
  ///// [To do]
  //Before reading the real to do based on the stuff we have
  //and assuming we have full db structure with tables ready,
  //but there is no data in it yet:
  //---------------------------
  //let's try:
  //0. HERE WE START: ConditionModelApp in this of the other passess a future to ConditionModel parent
  //super class; the future returns ConditionDataManagementDriver object. The ConditionModel waits
  //until the future completes and then sets up the inited and ready to use late final _driver
  //property with the driver returned by the future. Why using the future? Because it may be
  //impossible to create and init a driver because f.e. a db sqlite3 file might be malformed or there
  //may be some other error. So while the future is not completed a ConditionModelApp my attempt
  //to create an alternative temporary driver based on diferent db engine - f.e. memory.
  //-
  //Having the driver ready the model as listed below either creates the models corresponding
  //table row/entry, or reads it's data from the db table usually based on whether or not an id
  //property of the newly created model has been set up. See more below.
  //-
  //1. Implement a ConditionModelApp initial data reading when the db is empty using
  //   default settings from condition_configuration.dart if it is a good idea of course
  //   with possible passing the initial data via the constructor (f.e. 5 apps at the same time
  //   scenario)
  //2. Only on model object creation, object constructor part: Let's implement creating
  //   a new model db entry when id is null in the model but there is
  //   data that passess validation process. Try to make as simple as you can with
  //   temporary patching any stuff should be handled better.
  //3. Only on model object creation, object constructor part: Let's implement
  //   reading an existing model from db when there is an int id value set. Try to make as simple
  //   as you can with temporary patching any stuff should be handled better.
  //----------------------------
  //We are here, all below is not about working with db, some rules of validation
  //and settings values to variables i think
  //now we need to workout and implement ConditionModelField object.value = something setting
  //we need to override the value property to be int, String for now
  //----------------------------
  //Read all in this dashed part
  //We need to make it final for this we need to extend classess and override the value property with final key word
  //Optionally, not to create new ConditionModelField - like classes we can now if a field object is a final value one.
  //Then we have two value properties instead of one value and late final valueFinal, and if a field object is final value,
  //then valueFinal is used, then it can be set once and the most importat if you try to set-up the value for the second
  //time you have a Visual Studio Express error or compile time error - that is the idea of this, that you can
  //fixed the stuff before compilation and make the hyphothetical other programmers job easier.
  //---------------------------
  //We need to implement the detection that if id is not set a model object is new, but if id is set it's been created based on the db data, then it is fully validated.
  //We need to think what to do when models like ConditionModelApp (maybe only this one) myabe cannot have initial values on it's creation that normally cannot be null. The only reason for that is that it must fetch it's data from the db first. Such model cannot be considered inited and ready to work.
  //*/

  //here now?:
  /// [to do:] A model can be created in validation mode, especially for the global server operations,
  /// if it is then it cannot be accepted as a child into the model tree and should have some
  /// other limitations, and but the advantages is that it should be passed easier during some
  /// initiation process ([initModel() related stuff)
  /// NOT TO FORGET AND REMINDER: this stuff BELOW is needed to be done before i return to [ConditionModelPropertyChangeInfo] stream related stuff
  /// and i also got to a point where tested in the code in this file for server_id being set up
  /// for the first time for being use by a child widget model [ConditionModelContact] in this case
  /// so those logic there could be implemented with the following stuff to be implemented now:
  /// to Do related to _parentNode:
  /// a model is in the tree when it has a parentModel set up
  /// but a model in a link model could have a list of link _parentLinkModels
  /// (which with related stuff for now should be implemented in ConditionModelWidget class)
  /// but updated realtime according to how many such links exist in the model tree
  /// any fully functinal model can be created fully independently and never placed in a tree
  /// as designed - independently even if it has a parent model.
  /// however:
  /// one model can be in one and only right place of a tree but a model can be linked by many link models:
  /// by right place means a widget model has or doesn't have a parent model (f.e. parent_id property)
  /// so this and other possible stuff like (contact_owner_id ?) must agree when model is placed into a model tree
  /// but a model can find itself in other places indirectly especially,
  /// f.e. there is a model that is a link model to another model and the latter model may be placed in
  /// some variable of the first "link" model for rendering purposes.
  /// and the latter model is fully functional and independent with it's own children and ancestor
  /// see the description in some extending class a_parent_id property which is not exactly the same in function like [parent_id]/[a_parent_id]. parent_id is when a model of the same type is low in hierarchy in a model tree like a contact belongs to contact group or you give an answer to a message - it is submessage, but the [_parentModel] property may be f.e a contact [ConditionModelContact] model belonging to a _parentModel [ConditionModelUser] model and the user model has its child contact in its [children]/[_children] property
  /// Update: not to get confused: parent Some validation difficult to say bat when parent_id is set _parentModel should be present so that the current model's widget could be immediately placed into the tree. Models must not intependent on their parents, ancestors or children to be easily moved in the model tree. not final because you can move this model to another place in the model tree and by this change the immediate parent. You need the property to traverse up the tree to find some ancestor models (like in javascript DOM level 2 parentNode property) seek searching methods - All normal models along with ConditionModelUser have the property, except for the top ConditionModelApp
  //think over/work out // with children property - on adding a child model a property a _parentModel (maybe @protected) would be set/changed and _children + @protected or public (yeah maybe public) children setter and getter would be put in place
  /// To simplify when a model is not [ConditionModelApp] then it's _parentModel is null, the model
  /// is not in the model tree, it is kind of standalone and independent
  /// INFO: The related [_parentLinkModels] property was moved into a model class that handles link property
  late ConditionModelParentIdModel? _parentModel;
  //start properties db update system --------------------------------------
  //----------------------------------------------------------

  /// To understand the model tree architecture [ConditionModel] class's _parentModel property's description and found in some extending class a property called [_parentLinkModels] description - not without a reason you always check if you can do somehting using related method or getter first, because any adding or removing of an element may involve additional stuff like sending a notification by adding an event to a certain [Stream] object or something else!. it is worth to see Read it all: You do not add or remove anything using this property - use @protected children addChild removeChild getters and setters which are used to adding/removing things internally, especially when you add a child model to a parent model, the parent model sets up the [_parentModel] value. Such things need to be protected from chanding like model._parentNode = othermodel like assignement - read parentMode and related descriptions.
  @AppicationSideModelProperty()
  final Set<ConditionModelParentIdModel> _children = {};

  /// (public getter with no underscore) set up in [addChild] and [removeChild]  (right after both the childModel is added or removed and [_parentModel] of the childModel is updated according to the operation of adding or removing the childModel from the parent model) but also events to the [changesStreamController] stream of [_parentModel] and childModel is issued at the right time.
  bool _isModelInTheModelTree = false;

  /// see [_isModelInTheModelTree]
  get isModelInTheModelTree => _isModelInTheModelTree;

  final bool hangOnWithServerCreateUntilParentAllows;
  final Completer<void>? _hangOnWithServerCreateUntilParentAllowsCompleter;

  final bool autoRestoreMyChildren;

  /// This is most probably called at first in initCompleteModel() body of any class habing it. It can be called also when a model is cleared from it's children (lazy loading, dynamic updates, etc.) but then they are back again.To remind first: The general rule and architecture is that each model in a sense cares for itself. So you basically cannot or at least should add _children of a your child model, you can add children of you your self. If you ignore the rule of quite an independence of a model in "all" aspects there maybe damage to the data integrity or so - simplified rule may not be that sometimes obvious looking at the code, but it is the rule applied wherever possible. This method recreates from the db children of the current model and the children are added to the _children property and should be rendered at the proper moment, especially if the currentTreeLevel property allows for that, how? The currentTreeLevel param tells you what level it is in the tree, and is respected at the start of the app. Each model class implements it's own version of the method. F.e. if grandfather currentTreeLevel == 1 ([ConditionModelApp]) then father currentTreeLevel == 2, child == 3, and so on. If in the global or maybe other settings the max current level is 3 the standard version of the app will restore its models from the db in such a way that [ConditionModelApp] (grandfather currentTreeLevel == 1) object will be restored and rendered also father [ConditionModelUser] and finally all first level [ConditionModelContact] users/groups, subcontacts and subgroups won't be rendered. Good to remember f.e. [ConditionModelMessage] messages may not be rendered, because of the nature of displaying such stuff. So this is the rule and also an example that like messages there maybe some different implementation of the rule related to currentTreeLevel param. So why is the ignoreCurrentTreeLevel param? When you want to lazy loading the next level of models this will enable you doing so.
  @protected
  restoreMyChildren(
      //int currentTreeLevel, [bool ignoreCurrentTreeLevel = false]
      ) {
    //MOdels // implement class mixin with this method - no need to define the method here?
    /// Any time you impelment the method check out for this:

    if (!this._children.isEmpty) {
      throw Exception(
          'ConditionModelParentIdModel, restoreMyChildren() method: To restore this model\'s children models the _children property must be empty - must be this._children.isEmpty == true');
    }

    var thisAsConditionModelEachWidgetModel =
        this as ConditionModelEachWidgetModel;

    // READ IT FIRST:
    // AS FAR AS I REMEMBE MUCH OF HERE BELOW IS BASED ON THE SAME METHOD OF ConditionModelUser class achievements
    // There, there may still be some educational code left

    if (ConditionConfiguration.initDbStage != null &&
        ConditionConfiguration.initDbStage! >= 3 &&
        ConditionConfiguration.debugMode) {
      // to avoid endless loop for now in this debug stage
      if (this is ConditionModelContact) {
        //ConditoinModelBelongingToContact
        var subcontact = ConditionModelContact(
            conditionModelApp,
            conditionModelUser,
            <String, dynamic>{
              'contact_e_mail': 'adfafaasdfasfafaasfasfsf2@gmail.com.debug',
              //'user_id': //id, is it// allowed when hangOnWithServerCreateUntilParentAllows: true see addChild?
            },
            hangOnWithServerCreateUntilParentAllows: true,
            autoRestoreMyChildren:
                false // to avoid infinite child adding in this debug not proper conditions

            );

        //to do: // put restoreChildren debug stuff into if statement, when flutter run ... -a debugging and put some info about that into README
        // ConditionConfiguration.debugMode
        //To do: // For now we have only testing addding completely new objects throught restorechildren methods
        // however in no debug world we can only get objects from db on restoration
        // but in debug we need to test adding hangOnWithServerCreateUntilParentAllows: false objects
        // where you have to already pass into the contstructor some initial properties via defValue like parent_id or owner_contact_id
        // and take into account sub-scenarios like server_parent_id - must be? Not? and some more.
        // As far as i remember addChild like method don't require server_ like properties, this must be solved internally.
        // But is the library compeletely prepared for each scenario?

        addChild(subcontact);

        //ConditoinModelBelongingToContact
        var message = ConditionModelMessage(
            conditionModelApp, conditionModelUser, this, <String, dynamic>{},
            hangOnWithServerCreateUntilParentAllows: true,
            autoRestoreMyChildren:
                false // to avoid infinite child adding in this debug not proper conditions
            );

        var message2 = ConditionModelMessage(
            conditionModelApp, conditionModelUser, this, <String, dynamic>{},
            hangOnWithServerCreateUntilParentAllows: true,
            autoRestoreMyChildren:
                false // to avoid infinite child adding in this debug not proper conditions
            );

        message.addChild(
            message2); // message2 will be correctly added in stages only after this.addChild finishes all complicated stuff

        addChild(message);

        message.getModelOnModelInitComplete().then((model) {
          debugPrint(
              'B] We are in [ConditionModelParentIdModel]\'s restoreTreeTopLevelModelsOrMostRecentMessagesModels() in then() of getModelOnModelInitComplete() method of a ConditionModelParentIdModel model. the model just has been inited and is ready to use. Let\'s debug-update a field/property of the model. Each time the value will be different - timestamp');
          message.description =
              ConditionModelApp.getTimeNowMillisecondsSinceEpoch()
                  .time
                  .toString();
          debugPrint(
              'B] And the value now is message.description == ${message.description}');
        }).catchError((error) {
          debugPrint('catchError flag #cef14');

          debugPrint(
              'B] Error of: We are in [ConditionModelParentIdModel]\'s restoreTreeTopLevelModelsOrMostRecentMessagesModels() in then() of getModelOnModelInitComplete() method of a ConditionModelParentIdModel model, the error message ${error.toString()}');
        });

        debugPrint(
            'P] restoreTreeTopLevelModelsOrMostRecentMessagesModels(): let\'s get into a loop creating top lever models for later rendering widgets.');
        debugPrint(
            'P]restoreTreeTopLevelModelsOrMostRecentMessagesModels() conditionModelApp.currently_active_user_id ${conditionModelApp.currently_active_user_id} and currently processed user id is $id');
        if (conditionModelApp.currently_active_user_id == id) {
          debugPrint(
              'P]the currently processed user IS active and some of it\'s models are going to be restored now. Some other stuff yet may be done.');
        } else {
          debugPrint(
              'P]the currently processed user is NOT active and it\'s models are not going to be restored now. Some other stuff yet may be done.');
        }
      }
    }

    scheduleMicrotask(() async {
      // PRODUCTION NON TESTING/DEBUG CODE IN THIS ASYNC scheduleMicrotask() call:
      // This is user model we need to restore as children all it's top level contacts and groups, but not subcontacts or subgroups
      // and ofcourse no messages/tasks belonging to contacts here

      // Educationally: as you can see this restoreMyChildren method is called after this model is inited
      // and have it's id property. Apart from that the app already passes the id when creating ConditoinModelUser object
      // so this is why the next "await getModelOnModelInitComplete();" line is not necessary and commented
      // await getModelOnModelInitComplete(); // if assigned to a variable this method would return "this" object

      try {
        debugPrint(
            'restoreMyChildren() method non-ConditionModelUser method. We are going to call local server driver.readAll() method to restore top level contacts.');
        // add constructor param that the object is fully restored from a full the map, thanks to it we wont make two requests to a db
        // add educational info on that here that an object can be fully created from a map or just you pass an id.
        // at the same time what if someone created an object with fake data but right id? hence think how hermetize itf
        // maybe it could be limited private methods or properties or some even more restricted stuff or just be reasonable and give freedom of imagination.
        // but no from outside of the api it should be "hacked"
        List<Map<String, dynamic>>? conditionMapList = await driver.readAll(
          "",
          ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
            ..add('parent_id', id)
          //..add('owner_contact_id', it would be error if used              id,)
          ,
          limit:
              null, // returns all results - local server and don't expect many results while contacts aren't so resourcerul, are they?
          //columnNames: {'id'}, we want all db record not just a record with db solumn
          dbTableName: 'ConditionModelWidget',
          //below is commented - this is local server, local device/smartphone request, no key needed
          //globalServerRequestKey: globalServerRequestKey
        );

        debugPrint(
            'restoreMyChildren() method non-ConditionModelUser method. . A result of local server driver.readAll (that was invoked by requestGlobalServerAppKeyActualDBRequestHelper(key)) has arrived. Here how it looks like: conditionMapList == $conditionMapList and :');

        if (conditionMapList == null || conditionMapList.isEmpty) {
          debugPrint(
              'restoreMyChildren() method non-ConditionModelUser method. It is null or empty :( but it is NOT a db error! A new key will be obtained in a while or later');
        } else {
          debugPrint(
              'restoreMyChildren() method non-ConditionModelUser method. result: It is not null :) so we recreate the contact objects if fly');

          // fix the below;

          // not necessary: with very big data you could remove each element after creating an object. But be reasonable, not needed.
          for (int i = 0; i < conditionMapList.length; i++) {
            //!!!! Here
            // a_parent_id syntax the parent_id IN TWO PLACES is updated in the addChild so you need ANALYSE ALL THE PROCESS
            // ALSO !!! it maybe or not that it is in other cases also set up twice.
            // much analysis awaits
            //
            //
            //
            //
            //

            // when isAllModelDataProvidedViaConstructor: true and parent_id must be set up and ready always probably even with hangOnWithServerCreateUntilParentAllows = true
            // and by this not set up in the method
            //, some unexpected update - no change to parent id
            //this may have an impact: isAllModelDataProvidedViaConstructor: true - new property and new independent stuff in initModel()
            //but also thi hangOnWithServerCreateUntilParentAllows == false
            //copy/paste: UPDATE model == ConditionModelContact we are now in the ConditionDataManagement object invoking UPDATE method. let' see how the query looks like and then throw exception until it is ok:
            //flutter: UPDATE "t8QjKjA_ConditionModelWidget" SET parent_id = 0, update_date_timestamp = 1688861150751 WHERE id = 718;
            //-----------
            // And this not far i guess related - global server shouldn't do anything when model is created from full data isAllModelDataProvidedViaConstructor: true:
            // but trying to set parent_id = 0 may have revealed that global server was not inited properly or too early or something suprising.
            // So maybe there is a need if in this configuration all is inited properly an i can set description = 'text' and it will be updated on the local and global servers
            // Inside triggerLocalAndGlobalServerUpdatingProcess() a Timer invoked the performTheModelUpdateUsingDriver() which invoked update() and returned error, NOT updated, result error, depending on the type of error (two processess accessed the same db file (if sqlite3) at the same time, internet connection lost, etc) !!!we now are trying to update the model doing it once per some longer time!!!: C] Inside triggerLocalAndGlobalServerUpdatingPr

            //    var j = 0;
            //    for (var enumValue in ConditionModelClasses.values) {
            //      j++; // in the db all starts from 1
            //      String className =
            //          enumValue.toString().replaceFirst('ConditionModelClasses.', '');
            //      if (className == runtimeType.toString()) {
            //        //return j;
            //      }
            //    }
            //    // Always above 0 bu so that there is int returned you need to tell the dart it will be int returned
            //    return 0;

            Map<String, dynamic> currentMap = conditionMapList[i];

            ConditionModelClasses conditionModelClass =
                ConditionModelClasses.values[currentMap['model_type_id'] - 1];
            String className = conditionModelClass
                .toString()
                .replaceFirst('ConditionModelClasses.', '');

            switch (className) {
              case 'ConditionModelContact':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelContact');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');
                // Only contacts can have subcontacts, if this case is run we are in contact model object (assumed db data was never changed manually)
                addChild(ConditionModelContact(
                        conditionModelApp,
                        conditionModelUser,
                        Map<String, dynamic>.from(conditionMapList[
                            i]), // see debug examples in this method when no-db compeletely new contacts are created
                        // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                        // changesStreamController: contactChangesStreamController, // a default object will be created
                        hangOnWithServerCreateUntilParentAllows:
                            false, // default value but here placed to see the difference from previous examples or following possibly
                        autoRestoreMyChildren: true,
                        isAllModelDataProvidedViaConstructor:
                            true // normally it is discouraged to use this property == true see the definition of it with it's all description
                        )
                    // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                    //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                    );
                break;
              case 'ConditionModelMessage':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;

              case 'ConditionModelVideoConference':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;
              case 'ConditionModelTask':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;
              case 'ConditionTripAndFitness':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;
              case 'ConditionModelURLTicker':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;

              case 'ConditionModelReadingRoom':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;

              case 'ConditionModelWebPage':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;

              case 'ConditionModelShop':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;
              case 'ConditionModelProgramming':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;
              case 'ConditionModelPodcasting':
                debugPrint(
                    'restoreMyChildren() method non-ConditionModelUser method. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${Map<String, dynamic>.from(conditionMapList[i])}');
                debugPrint(
                    'flag #owfan7iru293u5pfiuds : description runtimeType ${conditionMapList[i]['description'].runtimeType} , value = ${conditionMapList[i]['description']}');

                try {
                  addChild(ConditionModelMessage(
                          conditionModelApp,
                          conditionModelUser,
                          this is ConditionModelContact
                              ? this
                              : thisAsConditionModelEachWidgetModel
                                  .conditionModelContact,
                          Map<String, dynamic>.from(conditionMapList[
                              i]), // see debug examples in this method when no-db compeletely new contacts are created
                          // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                          // changesStreamController: contactChangesStreamController, // a default object will be created
                          hangOnWithServerCreateUntilParentAllows:
                              false, // default value but here placed to see the difference from previous examples or following possibly
                          autoRestoreMyChildren: true,
                          isAllModelDataProvidedViaConstructor:
                              true // normally it is discouraged to use this property == true see the definition of it with it's all description
                          )
                      // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                      //..description = "descchange${ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time.toString()}"
                      );
                } catch (e) {
                  debugPrint(
                      'restoreMyChildren() method non-ConditionModelUser method exception. we are restoring a child, which class is ConditionModelMessage, conditionMapList[i] == ${conditionMapList[i]} the error message $e');
                  rethrow;
                }

                break;

              default:
                throw Exception(
                    'restoreMyChildren() method non-ConditionModelUser method. exception: couldn\'t has found proper model class name for currentMap[\'model_type_id\'] which == ${currentMap['model_type_id']}');
            }
          }
          conditionMapList = null;
        }
      } catch (e) {
        // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
        debugPrint(
            'restoreMyChildren() method non-ConditionModelUser method. checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper(key) Predefined error message, rather throw Excepthion custom class, There was a db_error,error $e');
        // now in debug it rethrows but it should seek a way for the app to recover itself from this situation?
        // normally it should never throw and catch here.
        rethrow;
      }
    });
  }

  bool isModelInTheTreeOrInsideAParentLinkModel() => _isModelInTheModelTree ||
          (this is ConditionModelEachWidgetModel &&
              (this as ConditionModelEachWidgetModel)._hasModelParentLinkModels)
      ? true
      : false;

  // START ------------------ RETIREMENT RELATED STUFF BEFORE RETIRE METHOD DEFINITION --- IN "ONE" PLACE ----------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //
  // ---------------------------------------------------------------------------------------------------------------- //

  /// ! Caution! Never use this anywhere, only use @protected setter and public getter [retireModelWhenWhenRemovedFromTheModelTree] instead because this is internally used property, the setter does important stuff adding an event to the [_changesStreamController] event stream! Any non constructor change of the model to the "true" (if the previous value was false of course) emits [ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree] event (read more important details in the event class description). Let's say for now, it is @protected and not final but has a public getter. Default == true, When a model is 1: attached to the model tree via ([addChild], [_addParentLinkModel]) and after that removed from the tree (remove versions of the mentioned methods), then if this [_retireModelWhenWhenRemovedFromTheModelTree] == true, the model among other things will have it's descrtoy() method called adn conditionModelApp will remove the model from it's internal Set [_allAppModels] of models (not the same as the model tree) (seek the special property and it's description). Then there is no existing reference to the model in the entire app (this is assumed so). If, however, any reference is left it is considered a mistake of any random programmer making changes to the library/app and a fatal error is thrown (not Exception if different decision was taken), because it is an error in the app development stage. However when a programmer or original developer(s)? set [_retireModelWhenWhenRemovedFromTheModelTree] = false it points out that the model after removal from the tree still exists on the conditionModelApp list ([_allAppModels] Set object) which allows not only for reataching and reusing an existing model but also using it in different way, like for example rendering it sort of completely outside the application/main model tree in some completely custom way. The major point of removing unused models is to save memory, processor, etc. (f.e. lazy loading of models, removing big data models, preventing models from sending events to the changesStreamController.stream or receiving any event and possibly much more),  At one point a readme file of one of the commits contained or still contains more detailed explanations.
  bool _retireModelWhenWhenRemovedFromTheModelTree;
  // TODO: FIXME: ??? above change// the name or not in the model tree, because when you change the value of this property by setter to true when at the moment model is not in the tree it will trigger the whole removal process

  @protected
  @Deprecated(
      'Probably retire() with stuff elsewhere now do this - is this used? Probably not and to be removed')
  set retireModelWhenWhenRemovedFromTheModelTree(bool value) {
    if (value == _retireModelWhenWhenRemovedFromTheModelTree) {
      throw Exception(
          'bool set retireModelWhenWhenRemovedFromTheModelTree(bool value) exception. For how it is considered an exception and a badly designed piece of code on the part of third party developer (excuse me don\'t know how to put it) if he/she sets the same value as the previous one and may not be fully aware what is doing causing possible draining device resources for example.');
    }
    _retireModelWhenWhenRemovedFromTheModelTree = value;
    if (!_retireModelWhenWhenRemovedFromTheModelTree) {
      /// using synchronous version of the stream
      /// to remind you: this is especially listened to by the models ConditionModelApp
      /// and the ConditionModelApp model will check whether or not to remove it's link to the model
      /// calling proper method/s
      /// releasing (some procedure) resources like memory.
      _changesStreamController.add(
          ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree(
              this));
    }
  }

  bool get retireModelWhenWhenRemovedFromTheModelTree =>
      _retireModelWhenWhenRemovedFromTheModelTree;

  // ---------------------------------------------------------------------------------------------------------------- //
  // SYNCHRONOUS PART ----------- //
  // ---------------------------------------------------------------------------------------------------------------- //

  /// See the [lastRetireModelProcessStart] which is not the same. Each call of retire uptates this property with timestamp.
  ConditionTimeNowMillisecondsSinceEpoch? _lastRetireMethodCall;
  ConditionTimeNowMillisecondsSinceEpoch? get lastRetireMethodCall =>
      _lastRetireMethodCall;

  ConditionTimeNowMillisecondsSinceEpoch?
      _retireMethodItsBodyCodeExecutionLastStart;

  /// important - always updated when [_retireMethodItsBodyCodeExecutionLastStart] updated, even when synchronous body exception is thrown
  ConditionTimeNowMillisecondsSinceEpoch?
      _retireMethodItsBodyCodeExecutionLastFinish;

  /// Means synchronous aspect of the [retire] method body, read more: With [isRetirementProcessPending] you can use the both properties features as you need (use public getters). Check out if some stuff is performed even befor this property is set at the top or the [retire] method. The [retire] method is executed synchronously but apart from [isRetirementProcessPending] is not everything we need to know if the method is being executed right know which is not the same as [isRetirementProcessPending] which may last after the body or the [retire] method was executed.
  bool _isRetireMethodBodyAlreadyBeingExecuted = false;
  bool get isRetireMethodBodyAlreadyBeingExecuted =>
      _isRetireMethodBodyAlreadyBeingExecuted;

  // ---------------------------------------------------------------------------------------------------------------- //
  // ASYNCHRONOUS PART ----------- //
  // ---------------------------------------------------------------------------------------------------------------- //

  /// Use getter - this is internal stuff, Not the same as [lastRetireMethodCall] (if both properties are changed in the same [retire] method called they have the same time) where each call on retire() method updates the the [lastRetireMethodCall] while [lastRetireModelProcessStart] is updated when we start an actual retire process. this See also properties here starting from "retire..." and the retire method. When [retire]() is called this value is updated ConditionModelApp.getTimeNowMillisecondsSinceEpoch(); When retire is called unsuccessfuly a conditoinModelApp may monitor the model for some time by calling the retire method cyclically; if [conditionModelApp] detects that f.e. model has been reattached to the model tree it stops cyclically calling the retire method. Other factors may have impact if the retire method is called on a model or not. And after the model is retired it is unlinked from the app models or similar ? app property - 2 properties are for this.
  ConditionTimeNowMillisecondsSinceEpoch? _lastRetireModelProcessStart;
  ConditionTimeNowMillisecondsSinceEpoch? get lastRetireModelProcessStart =>
      _lastRetireModelProcessStart;

  /// Use the public getter of [_lastRetireModelProcessStart], but see the desc of [_lastRetireModelProcessStart]
  ConditionTimeNowMillisecondsSinceEpoch? _lastRetireModelProcessFinish;
  ConditionTimeNowMillisecondsSinceEpoch? get lastRetireModelProcessFinish =>
      _lastRetireModelProcessFinish;

  /// Do not change it, only reading purposes, this is managed by [conditionModelApp] conditionModelApp property, this is used byt it's [hangOnModelOperationIfNeeded] and is related to model retiring system ([retire] method) allowing to release resources taken by unused models. if a completer is not completed it means a model will not start a particular operation until the completer completes (related future finishes) which allows to retire method safely most probably not interrupting a possibly long global server operation. When we can prevent such an operation or other from starting we can retire model and release it's resources or possibly resume all model to fully active state if in the meantime a model was restored to the model tree, read more. conditionModelApp will monitor models that are removed from children list (removeChild method) if their resources can be released by unlinking from _allAppModels or so Set. It can be assumed that if conditions are met no link is left to the model after retire() method was called successfuly, etc. quite a number of factors involved.
  final Map<ConditionModelClassesTypeOfSucpendableOperation, Completer?>
      _conditionModelAppHangOnModelOperationsCompleters = {};

  /// only if non-null completer.isCompleted == false the retirement process is being in progress now. All important retire stuff depend on it, like public [isRetired], [isRetirementProcessPending], [pendingRetirementProcessFuture], or [retire] method if not more. If non-null completer.isCompleted == true, the model is retired. The [retire]() method updates this completer. The retirement may be completely cancelled. Maybe pending already for f.e. 10 seconds, may be created new, etc. So retire() methods updates it and you use the Future getter only in normal circumstances.
  Completer<bool>? _pendingRetirementProcessCompleter = null;

  /// Read used here [_pendingRetirementProcessCompleter] desc.
  Future<bool>? get pendingRetirementProcessFuture =>
      _pendingRetirementProcessCompleter?.future;

  /// Read used here [_pendingRetirementProcessCompleter] desc.
  bool get isRetirementProcessPending =>
      _pendingRetirementProcessCompleter != null &&
              !_pendingRetirementProcessCompleter!.isCompleted
          ? true
          : false;

  /// ! Use getter [isRetired] got a reason!. The value can be set once and bee true; The code setting up the up-to-date value is in [retire]() method at the top of it probably. Verify this desc - is older a bit. Used in connection with retire() method and [ConditionModelApp] managing all the models connected to the [ConditionModelApp] object. the property is set internally, use getter isRetired. The property can be set once and be true if set, getter will return false if this property is not initialized (the getter catches exception and correctly returns false)
  late final _isRetired;
  bool get isRetired {
    try {
      return _isRetired;
      //exception when not inited - its fine this is to prevent from setting-up this twice or more and to detect any incorrect modifications to this library
    } catch (e) {
      return false;
    }
  }

  // Probably universal but this is called by retire method just before _isRetired = true;. Must be before the retire is finished, it is to trigger possible retirement process for children also where possible, it may be that at this stage any exception will be catched in the method
  removeAllChildren() {
    // you cannot remove elements from an iterable ? when now it being iterated - we need a copy of the set
    Set<ConditionModelParentIdModel> childrenSetCopy = Set.from(
        _children); // the variable is destroyed after the method finished
    for (ConditionModelParentIdModel child in childrenSetCopy) {
      // remove child triggers retirement process on child automatically - it will be successful or not - which is fine bet the child 100% will be removed from the model too.
      // and important: when removed from the tree an event is sent to conditionModelApp and cyclically it will be checked if the child can be removed from _allApp scheduled for unlinking etc. Set
      // Monitor the synchronous apsect.
      removeChild(child);
    }
  }

  /// Never returns null - null for compatibility with the [retire] return method. As with the [retire] method body must be performed synchronous even if it returns the future. Used by the [retire] method couple of times so the need to put it into a separate method
  Future<bool>? _retireRealSynchronousCodeExecutionFinish() {
    _retireMethodItsBodyCodeExecutionLastFinish =
        ConditionModelApp.getTimeNowMillisecondsSinceEpoch();
    _isRetireMethodBodyAlreadyBeingExecuted = false;
    _changesStreamController.add(
        ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution(
            this));

    /// It must be not null. At the time of writing the only situation null was allowed or the retire method when _isRetireMethodBodyAlreadyBeingExecuted was already called
    return _pendingRetirementProcessCompleter!.future;
  }

  /// Synchronously returns null probably only when [_isRetireMethodBodyAlreadyBeingExecuted] == true. Warnings: One retirement process triggered by the retire method (information about it taken from the future) must and "decides" how long it can last but it should be designed in a way it doesn't last for too long. [retireModelWhenWhenRemovedFromTheModelTree] == false (value can be changed) is to be used by conditionModelApp internally to prevent model from removing from internal list/s, also can be used in custom code, but here retire does it's job; Public and synchronous body on purpose. Returns future of [_pendingRetirementProcessCompleter] ".future" property. It is public because you may create a model object outside this library and when it is independent of the main tree you may want to retire it on your own. Important if this synchronous-body method returns the completer which is is already completed .isCompleted == true, you may use it in a regular synchronous if (completer.isCompleted == true) function body you don't need to use in async await method but you can ofcourse do the await completer.future anytime you want when you wait for the completer to complete. Sometimes it is needed to have the information right now. You can call the method any time you want, true = retired, false = not - it is as it was. If you use models customarily then after the future is complete you can set any remaining pointer to it to null. If however a model is in the model tree. The retire method will not work and will throw an asynchronous exception (completeError). May be in Readme more desc. This must be somehow implemented however difficult it might be. Not going here into details here but there may be model removed from the model tree, there may be no other reference active to the model except for a special List of models in the ConditionModelApp class. When a model is nowhere else except for this list it must be removed. It could be implemented with some delay - if it is not in the tree and no property change induced by app user has taken place, the model can be detached and send some locking if accidentally it is suprisingly linked somewhere, and in the development process such places will be gradually corrected, some log messages, errors (no exceptions - wrongly constructed piece of code). No unused link to the model can be left
  Future<bool>? retire() {
    // READ AND KEEP IT AT THE TOP
    // READ - ONE ASYNC RETIRE PROCESS MUST NOT LAST FOR TWO LONG TO ABOUT 30 SECODS FOR EXAMPLE.
    // THIS IS BECAUSE ConditionModelApp or maybe more in the future is depending on the workings of this method
    // To achieve that there is need for efficient finishing or locking global server operations
    // by setting timeouts on the remote url servers and timeouts defined in the app
    // WHERE ALL OF THIS IS ALREADY TAKEN INTO ACCOUNT BUT NEEDS REVISION.

    // READ AND KEEP IT AT THE TOP
    // READ! NO ASYNC HERE, See why in the method description. return true if retired, or false if not it is assumed that if false it the model is fully functional as it was
    // HOWEVER, at some point there was scheduleMicrotask() which is a slightly delayed separate piece of code execution
    // and in this and as i assume possible other cases it is documented why this async separate call won't work on a changed variables/properties values and why
    // SO KEEP IN MIND THE ABOVE WHEN YOU WANT TO MESS UP THIS METHOD ! :)

    // Review event, timestamps, some other, not all stuff in the right order of occuring:
    // Important, again and again all related to reaction to synchronous aspect of retire call
    // ---------------
    // _lastRetireMethodCall
    // ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel
    // ---------------
    //
    // _retireMethodItsBodyCodeExecutionLastStart
    // _isRetireMethodBodyAlreadyBeingExecuted == true;
    // ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled
    // --------------------
    // _retireMethodItsBodyCodeExecutionLastFinish // important - always updated when _retireMethodItsBodyCodeExecutionLastStart updated, even when synchronous body exception is thrown
    // _isRetireMethodBodyAlreadyBeingExecuted == false;
    // ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution

    if (isModelInTheTreeOrInsideAParentLinkModel()) {
      throw Exception(
          'retire() method exception: You cannot retire a model that is in the main model tree as a child or as as a model in it\'s parent/container that is a link model. Using removeChild() method and/or removeParentLinkModel() on all models will trigeer retirement process automatically when conditions are met.');
    }

    final ConditionTimeNowMillisecondsSinceEpoch commonTimestampNow =
        ConditionModelApp.getTimeNowMillisecondsSinceEpoch();

    _lastRetireMethodCall = commonTimestampNow;

    _changesStreamController.add(
        ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel(
            this));

    if (_isRetireMethodBodyAlreadyBeingExecuted) {
      return null;
    } else {
      _retireMethodItsBodyCodeExecutionLastStart = commonTimestampNow;
      _isRetireMethodBodyAlreadyBeingExecuted = true;
      _changesStreamController.add(
          ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled(
              this));
    }

    /// We have to make sure that if an exception is thrown by the SYNCHRONOUS PART OF THE METHOD we call _retireRealSynchronousCodeExecutionFinish(); but probably rethrow;
    try {
      if (isRetired) {
        // WARNING BELOW CONDITOIN IS NOT TO BE THE SAME AS isRetirementProcessPending GETTER so it is not
        if (_pendingRetirementProcessCompleter == null ||
            !_pendingRetirementProcessCompleter!.isCompleted) {
          throw Exception(
              'retire() method. Closer to a debug exception. It is assumed that by design it is not going to be thrown. While the model is alread retired for some reason it\'s completer is null or is not completed ');
        }
        return _retireRealSynchronousCodeExecutionFinish();
      } else if (isRetirementProcessPending) {
        // it is understood that previous retire() call is still working so we don't change _lastRetireModelProcessStart
        // it is important that this is synchronous body of a method that synchronously returns future, not value, after finishing the body
        // so in no way on the event loop something should have changed and we can return the future now
        return _retireRealSynchronousCodeExecutionFinish();
      } else if (_pendingRetirementProcessCompleter ==
              null // can be so because isRetirementProcessPending has just been checked
          ) {
        _lastRetireModelProcessStart = commonTimestampNow;

        // is not retired so:
        _pendingRetirementProcessCompleter = Completer<bool>();

        _pendingRetirementProcessCompleter!.future.catchError((e) {
          debugPrint(
              'internal retire() method body catchError (method non async body syntax exception) the completer will be completed with false value anyway: $e');
        });
      } else {
        // it IS completed and NOT null and NOT retired // OLD DESC: it is not retired but also it is completed isCompleted == true,
        // SO we need update "the" timestamp a new completer object
        _lastRetireModelProcessStart = commonTimestampNow;
        _pendingRetirementProcessCompleter = Completer<bool>();
      }

      // Interesting syntax anyway now dart cast this as thisAsConditionModelParentIdModel automatically
      // ConditionModelParentIdModel thisAsConditionModelParentIdModel = this;

      // FIRST PART/TYPE OF CHECKING CAREFULLY CHECK OUT IF SOMETHING IS MISSING
      // !!! yeah i found one missing and working (models added/removed not tested in real life):
      // ConditionModelEachWidgetModel get hasModelParentLinkModels of the private _....
      // IS IT TO BE PERFORMED HERE OR IN THE CONDITION MODEL APP? I THINK HERE BUT...
      // First we won't retire model that is not in the main tree a a child or in any model as link child
      // also there is param or more params that tell - the model cannot be retired automatically seek the params
      if (
          // isModel... may be called two times - one time on conditionmodelapp however it is not an expensive operation
          isModelInTheTreeOrInsideAParentLinkModel() // it utilises probably now two properties updated correctly
          // WARNING retireModelWhenWhenRemovedFromTheModelTree == true // removed part: this is to be used by conditionModelApp that just won't call retire at all
          ) {
        // if model is prepared to be removed when retire() called and model is not in the tree/etc and retireModelWhenWhenRemovedFromTheModelTree == true
        // if model is successfuly retired or before that it must remove it's children - unlink so that they can be automatically retired too if conditions are met
        // is not retired so:
        // we have:
        // new _pendingRetirementProcessCompleter, updated _lastRetireModelProcessStart (and as always updated _lastRetireMethodCall)

        _lastRetireModelProcessFinish = commonTimestampNow;
        _pendingRetirementProcessCompleter!.complete(false);
        return _retireRealSynchronousCodeExecutionFinish();
      } // no else we can go ahead with the code below

      /// SECOND PART/TYPE OF CHECKING

      // !!!! ARE THE COMMENTS HERE UP TO DATE ??? !!!!
      // -----------------------------------------------------------
      // YOU NEED TO ANALYSE ALL THE PROCES OF INITING, CREATING, UPDATING ETC. TO MODIFY IT TO OR ALIGN IT WITH RETIRE METHOD.
      // - NOT A ONE MINUTE MATTER
      // problem: global server may not be working so this will prevent the model from retirement.
      // so we will have to change the the uptate for the global server
      // something like:
      // one update cycle failed
      // we have time windows to retire model if we want to.
      // we can retire model
      // if not we try the update cycle to make sure model cant be retired in the meantime.
      // so global server update cycle cannot last too long
      //
      // but basically it is assumed that update cycle for local serve is always successful because it is on disk and "fast" like in memory.
      // --------------------------------------
      // there is a need to retire model any way but wait until ome timeout ends
      // when the timeout ends it will
      // so you add isModelLocked but not yet retired because you are sure the model will be retired - all neccessary conditoins are met.
      // you think over if some regular or finalizing events in the changes stream are allowed and which ones
      // global singular operation cannot be interupted but also must be prevented from repeating
      // when model is removed from ConditionModelApp it will be recreated periodically as standalone, added to conditionmodelapp
      // then removed when synchronisation, update is finished, etc.
      // when any model is created when it exists on the conditionmodelapp list exception should be thrown.
      // so if a model is in the tree get it or create new. However if you get a now retiring object it's a big problem.
      // !!! you then need to wait or a mechanism of possible replacement of two such objects if needed should be implemented
      // model may need time to be inited locally but it's on hard disk - 30 seconds and must be inited, for retire() purposes
      // so you need another mechanism.

      // THIS condition if true as a starting point doesn't retire the model,
      // however we will try to seek if we can do something about it, has some additional information - analyse please the belo code

      bool localServerRetireConditionSet = _modelIsBeingUpdated ||
          _fieldsToBeUpdated.isNotEmpty ||
          _fieldsNowBeingInTheProcessOfUpdate.isNotEmpty;

      if (!__inited || localServerRetireConditionSet) {
        // REMINDER inited is local server so it is considered "immediate" operation you don't wait long as if from RAM So we don't care and finish quickly with false;
        // is not retired so:
        // we have:
        // new _pendingRetirementProcessCompleter, updated _lastRetireModelProcessStart (and as always updated _lastRetireMethodCall)

        _lastRetireModelProcessFinish = commonTimestampNow;
        _pendingRetirementProcessCompleter!.complete(false);
        return _retireRealSynchronousCodeExecutionFinish();
      } else if (
          // we know is is false==localServerRetireConditionSet HOWEVER THE VARIABLE MUST BE UPDATED AGAIN IN ASYNC schedule scheduleMicrotask() BECAUSE OF THE DELAY SCHEDULEMICROTASK IS CALLED ON THE EVENT LOPP. It is not impossible some values to changed in the meantime
          _modelIsBeingUpdatedGlobalServer // !!! read below we will focus on to determine if we can retire the model anyway
              ||
              _fieldsToBeUpdatedGlobalServer
                  .isNotEmpty // possible this one can allow for retirement if possible see later
              ||
              _fieldsNowBeingInTheProcessOfUpdateGlobalServer
                  .isNotEmpty // possible this one can allow for retirement if possible see later
          ) {
        // is not retired so:
        // we have:
        // new _pendingRetirementProcessCompleter, updated _lastRetireModelProcessStart (and as always updated _lastRetireMethodCall)

        // SEE PLEASE, if the below list of variables play any important role here or in the conditoin above:
        // any model must be inited quickly from local storage so inited must be in the main condition
        // __inited, _completerInitModel, __initedGlobalServer, _completerInitModelGlobalServer, _isModelInTheModelTree
        // i found also this _hasModelParentLinkModels
        // has Future?: hangOnWithServerCreateUntilParentAllows, _hangOnWithServerCreateUntilParentAllowsCompleter,
        // autoRestoreMyChildren

        // IMPORTANT EDUCATIONAL: This absolutely could be done synchronously and the return of the retire method might be bool not Completer
        // However it takes into account possible longer period actions to be performed to retire the model

        // here we attempt to retire. CAUTION! Maybe better With no async/await you have one piece of code in the event loop executed at once; any stop may cause change to some property values in the meantime
        scheduleMicrotask(() {
          // READ this body is also somewhat educative, NOT necessary the MOST EFFICIENT NOW!
          // f.e. this if there is an exception it should be handled
          // in such a way we are sure the retire process didn't finish correctly and can be started again from now
          // basically when the exception is catched in the catch body
          try {
            // If you are going to be successfull complete true if not: false; false means the model is active as it was
            // EXPECTED KEY EFFECTS:
            // 1.
            //_pendingRetirementProcessCompleter!.complete(false);
            // ---- OR ------
            // 2. In the order presented here
            // _isRetired=true;
            //_pendingRetirementProcessCompleter!.complete(true);

            // to siimplify for now

            // As mentioned earlier we will focus now if we can retire the model if _modelIsBeingUpdatedGlobalServer is true

            // what can be made of "Completer hangOnModelOperationIfNeeded("
            // 1. We can retire the model if _modelIsBeingUpdatedGlobalServer but
            // SYNCHRONOUSLY - IT MEANS ALL ON THE EVENT LOOP BUT IN ONE FULL SYNC CODE FRAGMENT TO BE EXECUTED SO THAT NO CHANGES IN THE MODEL STATE ARE DONE IN BETWEEN ASYNC/AWAIT CALLS NO ASYNC AWAIT NOW
            // 2. Synronously During code execution hangOnModelOperationIfNeeded was called and the code STOPPED (!isCompleted) and RIGHT NOW is waiting in suspension
            //    f.e. !this._conditionModelAppHangOnModelOperationsCompleters[ConditionModelClassesTypeOfSucpendableOperation.globalServerCreate].isCompleted
            // 3. After that synchronously We _isRetired=true; conditionModelApp never cannot finish the future or change it withing it's list/set, etc.
            // 4. We complete the completer the future with true

            // As mentioned earlier this value must be assigned again i quote from the condition block we are in as it is/was: "HOWEVER THE VARIABLE MUST BE UPDATED AGAIN IN ASYNC schedule scheduleMicrotask() BECAUSE OF THE DELAY SCHEDULEMICROTASK IS CALLED ON THE EVENT LOPP. It is not impossible some values to changed in the meantime"
            localServerRetireConditionSet = _modelIsBeingUpdated ||
                _fieldsToBeUpdated.isNotEmpty ||
                _fieldsNowBeingInTheProcessOfUpdate.isNotEmpty;

            /// !!! CAUTION! We are sure that in this synchronous code block the _pendingRetirementProcessCompleter will be completed with this date
            _lastRetireModelProcessFinish =
                ConditionModelApp.getTimeNowMillisecondsSinceEpoch();

            if (localServerRetireConditionSet) {
              _pendingRetirementProcessCompleter!.complete(false);
            } else if (
                // checking if the global server code has been locked right now - prevented from STARTING data operation it is not in the middle
                (
                        // This means a situation where global server possibly longer action event-loop code execution has stopped and is suspended
                        // and normally it would be unlocked in another place also on the event-loop synchronous code block
                        // "normally" is not now because we are going to retire the method with this condition met and the model
                        // will never have it's lock code unlocked
                        // TODO: // [To do: #dlkj2fhpeg8nqxwpiu]
                        // TODO: to // do: around line 8127
                        // TODO: So // add in conditionmodelapp to never complete (no error so no completeError needed) for all of completers the completer belong to this model so they will be unlinked automatically when model has no link. Make sure there no accident before the model is removed from modelsscheduledforunlinking list
                        // TODO: Also // [ok but user and conditionmodelapp addchild need another approach?] models in the retirement process or when at the moment their retire method body is synchronously called cannot be added via addchild nor add parent link methods or something like that
                        // TODO: also// [ok] you can call on the retire method only if a model is not in the main model tree, it works this way when child is removed (again review) but not sure if it is allowed or no
                        // TODO: Forgot // [ok just before _isRetired == true done whats needed] about removing all children from the model when the model hasretired or possibly just before (which exactly pinpointed moment is the best?). Is 100% any process triggered just after the removal? Should they be retired too? Or first checked for getter retireModelWhenWhenRemovedFromTheModelTree ?
                        // TODO: Unfortunately // i need to rethink ConditionModelApp and at least and especially ConditionModelUser in tree and retirement process for now user probably can be retired but maybe it never should, because it takes not much memory and is too much work. But user can be excluded from many actions and exceptions should be thrown.
                        // TODO: !!!! SUMMING UP
                        // TODO: ! ALL APP AND USER MODELS ARE IRREMOVABLE AND URETIRABLE
                        // TODO: ! FOR APP MODELS WE HAVE STATIC SET ConditionModelApps
                        // TODO: ! FOR USERS we have isLogged to block any submodels/children global operations if == false but not local
                        // TODO: ! if for each app + users falss 100 usual models in memory the 1-5 typical models is 1000 other in RAM
                        // TODO: ! SO NO NEED TO CARE FOR PERMANENT STORAGE OF APP AND USER MODELS IN RAM
                        // TODO: ! IF IT WAS TO CHANGE SOMEONE HAS TO PAY BILLIONS TO IMPLEMENT NEEDLESS STUFF.
                        // TODO: ! SnappApps: BUT YOU CAN BYPASS IT BY ADDING TO app constructor option doNotAddToTheGlobalAppList = true (DEFAULT FALSE), by doing this you are ready to pay the price of possible unfinished operations which is fine, databases may be removed after session time out, etc., there may be global/local server apps like this - snap apps, removing any last link to the app would cause cascadingly submodels destructdion with reasonable expectations no data will be left in memory
                        // TODO: !!! Reject duplicate apps (throw the first already existing app in Exception like in parentidmodels and method to checkout like it too) you sniff especially by db/table prefixes, filename for sqlite, host/login/password for mysql, but global server settings can be ignored - we may have many objects connecting to the global server
                        // TODO: !!! For this you need for local driver to add required sort of interface method isDriverDuplicate() or operator == that calls the method mentioned. It is easier just method, less confusing
                        // TODO: EDIT: got to a conslusion no need to care but you make test if a future ends with error when pointer is lost or what else happens ! //some methods may be suspended now so we need to finish them by completing completers! so in retire() we need to complete them with errors and modify the code to react properly. Curious how unlinked futures/completers finish? with an error? They should!
                        _conditionModelAppHangOnModelOperationsCompleters[
                                    ConditionModelClassesTypeOfSucpendableOperation
                                        .globalServerCreate] !=
                                null &&
                            !_conditionModelAppHangOnModelOperationsCompleters[
                                    ConditionModelClassesTypeOfSucpendableOperation
                                        .globalServerCreate]!
                                .isCompleted) ||
                    (
                        // This means a situation where global server possibly longer action event-loop code execution has stopped and is suspended
                        // and normally it would be unlocked in another place also on the event-loop synchronous code block
                        // "normally" is not now because we are going to retire the method with this condition met and the model
                        // will never have it's lock code unlocked
                        _conditionModelAppHangOnModelOperationsCompleters[
                                    ConditionModelClassesTypeOfSucpendableOperation
                                        .globalServerUpdate] !=
                                null &&
                            _conditionModelAppHangOnModelOperationsCompleters[
                                    ConditionModelClassesTypeOfSucpendableOperation
                                        .globalServerUpdate]!
                                .isCompleted)) {
              // Must be before the retire is finished, it is to trigger possible retirement process for children also where possible, it may be that at this stage any exception will be catched in the method
              removeAllChildren();
              //
              _isRetired = true;
              // Now, this is key thing to remember that this is synchronous issue of event so it is handled internally right away by conditionModelApp object
              // Also the order is important, before the async completer is completed, just after this stream event handled synchronously
              _changesStreamController.add(
                  ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired(
                      this));

              _pendingRetirementProcessCompleter!.complete(true);
            } else {
              _pendingRetirementProcessCompleter!.complete(false);
            }

            // already completed no need again _pendingRetirementProcessCompleter!.complete(false);
          } catch (e) {
            // !!! READ the debug print message.
            debugPrint(
                'retire() method exception: the retire async part of the retirement process excpressed in the retire method mainly, couldn\'t had finished the retirement of the model correctly, so it hasnt retired yet. Now a new retirement process can be started by the new call of the retire method. Additionally. There should be no exception like this, because of the design of the retirement process where any issues should be intercepted and fully handled earlier. If an exception like this is thrown it might hypothetically mean that some settings of the model has been irreversibly changed causing possible malfunction of the model. The exception message: $e');
            _lastRetireModelProcessFinish =
                ConditionModelApp.getTimeNowMillisecondsSinceEpoch();
            _pendingRetirementProcessCompleter!.complete(false);
          }
        });

        return _retireRealSynchronousCodeExecutionFinish();

        //_triggerServerUpdatingProcessRetrigerAfterFinish
        //_triggerServerUpdatingProcessRetrigerAfterFinishGlobalServer
      } else {
        // is not retired so:
        // we have:
        // new _pendingRetirementProcessCompleter, updated _lastRetireModelProcessStart (and as always updated _lastRetireMethodCall)

        // The model can be retired now
        // if _isRetired == true; all operations on the model are locked assigning to the properties, local and global server updates and more

        // Must be before the retire is finished, it is to trigger possible retirement process for children also where possible, it may be that at this stage any exception will be catched in the method
        removeAllChildren();
        //
        _isRetired = true;
        _lastRetireModelProcessFinish = commonTimestampNow;
        _changesStreamController.add(
            ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired(
                this));
        _pendingRetirementProcessCompleter!.complete(true);
        return _retireRealSynchronousCodeExecutionFinish();
      }
    } catch (e) {
      _retireRealSynchronousCodeExecutionFinish();
      rethrow;
    }
  }

  @override
  initCompleteModel() async {
    debugPrint(
        '!!We\'ve entered the initCompleteModel() of ConditionModelParentIdModel runtimeType == $runtimeType');
    bool restoreSomeUsersWidgetModels = false;
    //The // exception should never occur (local server is assumed to always work) so any
    // exception maybe shouldn't be catched - redesign it better
    try {
      await initModel(); // it is always ok and returns the "this" model itself. It probably never throws error - checkit out.
      //pretty // much not sure if isInited or similar stuff is done in ConditionModel
      // so no need to use this. Model must be inited locally it could be fatal error
      // not a catched exception. To redesign?
      // bool isInited = true;
      debugPrint(
          'initCompleteModel() of ConditionModelParentIdModel Custom implementation of initCompleteModel(): runtimeType == $runtimeType Model of [ConditionModelParentIdModel] has been inited. Now we can restore all tree tree top-level widget models belonging to the currently logged AND FRONT SCREEN ACTIVE user models like contacts, messages, probably not rendering anything yet. Possibly some other users related stuff is going to be performed ');
      restoreSomeUsersWidgetModels = true;
    } catch (e) {
      debugPrint(
          'Custom implementation of initCompleteModel() exception: runtimeType == $runtimeType Model of [ConditionModelParentIdModel] hasn\'t been inited. The error of a Future (future.completeError()) thrown is ${e.toString()}');
      // ARE WE GOING TO USE NOT ENDLESSLY INVOKED TIMER TO invoke initModel() again with some addons if necessary? Some properties might has been set already.
    }

    if (restoreSomeUsersWidgetModels) {
      if (autoRestoreMyChildren) {
        restoreMyChildren();
      }
    }
  }

  _performValidatingSettingUnlockingSendingEvent(
      ConditionModelParentIdModel childModel) {
    debugPrint(
        'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #B1');

    //childModel['parent_id']=this['id'];

    //
    //
    // Again childModel is! ConditionModelContact is used instead of
    // childModel is ConditionModelBelongingToContact because childModel is ConditionModelContact
    // and it would be better if it wouldn't see more such like comments in this method
    // contact is ConditionModelBelongingToContact but it shouldn't see addChild() similar comments
    // conditions below take into account now and possible future change that ContactModelContact
    // will may no longer belong to ConditionModelBelongingToContact which may becaome a mixin class
    //  for models like message, task
    // !ALL IMPORTANT PRE-CONDITIONS WITH EXCEPTIONS THROWN ARE IN THE addChild() method!
    if ((this is ConditionModelContact ||
                (this is! ConditionModelContact &&
                    this is ConditionModelBelongingToContact))
            // no user and no app model this is
            &&
            (childModel is! ConditionModelContact &&
                childModel is ConditionModelBelongingToContact)

        // task, message, but no contact (for now contact too but as written earlier it should change in the future)
        ) {
      final expectedOwnerContactIdValue =
          this is ConditionModelContact ? this['id'] : this['owner_contact_id'];

      if (childModel.isAllModelDataProvidedViaConstructor &&
          childModel['owner_contact_id'] != expectedOwnerContactIdValue) {
        throw Exception(
            'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): exception: condition causing the exception: childModel.isAllModelDataProvidedViaConstructor&& childModel[\'owner_contact_id\']!= expectedOwnerContactIdValue');
      } else if (!childModel.isAllModelDataProvidedViaConstructor &&
          childModel['owner_contact_id'] == null) {
        debugPrint(
            'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #B2');
        // earlier it is throwing exception (or method already finished for other positive reason) if it would be a user model or app model
        // to stop here to do:
        // owner_contact_id is not the same as parent_id - it is the same as parenNode owner_contact_id or if parentNode is a contact then its id id

        //if (childModel['owner_contact_id']!=this['id']) {
        //  throw Exception ('ConditionModel addChild method after if (this is ConditionModelContact && childModel is! ConditionModelContact) == true:  childModel[\'c\'] must be null');
        //}
        //!warning // in addChild     } else if (childModel['parent_id'] == null) {
        //!warning// the question then is parent_id can be null in this case but should it be checked owner_contact_id the same way there
        //! // probably it is included already as initially far as i guess but you make sure once again
        childModel.a_owner_contact_id._fullyFeaturedValidateAndSetValue(
            expectedOwnerContactIdValue, true, false);
        //this is done elsewhere somewhere just below: if (childModel.hangOnWithServerCreateUntilParentAllows) {childModel._hangOnWithServerCreateUntilParentAllowsCompleter!.complete();}
        //this is done elsewhere somewhere just below: childModel._changesStreamController.add(ConditionModelPropertyChangeInfoModelHasJustBeenUnlockedByParentModel(this));
      }
    }

    // The condition used here is simpler because there are exceptions in the addChild for this and also [ConditionModelUser] as form now must already be inited (so its has it's own 'id'), but other models don\'t have to.
    final expectedUserIdValue =
        this is ConditionModelUser ? this['id'] : this['user_id'];

    if (childModel.isAllModelDataProvidedViaConstructor &&
        childModel['user_id'] != expectedUserIdValue) {
      throw Exception(
          'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): exception: condition causing the exception: childModel.isAllModelDataProvidedViaConstructor && childModel[\'user_id\'] != expectedUserIdValue');
    } else if (!childModel.isAllModelDataProvidedViaConstructor &&
        childModel['user_id'] == null) {
      debugPrint(
          'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #B3 this[\'id\'] = ${this['id']}, this[\'user_id\'] = ${this['user_id']},');
      childModel.a_user_id._fullyFeaturedValidateAndSetValue(
          this is ConditionModelUser ? this['id'] : this['user_id'],
          true,
          false);
    }

    final expectedParentIdValue = this is ConditionModelUser ? 0 : this['id'];

    if (childModel.isAllModelDataProvidedViaConstructor &&
        childModel['parent_id'] != expectedParentIdValue) {
      throw Exception(
          'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): exception: condition causing the exception: childModel.isAllModelDataProvidedViaConstructor && childModel[\'parent_id\'] != expectedParentIdValue');
    } else if (!childModel.isAllModelDataProvidedViaConstructor) {
      childModel.a_parent_id._fullyFeaturedValidateAndSetValue(
          expectedParentIdValue,
          true,
          childModel.hangOnWithServerCreateUntilParentAllows ? false : true,
          childModel.hangOnWithServerCreateUntilParentAllows ? false : true);
    }

    if (childModel.hangOnWithServerCreateUntilParentAllows) {
      debugPrint(
          'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #B4');
      childModel._hangOnWithServerCreateUntilParentAllowsCompleter!.complete();
    }
    debugPrint(
        'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #B5');
    childModel._changesStreamController.add(
        ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenUnlockedByParentModel(
            this));
  }

  _performAddingChildToParentModel(ConditionModelParentIdModel childModel) {
    debugPrint(
        'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #C1');
    _children.add(childModel);
    // Warning !!! Don't change the order of stream events (_changesStreamController) because
    // the conditionModelApp object have all models streams and it reacts synchronously to
    // the [ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel]
    // that is just below in this method
    childModel._parentModel = this;
    childModel._isModelInTheModelTree = true;
    childModel._changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree(
            this, childModel));
    // Warning !!! Don't change the order of stream events (_changesStreamController) because
    // the conditionModelApp object have all models streams and it reacts synchronously to
    // the [ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree]
    // that is just above in this method
    debugPrint(
        'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #C1A1');
    //return; WHY WAS IT HERE???!!! THE RETURN OFCOURSE
    _changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel(
            this, childModel));
    return true;
  }

  /// See the description of the [_children] property.
  @protected
  bool addChild(ConditionModelParentIdModel childModel) {
    debugPrint(
        'ConditionModelParentIdModel addChild() method: we\'ve just entered the method');

    // !!!here // Most probably you must compare if childModel has the same conditionModelApp
    // as _parentModel you don't need it for removeChild the child was ok when it was added
    //x it guarantees that conditionmodelapp has this model on a list even if a model is not
    // in a modell tree, and can be found _findExistingModelObject(int id)
    // Still tricky because there may be many unused models.
    //here// [To do:] there is link "parent" models property - do something similar
    // when you have a link "parent/container" model and attach the linked model
    // to the link model (a property with list of parent/container link models) you add
    // to the property another "parent/container" model to the list
    //here // and for this only one object of a model id can exist in the tree NOT IMPLEMENTED
    //OVERALL RULE not only here
    // Now two 2+ object models of the same model['id'] can exist
    // can exist
    //
    // also // make sure if you do changes to this or to childModel
    // also in Readme To do also in ConditionModelBelongingToContact desc marked as to do later.
    // ConditionModelContact is ConditionModelBelongingToContact but logically it shouldn't
    // So check for possibility to make ConditionModelBelongingToContact class mixin.
    // but it's alrright: !!! here in this method we can use ConditionModelContact instead
    //also // when this is ConditionModelContact (ConditionModelContact) then both non-ConditionModelContact model
    // and ConditionModelWidget (?) must have analysed and solved the owner_contact_id
    //watch out! // conditionmodelwidget may have parent_id null which mean top widget
    //, but probably it must be set separately? So bear in mind it is for those normal widgets
    // but user, or app object dont use parent_id - are they ConditionModelParentIdModel ?
    //add //???model was added to the tree or removed - then widgets could be removed also
    //add // All in this method: what more events? child that it was attached to the the parent (below
    // and sometimes earlier than it is unlocked), that a parent has a new child, and possibly
    // this could be directed to the widget to rebuild itself with its new set of children (+1)
    // Maybe, (not necessary event issued when all stuff finished also parentModel = amodel) maybe also that a parentModel property has been just set
    // Maybe, event that the tree already contains the model
    // ok: exception thrown: making sure model cannot be added in two places using addChild - only "link"  models allowed as a carrier
    // ok: also model is or not is in the tree
    try {
      if (childModel._parentModel !=
          null) {} // exception thrown when not initialized
    } catch (e) {
      childModel._parentModel = null;
    }

    if (childModel.isRetired) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: The model cannot be added if it already has retired. Such model cannot be used and be unlinked - there should be no references left by the third-party programmer. The Condition library/framework also internally removes the remaining links as soon as it is able to.');
    } else if (childModel.isRetireMethodBodyAlreadyBeingExecuted ||
        childModel.isRetirementProcessPending) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: The model cannot be added when it is in the process of retirement. Add the model if it is not retired and the process triggered by the retire method finished with false result (more properties can be found to help, possibly synchronous too, but the more async completer/future returned by the retire method may be enough.)');
    }

    if (isRetired) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: The parent model cannot accept another child if the parent already has retired. Such model cannot be used and be unlinked - there should be no references left by the third-party programmer. The Condition library/framework also internally removes the remaining links as soon as it is able to.');
    } else if (isRetireMethodBodyAlreadyBeingExecuted ||
        isRetirementProcessPending) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: The parent model cannot accept another child if the parent is in the process of retirement. Add the model if it is not retired and the process triggered by the retire method finished with false result (more properties can be found to help, possibly synchronous too, but the more async completer/future returned by the retire method may be enough.)');
    }

    if (childModel._parentModel != null) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: The model cannot be added to a second place. It is already both in the proper tree and in the in\'s one unique place. However you can use the model outside the tree as a separete whole independent model or tree of models in some custom way, but not into the ConditionModelApp object\'s tree.');
    } else if (!identical(conditionModelApp, childModel.conditionModelApp)) {
      throw Exception(
          'ConditionModelParentIdModel addChild() method: You can only use two model belonging to The same [ConditionModelApp] - conditionModelApp property of [ConditionModelIdAndOneTimeInsertionKeyModel] (that was the name of the class at the time of writing this exception message)');
    } else if (_children.contains(childModel)) {
      // For errors is exception. But False ok - the model already is ont the [_children] list
      //childModel._changesStreamController.add(ConditionModelPropertyChangeInfoModelWontBeAddedBecauseItIsAlreadyInTheTreeNothingChanged(this, childModel));
      throw Exception(
          'ConditionModelParentIdModel addChild() method: you can\'t add the same child for the second time. If you do this it implies that a piece of code is written wrongly. If you really must have such an option check if the model you are trying to the tree is already in the tree');
      //return false;
      // throw Exception ('ConditionModel addChild method: You are trying to add a model that already exists in the tree. As for now it is considered a wrong design of a piece of code to do such a thing (but in your (developer) case that might be not the case). But you can catch the exception and it\'s fine, the model has been already there, it should\'t damage the app workings at all.');
    }

    // ConditionModelContact is ConditionModelBelongingToContact but it may change in the future
    // as of today this is in the method comments somewhere and ConditionModelBelongingToContact class desc.
    if (this is ConditionModelApp && childModel is! ConditionModelUser) {
      throw Exception(
          'ConditionModelParentIdModel addChild if statement: this is ConditionModelApp && childModel is! ConditionModelUser, you cannot add a child that is not ConditionModelUser to the ConditionModelApp');
    } else if (this is ConditionModelUser &&
        childModel is! ConditionModelContact) {
      throw Exception(
          'ConditionModelParentIdModel addChild if statement: this is ConditionModelUser && childModel is! ConditionModelContact, you cannot add a child that is not ConditionModelContact to the ConditionModelUser');
    } else if (this is ConditionModelContact &&
        (childModel is! ConditionModelBelongingToContact &&
            childModel is! ConditionModelContact)) {
      // read comments here and elsewhere that for now contact is also ConditionModelBelonging to contact but it may change in the future
      throw Exception(
          'ConditionModelParentIdModel addChild if statement: this is ConditionModelContact && (childModel is! ConditionModelBelongingToContact && childModel is! ConditionModelContact), you cannot add a child of f.e ConditionModelUser class or ConditionModelApp to this type of model as pointed by the condition add the beginning of the exception message.');
    } else if ((this is! ConditionModelContact &&
            this is ConditionModelBelongingToContact) &&
        (childModel is ConditionModelContact)) {
      throw Exception(
          'ConditionModelParentIdModel addChild if statement: ((this is! ConditionModelContact && this is ConditionModelBelongingToContact) && (childModel is ConditionModelContact)), you cannot add a child of f.e ConditionModelContact class to this type of model (a model that belongs to a contact like a message, task).');
    }

    if (this is ConditionModelApp) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: "this" object is ConditionModelApp but i cannot be. At the time of writing of this method, ConditionModelApp didn\'t extend the class that implemented it, and had it\'s own addChild method. However it might possibly change in the future so this Exception is to inform you now or prevent any problems in the future when the circumstances change (granted, if they ever will)');
    } else if (this is ConditionModelUser) {
      if (!inited) {
        throw Exception(
            'ConditionModelParentIdModel addChild method: "this" object is ConditionModelUser but is not this.inited==true so it must be inited at this point now (other object don\'t have to) so it doesn\'t have a local server "id" property set to int value');
      }
      // from the previous "if" it must contact
      if (childModel['user_id'] != null &&
          this['id'] != childModel['user_id']) {
        throw Exception(
            'ConditionModelParentIdModel addChild method: condition causing the exception: childModel[\'user_id\']!=null&&this[\'id\']!=childModel[\'user_id\']');
      }
    } else if (this is! ConditionModelUser &&
        (this is ConditionModelContact ||
            this is ConditionModelBelongingToContact)) {
      // from the previous "if" it must contact
      if (childModel['user_id'] != null &&
          this['user_id'] != childModel['user_id']) {
        throw Exception(
            'ConditionModelParentIdModel addChild method: childModel[\'user_id\']!=null&&this[\'user_id\']!=childModel[\'user_id\']');
      }
    }

    // My understanding is that:
    // "this" is not user
    // constructor of ConditionModelParentIdModel of parent and child object checks it all out
    // including caring that conditionModelUser is inited and has needed data.
    // So here you just need to care that user object is the same class instance for both objects (pointer to the same place in memory).
    if (!childModel.hangOnWithServerCreateUntilParentAllows) {
      // the ancestor constructor ConditionModelParentIdModel of both objects below already care that they have conditionModelUser property non-null.
      if (!identical(this is ConditionModelUser ? this : conditionModelUser,
          childModel.conditionModelUser)) {
        throw Exception(
            'addChild() method version of similar conditions: conditionModelUser property of parentModel and childModel must be the same instance (pointer to the same object in memory), parent is of $runtimeType class and child is of ${childModel.runtimeType}');
      }
    }

    debugPrint(
        'ConditionModelParentIdModel addChild() method: info: control point #L1; childModel.hangOnWithServerCreateUntilParentAllows = ${childModel.hangOnWithServerCreateUntilParentAllows}, childModel = $childModel ;');

    if (childModel.hangOnWithServerCreateUntilParentAllows == true &&
        (childModel['parent_id'] != null ||
            childModel['id'] != null ||
            childModel['owner_contact_id'] != null)) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: Condition causing the exception: childModel.hangOnWithServerCreateUntilParentAllows == true && (childModel[\'parent_id\'] != null || childModel[\'id\']!=null) || childModel[\'owner_contact_id\'] != null');
    } else if (childModel.hangOnWithServerCreateUntilParentAllows == false &&
        ((this is! ConditionModelUser && childModel['parent_id'] == null) ||
            childModel['id'] == null ||
            (this is! ConditionModelContact &&
                this is ConditionModelBelongingToContact &&
                childModel['owner_contact_id'] == null))) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: Condition causing the exception: (childModel.hangOnWithServerCreateUntilParentAllows == false && ((this is! ConditionModelUser && childModel[\'parent_id\'] == null) || childModel[\'id\'] == null || (this is! ConditionModelContact && this is ConditionModelBelongingToContact && childModel[\'owner_contact_id\'] == null)))');
    } else if (childModel.hangOnWithServerCreateUntilParentAllows == false &&
        this is ConditionModelUser &&
        childModel['parent_id'] != 0) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: if parentModel is ConditionModelUser, child model parent_id must == 0 (zero).');
    } else if (this is! ConditionModelUser &&
        (childModel['parent_id'] != null &&
            (childModel['parent_id'] != this['id'] ||
                childModel['parent_id'] == 0 ||
                childModel['parent_id']
                    is! int // fast fix of hypothetical problem because this id is not null so must be > 0
            ))) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: ConditionModelParentIdModel parent_id property of the model passed as a parameter of addChild is integer but is not the same as the id property of the model the child was intended to be added to. parentModel this[\'id\'] == ${this['id']} childModel[\'id\'].runtimeType == ${this['id'].runtimeType} childModel vardump $childModel');
    } else if (
        // I often remind that if a model is contact it is also ConditionModelBelongingToContact for now which is not logic but it stays for now and i remind in maybe all places with a condition like below about it
        this is! ConditionModelContact &&
            this is ConditionModelBelongingToContact &&
            (childModel is! ConditionModelContact &&
                childModel is ConditionModelBelongingToContact) &&
            childModel['owner_contact_id'] != null &&
            childModel['owner_contact_id'] != this['owner_contact_id']) {
      // a contact parentModel has id as it's childModel owner_contact_id
      throw Exception(
          'ConditionModelParentIdModel addChild method: (this is! ConditionModelContact && this is ConditionModelBelongingToContact && (childModel is! ConditionModelContact && childModel is ConditionModelBelongingToContact) && childModel[\'owner_contact_id\'] != null && childModel[\'owner_contact_id\'] != this[\'owner_contact_id\'])');
    } else if (
        // I often remind that if a model is contact it is also ConditionModelBelongingToContact for now which is not logic but it stays for now and i remind in maybe all places with a condition like below about it
        this is ConditionModelContact &&
            (childModel is! ConditionModelContact &&
                childModel is ConditionModelBelongingToContact) &&
            childModel['owner_contact_id'] != null &&
            childModel['owner_contact_id'] != this['id']) {
      // non contact message/task parentModel has the same owner_contact_id as it's childModel
      // also important to this point should be exception earlier if this is ConditionModelUser
      // but for example childModel is ConditionModelMessage
      throw Exception(
          'ConditionModelParentIdModel addChild method: this is ConditionModelContact && (childModel is! ConditionModelContact && childModel is ConditionModelBelongingToContact) && childModel[\'owner_contact_id\'] != null && childModel[\'owner_contact_id\'] != this[\'id\']) is true so exception is thrown - improve the exception message');
    } else if (this is! ConditionModelContact &&
        this is ConditionModelBelongingToContact &&
        childModel['owner_contact_id'] != null &&
        childModel['owner_contact_id'] != this['owner_contact_id']) {
      // non contact message/task parentModel has the same owner_contact_id as it's childModel
      // also important to this point should be exception earlier if this is ConditionModelUser
      // but for example childModel is ConditionModelMessage
      throw Exception(
          'ConditionModelParentIdModel addChild method: this is! ConditionModelContact && childModel[\'owner_contact_id\'] != null && childModel[\'owner_contact_id\']!=this[\'owner_contact_id\'] is true so exception is thrown - improve the exception message');
    }

    // Also to remeber that any model is independent as to saving it\'s data to local storage
    // to make it flexible for a developer to use models as he/she wants as much as it is possible.
    // any changes to ANY existing !inited! model are synchronized with the local and global server
    // only after it is inited first with proper setter "[_inited]"
    if (this is ConditionModelUser /* || this is ConditionModelApp*/) {
      debugPrint(
          'ConditionModelParentIdModel addChild() method: info: this is user model');

      //DUPLICATE, SEE ERALIER
      //if (childModel['parent_id'] != 0) {
      //  // good to know that it might has been decided in the meantime that
      //  // a ConditionUserModel can have parent_id != for special local app global server purposes.
      //  // it is not yet decided for sure
      //  throw Exception(
      //      'ConditionModelParentIdModel addChild method after if (this is ConditionModelUser || this is ConditionModelApp) == true:  childModel[\'parent_id\'] must be null for parentModel (_parentModel ?) classes like ConditionModelUser, ConditionModelApp.');
      //} else {

      // But the problem is that basically the parent_id might be set to int after that.
      // Let's prevent it from that by setting value to null manually
      // if it has been set already an exception will be thrown because the value is final.
      // And that's fine. It will be catched. (also could be done without try, catch using "inited" like property of a_parent_id)
      //
      // As far as i can see this condition is done even better in _performValidatingSettingUnlockingSendingEvent just after it
      // and what is important the value is not set twice which could prompt some error (don't know if this is the case)
      //if (this is ConditionModelUser &&
      //    childModel.isAllModelDataProvidedViaConstructor &&
      //    childModel['parent_id'] != 0) {
      //  throw Exception(
      //      'ConditionModelParentIdModel addChild method: exception: condition causing the exception: this is! ConditionModelUser && childModel.isAllModelDataProvidedViaConstructor &&childModel[\'parent_id\']!=0');
      //} else if (this is! ConditionModelUser) {
      //  try {
      //    childModel.a_parent_id._fullyFeaturedValidateAndSetValue(
      //        0,
      //        true,
      //        childModel.hangOnWithServerCreateUntilParentAllows ? false : true,
      //        childModel.hangOnWithServerCreateUntilParentAllows
      //            ? false
      //            : true);
      //  } catch (e) {
      //    debugPrint(
      //        'ConditionModelParentIdModel addChild method after if (this is ConditionModelUser || this is ConditionModelApp) == true: Catched exception, parent_id cannot be set up twice');
      //  }
      //}
      debugPrint(
          'ConditionModelParentIdModel addChild() method: info: point #A1');

      _performValidatingSettingUnlockingSendingEvent(childModel);
      _performAddingChildToParentModel(childModel);
      return true;
    } else {
      if (childModel['parent_id'] == null) {
        debugPrint(
            'ConditionModelParentIdModel addChild() method: info: control point #2 just about to happen: _performValidatingSettingUnlockingSendingEvent(childModel)');
        if (inited) {
          _performValidatingSettingUnlockingSendingEvent(childModel);
        } else {
          debugPrint(
              'ConditionModelParentIdModel addChild() method: info: control point #2 just about to happen: getModelOnModelInitComplete() and then _performValidatingSettingUnlockingSendingEvent(childModel)');
          getModelOnModelInitComplete().then((parentModel) {
            //parentModel the same as "this" object
            _performValidatingSettingUnlockingSendingEvent(childModel);
          });
        }
        //throw Exception ('ConditionModel addChild method: ConditionModelParentIdModel parent_id property of the model passed as a parameter of addChild is not the same as the id property of the model the child was intended to be added to.');
      }
      // it is roughly assumed that when the model is inited == true then parent_id is set up. The exceptions are to help developers and not to make impossible to bypass the app system.
      // THE LIMITATION BELOW HAS BEEN ABOLISHED IN THE MEANTIME - READ ALL COMMENTS IN THE METHOD
      //if (!model.inited) {
      //   //throw Exception ('ConditionModel addChild method: ConditionModelParentIdModel model is not yet inited (model.inited/model._inited) and ready to be regularly used especially added as an exclusive one and only child to the model tree.');
      //} else {
      //
      //}
    }
    _performAddingChildToParentModel(childModel);
    return true;
  }

  /// See the description of the [_children] property.
  @protected
  removeChild(ConditionModelParentIdModel childModel) {
    throw Exception(
        'method removeChild() of ConditionModelParentIdModel class: of See README.md[To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31] : related pretty much stuff not implemented. Especially ConditionModelApp model (not the parentModel) must make sure the child is inited on the locall server before it is removed and retired. The second it cannot be removed at this stage of the library/app development until the child is globally inited with it\'s children and further descentants too. the mentioned to do has steps to implement before this exception is removed');

    if (!_children.contains(childModel)) {
      throw Exception(
          'ConditionModelParentIdModel removeChild() method: Model cannot be removed from the model tree, because it is not in the model tree.');
      //childModel._changesStreamController.add(ConditionModelPropertyChangeInfoModelWontBeRemovedBecauseItIsAlreadyNotInTheTreeNothingChanged(this, childModel));
      //throw Exception ('ConditionModel removeChild method: You are trying to remove a model (childModel) that is not in the tree. As for now it is considered a wrong design of a piece of code to do such a thing (but in your (developer) case that might be not the case). But you can catch the exception and it\'s fine, the model has been already there, it should\'t damage the app workings at all.');
      //return;
    }

    childModel._parentModel = null;
    _children.remove(childModel);
    childModel._isModelInTheModelTree = false;
    // Warning !!! Don't change the order of TWO stream events BELOW (_changesStreamController)
    // because the conditionModelApp object have all models streams and it reacts synchronously
    // to the [ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved]
    // NOT TO [ConditionModelInfoEventModelTreeOperationModelHasJustBeenRemovedFromTheModelTree]
    childModel._changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustBeenRemovedFromTheModelTree(
            this, childModel));
    _changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved(
            this, childModel));
  }

  //for informational purpose: earlier here was the _parentModel property but read the a_parent_id description and the _parentModel property desc in the [ConditionModel] class
  //ConditionModelParentIdModel? _parentModel;

  /// see the description of ConditionModelParentIdModel? _parentModel property which is not exactly the same in function like [parent_id]/[a_parent_id]. parent_id is when a model of the same type is low in hierarchy in a model tree like a contact belongs to contact group or you give an answer to a message - it is submessage, but the [_parentModel] property may be f.e a contact [ConditionModelContact] model belonging to a _parentModel [ConditionModelUser] model and the user model has its child contact in its [children]/[_children] property
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_parent_id =
      ConditionModelFieldIntOrNull(this, 'parent_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized,
          isFinal: false);

  ConditionModelParentIdModel(
    super.conditionModelApp,
    super.conditionModelUser,
    super.defValue, {
    super.appCoreModelClassesCommonDbTableName,
    super.changesStreamController,
    retireModelWhenWhenRemovedFromTheModelTree = true,
    super.isAllModelDataProvidedViaConstructor,
    this.hangOnWithServerCreateUntilParentAllows = false,
    this.autoRestoreMyChildren = true,
  })  : _retireModelWhenWhenRemovedFromTheModelTree =
            retireModelWhenWhenRemovedFromTheModelTree,
        _hangOnWithServerCreateUntilParentAllowsCompleter =
            hangOnWithServerCreateUntilParentAllows == false
                ? null
                : Completer<void>() {
    // conditiionModelApp has stream listener - a receiver that will add: this.conditionModelApp._allAppModelsNewModelsWaitingRoom.add(thismodel);
    // READ: (also stream event class description read) try not to move this code to the ConditionModel class as possibly best expected because here you have the retire() method also, what doesn't seem to me the best the conditionModelApp handles only objects of this class, so it was once planned
    // Important: the below stream may throw exception if model already exist so a custom code programmer could do one of the following:
    // 1. He could use conditionModelApp.getModelIfItIsAlreadyInTheAppInstance(int id) which returns model of having the id or null if it ws not found.
    // 2. He could catch the exception of class ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance,
    //  the exception has a property with the model found and you use the model instead you tried to create
    if (this is! ConditionModelUser) {
      _changesStreamController.add(
          ConditionModelInfoEventModelAcceptModelToTheConditionModelAppWaitingRoomSet(
              this, temporaryInitialData['id']));
    }

    if (hangOnWithServerCreateUntilParentAllows) {
      if (temporaryInitialData['id'] is int) {
        // no need to check for null or < 1 because when hangonWith... is true it doesn't allow anything but null.
        throw Exception(
            'A completely new model of descendant class of ConditionModelParentIdModel, that is new with no "id" set up must have no initial thid["id"]. it must be null. Improve the exception message :) ');
      }
      _changesStreamController.add(
          ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenLockedAndWaitingForParentModelToUnlockIt(
              this));
    } else {
      // Let's say we allow for using not inited conditionModelUser but it will have a given id for now.
      // It is noteworthy that addChild of this class check if parentModel and childModel have pointer to the same object in memory using "identical()" not "==" operator
      if (this is! ConditionModelUser &&
          (conditionModelUser!['id'] == null ||
              conditionModelUser!['id'] is! int ||
              conditionModelUser!['id'] < 1)) {
        throw Exception(
            'A completely new non-ConditionModelUser model of a descendant class of ConditionModelParentIdModel exception: While it is allowed that conditionModelUser is not yet inited (seek getter inited) the id of conditionModelUser must be int and >= 1. The current id value returned is ${conditionModelUser!['id']}');
      }
      // WARNING: SOME OR ALL OF THE LOGIC RULES HERE ARE TO BE COMPATIBLE WITH addChild method (couple of implementations)
      // this condition was added after in a case where sqlite insert query couldn't had been performed because user_id was null or something like that
      if (this
              is! ConditionModelUser // so it needs to have non-null conditionModelUser
          &&
          temporaryInitialData['id'] == null &&
          (temporaryInitialData['user_id'] is! int ||
              (temporaryInitialData['user_id'] is int &&
                  temporaryInitialData['user_id'] < 1))) {
        if (temporaryInitialData['user_id'] is int &&
            temporaryInitialData['user_id'] < 1) {
          throw Exception(
              'A completely new non-ConditionModelUser model of a descendant class of ConditionModelParentIdModel exception: user_id must be int and >=1. when non-model-init-blocking option hangOnWithServerCreateUntilParentAllows == false.');
          //    super.hangOnWithServerCreateUntilParentAllows,
          //    super.autoRestoreMyChildren,
        } else if (conditionModelUser!['id'] == null ||
            (conditionModelUser!['id'] is int &&
                conditionModelUser!['id'] < 1)) {
          throw Exception(
              'A completely new non-ConditionModelUser model of a descendant class of ConditionModelParentIdModel exception: in this case conditionModelUser![\'id\'] must be > 1.');
        } else {
          temporaryInitialData['user_id'] = conditionModelUser!['id'];
        }
      }
      // now it all should be set up correctly or it has been alredy earlier, so now is the final check
      if (this is! ConditionModelUser &&
          temporaryInitialData['user_id'] != conditionModelUser!['id']) {
        throw Exception(
            'A completely new non-ConditionModelUser model of a descendant class of ConditionModelParentIdModel exception: in this case temporaryInitialData[\'user_id\']!=conditionModelUser![\'id\']');
      }
    }
    a_parent_id.init();
  }

  Future<void>? get hangOnWithServerCreateUntilParentAllowsFuture =>
      _hangOnWithServerCreateUntilParentAllowsCompleter != null
          ? _hangOnWithServerCreateUntilParentAllowsCompleter!.future
          : null;

  @override
  void operator []=(key, value) {
    debugPrint('yerttttt1____' + key);

    switch (key) {
      case 'parent_id': // see [id_protected] setter, this is set internally but the property must be enlisted so that no exception can be thrown.
        parent_id = value;
        break;
      default:
        super[key] = value;
        break;
    }
  }

  /// See the parent's class id setter description
  @protected
  set parent_id(int? value) => a_parent_id.validateAndSet(value);

  /// See the parent's class id getter description
  int? get parent_id => defValue['parent_id'].value;
}

abstract class ConditionModelIdAndOneTimeInsertionKeyModelServer
    extends ConditionModelParentIdModel {
  /// We start part which is about syncrhonizing with Global server and the global server has it's own id so you have to store the local server id in local_id also - in the local server both must be the same and not null but on the global server they are obviously different.
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_local_id =
      ConditionModelFieldIntOrNull(
          this, 'local_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only,
          isFinal: true);

  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_user_id =
      ConditionModelFieldIntOrNull(this, 'server_user_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only);

  /// WARNING [TO DO:] or to rethink again later: take care (as it is now) that app_id is taken by the ConditionModelApp server key on the global server not on app_id property. And the local app should\'nt rather "know" the app_id. Yet to rethink if such restrictions are needed. It is starting to seem that actually the key may not be finally absolutely neccessary and app_id would be faster. Don\'t change your mind in a hurry.
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_app_id =
      ConditionModelFieldIntOrNull(this, 'app_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only,
          isFinal: true);

  // On a completely new model crettion or each change/update to the model this is set to 1 depending on whether or not a property needs to be synchronized
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldInt a_to_be_synchronized =
      ConditionModelFieldInt(this, 'to_be_synchronized',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only,
          isFinal: false);

  /// See also [ConditionModelIdAndOneTimeInsertionKeyModel] id property and similar. The properties below are counterparts of the loacal server properties. Global server id. You cannot update or remove widget without it's id on the remote global server server
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_id =
      ConditionModelFieldIntOrNull(this, 'server_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only,
          isFinal: true);

  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_parent_id =
      ConditionModelFieldIntOrNull(this, 'server_parent_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only,
          isFinal: true);

  /*/// Cannot be final, because there may be a duplicate in the sql backend server (almost impossible, but almost). Warning, whether or not you use the key a message is received by the destination second user anyway and immediately. Also the model itself cares to remove the key if for some reason a record was created but the model was not able to get it's own id, after a year internally by the backend system - we say about completely rare situations. In 99.9% cases or more you get the key and remove the key after less than a second model was sent to be inserted into sql db. It can be reasonalby assumed that if let's say you sent a [ConditionModelMessage] message it will be received by the destination user without the model trying to get to know the id that was inserted into the db. So even in critical situations this shouldn't have impact on speed in crucial tasks. If video, audio transmission is ever implemented it might be done differently without using [__one_time_insertion_key] solutions like this.
  /// Special sql db property for id retrieving in some more complicated situations. See also [__one_time_insertion_key] and [getModelIdByOneTimeInsertionKey] method of [ConditionDataManagementDriver] class. Only a driver assigned to the object can change the value of this property (when two rows has the same unique key). You as user don't use it up on your own (except for a getter, no need for a setter). On a completely new model creation this unique key is set up automatically and internally to obtain the id of the model after it has been crated. After the id was obtained the key on the db is to be nullified.
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_server_one_time_insertion_key =
      ConditionModelFieldStringOrNull(this, 'server_one_time_insertion_key',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized,
          isFinal: false);
*/
  ConditionModelIdAndOneTimeInsertionKeyModelServer(
    super.conditionModelApp,
    super.conditionModelUser,
    super.defValue, {
    super.appCoreModelClassesCommonDbTableName,
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) {
    debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B1');
    if (null == temporaryInitialData['id']) {
      debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B1A1');
      // id is possibly set in the class extending but here
      temporaryInitialData['to_be_synchronized'] = 1;
      try {
        throw Exception(
            'ConditionModelIdAndOneTimeInsertionKeyModelServer constructor Catched exception: For some reason if you do "1" instead of int 1 the #b1a2 debugPrint is not showing and the rest of the code is not processed. Like a hidden error.');
      } catch (e) {
        debugPrint("$e");
      }
      // this is called on top: f.e ConditionModelMessage: validateInitialData(this); // not implemented, maybe done with little delay
      //  _createAndSetOneTimeInsertionKeyServer();
      debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B1A2');
    } else {
      debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B1A3');
      temporaryInitialData['local_id'] = temporaryInitialData['id'];
      debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B1A4');
    }

    debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B2');
    a_local_id.init();
    a_server_user_id.init();
    a_app_id.init();
    a_to_be_synchronized.init();
    a_server_id.init();
    a_server_parent_id.init();
    // a_server_one_time_insertion_key.init();

    if (this is! ConditionModelContact &&
        this is ConditionModelBelongingToContact &&
        hangOnWithServerCreateUntilParentAllows == true &&
        temporaryInitialData['id'] != null) {
      throw Exception(
          'ConditionModelBelongingToContact constructor exception: To my humble knowledge condition if (hangOnWithServerCreateUntilParentAllows==true&&temporaryInitialData[\'id\']!=null cannot be true');
    }
    debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B3');

    // Based on [To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31] in README.md
    // childModel cares to get its server_id or if needed server_owner_contact_id.
    // This is important that the stuff here is done before the initModel();
    // So i can listen to the changes stream
    // it is assumed that when [hangOnWithServerCreateUntilParentAllows]==false, [parentModel] is inited and has all needed local properties
    // also == true id = null - a new model right now - see earlier exception in the constructor
    if (hangOnWithServerCreateUntilParentAllows == true ||
        (hangOnWithServerCreateUntilParentAllows == false &&
            !temporaryInitialData.containsKey(
                'server_parent_id') // it is final can be set once, can be null, condition means it's been not set-up yet
        )) {
      debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B4');
      // now this model is not attached as child yet, we are waiting for it
      // and then wait until the parentModel is global server inited
      // so that the childModel can init itself on the global server
      // changesStreamController
      //ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree
      // this time we choose the async version of the stream _changesStreamController
      // updating on the global server is asynchronous by nature so all goes to the event loop
      this.changesStreamController.stream.listen((event) async {
        if (event
                is ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree
            //  event is ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel
            //  || event is ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel
            ) {
          if (!identical(event.childModel, this)) {
            throw Exception(
                'ConditionModelBelongingToContact constructor : programmer\'s error, not library bad construction error: childModel contained in [ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree] event is not the same object (identical(object1, object2)==false), and this typically means that two different models got in their constructor the same identical object changesStreamController, but each model must have distint object for this param to work properly. The problem is that when you listen to the stream changesStreamController you got event from the two objects, casing the framework to malfunction. However this exception in this case prevents the problem directing you as programmer to fix your code. Some other solution than this exception was considered inferior. However this exception shouldn\'t cause the app to work improperly at all bacause it is a separate event-loop event from stream.');
          }

          if (hangOnWithServerCreateUntilParentAllows == false &&
                  a_server_parent_id._firstValueAssignementCompleter
                      .isCompleted // may return null but it wasn't set bacause even on each never-set-up key null is returned)
              ) {
            // [To do:#aDcN9a!8e9d] server_parent_id is to make search for the record in the global server faster, if the id is wrong no record is returned
            // so if you set up a wrong value incompatible with the local server it's the fault of the programmer and global server will be intact
            return;
          }

          // now we have properties parentModel and childModel in the event
          // but if the child it was removed in the meantime this.parentModel == null
          // (at the time of writing this comment temporarily removeChild throwed exceptions however)
          // SO WE need unchangeable parentModel var - it is always one
          //make sure // !!! that if a model has server_id already it is globally inited!!!
          //Think over and Add // a top_owner_contact_id - server_top_owner_contact_id - top_parent_id and server_top_parent_id too? It is preliminary assumed it will help searching the tree in the db from top to bottom or at least it will allow render all contact tree even if you subgroup is somewhere in the middle.

          debugPrint(
              'ConditionModelBelongingToContact constructor : A model has been attached to the tree, we are now waiting for parentModel to be inited on the global server (it might has happened already for couple of different reasons.) ; parentModel is ${event.parentModel!.runtimeType} and childModel is ${event.childModel.runtimeType} compare child: ${runtimeType}');
          await event.parentModel!.getModelOnModelInitCompleteGlobalServer();
          debugPrint(
              'ConditionModelBelongingToContact constructor : A parentModel has been inited as previous debugPrint was saying so now we can assign the server_id value this[\'server_parent_id\'] == ${this['server_parent_id']} , event.parentModel![\'server_id\'] == ${event.parentModel!['server_id']};');

          // old code actually was good
          // code seems to be correct i suppose automatic temporary assignement might somewhere iterate through keys and set up null

          //try {
          this['server_parent_id'] = event.parentModel is ConditionModelUser
              ? 0
              : event.parentModel!['server_id'];
          //} catch (e) {
          //  debugPrint(
          //      'flag #va!4ndAS4pqh8 this : assignement-times counter is $ccccccccounter runtimeType == $runtimeType , a_server_parent_id._isThisFirstValueAssignement = ${a_server_parent_id._isThisFirstValueAssignement} a_server_parent_id._firstValueAssignementCompleter.isCompleted == ${a_server_parent_id._firstValueAssignementCompleter.isCompleted} this : $this, the error is: $e');
          //  rethrow;
          //}
          // server_user_id - you cannot take from parent - new widget may have different user
          // server_contact_user_id cannot take from parent - tricky stuff for later
          // to remind you contact logically shouldn't be ConditionModelBelongingToContact but it is for now

          if (this is! ConditionModelContact &&
              this is ConditionModelBelongingToContact) {
            this['server_owner_contact_id'] =
                event.parentModel! is ConditionModelContact
                    ? event.parentModel!['server_id']
                    : event.parentModel!['server_owner_contact_id'];
          }
        }
      });
    } else {
      debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B5');
      if (temporaryInitialData['server_id'] != null) {
        // ok, do nothing, however some stricter validation, it cannot be wrongly coded.
        if (temporaryInitialData['server_id'] < 1) {
          throw Exception(
              'ConditionModelBelongingToContact constructor : if server_id != null then it cannot be < 1');
        }
      } else {
        // The model will be now read from the db, no need to implement anything here, right?
        // there is for read model check out if server_id is set, if not the model will be
        // sent to the global server to end up obtaining the server_id
        // throw Exception('ConditionModelIdAndOneTimeInsertionKeyModelServer constructor: not implemented if else block see the place of this exception, also exception related to the [To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31] in README.md file');
        // Based on [To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31] in README.md
        // the stuff below is to be implemented at some later point in time

        // in else we just wait for the parentModel to be global server inited
        // if a model doesn't have server_id or server_owner_contact_id, etc.
        // it is because it was not yet globally inited so we wait until the model i added to the
        // tree.
        // So scenarious and conditions for them below:
        // 1. we have server_id - it is assumed that when we do we have server_owner_contact_id
        //    - earlier mechanisms assure that. it's ok we don't do anything
        // 2. We don't have server_id, server_owner_contact but
        //  the model has local parent_id or owner_contact_id
        //  a: we wait until our init == true (there is some future for that)
        //  b: we seek if there is a parentModel currently on the ConditionModelApp flat list (Set)
        //  c: if so get parentModel ~initmodelglobalserver (?) future (WARNING! Again make sure that models that already were created on the global server are inited )
        //    --! dont use addChild and similar stuff
        //  d: If the model is not on the global list restore the model from the db as standalone and retire it when no longer needed and remove it from the ConditionModelApp
        //  e: Remember that the parent model may need to restore it's parent.
      }
    }

    //Dead code or already implemented above similar if/else? // we will do it in the global server ConditionDataManagementDriver - faster but
    // little more resourcefull on the global server
    scheduleMicrotask(() async {
      // related to _doDirectCreateOnGlobalServer method, see overall to do there in comments
      // to remind you hangOnWithServerCreateUntilParentAllows is !local server! stuff
      // when parent is ready it is setting up something in its newly created child
      // then child is unlocked and it starts doing it's local create but
      // to create on the global server ConditionModelBelongingToContact must have first
      // set up server_owner_contact_id and then it is unlocked
      // so:
      if (hangOnWithServerCreateUntilParentAllows == true) {
        // I think it would be easier to do it using the db
        // but trying to do this in memory first maybe faster - what if 100 models are waiting
        // checking the db every f.e. 1 second? Rare but i would consider this.
        // it should be done both ways, the memory way always when the model is in the tree.
        // it is a completely new model we are waiting until
        // 1. we have a parentMode != null (we are attached to the main tree via addChild)
        // 2. then we future-first-change read either:
        //    a: server_id if the parent is a ConditionModelContact or
        //    b: server_owner_contact_id is if the parent is a ConditionModelBelongingToContact
        //       and also is not a ConditionModelContact
        //       !BOTH CONDITIONS MUST BE MET
      } else {}
    });
  }

  /// See [_createAndSetOneTimeInsertionKey] description with optionally contents of the method and it's comments.
  //void _createAndSetOneTimeInsertionKeyServer() {
  //  defValue['server_one_time_insertion_key'] = getInsertionKey();
  //}

  @override
  void operator []=(key, value) {
    debugPrint('yerttttt1____' + key);

    switch (key) {
      case 'local_id':
        local_id = value;
        break;
      case 'server_user_id':
        server_user_id = value;
        break;

      case 'app_id':
        app_id = value;
        break;
      case 'to_be_synchronized': // this is set internally but the property must be enlisted so that no exception can be thrown.
        to_be_synchronized = value;
        break;

      //case 'server_one_time_insertion_key': // this is set internally but the property must be enlisted so that no exception can be thrown.
      //  server_one_time_insertion_key = value;
      //  break;
      case 'server_id': // see [id_protected] setter, this is set internally but the property must be enlisted so that no exception can be thrown.
        server_id = value;
        break;
      case 'server_parent_id': // see [id_protected] setter, this is set internally but the property must be enlisted so that no exception can be thrown.
        server_parent_id = value;
        break;

      default:
        super[key] = value;
        break;
    }
  }

  @protected
  set local_id(int value) => a_local_id.validateAndSet(value);

  int get local_id => defValue['local_id'].value;

  @protected
  set server_user_id(int? value) => a_server_user_id.validateAndSet(value);

  int? get server_user_id => defValue['server_user_id'].value;

  @protected
  set app_id(int? value) => a_app_id.validateAndSet(value);

  int? get app_id => defValue['app_id'].value;

  @protected
  set to_be_synchronized(int value) =>
      a_to_be_synchronized.validateAndSet(value);

  int get to_be_synchronized => defValue['to_be_synchronized'].value;

//  @protected
//  set server_one_time_insertion_key(String? value) =>
//      a_server_one_time_insertion_key.validateAndSet(value);
//
//  /// see more [_server_one_time_insertion_key] and parent-class [_one_time_insertion_key]
//  String? get server_one_time_insertion_key =>
//      defValue['server_one_time_insertion_key'].value;

  /// See the parent's class id setter description
  @protected
  set server_id(int? value) => a_server_id.validateAndSet(value);

  /// See the parent's class id getter description
  int? get server_id => defValue['server_id'].value;

  /// See the parent's class id setter description
  @protected
  set server_parent_id(int? value) => a_server_parent_id.validateAndSet(value);

  /// See the parent's class id getter description
  int? get server_parent_id => defValue['server_parent_id'].value;
}

abstract class ConditionModelCreationDateModel
    extends ConditionModelIdAndOneTimeInsertionKeyModelServer {
  /// a creation date of the model/widget, app timestamp replaced by server timestamp immediataly after creation. Timestamp is neccessary for presentation some but not all widgets in the right order - like messages, but contact list need different mechanisms for sorting
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldInt a_creation_date_timestamp =
      ConditionModelFieldInt(this, 'creation_date_timestamp',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  /// se [_creation_date_timestamp]. Creation date on the server side
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_creation_date_timestamp =
      ConditionModelFieldIntOrNull(this, 'server_creation_date_timestamp',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only);

  /// See [_ultimate_creation_date_timestamp]
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_update_date_timestamp =
      ConditionModelFieldIntOrNull(this, 'update_date_timestamp',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  /// See [_update_date_timestamp]
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_update_date_timestamp =
      ConditionModelFieldIntOrNull(this, 'server_update_date_timestamp',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  ConditionModelCreationDateModel(
    super.conditionModelApp,
    super.conditionModelUser,
    super.defValue, {
    super.appCoreModelClassesCommonDbTableName,
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) {
    if (null == temporaryInitialData['id']) {
      temporaryInitialData['creation_date_timestamp'] =
          createCreationDateTimestamp().time;
    }
    a_creation_date_timestamp.init();
    a_server_creation_date_timestamp.init();
    a_update_date_timestamp.init();
    a_server_update_date_timestamp.init();
  }

  /// Take into account that this method may be used in some unexpected places so make sure all will work fine after any changes to
  ConditionTimeNowMillisecondsSinceEpoch createCreationDateTimestamp() =>
      ConditionModelApp.getTimeNowMillisecondsSinceEpoch();

  @override
  void operator []=(key, value) {
    switch (key) {
      case 'creation_date_timestamp':
        creation_date_timestamp = value;
        break;
      case 'server_creation_date_timestamp':
        server_creation_date_timestamp = value;
        break;
      case 'update_date_timestamp':
        update_date_timestamp = value;
        break;
      case 'server_update_date_timestamp':
        server_update_date_timestamp = value;
        break;
      default:
        super[key] = value;
    }

    //this.defValue[key] = value;
  }

  @protected
  set creation_date_timestamp(int value) =>
      a_creation_date_timestamp.validateAndSet(value);
  int get creation_date_timestamp => defValue['creation_date_timestamp'].value;
  @protected
  set server_creation_date_timestamp(int? value) =>
      a_server_creation_date_timestamp.validateAndSet(value);
  int? get server_creation_date_timestamp =>
      defValue['server_creation_date_timestamp'].value;
  @protected
  set update_date_timestamp(int? value) =>
      a_update_date_timestamp.validateAndSet(value);
  int? get update_date_timestamp => defValue['update_date_timestamp'].value;
  @protected
  set server_update_date_timestamp(int? value) =>
      a_server_update_date_timestamp.validateAndSet(value);
  int? get server_update_date_timestamp =>
      defValue['server_update_date_timestamp'].value;
}

/// Data model (also a Map Object with possible Map properties in tree like structure to json encode!) an object can be saved/updated just by invoking save method, extending a Model class you can create setter which triggers saving automaticaly; cascade removal, etc. you can pase code generators to a constructor if you want to produce full code for f.e. creating database with tables or for creating f.e. mvc code in a backend language like php, c#
@ToDo(
    'Checkout whether addListener() overrides same ancestor class function and change it\'s name if so',
    '')
abstract class ConditionModelWidget extends ConditionModelCreationDateModel {
  /// When navigator with using url one day is implemented: If the value of this->.[url_alias] is null some unfriently standard path will be allowed like id:15, or so. it could be changed - meant to write url by hand maybe for SEO. Dynamic apps don't seem to be especially seo friently.
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_url_alias =
      ConditionModelFieldStringOrNull(this, 'url_alias',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  ConditionModelWidget(
    super.conditionModelApp,
    super.conditionModelUser, // starting from here null value is acceptible this class is extented by ConditionModelUser but the child class is not so the child class does't let null value for this param.
    super.defValue, {
    super.appCoreModelClassesCommonDbTableName,
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) {
    if (false && null == temporaryInitialData['id']) {
      throw Exception(
          'Are you sure it should be here? : see code of ConditionModelWidget class This is probably done differently. remove the method called if not needed.');
      //here i stopped
      // implement it
      final future_returned =
          createNewModelInTheDbAndGetLocalServerModelId(); // forcus on it
    }

    a_url_alias.init();
  }

  @override
  void operator []=(key, value) {
    debugPrint('yerttttt1____' + key);

    switch (key) {
      case 'url_alias':
        url_alias = value;
        break;
      default:
        super[key] = value;
        break;
    }
  }

  set url_alias(String? value) => a_url_alias.validateAndSet(value);
  String? get url_alias => defValue['url_alias'];

  //this.defValue[key] = value;
  // returns eight id fo the model on the local server of the app or null (some db implementations or internet connection lost can cause the model not to receive it's id, see one_time_key... property somewhere)
  @Stub()
  Future<int?> createNewModelInTheDbAndGetLocalServerModelId() {
    return Completer<int?>().future;
  }
}

/// WARNING! Verify how it is needed now. Was it for the json-like non-sql architecture that has been abandoned? The previous descritpion: Let's say: You've just loaded the app in the browser and just after that gotten offline (!!! BASE FOR THE DATA ARCHITECTURE). [ConditionModelId] id pseudo model class - just a [Map]. Example On login you get full model tree (data models of widget) which is a Map of [ConditionModel] extended class models (almost always data models of widgets) - it's a [Map]. A simplified mirror [Map] consisting of [ConditionModelId] class (also [Map]) is created and json encoded as is to LocalStorage. This ConditionModelId Map contains only ids of the widget f.e [5] : [24, 7, 19] widget id 5 has three widgets 24, 7, 19. You change order to [7, 24, 19]. You reload page but from the cashe (explained in readme file) you create final model map (you create app with this [ConditionModelApp](map?)). The final model has our [7, 24, 19] but in this simplified way [ConditionModelEachWidgetModel map, ConditionModelEachWidgetModel map, ConditionModelEachWidgetModel map] where each ConditionModelEachWidgetModel map is link to an object the mentioned original ConditionModel map tree - you don't want to (clone objects and waiste memory right?). Return to our local storage. We changed a widget, or added we now mark a [ConditionModelEachWidgetModel} widget model as changed you have getter for changed property it returns true now (change in comparison to the full widget model tree loaded from cashe in case there is no internet). We again create a new reflection the current working model and store it in localStorage. How? One by one we check each widget model and for local storage use only its id if it hasn't been changed (after change model.change property of the model == true) or added (after addition also true) as you already should know or the model serialized [ConditionModelEachWidgetModel jsonserializedmap]. Again we create all the model tree for the app as already explained - we seek models from the original first model tree created from the casche after offline reload gets links to them in the final model also deserialise new or changed models from localStorage and put them into final model. After we get online we synchronize all the data reload the app if app was successfully reloaded then we can clean the localstorage
@Stub()
@Deprecated('Don\'t know if it is depreciated or no, see the class description')
class ConditionModelId extends ConditionMap {
  ConditionModelId(defValue) : super(defValue) {}
}

abstract class ConditionModelBelongingToContact extends ConditionModelWidget {
  /// Should beDo all relevant checking in constructo or class extending implement these rules: Each non-contact (!) [ConditionModelContact] model must belong to a contact. Remembering that data models render widgets, it is set to null when it is for a non-contact/non-group (! f.e. not a [ConditionModelContact] model but [ConditionModelMessage], [ConditionModelTask] and so on) user's private widget (null), or it is for a contact/group ([ConditionModelContact] model) normal widget that doesn't belong to parent group/contact (contacts are also groups).
  late ConditionModelContact? conditionModelContact;

  // !!! Widget id and server_id are defined in the parent class
  // !!! you don't need to have type_id because this is stored in the model class name - ConditionModelMessage has the information what table the information should be stored in. not the same with [link_type_id] and [server_link_type_id]

  /// It says that f.e. a message/task belongs to a contact or group (for top contact == null), but a message, task always belongs to a contact id. if not null it has group (which technically is also a contact) as parent
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_owner_contact_id =
      ConditionModelFieldIntOrNull(this, 'owner_contact_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// corresponding id of [_owner_contact_id] property but on the server side
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_owner_contact_id =
      ConditionModelFieldIntOrNull(this, 'server_owner_contact_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only);

  ConditionModelBelongingToContact(
    conditionModelApp,
    ConditionModelUser
        conditionModelUser, // no null acceptible this class is not extented by ConditionModelUser but parent class ConditionModelWidget is and it has let's null value here.
    this.conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, defValue,
            appCoreModelClassesCommonDbTableName: 'ConditionModelWidget') {
    a_owner_contact_id.init();
    a_server_owner_contact_id.init();
  }

  @override
  void operator []=(key, value) {
    switch (key) {
      case 'owner_contact_id':
        owner_contact_id = value;
        break;
      case 'server_owner_contact_id':
        server_owner_contact_id = value;
        break;
      default:
        super[key] = value;
    }

    //this.defValue[key] = value;
  }

  set owner_contact_id(int? value) => a_owner_contact_id.validateAndSet(value);
  int? get owner_contact_id => defValue['owner_contact_id'].value;
  set server_owner_contact_id(int? value) =>
      a_server_owner_contact_id.validateAndSet(value);
  int? get server_owner_contact_id => defValue['server_owner_contact_id'].value;
}

/// This class is a base for each widget to be inserted, moved, linked everywhere in the widget tree, also between tabs and logged users. In the class a member like "static ConditionModelFieldInt _id = new [ConditionModelFieldInt]({...});"" means configuration of a model.id property which in a documentation generated via "dart doc" gives you information you need about the field. Question mark "?" like in "ConditionModelFieldInt?" is just by convention to tell you whether a field like _id or _parent_id can be set to null in the model or in the backend DB. The configuration property also is to contain information f.e. what table in a backend sql is to be assigned to the property, what type the property is, what name is to be used in the SQL field, etc. It is also contains information for some backend language (f.e. PHP) code automatic generators. When you set model.id = 10, then a setter set id(...) sets its value like this: this['id'] = id . the same for the getter _id static property is not updated because it doesn't contain a value but a configuration and is also used for information in the generated documentatino as already mentioned. _configuration is handled by models extending this model like ConditionContactModel. configuration (not _configuration) property is a Map which is also to help to organize data in the backend in the SQL - f.e. to decide whether to put the configuration to a separate field as json string of one, and the same table of the model, or to create a different table with each field corrensponding to fields of a model class. Also you can extend models "db" types like [ConditionModelFieldInt] to change them and use in extended model classes, f.e. you need integer max value to be less than typical value to be compatible with some requirements in the backend so an example extended [ConditionModelFieldInt]LimitedRange class type object and it's validator could help you with that that
@Stub()
abstract class ConditionModelEachWidgetModel
    extends ConditionModelBelongingToContact {
  /// See all the [ConditionModel] class's [_parentModel] property's descriptions and related properties. It needed to rememeber that the property [_parentLinkModels] needs to be changed or updated internally, not like someModelObject._parentLinkModels.add(), because adding or removing a parent link model may involve doing additional stuff issuing some notifications use @protected method this.addParentLinkModel() and removeParentLinkModel() if nothing else was later added by a developer. There is all to do like stuff and architecture ideas [_parentModel] can be null or one, but these parent link models can be .length == 0 or more (> 0).
  final Set<ConditionModel> _parentLinkModels = <ConditionModel>{};
  ConditionModelEachWidgetModel?
      _childLinkModel; // not the best naming but it is more intuitive ?
  ConditionModelEachWidgetModel? get childLinkModel => _childLinkModel;

  /// Following pattern set up in [_isModelInTheModelTree], you may see its description. and addChild()/remove (public getter with no underscore). It returns true if at least one model is attached to a [parentLinkModel] model (seek local variable in this class).
  bool _hasModelParentLinkModels = false;

  /// see [_hasModelParentLinkModels]
  get hasModelParentLinkModels => _hasModelParentLinkModels;

  /// !!!
  /// !!! This should be moved to ConditionModel class and should be checkout on any model creation
  ///
  /// that seek a model in ConditionModelApp
  /// However any (!) model must be found in the ConditionModelApp but such a model don't need
  /// to be added to the tree of models it may be a standalone object. As long as it exists
  /// (when there is any working reference to it) it cannot be replaced by a second model (copy/twin).
  /// When these pre-conditions are met then it is trustworthy that _parentLinkModels contains
  /// all models not only some, and possibly the twin object some.
  /// If the model is not found it is considered that it's not been created so far anywhere at all
  ConditionModel? _findExistingModelObject(int id) {
    // Should it be private or @protected?
    // here
    // See the desc. The method should be moved to ConditionModel class, but it
    // was needed here in ConditionModelEachWidgetModel class for the first time.
    // The functionality of it is not however restricted to this class.
    throw Exception('_findExistingModelObject is not implemented yet');
  }

  /// See the [_parentLinkModels] property description.
  @protected
  _addParentLinkModel(ConditionModelEachWidgetModel parentLinkModel) {
    // Much of what is here is patterned on addChild method.
    // this class ConditionModelEachWidgetModel can have parentLinkModels
    // and at the same time it can have one child in a separate variable if it has link_id != null
    // Assuming _findExistingModelObject is in the constructor we don\'t bother
    //here // And assuming that: Most probably you must compare if childModel has the same conditionModelApp
    // as _parentModel you don't need it for removeChild the child was ok when it was added

    if (parentLinkModel.isRetired) {
      throw Exception(
          '_addParentLinkModel method: The param parentLinkModel model cannot be added if it already has retired. Such model cannot be used and be unlinked - there should be no references left by the third-party programmer. The Condition library/framework also internally removes the remaining links as soon as it is able to.');
    } else if (parentLinkModel.isRetireMethodBodyAlreadyBeingExecuted ||
        parentLinkModel.isRetirementProcessPending) {
      throw Exception(
          '_addParentLinkModel method: The param parentLinkModel model cannot be added when it is in the process of retirement. Add the model if it is not retired and the process triggered by the retire method finished with false result (more properties can be found to help, possibly synchronous too, but the more async completer/future returned by the retire method may be enough.)');
    }

    if (isRetired) {
      throw Exception(
          '_addParentLinkModel method: The child hosting its parentLinkModel model cannot accept it\'s parentLinkModel if the child already has retired. Such model cannot be used and be unlinked - there should be no references left by the third-party programmer. The Condition library/framework also internally removes the remaining links as soon as it is able to.');
    } else if (isRetireMethodBodyAlreadyBeingExecuted ||
        isRetirementProcessPending) {
      throw Exception(
          '_addParentLinkModel method: The child hosting its parentLinkModel model cannot accept it\'s parentLinkModel when the child is in the process of retirement. Add the model if it is not retired and the process triggered by the retire method finished with false result (more properties can be found to help, possibly synchronous too, but the more async completer/future returned by the retire method may be enough.)');
    }

    //here// [To do:] there is link "parent" models property - do something similar
    // when you have a link "parent/container" model and attach the linked model
    // to the link model (a property with list of parent/container link models) you add
    // to the property another "parent/container" model to the list
    //here // and for this only one object of a model id can exist in the tree NOT IMPLEMENTED
    if (!identical(conditionModelApp, parentLinkModel.conditionModelApp)) {
      throw Exception(
          '_addParentLinkModel() method: You can only use two model belonging to The same [ConditionModelApp] - conditionModelApp property of [ConditionModelIdAndOneTimeInsertionKeyModel] (that was the name of the class at the time of writing this exception message)');
    } else if (_parentLinkModels.contains(parentLinkModel)) {
      throw Exception(
          '_addParentLinkModel() method: You cannot attempt to add the same parentModel object again to the _parentLinkModels list (Set precisely)). It implies wrong library construction or some developer\'s wrong piece of code.');
    }

    _parentLinkModels.add(parentLinkModel);
    parentLinkModel._childLinkModel = this;
    _hasModelParentLinkModels = true;
    parentLinkModel._changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustReceviedChildModel(
            parentLinkModel, this));
    // Warning !!! Don't change the order of TWO stream events BELOW (_changesStreamController)
    // because the conditionModelApp object have all models streams and it reacts synchronously
    // to the [ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel]
    // NOT TO [ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustReceviedChildModel]
    // DANKE SHOEN! ET XIE, XIE.
    _changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel(
            parentLinkModel, this));
  }

  /// Se retire, See the [_parentLinkModels] property description.
  @protected
  _removeParentLinkModel(ConditionModelEachWidgetModel parentLinkModel) {
    // think of this method also in context of retire() method here and in different other places
    // like in the ConditionModel class
    if (!_parentLinkModels.contains(parentLinkModel)) {
      throw Exception(
          '_addParentLinkModel() method: You cannot attempt to remove a parentModel object that is not on the list (Set precisely). It implies wrong library construction or some developer\'s wrong piece of code.');
    }
    parentLinkModel._childLinkModel = null;
    _parentLinkModels.remove(parentLinkModel);
    if (_parentLinkModels.isEmpty) _hasModelParentLinkModels = false;
    // Warning !!! Don't change the order of TWO stream events BELOW (_changesStreamController)
    // because the conditionModelApp object have all models streams and it reacts synchronously
    // to the [ConditionModelInfoEventModelTreeOperationChildModelHasJustHadHisParentLinkModelRemoved]
    // NOT TO [ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustHadHisChildModelRemoved]
    // DANKE SHOEN! ET XIE, XIE.
    parentLinkModel._changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationParentLinkModelHasJustHadHisChildModelRemoved(
            parentLinkModel, this));
    _changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationChildModelHasJustHadHisParentLinkModelRemoved(
            parentLinkModel, this));
  }

  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldInt a_model_type_id = ConditionModelFieldInt(
      this, 'model_type_id',
      propertySynchronisation:
          ConditionModelFieldDatabaseSynchronisationType.app_only,
      isFinal: true);

  // !!! Widget id and server_id are defined in the parent class
  // !!! you don't need to have type_id because this is stored in the model class name - ConditionModelMessage has the information what table the information should be stored in. not the same with [link_type_id] and [server_link_type_id]

  /// Deprecated. To be removed later from db schema also. See @Deprecated annotation. The what a given type id represents you can recognize from [_ids_oa_model_class_names]. Also see [_link_id], [_server_link_type_id] [_server_link_id], desc - if type = 0 it is a contact [ConditionModelContact], 1 - message [ConditionModelMessage], 2 ... , etc.
  /// Older, i noticed it back then already: Howerver you don't need to have application side type_id because this is stored in the model class name - f.e. [ConditionModelMessage] has the information what table the information should be stored in. not the same with [link_type_id] and [server_link_type_id]
  @BothAppicationAndServerSideModelProperty()
  @protected
  @Deprecated(
      'Link is link no need to have this information, the model will have its linked model object attached. There it has info about what it is')
  late final ConditionModelFieldIntOrNull a_link_type_id =
      ConditionModelFieldIntOrNull(this, 'link_type_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  /// See also [_link_type_id] it is a link to another widget from you app widget ids, so the widget linked to will display here (each widget must fully work independently from a place in a tree, because it can be by linkage placed in couple of places at the same time with its children/descendants)
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_link_id =
      ConditionModelFieldIntOrNull(this, 'link_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// see [_link_id] each link_id has it's equivalent property on the server side
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_link_id =
      ConditionModelFieldIntOrNull(this, 'server_link_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only);

  // ----------------------------------------------------

  /// title - for example a contact widget/model it can be treated as a name you gave to a contact, apart from name from the server is in the ConditionModelContact
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_title =
      ConditionModelFieldStringOrNull(this, 'title',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  /// Description
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_description =
      ConditionModelFieldStringOrNull(this, 'description',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  /// Configuration, watch out this is strictly geared with configuration property. Yet to be implemented
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_configuration =
      ConditionModelFieldStringOrNull(this, 'configuration',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  /// See also a_configuration desc. Each widget has it's custom configuration which is a [Map], f.e. a message has it's message text
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelConfigurationModel configuration =
      ConditionModelConfigurationModel(this, {});

  ConditionModelEachWidgetModel(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    if (null == temporaryInitialData['id']) {
      temporaryInitialData['model_type_id'] = getModelTypeId();
    }

    a_model_type_id.init();
    a_link_type_id.init();
    a_link_id.init();
    a_server_link_id.init();
    a_title.init();
    a_description.init();
    a_configuration.init();
  }

  int getModelTypeId() {
    var i = 0;
    for (var enumValue in ConditionModelClasses.values) {
      i++;
      String className =
          enumValue.toString().replaceFirst('ConditionModelClasses.', '');
      if (className == runtimeType.toString()) {
        return i;
      }
    }
    // Always above 0 bu so that there is int returned you need to tell the dart it will be int returned
    return 0;
  }

  @override
  void operator []=(key, value) {
    switch (key) {
      case 'model_type_id':
        model_type_id = value;
        break;

      case 'link_type_id':
        link_type_id = value;
        break;
      case 'link_id':
        link_id = value;
        break;
      case 'server_link_id':
        server_link_id = value;
        break;
      case 'title':
        title = value;
        break;
      case 'description':
        description = value;
        break;
      /*case 'configuration':
        configuration = value;
        break;*/
      default:
        super[key] = value;
    }

    //this.defValue[key] = value;
  }

  @protected
  set model_type_id(int value) => a_model_type_id.validateAndSet(value);
  int get model_type_id => defValue['model_type_id'].value;

  @protected
  @Deprecated('See a_link_type_id property description')
  set link_type_id(int? value) => a_link_type_id.validateAndSet(value);
  @Deprecated('See a_link_type_id property description')
  int? get link_type_id => defValue['link_type_id'].value;
  @protected
  set link_id(int? value) => a_link_id.validateAndSet(value);
  int? get link_id => defValue['link_id'].value;
  @protected
  set server_link_id(int? value) => a_server_link_id.validateAndSet(value);
  int? get server_link_id => defValue['server_link_id'].value;
  set title(String? value) => a_title.validateAndSet(value);
  String? get title => defValue['title'].value;
  set description(String? value) => a_description.validateAndSet(value);
  String? get description => defValue['description'].value;

  /// this variable has it's own validators remember the variable is also a Map to be easily encoded via [jsonEncode()];
  /*@protected late final set configuration(ConditionModelConfigurationModel value) {
    defValue['configuration'] = value;
    changed = true;
  }*/

/*  ConditionModelConfigurationModel get configuration {
    return this.defValue['configuration'];
  }*/
}

/// In the architecture changed and this is no longer used. ConditionModelEachWidgetModel
/*class ConditionModelEachWidgetBelongingToAContactModel
    extends ConditionModelEachWidgetModel {
  /// Should beDo all relevant checking in constructo or class extending implement these rules: Each non-contact (!) [ConditionModelContact] model must belong to a contact. Remembering that data models render widgets, it is set to null when it is for a non-contact/non-group (! f.e. not a [ConditionModelContact] model but [ConditionModelMessage], [ConditionModelTask] and so on) user's private widget (null), or it is for a contact/group ([ConditionModelContact] model) normal widget that doesn't belong to parent group/contact (contacts are also groups).
  late ConditionModelContact conditionModelContact;

  /// Also see description for [conditionModelContact] property. Each widget belongs to a contact id where each contact is at the same time a group not neccessary having children
  @AppicationSideModelProperty()
  late ConditionModelFieldIntOrNull _contact_id =
      new ConditionModelFieldIntOrNull(this,
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /* DON'T REMOVE COMMENT
  THE IDEA BELOW IS REPLACED WITH DIFFERENT DATA ARCHITECTURE see README.md - [ConditionModelUser] have such _local... key and something more
  /// read also [_local_network_contact_key] (dropped property see _local_network_contact_key). If int? value is null - normal contact, if 1 device to device contact, if 2- both server first and also device to device - because in the case of lack of the internet you could connect to a device directly - read about the mentioned second property.
  @BothAppicationAndServerSideModelProperty()
  @Stub()
  late ConditionModelFieldIntOrNull _type_oa_contact =
      new ConditionModelFieldIntOrNull(this,
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);
  */
  /* DON'T REMOVE COMMENT
  THE IDEA BELOW IS REPLACED WITH DIFFERENT DATA ARCHITECTURE see README.md - [ConditionModelUser] have such _local... key and something more
  /// Read also [_type_of_contact] If there is no internet at all for long time: Signalling a possibly complicated idea but very important so read it all. All written next includes video/voice transmission also, and if you connect to a second device this device can connect to a third and the third is to be able to connect to your (first) device, and the forth in a tree and so forth, but you put burden on the second device, you care only of the directly connected devices to you.  If not null with this long unique key you can communicate with another defice you are connected via bluetooth, outside wi-fi or wifi in your phone, etc. This contact doesn't have a corresponding user on the server - it is local but all messages/tasks are stored on the server independently from you, and the second device does independently the same. Not an easy idea to implement. You can assign this contact to a group of regular contacts, etc., but you can take advantage of this contact having direct connection with it's device using this key. However, when internet connection is possible (remote area,), the contacts are to be recognized between themselves, and communication is to be possible also via internet. Only after having this functionality you can extend it in a way that you can connect two contact directly based on contacts that are on the internet.
  @BothAppicationAndServerSideModelProperty()
  @Stub()
  late ConditionModelFieldStringOrNull _local_network_contact_key =
      ConditionModelFieldStringOrNull(this,
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null
  */
  /// Also see description for [conditionModelContact] property. Each widget belongs to a contact id where each contact is at the same time a group not neccessary having children
  @ServerSideModelProperty()
  late ConditionModelFieldIntOrNull _server_contact_id =
      new ConditionModelFieldIntOrNull(this,
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only);

  ConditionModelEachWidgetBelongingToAContactModel(
      ConditionModelApp conditionModelApp,
      ConditionModelUser conditionModelUser,
      ConditionModelContact this.conditionModelContact,
      defValue)
      : super(conditionModelApp, conditionModelUser, defValue) {}

  @override
  void operator []=(key, value) {
    switch (key) {
      case 'contact_id':
        this.user_id = value;
        break;
      case 'server_contact_id':
        this.parent_id = value;
        break;
      default:
        super[key] = value;
    }

    //this.defValue[key] = value;
  }

  set contact_id(int value) {
    if (this._contact_id.validateAndSet(value, 'fieldNme')) {
      this.defValue['contact_id'] = value;
      changed = true;
    } else
      throw ConditionModelFieldIntException(
          this._contact_id._validation_exception_message);
  }

  int get contact_id {
    return this.defValue['contact_id'];
  }

  set server_contact_id(int? value) {
    if (this._server_contact_id.validateAndSet(value, 'fieldNme')) {
      this.defValue['server_contact_id'] = value;
      changed = true;
    } else
      throw ConditionModelFieldIntException(
          this._server_contact_id._validation_exception_message);
  }

  int? get server_contact_id {
    return this.defValue['server_contact_id'];
  }
}
*/

// [it's ok now but To do:] unfortunately ConditionModelContact while technically is but in reality is not a ConditionModelBelongingToContact widget. It is accepted this way. Check out if there is a possibility to use mixing. For now in methods like addChild the condition is checked not for [ConditionModelBelongingToContact] but for [ConditionModelContact] class
@Stub()
class ConditionModelContact extends ConditionModelEachWidgetModel
    implements ConditionModelCompleteModel {
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_contact_user_id =
      ConditionModelFieldIntOrNull(this, 'contact_user_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// see [_link_id] each link_id has it's equivalent property on the server side
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_server_contact_user_id =
      ConditionModelFieldIntOrNull(this, 'server_contact_user_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only);

  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_contact_accepted_invitation =
      ConditionModelFieldIntOrNull(this, 'contact_accepted_invitation',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized);

  /// e-mail address field. contact with no e-mail nor phone number is a group to make matters simple, and this is left for this models's widget how to interpret it.
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_contact_e_mail =
      ConditionModelFieldStringOrNull(this, 'contact_e_mail',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  /// phone number field as you can see. contact with no e-mail nor phone number is a group to make matters simple, and this is left for this models's widget how to interpret it.
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_contact_phone_number =
      ConditionModelFieldStringOrNull(this, 'contact_phone_number',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  /// See more description of similar fields _local_server_key, _local_server_login in the [ContactModelUser] class
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_contact_local_server_key =
      ConditionModelFieldStringOrNull(this, 'contact_local_server_key',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  /// phone number field as you can see. contact with no e-mail nor phone number is a group to make matters simple, and this is left for this models's widget how to interpret it.
  @BothAppicationAndServerSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_contact_local_server_login =
      ConditionModelFieldStringOrNull(this, 'contact_local_server_login',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  /*
  You may use the title field or configuration field instead
  /// This is obtained from the server
  @BothAppicationAndServerSideModelProperty()
  late ConditionModelFieldStringOrNull _user_name =
      ConditionModelFieldStringOrNull(
          this,
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null
*/
  ConditionModelContact(
    conditionModelApp,
    conditionModelUser,
    // conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, null, defValue) {
    a_contact_user_id.init();
    a_server_contact_user_id.init();
    a_contact_accepted_invitation.init();
    a_contact_e_mail.init();
    a_contact_phone_number.init();
    a_contact_local_server_key.init();
    a_contact_local_server_login.init();
    initCompleteModel();
  }

  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }

  @override
  void operator []=(key, value) {
    switch (key) {
      case 'server_contact_user_id':
        server_contact_user_id = value;
        break;
      case 'contact_user_id':
        contact_user_id = value;
        break;
      case 'contact_accepted_invitation':
        contact_accepted_invitation = value;
        break;

      case 'contact_e_mail':
        contact_e_mail = value;
        break;
      case 'contact_phone_number':
        contact_phone_number = value;
        break;
      case 'contact_local_server_key':
        contact_local_server_key = value;
        break;
      case 'contact_local_server_login':
        contact_local_server_login = value;
        break;
      default:
        super[key] = value;
    }
  }

  set server_contact_user_id(int? value) =>
      a_server_contact_user_id.validateAndSet(value);
  int? get server_contact_user_id => defValue['server_contact_user_id'].value;

  set contact_user_id(int? value) => a_contact_user_id.validateAndSet(value);
  int? get contact_user_id => defValue['contact_user_id'].value;

  set contact_accepted_invitation(int? value) =>
      a_contact_accepted_invitation.validateAndSet(value);
  int? get contact_accepted_invitation =>
      defValue['contact_accepted_invitation'].value;

  set contact_e_mail(String? value) => a_contact_e_mail.validateAndSet(value);
  String? get contact_e_mail => defValue['contact_e_mail'].value;
  set contact_phone_number(String? value) =>
      a_contact_phone_number.validateAndSet(value);
  String? get contact_phone_number => defValue['contact_phone_number'].value;
  @protected
  set contact_local_server_key(String? value) =>
      a_contact_local_server_key.validateAndSet(value);
  String? get contact_local_server_key =>
      defValue['contact_local_server_key'].value;
  @protected
  set contact_local_server_login(String? value) =>
      a_contact_local_server_login.validateAndSet(value);
  String? get contact_local_server_login =>
      defValue['contact_local_server_login'].value;
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelMessage extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelMessage(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// Pretty much autmomatically organized by the app based on the contacts belonging to a group/contact (contact is also a group)
@Stub()
class ConditionModelVideoConference extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelVideoConference(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelTask extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelTask(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionTripAndFitness extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionTripAndFitness(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelURLTicker extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelURLTicker(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelReadingRoom extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelReadingRoom(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelWebPage extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelWebPage(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelShop extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelShop(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelProgramming extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelProgramming(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

/// For pattern of defining setters, getters, overriding operator []= see a class [ConditionModelContact] which (what important) extends [ConditionModelEachWidgetModel]
@Stub()
class ConditionModelPodcasting extends ConditionModelEachWidgetModel
    implements
        ConditionModelCompleteModel /*ConditionModelEachWidgetBelongingToAContactModel*/ {
  ConditionModelPodcasting(
    conditionModelApp,
    conditionModelUser,
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
    super.autoRestoreMyChildren,
    super.isAllModelDataProvidedViaConstructor,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    //initModel();
    super
        .initCompleteModel(); // which in turn will trigger the initModel method
  }
}

// These core class names must be in equal order with what is in the db ConditionModelClassess table. Anything here is compatible with ConditionModelClassess table in the app sql db-s. Any widget is of type listed here - it means (if not changed in the meantime) f.e. that in the db ConditionModelContact model/widget in db in a table named ConditionModelWidget in the column model_type_id has value 1 and f.e. ConditionModelTask has value 4 - if 4 it is a task, messagaes is of course 2
enum ConditionModelClasses<ConditionModelEachWidgetModel> {
  ConditionModelContact,
  ConditionModelMessage,
  ConditionModelVideoConference,
  ConditionModelTask,
  ConditionTripAndFitness,
  ConditionModelURLTicker,
  ConditionModelReadingRoom,
  ConditionModelWebPage,
  ConditionModelShop,
  ConditionModelProgramming,
  ConditionModelPodcasting,
}

/// Read also [getTimeNowMillisecondsSinceEpoch]() of [ConditionModelApp] class - may be important. This object has time now property - milliseconds since epoch. However in time it will check if an internal clock changed and will contain other properties to indicate that there is a problem, for this there may be static properties also to be used by object instance properties.
class ConditionTimeNowMillisecondsSinceEpoch {
  /// Do not use... It means you can but: This is not to be used normally use [referenceTime] instead because it contains possibly corrected time when errors related to time occured an were corrected afterwards.
  static final int referenceTimeWhenTheLibraryWasLoaded =
      DateTime.now().millisecondsSinceEpoch;

  /// this is a static property that is to be compared with object instance [time] property and this is used by all standard methods, f.e. [isTimeLaterThanReferenceTime]()
  static final int referenceTime =
      referenceTimeWhenTheLibraryWasLoaded; // to be exactly the same at the beginning at least not possibly one millisecond different;

  final int time = DateTime.now().millisecondsSinceEpoch;

  bool isTimeLaterThanTheReferenceTime() => time > referenceTime;
  bool isTimeLaterOrEqualThanTheReferenceTime() => time >= referenceTime;

  @override
  toString() => time.toString();

  @override
  bool operator ==(dynamic other) {
    if (other is ConditionTimeNowMillisecondsSinceEpoch) {
      return time == other.time;
    } else if (other is int) {
      return time == other;
    } else {
      throw Exception(
          'Time you are trying to compare is neither [int] nor [ConditionTimeNowMillisecondsSinceEpoch] instance');
    }
  }

  /// Added because of this recommendation https://dart.dev/tools/linter-rules/hash_and_equals the overriden "==" operator is no longer marked by linter so the editor is more happy :)
  @override
  int get hashCode => time.hashCode;

  bool operator >(dynamic other) {
    if (other is ConditionTimeNowMillisecondsSinceEpoch) {
      return time > other.time;
    } else if (other is int) {
      return time > other;
    } else {
      throw Exception(
          'Time you are trying to compare is neither [int] nor [ConditionTimeNowMillisecondsSinceEpoch] instance');
    }
  }

  bool operator <(dynamic other) {
    if (other is ConditionTimeNowMillisecondsSinceEpoch) {
      return time < other.time;
    } else if (other is int) {
      return time < other;
    } else {
      throw Exception(
          'Time you are trying to compare is neither [int] nor [ConditionTimeNowMillisecondsSinceEpoch] instance');
    }
  }

  bool operator >=(dynamic other) {
    if (other is ConditionTimeNowMillisecondsSinceEpoch) {
      return time >= other.time;
    } else if (other is int) {
      return time >= other;
    } else {
      throw Exception(
          'Time you are trying to compare is neither [int] nor [ConditionTimeNowMillisecondsSinceEpoch] instance');
    }
  }

  bool operator <=(dynamic other) {
    if (other is ConditionTimeNowMillisecondsSinceEpoch) {
      return time <= other.time;
    } else if (other is int) {
      return time <= other;
    } else {
      throw Exception(
          'Time you are trying to compare is neither [int] nor [ConditionTimeNowMillisecondsSinceEpoch] instance');
    }
  }
}

/// More on this in [ConditionModelParentIdModel] also similar exceptions are thrown (the exception classes definitions still below?) in relatiion to [ConditionModelApp] [ConditionModelApps] classes to avoid having two separate instances of the same app (app model).
class ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance
    implements Exception {
  final ConditionModelParentIdModel anotherModelWithTheSameId;
  final String msg =
      'ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance exception: A failed attempt to create a ConditionModelParentIdModel object failed because an id of the model was supplied in the constructor but another model object with the same id has been created and attached to one of the special sets/lists of the conditionModelApp object. However this exception object has anotherModelWithTheSameId property containing another model with the same id. So if you catch this exception you can replace the failed model object with anotherModelWithTheSameId, f.e. by assigning to a variable you possibly wanted to use hoping that the excepiton won\'t be thrown. Once upon a time ... :)';
  ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance(
      this.anotherModelWithTheSameId);

  @MustBeImplemented()
  String toString() => msg;
}

/// Twin [ConditionModelAppExceptionDuplicateSettingsConditionDataManagementDriverLocalServerDriverIsAlreadyOnTheConditionModelAppsClassStaticSet] and related [ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance] exception of [ConditionModelParentIdModel]. (the exception class definition still above?) in relatiion to [ConditionModelApp] [ConditionModelApps] classes to avoid having two separate instances of the same app (app model).
class ConditionModelAppExceptionAnotherConditionModelAppWithDuplicateConditionDataManagementLocalServerDriverSettingsIsHowCanIPutItPolitelyAlreadyOnTheConditionModelAppsClassStaticSetIsntIt
    implements Exception {
  final ConditionModelApp duplicateAppModel;
  final String msg =
      'ConditionModelAppExceptionAnotherConditionModelAppWithDuplicateConditionDataManagementLocalServerDriverSettingsIsHowCanIPutItPolitelyAlreadyOnTheConditionModelAppsClassStaticSetIsntIt exception: A failed attempt to create a ConditionModelApp object failed because an duplicate [ConditionDataManagement] local server driver in use has been found. More on that in [ConditionModelApps] class with special use uniqie apps and unique drivers properties. Notice that this Exception object contains duplicateAppModel property with the app considered duplicate found and you can catch the exception and use the app model instead of that you tried to create that cause this exception to be thrown right now.';
  ConditionModelAppExceptionAnotherConditionModelAppWithDuplicateConditionDataManagementLocalServerDriverSettingsIsHowCanIPutItPolitelyAlreadyOnTheConditionModelAppsClassStaticSetIsntIt(
      this.duplicateAppModel);

  @MustBeImplemented()
  String toString() => msg;
}

/// Twin [ConditionModelAppExceptionAnotherConditionModelAppWithDuplicateConditionDataManagementLocalServerDriverSettingsIsHowCanIPutItPolitelyAlreadyOnTheConditionModelAppsClassStaticSetIsntIt] and related [ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance] exception of [ConditionModelParentIdModel]. (the exception class definition still above?) in relatiion to [ConditionModelApp] [ConditionModelApps] classes to avoid having two separate instances of the same app (app model).
class ConditionModelAppExceptionDuplicateSettingsConditionDataManagementDriverLocalServerDriverIsAlreadyOnTheConditionModelAppsClassStaticSet
    implements Exception {
  final ConditionDataManagementDriver duplicateLocalServerDriver;
  final String msg =
      'ConditionModelAppExceptionDuplicateSettingsConditionDataManagementDriverLocalServerDriverIsAlreadyOnTheConditionModelAppsClassStaticSet exception: A failed attempt to create a ConditionModelApp object (or something else ?) failed because an duplicate [ConditionDataManagement] local server driver in use has been found. More on that in [ConditionModelApps] class with special use uniqie apps and unique drivers properties. Notice that this Exception object contains duplicateLocalServerDriver property with the app considered duplicate found and you can catch the exception and use the driver instead of that you tried to create that cause this exception to be thrown right now. However the Condition general library may prevent you from using the driver found, expecially to create new [ConditionModelApp] object. So possibly limited benefit.';
  ConditionModelAppExceptionDuplicateSettingsConditionDataManagementDriverLocalServerDriverIsAlreadyOnTheConditionModelAppsClassStaticSet(
      this.duplicateLocalServerDriver);

  @MustBeImplemented()
  String toString() => msg;
}

/// Used especially in [ConditionModelApp] class' [hangOnModelOperationIfNeeded]() method and with connetion with with model retire() method (and more) which all is related to releasing resources taken by not used models and See comnments in the enum definition body. The most important may be globalServerWrite or more precise ...Create/Update/Delete while these operations may last long and prevent model from being retired while local server or other operations seems kind of immediate even if asynchronous on event loop, Some of the items may never be used this is initial list. See what uses it in [ConditionModelApp] class and relevant descriptions
enum ConditionModelClassesTypeOfSucpendableOperation {
  any,
  localServer, // informally this would involve reading that were not in the enum list when this comment was written
  localServerWrite, // create and update, delete are more precise
  localServerCreate,
  localServerUpdate,
  localServerDelete,
  globalServer, // informally this would involve reading that were not in the enum list when this comment was written
  globalServerWrite, // possibly the most important item involves create and update, delete are more precise
  globalServerCreate, // see globalServerWrite
  globalServerUpdate, // see globalServerWrite
  globalServerDelete, // see globalServerWrite
}

/// Used used by [_addAppCycleMethod], [_removeAppCycleMethod] and [_cyclicalActionsOfAppModelsTimer] of [ConditionModelApps]
enum ConditionModelCycleCallEvent {
  slowInternetConnection,
  globalServerNotResponding,
  globalServerOverloadedAndSlowResponding,
}

/// A function Sygnature used by [_addAppCycleMethod] method or [_removeAppCycleMethod] of [CondiitionModelApps], skipThisCycle param (probably cannot be ignored but it is a developing story) is a strong request that the app doesn't perform any new cyclical action, especially that related to the global server operations; cycleCallEvents contain additional information not dependent on skipThisCycle, the information is like a stream event but without stream. The information may be that the internet connection is slow, or the global server not available or is overloaded, etc.
/// For now it returns future to imply possibly that another call is allowed when the future is completed.
/// TODO: Make sure the planned future is completed with error when app object looses it's last pointer.
typedef ConditionModelAppAppCycleFunction = Future<void> Function(
    bool skipThisCycle, Set<ConditionModelCycleCallEvent>? cycleCallEvents);

// [To do or done:] not part of /// doc warning : doNotAddAppToTheGlobalAppList == true would allow for two separate app objets which is not allowed, alternatively you could register some standard settings table prefixes at the core because you cannot use two separate yet twin apps
// [To do or done:] not part of /// doc to do: stream never stop existing when it has subscriber, and possibly more so stream = null won't destroy the stream object ant won't release any data. The same is with future you must address this in the retire method SYNCHRONOUSLY.
/// Important info is in the [ConditionModelApp] class [doNotAddAppToTheGlobalAppList] property, read also about comparing two driver objects in [ConditionDataManagementDriver] class description. By the way: Interesting idea: SnapApps. To the point: This stores links to the non-removable app model and each app model is added automatically when Constructor has its default param [doNotAddAppToTheGlobalAppList] = false. Thanks to this option when there is sort of "last" pointer/variable to the app model lost in the entire general applicatoin code the permanent acutal last link is stored using this static [permanentAppsHolder] property. While models are added internally you can also notice that models are added using [addApp] method of the [permanentAppsHolder] property and cannot be removed. No more advanced solution is needed in like-99,5% of possible usage. So if you need a permantently removable apps you just need to set [doNotAddAppToTheGlobalAppList] = true. If the sort-of "last" link is lost it is at the same time the last actual link. this should cascadingly remove and destroy all related models and objects attached to the [conditionModelApp] instance. So sucha a permanently removable app needs to work with some custom databases both global and local server, that are ready to hold some non-permanent data and remove them permanently after a short period of time like day or time of current session. While non-permanent app solution is best for only reading data from the global server some problems while interrupting writing data to the global server might have to be taken under condideration when the last link to the "snap" app is lost
/// Important info is in the [ConditionModelApp] [doNotAddAppToTheGlobalAppList] property. This class is a helper class to the [ConditionModelApps] which in unremovable static property holds this object with unremovable _apps property to which you can only add, not remove [ConditionModelApp] models.
class ConditionModelApps {
  /// Good to read the class description so not to repeat itself. A unique app means that there isn't another app object with the same local server [ConditionDataManagement] driver settings object.
  static final Set<ConditionModelApp> _allAndUniqueApps = {};

  // issue if not more of them: each item has    ConditionModelApp? conditionModelApp, which makes there is always last pointer left here in this property and no finalizer is triggered and the local driver of the no app object not belonging to _allAndUniqueApps is never removed. You probably must try to remove the app property and from possible other used objects there that might store them permanently.
  /// You can create completely independent driver object but is not recommended to use have it outside app object to keep data integrity withing models. Good to read the class description so not to repeat itself. This property is for situations where you want a [ConditionModelApp] object not to be in [_allAndUniqueApps] and to be destroyed when the last known to you pointer to it turns f.e. to null. However only one app and one local server driver is allowed in the entire app code. So in this property drivers of the apps not in the [_allAndUniqueApps] are stored. When the last pointer to such an app is lost a [Finalizer] starts playing it's role and removes the driver from the list. When a unique app or "independent/free" driver is removed a new driver with it's settings can be created in this or other way. A unique app means that there isn't another local [ConditionDataManagement] driver object with the same local server settings.
  static final Set<ConditionDataManagementDriver>
      _uniqueLocalDriversOfAppsNotInTheAllAndUniqueApps = {};

  // READ THIS ONE FIRST The point is you don't want two duplicate apps (two different app objects with the same driver settings)
  // And some exclamation point comments seem to forget about it. So two the SAME SETTING DRIVERS means TWO THE DUPLICATE APPS.
  /// Apps like in [ConditionDataManagementDriver] class or drivers can be stored making imposible to unlink them
  static final Finalizer<ConditionDataManagementDriver>
      _appNotInTheAllAndUniqueAppsFinalizer = Finalizer((localServerDriver) {
    _uniqueLocalDriversOfAppsNotInTheAllAndUniqueApps.remove(localServerDriver);
  });

  /// See also [maxId]. Try to establish a multiplatform int for IDs of regular models and possibly app models. For now it is based on https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MIN_SAFE_INTEGER
  static const int minId = -9007199254740991;

  /// like [minId] but based on https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER
  static const int maxId = 9007199254740992;

  /// Each app model object (not the same but similar in [ConditionModelApp] class) in the global scope app area has final unique id (uniqie globally). Some objects are finalized with [Finalizer] class object. So to trigger the finalizer of a removed object you cannot have any reference to them left, but you have to perform some actions on objects related to them, but not having any reference to the finalized object; so you need to find them somehow and this unique id is used for this. Apart from that [ConditionDataManagementDriver]s have it too. See [ConditionModelApps].
  static int _appModelUniqueIdCounter = ConditionModelApps.minId;
  static int get appModelUniqueIdCounter => _appModelUniqueIdCounter;
  static int _increaseByOneAppModelUniqueIdCounterAndGetItsValue() =>
      ++_appModelUniqueIdCounter;

  /// Similar to [_appModelUniqueIdCounter] and this property also doc-described there too.
  static int _driverUniqueIdCounter = ConditionModelApps.minId;
  static int get driverUniqueIdCounter => _driverUniqueIdCounter;
  static int _increaseByOneDriverUniqueIdCounterAndGetItsValue() =>
      ++_driverUniqueIdCounter;

  // ==================================================================================
  // START TO MANAGEMENT ON SOME CYCLICAL ASPECTS OF APP MODEL OBJECTS THAT MIGHT HAVE IMPACT ON "SECONDARY" MEMORY "LEAKS"
  // ==================================================================================
  // TODO: INFO START
  // 1. we need some global timer to perform cyclical stuff like:
  //   checking out for updates of models from global server
  // 2. a: Also we need to create a userProfiles with an example remote user that creates a different user
  //       on -a debugging -a initDbStage=2 -a userProfile=2, 1 is default
  //    b: on initDbStage=2 it creates a contact that is automatically read/added by a recipient user in userProfile=1
  //    c: on stage 3 a message is also sent/read.
  // All simplified - not implementing now much
  // For this you have use cyclical checking based on last check for the app id, we may need to check out changes to contact list first probably
  // And the global timer here is needed because each endless not cancelled timers run endlessely
  // So many things must be regulated from here, also stuff like low bandwidth, locking new global server actions of a particular app model object.
  //
  // More details should be in the following properties/methods
  // TODO: INFO END
  // Good to remember: a couple of objectss can be attached to one finalizer can be attached to one object. You can detach finalizer from objects
  // FIXME: TIMER LEAKS! NOT TO FORGET TO MAKE ALL ENDLESS CYCLICAL TIMERS CANCELABLE - each not finished timer lives even you have no reference to anything related to it so you have to have a property enabling you to cancel the timer when object is retired, disposed, destroyed, or looses the last pointer to it.

  // ==================================================================================
  // END TO MANAGEMENT ON SOME CYCLICAL ASPECTS OF APP MODEL OBJECTS THAT MIGHT HAVE IMPACT ON "SECONDARY" MEMORY "LEAKS"
  // ==================================================================================

  // TODO: NOW: I have an idea of having a separate class with "unremovable" properties that exist after the last pointer to the app is removed
  // The separate class object would perform unleaking actions on it's properties. Still much to think over.
  // Probably similar for non-ConditionModelApp but those regular ConditionModel objects.

  /// Read the [_addAppCycleMethod] description.
  static final Set<ConditionModelAppAppCycleFunction> _appCycyleMethods = {};

  /// FIXME: Stupid question and do a thorough research: if an app lost last pointer to it is it's method here [_appCycyleMethods] causing any hidden pointer to be kept? Logically should be: no. The method might be or not in a property of the app - whatever (not means created on spot as anonymous function).
  static final Finalizer<ConditionModelAppAppCycleFunction>
      _appCyclicalCallFinishFinalizer =
      Finalizer((conditionModelAppAppCycleFunction) {
    debugPrint(
        'conditionModelAppAppCycleFunction is to be removed from _appCycyleMethods (now ${_appCycyleMethods.length} these methods in total) info from toString:. $conditionModelAppAppCycleFunction');
    ConditionModelApps._appCycyleMethods
        .remove(conditionModelAppAppCycleFunction);
    debugPrint(
        'conditionModelAppAppCycleFunction has been removed now the number of these methods is:. now ${_appCycyleMethods.length} methods in total');
  });

  /// Added on [ConditionModelApp] object construction quite independent from [_allAndUniqueApps] Set which is among other things to avoing having two the same settings app instances and similar [Set] for driver objects. This must be removed when app looses it's pointer or other solution is needed to be found to avoid next finalizers
  static _addAppCycleMethod(
      ConditionModelApp app, ConditionModelAppAppCycleFunction method) {
    debugPrint(
        '_addAppCycleMethod called by app of app.appUniqueId ${app.appUniqueId}');
    _appCycyleMethods.add(method);
    _appCyclicalCallFinishFinalizer.attach(app, method);
  }

  /// Not needed - finalizer [_appCyclicalCallFinishFinalizer] is to remove the method. Read the [_addAppCycleMethod] description.
  @Deprecated('Left to remember for a while. See the desc of the method.')
  static _removeAppCycleMethod(ConditionModelAppAppCycleFunction method) {}

  /// Warning! It is set up by this class' static _initConditionModelAppsClass]() see desc - so do not use it - it is done by the library. The timer can be set up here on spot, for some reason it start working only when or after the main() function started running - we don't want to set up the value by placing something in the main file which a programmer would have to remember, but it is set up first when the first [ConditionModelApp] object is created. So this is the global Timer that is to call cyclically [ConditionModelAppAppCycleFunction] (see desc - important) methods belonging to all existing [ConditionModelApp] app models in the global scope of the application event those not in the [_allAndUniqueApps] [Set] which probably as of now involves apps related to [_uniqueLocalDriversOfAppsNotInTheAllAndUniqueApps] [Set]. registered with [_addAppCycleMethod].
  /// Each call of a registered method can trigger cyclical actions performed by on a global server especially, possibly other actions too as may be implied in [ConditionModelCycleCallEvent] enum function param.
  /// This timer is to avoid any other timer and secondary/higher-level-programming memory leaks. (higher doesn't mean better)
  static late final Timer _cyclicalActionsOfAppModelsTimer;

  /// Warning! Managed automatically internally by the library - so do not call it!. This sets up [_cyclicalActionsOfAppModelsTimer] property. This is called once when first [ConditionModelApp] object is created, the reason can be seen in the [_cyclicalActionsOfAppModelsTimer] description. This triggers a timer that will never cease to its method cyclically.
  static _initConditionModelAppsClass() {
    Timer.periodic(
        const Duration(
            milliseconds: ConditionConfiguration
                .globalBaseFrequencyForCyclicalStuffInMilliseconds), (timer) {
      // example implementation - maybe should be more asynchronous.
      debugPrint(
          '_cyclicalActionsOfAppModelsTimer timer cyclically calling its method that calls methods registered via _addAppCycleMethod (${_appCycyleMethods.length} methods will be called with the current library design restrictions).');

      for (final ConditionModelAppAppCycleFunction appCycyleMethod
          in _appCycyleMethods) {
        appCycyleMethod(false, null);
      }
    });
  }

  /// not implemented, just to signal possible but not immediate future need, it is called somewhere in the [ConditionModelapp] class, not necessary it will be - if return, possibly if many apps are in the app there will be attempts on different levels to decreas frequency of activity of different models, not only on this, but probably it will never be needed.
  /// FIXME: If deprecated is it used elsewhere?
  @Deprecated('? _addAppCycleMethod with it\'s cycle engine is gonna do that.')
  static bool _allowForThisCycleOfOverallCyclicallyPerformedOperationsOnTheApp(
      ConditionModelApp app) {
    //
    return true;
  }

  /// _addDriver() method was removed not for no reason, [addTheAppLocalServerDriverOnly] = true is not recommended or creating local driver objects not attached to any app may cause possibly instability if you try to save data independently of app main model tree update/save sistem. but the option == true is allowed to give you more freedom - an app may loose unexpectedly it's last pointer to it and the object may dissappear which can be fine if it is an app object read only, also it prevents from existing more than one the same settings local server driver. Uses [isThisAppUniqueAndCanBeUsed] method we want to throw excteption with the duplicate app, found as in some class elsewhere
  static _addApp(ConditionModelApp app,
      [bool addTheAppLocalServerDriverOnly = false]) {
    (bool, ConditionModelApp?) result = isThisAppUniqueAndCanBeUsed(app);
    if (result.$1 == true) {
      if (addTheAppLocalServerDriverOnly) {
        _uniqueLocalDriversOfAppsNotInTheAllAndUniqueApps.add(app.driver);
        _appNotInTheAllAndUniqueAppsFinalizer.attach(app, app.driver);
      } else {
        _allAndUniqueApps.add(app);
      }
    } else {
      throw ConditionModelAppExceptionAnotherConditionModelAppWithDuplicateConditionDataManagementLocalServerDriverSettingsIsHowCanIPutItPolitelyAlreadyOnTheConditionModelAppsClassStaticSetIsntIt(
          result.$2!);
    }
  }

  // _addApp informs about why this method shouldn't exist and be used.  It is not recommended to  Uses [isThisDriverUniqueAndCanBeUsed] method. we want to throw excteption with the duplicate app, (probably not driver itself because one unique driver object belongs to one unique app object - you cannot use the same driver object on two compeletely different app objects, it is checked, isn't it? ) found as in some class elsewhere
  //static _addDriver(ConditionDataManagementDriver driver) {
  //  (bool, ConditionDataManagementDriver?) result = isThisDriverUniqueAndCanBeUsed(driver);
  //  if (result.$1==true) {_uniqueLocalDriversOfAppsNotInTheAllAndUniqueApps.add(driver);} else {
  //    throw ConditionModelAppExceptionDuplicateSettingsConditionDataManagementDriverLocalServerDriverIsAlreadyOnTheConditionModelAppsClassStaticSet(result.$2!);
  //  }
  //}

  /// Convenience method using one aspect of [isThisAppOrDriverUniqueAndCanBeUsed] method, therefore the app param is here required.
  static (bool, ConditionModelApp?) isThisAppUniqueAndCanBeUsed(
      ConditionModelApp app) {
    (bool, ConditionModelApp?, ConditionDataManagementDriver?) result =
        isThisAppOrDriverUniqueAndCanBeUsed(app: app);
    return result.$2 != null ? (false, result.$2) : (true, null);
  }

  /// possibly not very often to be used app objects are important here and _addApp. Some "loopholes" are left to give you as a developer a bit more flexibility and freedom to use some stuff with greater risk of data integrity.
  static (bool, ConditionDataManagementDriver?) isThisDriverUniqueAndCanBeUsed(
      ConditionDataManagementDriver driver) {
    (bool, ConditionModelApp?, ConditionDataManagementDriver?) result =
        isThisAppOrDriverUniqueAndCanBeUsed(driver: driver);
    return result.$3 != null ? (false, result.$3) : (true, null);
  }

  /// For the method to work well each [ConditionDataManagementDriver] class should implement [isTheDriverTheSame] in a way that it is not the same if is of another class but also is not the same if especially it f.e. points to the same sqlite3 database file AND has the same prefixes for db name and db table, and possibly more especially for different drivers like mysql which should be implemented not in a long distant time (url, port, user, password). The app is considered not unique and already existing and added to the global list when local server driver settings are the same (tricky to check, some params considered to be satisfactory are going to be compared)
  static (bool, ConditionModelApp?, ConditionDataManagementDriver?)
      isThisAppOrDriverUniqueAndCanBeUsed(
          {ConditionModelApp? app, ConditionDataManagementDriver? driver}) {
    // mentioned in the retire list ([To do: #dlkj2fhpeg8nqxwpiu]???) method app was added if it has !local server! with f.e. in sqlite3 the same file name is the same class its raw db driver but also has the same db and table prefixes
    // but this should be checked in conditionmodeldriver to compare drivers
    // quickly too see doNotAddAppToTheGlobalAppList of conditionmodelapp and in the constructor body this constructor param
    // if the app is already found you can here throw exception with the model found
    if (app == null && driver == null) {
      throw Exception(
          'isThisAppOrDriverUniqueAndCanBeUsed of ConditionModelApps class exception: Both named params are null exception. At least one param cannot be null: app or driver');
    }
    driver ??= app!.driver;

    for (final ConditionModelApp uniqueApp in _allAndUniqueApps) {
      if (uniqueApp.driver.isDriverDuplicate(driver)) {
        return (false, uniqueApp, null);
      }
    }

    for (final ConditionDataManagementDriver uniqueDriver
        in _uniqueLocalDriversOfAppsNotInTheAllAndUniqueApps) {
      if (uniqueDriver.isDriverDuplicate(driver)) {
        return (false, null, uniqueDriver);
      }
    }

    return (true, null, null);
  }
}

/// App Configuration (also see [_driver] property). Among others it tells what users are logged preserving their ids in the app (not in the server). Tells what id can be assigned to a new user
@Stub()
class ConditionModelApp extends ConditionModel
    with ConditionModelOneDbEntryModel
    implements ConditionModelCompleteModel, ConditionModelOneDbEntryModel {
  late final ConditionWidgetBase /*ConditionAppBase*/ widget;

  // For now local server driver (among others the app local storage but http server at the same time see the read.me) - this must be set up. Read to the end!!! about caching webpage and reload! Drivers are simply String key, String? value - no other types, but strings are json encoded and they have integers, strings, etc. and [ConditionModel] models help to validate variables as to their type, range of values, etc. [_driver] gives you all widgets, and tree structure info when you start the app or reload the page, when all data is synchronized with the backend, for web there will be another driver for this - read only - technically reading data from javascript variable after full page reload. For all platforms all new data, new widgets, moving a model/widget elsewhere, model removal, whatever goes first to [_driver_temp]. For all platforms except web it will be a reference the exact same object as _driver (don't be worrying about namaspace stuff), but for web it will be the localStorage driver which can only contain up to 5MB (yet to confirm if encoding can increase the amount of data). 5MB - now you understand the reason of the two variables architecture. It is not bad anyway [_driver_temp] keeps clearly separaged data before it is updated in the backend. Simplifying: After the update for all platform except for web we update the main data managed by the [_driver] and clear the data [_driver_temp] manages but in case of the web only reload updates the data managed by [_driver] in a way that full data is loaded to the js variable (or html tag whatever), and only now localStorage can be cleared of temporary data. The idea is and important thing: if you f.e. lost internet connection but you created a div with data of _driver_temp - you could possibly exceed localStorage 5MB capacity, and if you next turn of the browser and turn on and the page loads from casche with the just mentioned div or something like that it should work, it would be wonderfull if it worked. Abandoned idea altarnatively you could read with AJAX all data for the [_driver] put it to a div for example and a page after reading from cashe would read it from the div. Also some browsers allow for saving page to the disk offline if the div with data from ajax was saved correctly you can pretty much work offline for some time. The point is can you store data to div or the app to disk so that it is loaded from cashe always ALSO I JUST RECALLED: when server ordered you to casche the page. YOU COULD also STORE files like IMAGES in the div!!! Finally: initially in the initial development period all drivers also for temp form browsers, probably for backend too are instances of the same class using [Hive] key-value database.
  // Each model belongs to a late final ConditionDataManagementDriver _driver;

  /*/// see all three [_driver]-like properties, especially the [_driver] for more comprehensive description
  @Deprecated('The app architecture changed in the meantime')
  late final /*ConditionDataManagementDriverLocalStorage*/ ConditionDataManagementDriver
      _driver_temp;

  /// !! Probably _driver_backend will reside in local server [ConditionDataManagementDriver] and then will be used if set up to synchronize data with global server. For now globl server driver. see read.me after you have seen all three [_driver]-like properties, especially the [_driver] prop and [_code_generator]-like this is development mode for the app to start working before developping the backend code - change it to [ConditioDataManagementDriverBackend], in constructor there is a corresponding [ConditioDataManagementDriverBackend] param
  @Deprecated(
      'Probably _driver_backend will reside in local server [ConditionDataManagementDriver] and then will be used if set up to synchronize data with global server')
  late final /*ConditionDataManagementDriverBackend*/ ConditionDataManagementDriver?
      _driver_backend;
*/

  // See also [_ids_of_model_class_names] Each [ConditionModel] instance needs this variable to get prefix when saving - i don't place a prefix property in a data driver because a couple of apps can use one driver. BUT! Instead A driver will read [ConditionModelApp] of a model and set prefix from the model's [ConditionModelApp] object
  //final String prefix;

  //final List<ConditionModelUser> loggedUsers = [];
  ConditionModelUser? activeUser;

  /*
  /// See [_ids_of_model_class_names], See [Type] class in doc, expecially "Type type = o.runtimeType;" - it implies i could do new type(); based on String (!) name of a given class. If possible things should be done automatically, and flexibly, in some cases you want to save data like in localStorage - for now you can find a widget by key like this: "appprefixu2t1w4" for appprefix you have the [prefix] property u means user the number after it means user id in the app not on the server, the "t" means the number in this [_ids_of_model_class_names] property, and finally you have "w" which means widget id
  final Map<String, Type> _ids_of_model_class_names = {
    '1': ConditionModelContact,
    '2': ConditionModelMessage,
    '3': ConditionModelVideoConference,
    '4': ConditionModelTask,
    '5': ConditionTripAndFitness,
    '6': ConditionModelURLTicker,
    '7': ConditionModelReadingRoom,
    '8': ConditionModelWebPage,
    '9': ConditionModelShop,
    '10': ConditionModelProgramming,
    '11': ConditionModelPodcasting,
  };

  /// Works with [_ids_of_model_class_names] property. Each models has id like user id, etc. this property means f.e. the next contact_id model/widget will be the int value assigned to it's key, and only after that increased by 1 and that umber used for a new widget. It seems the safest approach
  final Map<String, int> _model_types_id_counters = {
    '1': 1,
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    '10': 10,
    '11': 11,
  };
  */
  // data fields:

  /// Se also helper property [_serverKeyHelperContainer] +(setter/getter) desc. each app has it's id on the global server, each user belongs to this id - this helps to synchronize data between app installations of the same user, between different users. Difficult to explain see especially README.me file for overall up-to-date architecture. Each app that uses your app (with it's local server always running) as a it's global server has the key which is stored in [ConditionModelApp]s (Apps not App) db table, and the first mentioned app has it's own id all data is stored mainly this way app_id -> user id -> contact id -> anything else.
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_server_key =
      ConditionModelFieldStringOrNull(this, 'server_key',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only,
          isFinal: true);

  Completer<bool> serverKeyReadyCompleter = Completer<bool>();

  /// Use setter/getter (allowing return null while not throwing exception when this property yet not-initialized) This variable stores the key from local server, checks if it is still valid, if not
  /// the app will get a new one and all old synchronized data will be lost, new synchronizing
  /// should begin, FOR WHATEVER REASON - YOU CHANGED GLOBAL SERVER SETTINGS - not now such an option or in development mode you clean a db of global server
  /// it would be awfully configurable, it\'s probably going unnecessaryly far.
  /// But developers might have more flexible approaches - the main approach is STABILITY!!!
  /// FIXME: I will temporary make it final, probably changing key is server has had an accident and the app should be reinstalled or reset. probably - this will be tricky.
  /// FIXME: when changing the key will ever be implemented what will change ? Trace it out
  @protected
  late final String _serverKeyHelperContainer;
  set serverKeyHelperContainer(value) {
    _serverKeyHelperContainer = value;
    // educationally no! we cannot complete it here only when a_server_key.value has just been validated and set
    // serverKeyReadyCompleter.complete(true);
  }

  String? get serverKeyHelperContainer {
    try {
      return _serverKeyHelperContainer;
    } catch (e) {
      debugPrint(
          'catched error ConditionModelApp serverKeyHelperContainer getter _serverKeyHelperContainer not initialized original exception message: $e');
      return null;
    }
  }

  /// If you add a new user to the app this var tells you what id to assign to it
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_users_counter =
      ConditionModelFieldIntOrNull(this, 'users_counter',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// A currently displayed user on the screen
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_currently_active_user_id =
      ConditionModelFieldIntOrNull(this, 'currently_active_user_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// Comma separated ids in the app not server of Users [_currently_active_user_id] is in front on the screen the rest of the users are handled in the backround along with the incomming push messages to them
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_currently_logged_users_ids =
      ConditionModelFieldStringOrNull(this, 'currently_logged_users_ids',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// Comma separated ids in the app not server of Users registered in the app (this app instance) - not ids removed in the meantime
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_users_ids =
      ConditionModelFieldStringOrNull(this, 'users_ids',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only);

  /// All this app models [changesStreamController] streams (stream are added in the [ConditionModel] constructors - see the [changesStreamController] property description)
  @protected
  final StreamController<ConditionModelInfoStreamEvent>
      changesStreamControllerAllAppModelsChangesControllers =
      StreamController<ConditionModelInfoStreamEvent>();

  /// All this app models [_changesStreamController] streams (stream are added in the [ConditionModel] constructors - see the [changesStreamController] property description)
  final SynchronousStreamController<ConditionModelInfoStreamEvent>
      _changesStreamControllerAllAppModelsChangesControllers =
      StreamController<ConditionModelInfoStreamEvent>(sync: true)
          as SynchronousStreamController<ConditionModelInfoStreamEvent>;

  /// It may a bit change, and i might have forgotter to update this desc. First each model with id set or no id set (this is what may change) belonging to "this" conditinModelApp object goes to this set/list here in it's constructor via synchronous stream - important that doing such stuff synchronously to avoid changes in-between important actions. so the model goes here, then if added via [addChild] method ("parentid" in the class name probably version od the addChild method) to moved to [_allAppModels] but if a model was not yet moved to [_allAppModels] and retire() was called it is directly moved to [_allAppModelsScheduledForUnlinking] and some other stuff is or maybe performed. This is the idea how it works.
  final Set<ConditionModelParentIdModel> _allAppModelsNewModelsWaitingRoom =
      {}; // Warning, previously was used ConditionModel generic but ConditionModelParentIdModel is more suitable, while both classes are abstract so never used pure objects of only those classess

  /// Read also [_allAppModelsNewModelsWaitingRoom] desc for the order of actions. [_allAppModelsScheduledForUnlinking] description. Models are added using [_changesStreamControllerAllAppModelsChangesControllers].stream event handling probably something is prepared or a method is called in the constructor body. Represents all models getting a ConditionModelApp object into their constructor. They then belong to the app. Warning it is not the same as when you have a model ad add childs to it using addChild (or _addParentLink()) method for example. A model can be removed from the tree but Remain in this set here ([_allAppModels]) if a constructor param/property retireModelWhenWhenRemovedFromTheModelTree == false, more on that can be found in relevant ConditionModel properties description.
  final Set<ConditionModelParentIdModel> _allAppModels =
      {}; // Warning, previously was used ConditionModel generic but ConditionModelParentIdModel is more suitable, while both classes are abstract so never used pure objects of only those classess

  /// Read also [_allAppModelsNewModelsWaitingRoom] desc for the order of actions. Models from [Set]s [_allAppModelsNewModelsWaitingRoom] and [_allAppModels] always got to this property, read descriptions of the [Set]s. Models in this set are models that have had their method retire() called. They are immediately moved (the order of actions is yet to be established) to this list (class Set), when the model finished it's stuff, it is removed from the list here, and as it is supposed there souldn't be (MUST NOT BE!) any link to it left in the entire app. This will cause removing the object from the app memory with no unpredicted damage to the app.
  final Set<ConditionModelParentIdModel> _allAppModelsScheduledForUnlinking =
      {}; // Warning, previously was used ConditionModel generic but ConditionModelParentIdModel is more suitable, while both classes are abstract so never used pure objects of only those classess

  /// the same as _children of [ConditionModelParentIdModel], ConditionModelApp dont't extend [ConditionModelParentIdModel] so the need for additional implementation. But the children themselves are [ConditionModelParentIdModel] only. Usage, adding, removing children or implementing or not implementing some metods is done differently than in the case of [ConditionModelParentIdModel].
  @AppicationSideModelProperty()
  final Set<ConditionModelUser> _children = {};

  /// If object to not go to the global list it may create problems when the [ConditionModelApp] object looses last pointer to itself causing cascadingly uncontrolled unlinking/destroing other depending model of the app main model tree and other objects, while they may be performing a long operation like when a model updates itself on the global server. If the app object is not on the global app list any apps outside the list will have their local server ConditionDataManagmementDriver objects on another global app list; when any last pointer to an "outsider" app is lost the local driver will be removed thanks to the workings of [Finalizer] class; at the moment of writing it was planned that both the global app list and separately the local drivers belonging to "outsider" apps not attached to the global list would belong to the same class/classes [ConditionModelApps] [ConditionPermanentAppsHolder]. If true, the app can be (doesn't have to) meant to be read-only, short lived, or if false, in the constructor this property uses [ConditionModelApps], [ConditionPermanentAppsHolder] (read interesting points and ideas presented in the classes descriptions, also with throwing exceptions on duplicates) to store the app permantly to ensure data integrity. In custom cases such storing is not necessary. Read more of the just mentioned classes in their correspoding descriptions.
  final bool doNotAddAppToTheGlobalAppList;

  /// Each model object in an app object has final unique id (uniqie not globally but for the app object). Some objects are finalized with [Finalizer] class object. So to trigger the finalizer of a removed object you cannot have any reference to them left, but you have to perform some actions on objects related to them, but not having any reference to the finalized object; so you need to find them somehow and this unique id is used for this. Apart from that [ConditionDataManagementDriver]s have it too. See [ConditionModelApps].
  int _modelUniqueIdCounter = ConditionModelApps.minId;
  int get modelUniqueIdCounter => _modelUniqueIdCounter;
  int _increaseByOneModelUniqueIdCounterAndGetItsValue() =>
      ++_modelUniqueIdCounter;

  /// Not the same as [uniqueId] of all [ConditionModel] objects. This is a unique id across the entire app and as you can see in the constructor it is obtained from a private static property calling [ConditionModelApps].[_increaseByOneAppModelUniqueIdCounterAndGetItsValue](). [uniqueId] is unique id of a model across an app model object. So having both ids you can associate any finalizer with a concrete model. It shouldn't not impact the performance because any search through any lists/Sets of model objects belonging to an app model object should not take very much time but if any model had a unique id globally some searches might take lot of time because lists could be very long (not descrbed very educationally).  Never there are many app objects in the entire app. Also reading [ConditionModelApps] description may be good for overall understaning of this aspect of the architecture.
  final int appUniqueId =
      ConditionModelApps._increaseByOneAppModelUniqueIdCounterAndGetItsValue();

  ConditionModelApp({
    // As an exception to the rule this widget must be created immediatelly in setter after this object creation (widget property in ConditionModel) - no asynchronous waiting like Future
    // this piece of code is ok for frontend app only not for the server, different approach must be used
    //ConditionAppBase widget,
    String? dbNamePrefix,
    String? tableNamePrefix,
    map,
    driver, // see desc of _driver param for web it maybe different class
    //like driver_backend more precise type later*/ ConditionDataManagementDriver? driver_temp, // see desc of _driver param, for web it may be different class
    //ConditioDataManagementDriverBackend? driver_backend,
    Completer<ConditionDataManagementDriver>? driver_init_completer,
    this.doNotAddAppToTheGlobalAppList = false,
    super.changesStreamController,
    //super.retireModelWhenWhenRemovedFromTheModelTree, // not to be used for this, as an equivalent only ConditoinModelApp has doNotAddAppToTheGlobalAppList property
  }) : super(
            null,
            /*quick example debugging map: 
            // for debugging we add somthing that the map is not empty:
            //UNCOMMENT IT LATER: map,
            {
              'users_ids': '4,3,1',
              'users_counter': 5,
            },*/
            // FIXME: Regarding app model not the rest of one row models it may be solved because even when you won't pass id = 1 it will be assigned automatically and the ConditionModel class will try to find the id=1 row anyway and if it won't find any it will try to create a new row for this model with id = 1. Trace the process out see if it works as expected and update some docs on that in the best one or more places.
            // FIXME: maybe it is solved or not: in non-debug app should never have initial data, and there is possibly general problem with [ConditionModelOneDbEntryModel] one-sql-table-row models which [ConditionModelApp] model also is in that a new model that has no row in the table will get id = 1 but normally multi-row model classes won't get the id which means they will be created not updated;
            map ??
                    ConditionConfiguration.debugMode &&
                        ConditionConfiguration.initDbStage != null &&
                        ConditionConfiguration.initDbStage! >= 1
                ? <String, dynamic>{
                    'currently_logged_users_ids': '1,3',
                    'currently_active_user_id': 1,
                    'users_counter': 5,
                    'users_ids': '4,3,1',
                  }
                : {},
            driver ??
                ConditionDataManagementDriver.getNewDefaultDriver(
                  //initCompleter: driver_init_completer, added in the constructor body
                  hasGlobalDriver: true,
                )) {
    // [ConditionModelApps] class manages or take passive part in managging app models and/or the rest of the models which actually the rest of non-app models are managed by an app model (this one for example)
    try {
      // if not yet initialized an exception will be thrown. It is fine. We will catch it and init the [ConditionModelApps] class
      debugPrint(
          'ConditionModelApp constructor: if not yet initialized an exception will be thrown. It is fine. We will catch it and init the [ConditionModelApps] class.');
      ConditionModelApps._cyclicalActionsOfAppModelsTimer;
      debugPrint(
          'ConditionModelApp constructor: it is initialized already so it is the second or more [ConditionModelApp] app model object in the entire application running.');
    } catch (e) {
      debugPrint(
          'ConditionModelApp constructor: Catched exception. it is not initialized yet. Let\'s initialise it, and it is the first or more [ConditionModelApp] app model object in the entire application running.');
      ConditionModelApps._initConditionModelAppsClass();
    }

    //super.driver.addInitCompleter(this.driver_init_completer);

    // See relevant descriptions, an app may be or not destroyed when the last lint to this app model is lost in the app.
    // The purpose is to maintain data integrity so that no two the same apps but different object exist at the same time and some more stuff
    // You can catch an exception if thrown and use app from the exception (possibly a driver can be returned but not sure if it will be so in the future or it could be reused somehow - one local driver for one unique app rule
    // This is going add or to throw appropriate exception with app object or driver depending on the method that was invoked in this condition:
    //if (doNotAddAppToTheGlobalAppList) {
    ConditionModelApps._addApp(this,
        doNotAddAppToTheGlobalAppList); // May throw useful exception - seek to read more
    //} else {
    //  // adding app here is considered permanent and never removable, and it should be this way only, but you have an option above.
    //  ConditionModelApps._addApp(this);  // May throw useful exception - seek to read more
    //}

    // Now when nothing was thrown - see the above:
    ConditionModelApps._addAppCycleMethod(this, (bool skipThisCycle,
        Set<ConditionModelCycleCallEvent>? cycleCallEvents) {
      // TODO: IMPLEMENT THIS HERE YOU PERFORM ESPECIALLY GLOBAL SERVER OPERATIONS OF:
      // 1. READING FROM GLOBAL SERVER
      // 2. ALSO OF SENDING F.E. NEW MESSAGES THAT HAVE NO EXISTING MODEL OBJECT RIGHT NOW
      // WARNING !!! if an old operation is not finished no new it to be started. For this you have 2 options:
      // one is: old returned future is not finished yet, the second you just don't take action and return a finished future.

      // We get a record from the global server, seek for proper model object or create one with changing data and retiring it and removing pointer to it of course if any pointer to it was not "seazed"(used in two or more different places) by the app model in the meantime in an independent way

      debugPrint(
          'ConditionModelApp constructor: We are in the registered anonymous method that should be unnatached from the finalizer in ConditionModelApps class when this ConditionModelApp object looses the last pointer to it.');

      return Future.value();
    });

    _prepareActionsToTheModelTreeModelAddingRemovingStreamEvents();

    //this.driver.conditionModelApp = this;
    //this.driver.driverGlobal?.conditionModelApp = this;

    //this['server_key'] = 'adsfadsf';
    //users_counter = 5;

    a_server_key.init();
    a_users_counter.init();
    a_currently_active_user_id.init();
    a_currently_logged_users_ids.init();
    a_users_ids.init();
    initCompleteModel();
  }

  /// [it got statc] Important: The object returned contains the time but also info of possible problems like, time is or may be incorect because it's changed since the last call see details of the object returned because it is to be used by time-now request in the app. Calling this method by all models may possibly involve performing additional time related stuff for all models attached to the app object, this is still in the process of design. This method may need to be used by all models and they have conditionModelApp property; but if there is no need to use this method like possibly in ConditionModelDataManagement class or so all need to use instance [ConditionTimeNowMillisecondsSinceEpoch] with it's time property so all time related issues are managed properly. The method will care for any changing of the device's time and react adequately;
  static ConditionTimeNowMillisecondsSinceEpoch
      getTimeNowMillisecondsSinceEpoch() {
    return ConditionTimeNowMillisecondsSinceEpoch();
  }

  /// The point of this method is to prevent some operations from starting to allow other operations to be performed, especially to make retire method successful to prevent from starting a possibly very long lasting remote url model update operation for example. When this method returnes unfinished future? F.e. when retire() method was called on a model and failed to start to retire then for some time the future will be unfinished allowing the model to retire in the next retire() call, this method allows preventing some time consuming operations from starting like update on global server which tells that model is not "doing" anything important right now and can be retired if retire() is called again but if it is not called in the longer period of time the future will be finished, completers returend are up-to-date: new or replaced ones so you might have access to a old unused future if used non-standard custom way - the library uses it in a right way. Warning there may be only ConditionModelClassesTypeOfSucpendableOperation.globalServerUpdate, ConditionModelClassesTypeOfSucpendableOperation.globalServerCreate operations handled if nothing change in the meantime. The rest may return a completed [Completer], which means with it's finished [Future] and that means no suspension of related code execution. Any derivatives from here should use this one probably. Returns up to date completer (because Future class has no isCompleted property) Completer has finished future. "up-to-date" means any previous future was already completed and either there is no need for another and the old one is returned or there is a new Future and new blocking situation so wheneve you need to have the up-to-date completer with its future you need to call this method again. This method is used in async/await situation and is originally to be used internally by the library. The points of this method are that a global server writing operaiton like create/update or possibly also delete, read (not sure now delete, read of course "reads" but is not crucial for data integrity) may last very very long so it would prevent a model from retirement and release resources taken by it. This method enables to block some code/operations from being executed and allow a model to be retired but if the process of retirement fails and the app in the meantime again need the object it is not to be retired and this future is to be completed and the locked operations are resumed. The second use case is that [ConditionModelApp] object is going to manage some operaitons performed by models especially in case two models may want to access a db for writing. It is not sure if this method [hangOnModelOperationIfNeeded] is to do all the stuff needed for such queing db operations. However for now it is a clear way to show what feature is now used and needed.
  Completer hangOnModelOperationIfNeeded(ConditionModelParentIdModel model,
      ConditionModelClassesTypeOfSucpendableOperation operationType) {
    //_allAppModels.contains(model);
    //_allAppModelsScheduledForUnlinking.contains(model);
    try {
      throw Exception(
          'catched Exception method hangOnModelOperationIfNeeded has been being implemented but not yet implemented or not fully implemented');
    } catch (e) {
      debugPrint('$e');
    }

    // Below it is object that has the time but may inform you about issues, and one time for this entire method body
    ConditionTimeNowMillisecondsSinceEpoch timeNow =
        getTimeNowMillisecondsSinceEpoch();

    // never should happen any call after retirement, so let's make an educational exception)
    if (model.isRetired) {
      // return never finished Completer()
      throw Exception(
          'hangOnModelOperationIfNeeded() exception: you see it because by design the method should never be called after the model retired. It is assumed that a mistake was made during the design or when later some features had been added something had gone wrong and yet the method has been called.');
      // return Completer(); // never completed completer were it not for the exception was thrown.
    } else if ((operationType ==
                ConditionModelClassesTypeOfSucpendableOperation
                    .globalServerCreate ||
            operationType ==
                ConditionModelClassesTypeOfSucpendableOperation
                    .globalServerUpdate) &&
        (model._pendingRetirementProcessCompleter ==
                null // retirementpendingproperty == null - retire never executed
            ||
            (model._pendingRetirementProcessCompleter != null &&
                !model
                    ._isRetireMethodBodyAlreadyBeingExecuted // no retire sync body being executed right now
                &&
                !model
                    .isRetirementProcessPending // no asyn retirement pending - finished completer/future
                &&
                (model._lastRetireModelProcessFinish == null ||
                    timeNow.time - model._lastRetireModelProcessFinish!.time >
                        30000)))) {
      // as for now we want to
      if (
          // removed line: no need to use it, as below, null returned if key not found : !model._conditionModelAppHangOnModelOperationsCompleters.containsKey(operationType) // it would
          model._conditionModelAppHangOnModelOperationsCompleters[
                  operationType] ==
              null) {
        model._conditionModelAppHangOnModelOperationsCompleters[operationType] =
            Completer()..complete(); // return a new already completed model
      } else if (!model
          ._conditionModelAppHangOnModelOperationsCompleters[operationType]!
          .isCompleted) {
        model._conditionModelAppHangOnModelOperationsCompleters[operationType]!
            .complete();
      } else {
        // educationally - we have the model completed we can leave the stuff unchanged and return the completer as is
      }
    } else {
      /// For now we don't expect request for other ConditionModelClassesTypeOfSucpendableOperation operation types
      /// so we need to throw something shound't we?

      throw 'hangOnModelOperationIfNeeded method. Currently only ConditionModelClassesTypeOfSucpendableOperation.globalServerCreate, ConditionModelClassesTypeOfSucpendableOperation.globalServerUpdate are handled';

      //if (
      //  // removed line: no need to use it, as below, null returned if key not found : !model._conditionModelAppHangOnModelOperationsCompleters.containsKey(operationType) // it would
      //  model._conditionModelAppHangOnModelOperationsCompleters[operationType] == null
      //  || model._conditionModelAppHangOnModelOperationsCompleters[operationType]!.isCompleted
      //) {
      //  model._conditionModelAppHangOnModelOperationsCompleters[operationType]=Completer(); // return a new already completed model
      //} else {
      //  // educationally - we have the model NOT completed we can leave the stuff unchanged and return the completer as is
      //}

      // ??? always completer - of course replace with old completer where the same state of completion, like: model._conditionModelAppHangOnModelOperationsCompleters[ConditionModelClassesTypeOfSucpendableOperation.globalServerCreate]
    }

    // always completer - of course replace with old completer where the same state of completion, like: model._conditionModelAppHangOnModelOperationsCompleters[ConditionModelClassesTypeOfSucpendableOperation.globalServerCreate]
    return model
        ._conditionModelAppHangOnModelOperationsCompleters[operationType]!;
    // FIXME: Starting from here below probably there is just old code unused anymore
    // the code must have been commented to prevent errors
    //
    // TODO: Stopped here // not bad to read below comments, probably all is fine
    // TODO: //additionally in the retire meethod is sort of errors with comments with to do - maybe done maybe not

    // -----------------------------------------------------------------------
    // SOME OLDER ANALISYS TO BE POSSIBLY REMOVED
    // 1000 ms = 1s
    // here we need timestamp defined in the app object and to be used by any timestamp call in the app why?
    // because in one place we can first simply detect if time changed in the device.
    // second, later, in a more sophisticated case the time changed properly since the last call, but it stil seems to be not as it is reasonably expected.

    // IMPORTANT It is on the event loop so if no await/async one method in the event loop is performed fully at once with no parallel method called at the same time
    // So design it in a way that a piece of code that is to be performed fully with no stops is performed fully!
    // Don't know how to do it, me need to recall all the removal and possible reattachement (addchild) process again:
    // 1. A model is removeChild or (link) from the main app model tree. If not in the tree is moved to _allAppModelsScheduledForUnlinking
    //

    // TODO: iff // model.isRetired is possible here return the completer, however it should be Future (edit no because completer are in the model itself), because the as time passed finally it turns out that only conditionmodelapp object manages the completers states (isCompleted) it can be future returned
    /// The below code means, after the all retire process finished > 30 seconds (30000 milliseconds)
    /// If in the meantime no other retire method call occured we can return a completer completer/future
    /// to unlock especially locked global server operations while the model returned to its normal functioning
    // TODO: think // if the model is in the unlinking Set/List can we ever return a finished future to unlock especially locked global serve operation/s?
    // if the

    // TODO: Focus here // to return uncompleted completer the retire method sync and async aspect must not be pending now and
    // TODO: + model._lastRetireModelProcessFinish!.time > 30000 also maybe first too (it was called at leas once)

    //      if (model._lastRetireModelProcessFinish != null && timeNow.time - model._lastRetireModelProcessFinish!.time > 30000) {
    //        if (!model._conditionModelAppHangOnModelOperationsCompleters.containsKey(ConditionModelClassesTypeOfSucpendableOperation.globalServerCreate)) {
    //          model._conditionModelAppHangOnModelOperationsCompleters[ConditionModelClassesTypeOfSucpendableOperation.globalServerCreate]=completer;
    //        }
    //
    //        if (!model._conditionModelAppHangOnModelOperationsCompleters.containsKey(ConditionModelClassesTypeOfSucpendableOperation.globalServerUpdate)) {
    //          model._conditionModelAppHangOnModelOperationsCompleters[ConditionModelClassesTypeOfSucpendableOperation.globalServerUpdate]=completer;
    //        }
    //      } else {
    //
    //      }
    //
    //
    //      return completer;
    //
    //    } else {
    //      // the rest of the suspendable operaitions that are not handled causing the app to return a completed completer - finished future
    //      completer = Completer();
    //      completer.complete();
    //      return completer;
    //    }
    //
    //return completer;
  }

  /// Warning the real retire can be done by argument/model's [retire]() method of a model but this class internally used method does the rest of the stuff like checking retireModelWhenWhenRemovedFromTheModelTree == true which retire itself doesn't need because it perfomrms it's stuff of course if it is not in the tree and doesn't have a parent link model.
  _oneTimeRetireAndUnlinkModelAction(
      ConditionModelParentIdModel conditionModelAppDescendantModel) {
    // if a model is retired it cannot be unretired

    // This is done in the stream event area in this objects
    //if (conditionModelAppDescendantModel.isRetired) {
    //  _allAppModelsScheduledForUnlinking
    //      .remove(conditionModelAppDescendantModel);
    //} else

    if (conditionModelAppDescendantModel.isRetired ||
            conditionModelAppDescendantModel.isRetirementProcessPending ||
            conditionModelAppDescendantModel
                ._isRetireMethodBodyAlreadyBeingExecuted ||
            conditionModelAppDescendantModel
                    .retireModelWhenWhenRemovedFromTheModelTree ==
                false // i once wrote below this (important?): // the model.retire() method has the following information too: that is to be called is independent and doesn't use the property checking
        ) {
      return;
    } else {
//probably // the below do do is not about user models, so you don't care but return to it.
//implement like now // [TO DO: #AP9EWHP98HQ748TGPF] throw exception if model is in the conditionModelApp, think over what to do if a model is scheduled for unlinking but not retired
// we make sure if one part of code is made synchronously in the event loop, not parallel synchronous action is performed to avoid changing state like we start checking model is not being retired but after half of a method body the situation change we think not and get a model that will be retired and removed in a while
// conditionModelApp method must return synchronically such an object if exists but
// but if it is scheduled for unlinking we make sure retire method is not being executed now and won't be if the model will be returned
// at the same time we move the model from scheduled for unlinking to the normal list
// For this we need to define a method in conditionModelApp maybe also with information sort of "it is scheduled for retirement"
// can you 100% stop retiring such a model and return it? We want to do it synchronously if possible but
// IMPLEMTING IT IS ABOUT AN EXISTING ID NOT A NEW MODEL - THIS IS NOT AN ISSUE WITH A NEW MODEL
// test it by creating two such objects, etc. that in now way something is missed and delayed and two objects are added at once or in time period apart

// So this is the moment where model is not retired and not being retired right now
// 1.   _prepareActionsToTheModelTreeModelAddingRemovingStreamEvents()
//    this is synchronous stream so the info is up to date when model is in the tree again or for the first time
//    conditionModelApp._changesStreamControllerAllAppModelsChangesControllers.stream
//        .listen((event) {
//        event is that it was added to the tree - retire checkthis out when called
//        _allAppModelsScheduledForUnlinking.remove(childModel);
//        _allAppModels.add(childModel);
//    or from appmodels to scheduled
//
// =====================================================================
// =====================================================================
// PROBABLY BELOW IS THE ESSENCE WHAT TO DO IN THIS "BOX", READ MORE FOR CONTEXT IF NECESSARY
// =====================================================================
//Wait // we have two new types of model list for conditionModelApp/
//Wait2 // with no id also can go here all models must be retired and unlinked and they maybe in the process of something they may consume resourcess, they too should be handled correctly
// A. models that weren't yet added to the _allAppModels set which is synchronously done with synchronous stream event via addChild
//    ! id>0 (update probably with no id too) _allAppModelsNewModelsWaitingRoom for new models if moved to the _allAppModels they never return to _allAppModelsNewModelsWaitingRoom
//    because the app will have them in _allAppModels, _allAppModelsScheduledForUnlinking and by this they can be tracked until they are unlinked because they were successfully retired
//    THIS IS ONLY FOR MODELS WITH KNOWN ID FROM THE BEGINNING - THIS IS WHY DUPLICATE IS POSSIBLE, MAKE SURE USER MODELS IS NOT PROBLE (I AM ALMOST SURE IT IS NOT A PROBLEM)
//    ALL NEW MODELS WITH ID GO THERE AND THEY ARE MOVED
//    !!! WARNING THEY PROBABLY WILL BE ADDED IN THE ConditionModel CONSTRUCTOR like in addchild that calls _performAddingChildToParentModel
//        remembering the addChild using synchronous stream event
//    !!! so that it is managed in one place
//    model._changesStreamController.add(ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree(this, childModel));
//    WARNING BUT HOW TO UNLINK A MODEL IN _allAppModelsNewModelsWaitingRoom
//    BECAUSE ALL TO BE UNLINKED EVERYWHERE MODELS MUST CALL RETIRE() FIRST WE CAN SEND THE MODEL TO THE _allAppModelsScheduledForUnlinking
//    AND THIS MUST BE DONE AT THE VERY TOP OF THE RETIRE METHOD AS IF IT WAS MOVED TO THE UNLINKING LIST/SET
//    AND IN THAT PLACE IT WOULD BE DONE CYCLICALLY IF NECESSARY, PROBABLY NO MORE TO CARE FOR BUT MAKE SURE
//    such waiting-room model can be retired so again a model in the process of retirement or something couldn't be added could it?
// =====================================================================
// =====================================================================
// =====================================================================

//HERE BEST STEPS PROBABLY BASED ON THE ABOVE
// !!!!!!!!!!1 ALL ABOUT A TYPICAL MODEL WITH ID KNOWN !!!!!!!!!!!!!!!!!!!!!!1
// BUT WE MUST DO IT SYNCHRONOUSLY
// 1. So if the model is in the tree right now (synchronously performed, changed, and informed)
//      it is in the appModel list or otherwise appmodelscheduled .... list
//      or it is not here nor here
//      SO I JUST NOTICED IF NOWHERE THERE MAY BE 2 STANDALONE INSTANCES OF THE SAME MODEL - A LOOPHOLE.
//      SO YOU HAVE TO ADD EACH MODEL TO SOME LIST ANYWAY SORT OF WAITING ROOM YOU ARE ALWAYS AND ONLY ONCE: BEFORE THE CHILD WAS ADDED
//      AND REMOVED FROM THE LIST EXACTLY WHEN _allAppModels.add(childModel) IS SYNCHRONOUSLY CALLED
//
// 2. reminder the id of the model is known. then we can get the model but a third-party programmer doing it on his own SHOULD create/GET model with the option retireModelWhenWhenRemovedFromTheModelTree == false
//      And we can clearly inform him about it
//      Now the tricky part
//  3. reminder the id of the model is known.  we can publicly get information about model OF THIS ID, maybe record/tuple, conditionmodelapp.gettheexistingmodel() we get it with sychronous info if it is in the appmodels or scheduledforunlinking, etc. maybe willberetiredifremovedfromthetree, etc.
//     a: model is/is not on the app list
//     b: create the new model with the known id if not on the list
//  4. reminder the id of the model is known. As a convenience. based on 3 we create new model with the id and throw exception if a model was found on the list
//     a: the exception may send a working model with possibly addidional information, exactly that in 3. and you can catch it and assign in the catch body the model showed there - if you want.

// 5. Try to make relevant descriptions and examples

      //retire // cannot last for two long - like 30 seconds or so
      // and because of the design retire cares fully for this
      // and the conditionModelApp object will depend on if retire finished or not to call the retire again
      // so retire method must have shouting doc info what to implement about it and implement it

      // Another need and possibly comment above:
      // Solved in above else if: To be flexible we need info isRetirementProcessPending (pending i mean now being performed)
      // TAKE ALSO NOTE, that you can use private properties here not necessarily getters as suggested here below:
      // update if pending no retire call: old: but when it is pending also a call of retire should return a completer from previous call of retire() that hasn't finished yet
      // ok, done: so here you must use isRetirementProcessPending getter of private _is... property because the method is called cyclically you would do .then() 50 times on a one model if not checked the isReti....
      // but a regular programmer could call the retire() if he wants and it would return Future. It is logical he will not call retire() 50 times

      //here // so there is a problem if all models to be unlinked are retireModelWhenWhenRemovedFromTheModelTree == false
      // then we might do unnecessary resource consuming cyclical checkout - it this so - it this a potential problem we should optimize, now?

      //while // when error but somehow retired it will be remove, but make sure that retired models are not accepted to addChild and possibly addParent link methods
      // it maybe is already done

      //dont // forget that hangon... model can NEVER accidently have it's completer completed by this conditionModelApp object f.e. after it has already been retired it would f.e. unlocked suspended global server update.

      // not sure now but possibly we check if retire is pending, if not we try to retire
      conditionModelAppDescendantModel.retire();
      //stopped here // and instead of then() a synchronous stream event will be issued when is retired so that nothing happens in between
      //the // below event will be issued and catched when all the tree and model sets events are listened to
      //now // UPDATE IT IS NEEDED - IF NOT RETIRED YOU MUST CHECKITOUT: not sure if this method is even necessary it 2:30 am now have not much strength left
      //ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired

      //    .then((bool hasTheModelBeenRetired) {
      //  debugPrint(
      //      '_oneTimeRetireAndUnlinkModelAction() method and inside it a retire().then() call on a model, hasTheModelBeenRetired == $hasTheModelBeenRetired, if true we can remove the model from _allAppModelsScheduledForUnlinking Set which will result in having no link to the retired model in the entire application (it should be so if a programmer not implemented this the link would be left somewhere but the model would be useless and possibly throw exceptions at any time)');
      //
      //  // make sure that in this method by cyclical call it hasn't been removed in the meantime
      //  if (hasTheModelBeenRetired) {
      //    // with this ther should be no variable/pointer/reference to the object of conditionModelAppDescendantModel
      //    // if not the model is blocked from using it anyway
      //    _allAppModelsScheduledForUnlinking
      //        .remove(conditionModelAppDescendantModel);
      //  }
      //
      //  debugPrint(
      //      '_oneTimeRetireAndUnlinkModelAction() method and inside it a retire().then(); if the model had been retired i has just been removed from the _allAppModelsScheduledForUnlinking Set. As just mentioned there should be no link to the model in the entire application now.');

      //}).catchError((e) {
      //  debugPrint(
      //      '_oneTimeRetireAndUnlinkModelAction() method and inside it a retire().catchError() call on a model the model conditionModelAppDescendantModel.isRetired == {$conditionModelAppDescendantModel.isRetired} = if retired the model despite the error will be removed from _allAppModelsScheduledForUnlinking because it is retired (like impossible but if it happened it is retired and it matter most), exception: $e');
      //  // on error it should never be retired but if it is retired it will be removed on another cyclical call _oneTimeRetireAndUnlinkModelAction()
      //});
    }
  }

  /// Used by _oneCycleOfCyclicalRetiringAndUnlinkingModels. Some cyclical stuff should be delegated to the app configuration. No need to implement such risky settings quickly.
  ConditionTimeNowMillisecondsSinceEpoch?
      _lastAllowedOneCycleOfCyclicalRetiringAndUnlinkingModelsFinishedCall;

  bool _isOneCycleOfCyclicalRetiringAndUnlinkingModelsMethodAlreadyInProgress =
      false;

  /// This method may change in a way that one call of it picks up only one or couple of models not all as it is now, so counter property might be needed. Cosider that not many models scheduled for unlinkning may be at once, so not sure there is need to make it more sophisticated. However you can probably focus just on this method and add a counter property to this class. Remember: changes to the existing Set while it is being iterated by for throws exception. Now it is done on the event loop, (Warning, Edit: you can't use Isolates/Workers/Threads ? probably read why) but it would be better if threads and workers/js were used instead. For now probably workers cannot be used, at least not now. Much in the process depends on one full set of actions pefromed synchronously but on the event loop. So if one method is being executed now, you may feel comfortable that simultanously there is no other method being executed and changing some important data you thought in the first method code that nothing/no f.e. model property can change until you finish the first method/piece of code execution. For this you must make sure if a particular action you can perform using isolates/workers/threads
  _oneCycleOfCyclicalRetiringAndUnlinkingModels() {
    /// With future possible massive data situations in mind (never?). To make sure that f.e. 5000 (impossible?) models aren't synchronously still in the process of analysing
    /// Let's make sure this method is called with at least 10 seconds intervall
    if (_isOneCycleOfCyclicalRetiringAndUnlinkingModelsMethodAlreadyInProgress ||
            _allAppModelsScheduledForUnlinking.isEmpty ||
            _lastAllowedOneCycleOfCyclicalRetiringAndUnlinkingModelsFinishedCall ==
                null ||
            ConditionModelApp.getTimeNowMillisecondsSinceEpoch().time -
                    _lastAllowedOneCycleOfCyclicalRetiringAndUnlinkingModelsFinishedCall!
                        .time <
                10000 // 10 seconds
        ) {
      return;
    }

    // this method is run on the event loop, when it is finished first _oneTimeRetireModelAction is called
    // so it shouldn't throw any exception when _oneTimeRetireModelAction removes _allAppModelsScheduledForUnlinking[i] element
    // from the set while it is being iterated, because it is never done during the iteration
    try {
      // done earlier return false: if (!_allAppModelsScheduledForUnlinking.isEmpty) {
      for (var i = 0; i < _allAppModelsScheduledForUnlinking.length; i++) {
        // THIS WILL make sure not to create many .then() on one model or will return quickly if f.e. model is retired or in the tree.
        _oneTimeRetireAndUnlinkModelAction(
            _allAppModelsScheduledForUnlinking.elementAt(i));
      }
      //}
    } catch (e) {
      /// to make sure we can cyclically call the method
      debugPrint(
          '_oneCycleOfCyclicalRetiringAndUnlinkingModels() of [ConditionModelApp] class exception: $e');
      _isOneCycleOfCyclicalRetiringAndUnlinkingModelsMethodAlreadyInProgress =
          false;
      _lastAllowedOneCycleOfCyclicalRetiringAndUnlinkingModelsFinishedCall =
          ConditionModelApp.getTimeNowMillisecondsSinceEpoch();
      rethrow;
    }

    _lastAllowedOneCycleOfCyclicalRetiringAndUnlinkingModelsFinishedCall =
        ConditionModelApp.getTimeNowMillisecondsSinceEpoch();
    _isOneCycleOfCyclicalRetiringAndUnlinkingModelsMethodAlreadyInProgress =
        false;
  }

  /// this method is called only when a model has just been removed from the model tree (including from a parentLinkModel that has had this childModel). Apart from that when condition are met _allAppModelsScheduledForUnlinking is checked for models to be unlinked cyclically.
  _triggerModelRemovalProcess(conditionModelAppDescendantModel) {
    _allAppModelsScheduledForUnlinking.add(conditionModelAppDescendantModel);
    _allAppModels.remove(conditionModelAppDescendantModel);
    // This is an immediate call to the retire() method on the event loop.
    // The metod doesn't neccessary need to be called now because now it will be called cyclically until successful retirement
    // However _allAppModelsScheduledForUnlinking will be checked cyclically because the model
    // can have temporary settings or state (f.e. it is being updated now) that makes impossible for it to be removed
    // the cyclical retire may be called like in if condition
    // but the future the retire returns may not be finished soon
    // so it cannot be that on one model the retire is called cyclically 100 times and is blocked 100 times and "never finishes"
    _oneTimeRetireAndUnlinkModelAction(conditionModelAppDescendantModel);
  }

  /// You may use this in one synchronous code on the event loop. Public, it informes whether or not the model is either in [_allAppModelsNewModelsWaitingRoom], [_allAppModels], [_allAppModelsScheduledForUnlinking]
  ConditionModelParentIdModel? getModelIfItIsAlreadyInTheAppInstance(int id) {
    for (final ConditionModelParentIdModel model
        in _allAppModelsNewModelsWaitingRoom) {
      // it is understood that this time a model if not null has proper int id > 1, no need to check it out like with event.id
      if (model['id'] != null && model['id'] == id) {
        return model;
      }
    }

    for (final ConditionModelParentIdModel model in _allAppModels) {
      // it is understood that this time a model if not null has proper int id > 1, no need to check it out like with event.id
      if (model['id'] != null && model['id'] == id) {
        return model;
      }
    }

    // TODO:[To do : #WpEmwxpQm346q$u]
    // THIS ONE IS MOVED FROM OTHER PLACE SO SOME THINGS RELATE TO THE OTHER PLACE AND MAY HAVE BEEN SOLVED IN THE MEANTIME
    // TODO: here // it is described somewhere in this method not sure what to do
    // PROBABLY WE NEED TO KNOW IN THE EXCEPJTION: isModelInAllAppModelsScheduledForUnlinking or just isScheduledForRetirement
    // TODO: I // THINK WE CAN ONLY WAIT FOR THE MODEL TO RETIRE OR TO TRY TO CAUSE IT CANCEL RETIREMENT PROCESS PROBABLY
    // BY LOCKING RETIREMENT WHEN MODEL NOT IN THE TREE - the property, AND THEN USE IT when the CURRENT POSSIBLY PENDING
    // retirement process finished, property/completer,
    // TODO: !!! done to test. // IF TRUE IT MAY STILL IN THE TREE SO WE NEED TO REMOVE IT SYNCHRONOUSLY _allAppModelsScheduledForUnlinking in the retire method
    // AND BY THIS IT WON'T BE IN THE TREE
    // TODO:  done // describe in the ...parentid... in the class description and in the constructor body where the event is issued that it throw an exception if the app is already defined
    // so maybe for convinence, because we need to wait until the model ex
    // TODO:  // add child - cannot add if child is in the process of retirement, or _allAppModelsScheduledForUnlinking or similar stuff. Only if you cancel/rollback the pending retirement process and move the model from the unlinking area
    // TODO:  // based on because any ConditionModelApp must init itself synchronously, it maybe that you will create a model not internally but outside the app object, before the ConditionModelApp is inited for this you must throw exceptions. When the conditionmodelapp tries to restore it's children and then descendants some app models with a certain id might already exist
    // TODO:  // Another: what if a user is logging-out? - difficult to say but it would involve cascadingly retiring all models
    // TODO:  // If a model is retired it should have his children removeChild() - the method then yould care for the rest including retirement process if needed.
    // TODO:  // But when a user is inited at the start of the app we can then create completely new models synchronously
    // TODO:  // Because there is no need to give up on initial async stuff. however for some quick stuff in the future we may need to translate xml to model objects, etc. but for some reason to store it in the db. For this part may be sync part not.
    // TODO:  // For retire, as in _oneCycleOfCyclicalRetiringAndUnlinkingModels We synchronously need to add a registration when the call of the method started and finished with possible more.
    //   By this we will have that the retirement process is pending which is synchronous by nature, but also that the method body is being now excecuded.
    // [Maybe The end of this to do]
    // TODO:  here we stopped
    // TODO: ! // constantly // forgetting to throw exceptions on all if isRetired - mostly on setters, make sure hangonwith....
    // never completes after retirement make sure when retirement is finished but child added to the tree or as link
    // when hangon unlock some stuff like update global server (create too?). also if retire failed
    // but the model is not auto retired/standalone - it's one time not cyclical - all tricky
    // then maybe also you can finish the hang on - i don't know you think over the process again.
    // and all of this you want to do receiving events here.

    for (final ConditionModelParentIdModel model
        in _allAppModelsScheduledForUnlinking) {
      // it is understood that this time a model if not null has proper int id > 1, no need to check it out like with event.id
      if (model['id'] != null && model['id'] == id) {
        return model;
      }
    }

    return null;
  }

  _prepareActionsToTheModelTreeModelAddingRemovingStreamEvents() {
    // ! just to remind you, the event with underscore is a synchronous (not asyn... but a/one) stream
    // so stuff performed here is as it should be time unexpesive
    // the developer considered it necessary for the stuff here to be done synchronously
    // with related some stuff scheduled asynchronously when necessary
    conditionModelApp
        ._changesStreamControllerAllAppModelsChangesControllers.stream
        .listen((event) {
      // !!!!!!! WARNING! REALLY READ THIS: EVENT ORDER AAAAAAAAAAAAAAAAAAAA!
      // last related event sent (earlier ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree)
      // so you catch the last one (all is well prepared) AND DON'T CHANGE THE EVENT ORDER!!!
      // The relevant comment in the addChild and addParentLink or similar name
      if (event
          is ConditionModelInfoEventModelAcceptModelToTheConditionModelAppWaitingRoomSet) {
        // it is checked in the constructor of the event model but if anytime something changed think the process over...
        // if (this is! ConditionModelUser) {
        // }

        // this for new model/object instances with (with id, no id, maybe more - check it out if something changed)
        // do we have a second model with the same id?
        //
        // TODO: stopped here check: // all Lists/sets like _allAppModels.... if they have a model of this id then you can add model
        // to "the waiting room"
        // but if not found an exception should be thrown probably - because it is synchronous call so probably
        // we it will be catch in the parentid.... constructor where the event was issued
        // the exception will throw an existing model as error message so it can be catched and assigned i believe
        // if () event.id

        // the condition is checked in general but at later in an extending constructor not a parent as needed so we repeat :) :
        if (event.id == null ||
            (event.id != null && (event.id is! int || event.id! < 1))) {
          return;
        }

        ConditionModelParentIdModel? model =
            getModelIfItIsAlreadyInTheAppInstance(event.id!);

        if (model != null) {
          throw ConditionModelAppExceptionAnotherConditionModelParentIdModelWithTheSameIdIsAlreadyInTheAppInstance(
              model);
        }

        _allAppModelsNewModelsWaitingRoom.add(event.model);
      } else if (event
              is ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel
          // ! removed not to handle the same situation twice: ||  event is ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel
          ) {
        // corrected Error? // this would be done twice because the two events are issued at the same time basically
        // so we need to handle just one, which is better?

        // See the above comments at the beginning of this if, the event order is important
        // app models is set, no need to check if _allAppModels.contains(event.childModel)
        // BELOW casting because as it seems linter couldn't make it
        // (or not resolved syntax error caused it to show errors)
        var childModel = event.childModel;
        // var childModel = event
        //         is ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel
        //     ? event.childModel
        //     : (event
        //             as ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel)
        //         .childModel;

        // below line in case the model was detached from the model tree using removeChild for example but the model has mechanisms preventing it from retirement like when it is synchronising it's data or is used in a custor way. So if the model is added to the model tree via addChild it is moved to the _allAppModels and it is no longer checked out cyclically retire() will not be called on it and it won't be unlinked completelly from the _allAppModelsScheduledForUnlinking Set (ofcourse also from _allAppModels, from where the child model was moved to _allAppModelsScheduledForUnlinking Set)
        _allAppModelsScheduledForUnlinking.remove(childModel);
        _allAppModels.add(childModel);

        debugPrint(
            'ConditionModelApp _prepareActionsToTheModelTreeModelAddingRemovingStreamEvents() model has just been added to the [_allAppModels] [Set]. Event hat caused it: ${event.runtimeType}');
      } else if (
          // See the above comments at the beginning of this if, the event order is important
          // And i see two first events might be four but then action would be performed unnecesarily twice so for each major situation just one of two to pick from was chosen
          event is ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved ||
              event
                  is ConditionModelInfoEventModelTreeOperationChildModelHasJustHadHisParentLinkModelRemoved ||
              event
                  is ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree) {
        //
        //
        final childModel = event
                is ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel
            ? event.childModel
            : (event
                    as ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel)
                .childModel;
        debugPrint(
            'ConditionModelApp _prepareActionsToTheModelTreeModelAddingRemovingStreamEvents() an event arrived: ${event.runtimeType}');

        // See the above comments at the beginning of this if, the event order is important
        // app models is set, no need to check if _allAppModels.contains(event.childModel)
        // abc //and dont forget about this:
        //
        //
        // -------------------------------------------------
        // We have a flat list of descendant models models of ConditionModelApp (uses this as starting point when called with no params)
        // because a model can be only in ONE place of the tree in the valid conditionModelApp object
        // so, the tricky part, we need to check out if this particular model exists anywhere
        // NOT DIRECTLY IN THE tree but attached as a linked [_childLinkModel] model
        // that a compeletely different [_parentLinkModel] model points to. And the compeletely
        // Here we do it:
        //warning//ConditionModelUser has as parent id ConditionModelApp which is not [ConditionModelParentIdModel]
        // IT SEEMS LIKE CONDITIONMODELAPP MUST (edit: it won't) INHERIT FROM CONDITIONMODELPARENTITMODEL
        // OR THERE MUST BE A CLEVER MIXIN THAT IS USED BY BOTH CLASSES IN A WAY THAT
        // CONDITIONMODEL APP DOESN'T DEFINE THE PROPERTIES
        // AND THE METHOD MUST DISTINGUIS WHETHER OR NOT IT USES SOME ASPECT OF THE TWO CLASSES
        // IN METODS LIKE ADDCHILD ADDPARENTLINKMODEL AND THEIR REMOVE VESIONS (SOMETHING ELSE?).
        // ?ALSO TO BE MOVED ARE RELATED METHODS PLUS THESE NEW ONES:
        //?_checkOutIfAModelIsAttachedToMainTheTree()
        //?_getDescendantsFlatListInTheOrderOfTraversing()

        if (
            // Below: to remind you a model may be use in a custom way, then you set the below
            // property to false, which allows using the model
            // and retireModel... must be here first so that more expensive method !_isModelIn..
            // is not unnecessary called which matter when the event [ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree] was issued
            childModel.retireModelWhenWhenRemovedFromTheModelTree &&
                !childModel.isModelInTheTreeOrInsideAParentLinkModel()) {
          // After that we do this
          // different [_parentLinkModel] model is directly in the tree.
          // In case it is then the "this" model cannot be scheduled for removal, its children also
          // will not receive the similar request - each one to be checked whether or not
          // it is attached as a link somewhere else in the model tree.
          // think over carefully - this is really tricky.
          // done, First // do internally (for now only) adding ConditionModelUser
          // with implementing stream events property changes....
          // to remind you: an asynchronous method called retire must finish then the model
          // will be finally removed from the _allAppModelsScheduledForUnlinking list
          // it is a third-party-programmer's undetectable error if a model still has pointer to it left anywhere in the app
          // good info: // What i was afraid of and it is not the case, as i preliminary see
          // we can focus on one model at a time (here + the loop below). If you find
          // a descendant model that is attached somehow in the tree it just wont be removed and
          // won't retire except for the current model that is maybe to be removed.
          _triggerModelRemovalProcess(childModel);

          // Why have i written it below?
          // ???What's going on
          // ???we have first child

          //List<ConditionModelParentIdModel> descendantModels = event.childModel._getModelDescendantsFlatListInTheOrderOfTraversing();
          // WARNING! THE BELOW WAS REMOVED BECAUSE RETIRE METHOD ON ONE MODEL REMOVES CHILDRE USING removeChild ON ALL CHILDREN
          // WHEN MODEL IS TO set _isRetired = true. removeChild issues exactly the same events we exactly are in here in this if else block now
          // BUT IF RETIRE DECIDES NOT TO _isRetired = true THE removechild for children won't be called and the event is issued and handled here
          // SO IT'S GOOD AS IS SEE
          //for (final descendantModel in childModel
          //    ._getModelDescendantsFlatListInTheOrderOfTraversing()) {
          //  if (descendantModel.isModelInTheTreeOrInsideAParentLinkModel() &&
          //      descendantModel.retireModelWhenWhenRemovedFromTheModelTree) {
          //    _triggerModelRemovalProcess(descendantModel);
          //  }
          //}
        }
      }
      // See the related events handling after (?) this else if and the logic behind it
      // There is also a big chance that there is quick review there and also in the retire method about the order of the stuff
      else if (event
          is ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel) {
        // synchronously before the event _lastRetireMethodCall has been updated;
        // important - the switch between the [Set]s will always work because because it is on the event loop but synchronous
        // assume that if from waiting room, not first to _allAppModels but from waiting room directly to unlinking Set is probably no problem. Isn't it?
        if (_allAppModelsNewModelsWaitingRoom.contains(event.model)) {
          _allAppModelsNewModelsWaitingRoom.remove(event.model);
          _allAppModelsScheduledForUnlinking.add(event.model);
        }
      } else if (event
              is ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled
          // this is assumed this is the first and only place to receive this event synchronously to perform essential stuff before anything else
          ||
          event
              is ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution) {
        // TODO: REVIEW: it might be that for now these two events don't need to be handled,
        // because all the retire()-related properties related to the current state of the model should
        // block this instance of ConditionModelApp from removing model as far as i remember from the final
        // list called  [_allAppModelsScheduledForUnlinking] or do other stuff; after month need to recall all the process.

        // THE BELOW REVIEW TAKE FROM THE RETIRE METHOD
        // Review event, timestamps, some other, not all stuff in the right order of occuring:
        // Important, again and again all related to reaction to synchronous aspect of retire call
        // ---------------
        // _lastRetireMethodCall
        // ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustBeenCalledOnModel
        // ---------------
        //
        // _retireMethodItsBodyCodeExecutionLastStart
        // _isRetireMethodBodyAlreadyBeingExecuted == true;
        // ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustStartedItsSynchronousAspectOfBodyCodeExecutionJustAfterItHadBeenCalled
        // --------------------
        // _retireMethodItsBodyCodeExecutionLastFinish // important - always updated when _retireMethodItsBodyCodeExecutionLastStart updated, even when synchronous body exception is thrown
        // _isRetireMethodBodyAlreadyBeingExecuted == false;
        // ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution

        if (event
            is ConditionModelInfoEventConditionModelAppModelSetsManagementRetireMethodHasJustFinishedItsSynchronousAspectOfBodyCodeExecution) {
          //if (event.model) {
          //
          //}
        }
      } else if (event
          is ConditionModelInfoEventConditionModelAppModelSetsManagementModelHasJustRetired) {
        // _oneCycleOfCyclicalRetiringAndUnlinkingModels() calls for a model _oneTimeRetireAndUnlinkModelAction
        // and the latter calls model.retire() method if conditions are met like but it doesn't wait for the completer/future
        // to be retired and remove the model from _allAppModelsScheduledForUnlinking because it must be done synchronously
        // to make sure no model state or some curicial properties change in the meantime.
        // To achieve that this event like the other here is synchronously issued not for no reason.
        // So if it is synchronously issued it should do it's stuff synchronously, because in the retire method already is
        // or maybe something done depending on this synchronous action.
        //
        // to remind this event is issued synchronously the next code line after _isRetired is set to true;
        // important - the switch between the [Set]s will always work because because it is on the event loop but synchronous
        // impoertant any time retire is called model in _allAppModelsNewModelsWaitingRoom is moved to _allAppModelsScheduledForUnlinking
        // so at the moment the model is here _allAppModelsScheduledForUnlinking

        _allAppModelsScheduledForUnlinking.remove(event.model);
      }
    });
  }

  /*ConditionDataManagementDriver get driver {
    return _driver;
  }*/

  /// (From mixin [ConditionModelCompleteModel]) The idea beding this method may be best described in the place where the method was described first. It is in the [ConditionModelParentIdModel] class, but it might has been moved higher to the [ConditionModel] class
  @override
  @protected
  restoreMyChildren() {
    // British restoreMeChildren?
    // NOw it is level "1" because this is ConditionModelApp object, user = 2 - also renders all
    // so no need to use or implement parentMode.parenMode... checking
    // and by this we must render children
    // TODO: levels of restoring children solved a bit different via property restoremychildren or something, right?
    const int level = 1; // we use it or no let it be here not to get confused

    // Here // It is also in Readme.md We have a problem to solve a model may be in the tree or not.
    // [retiremodel... event is issued and handled:] which is determined by a constructor property retireModelWhenWhenRemovedFromTheModelTree
    // One scenario: a model was just properly added by addChild() method
    // related to ConditionConfiguration.maxNotLazyModelTreeRestorationLevel = 3 (?)
    // it's current level in the tree is by parentModel only parentModel.parentModel = null
    // it means my level == 2, so i will restoreMyChildren(), but my child will not (or so)
    // the level may change however when a model will be detached but used elsewhere without
    // a parent if it is allowed to do so (~standalone constructor property setter retireModelWhenWhenRemovedFromTheModelTree)
    // [eIDT:] conclusion !!!!!!!!!!!!!!!!!!!!!!!!
    // the properties decide initial number of levels, NEW PROPERTY IS NEEDED - BELOW:
    // So WHEN IT IS USED ALSO STANDALONE, WHENEVER IT CHANGES TO TRUE (CAN IT?)
    // a property ConditionConfiguration.maxNotLazyModelTreeRestorationLevelForStandaloneModels
    // will is used for the model as initial number of levels that are going to be restored on
    // start
    // IT WILL RENDER ALL IT'S LEVELS AS IT WAS THE TOP LEVEL MODEL.
    // AND IF IT IS A CONACT IT WILL RESTORE ALL ITS SUBCONTACTS. tHIS DOESNT CONSIDER LEVELS

    if (!this._children.isEmpty) {
      throw Exception(
          'restoreMyChildren() of ConditionModelApp override method: To restore this model\'s children models the _children property must be empty - must be this._children.isEmpty == true');
    }

    debugPrint(
        'restoreMyChildren() of ConditionModelApp: let\'s get into a loop creating last logged-in users.');
    // _children (users);
    // activeUser;

    // educationally this['this['currently_logged_users_ids'] will never throw exception, it will return null instead but currently_logged_users_ids property may throw it if the property.value (getter) hasn't gotten any value yet (late initialisation error)
    if (this['currently_logged_users_ids'] != null &&
        currently_logged_users_ids!.isNotEmpty) {
      debugPrint(
          'restoreMyChildren() of ConditionModelApp is not empty and not null: currently_logged_users_ids!.isNotEmpty');

      if (ConditionConfiguration.debugMode &&
          ConditionConfiguration.initDbStage != null &&
          ConditionConfiguration.initDbStage! >= 2) {
        scheduleMicrotask(() async {
          try {
            String localServerUsersCommand = '''
              INSERT INTO "t8QjKjA_ConditionModelUser" ("id", "app_id", "local_id", "to_be_synchronized", "e_mail", "phone_number", "password", "server_id", "local_server_login", "local_server_key", "one_time_insertion_key", "server_one_time_insertion_key", "url_alias", "creation_date_timestamp", "server_creation_date_timestamp", "update_date_timestamp", "server_update_date_timestamp", "parent_id", "server_parent_id", "user_id") VALUES (1,	123,	1,	1,	'adfafaasdfasfafaasfasfsf1@gmail.com.debug',	NULL,	'r!igPn94#95',	3,	NULL,	NULL,	NULL,	NULL,	NULL,	12121212,	NULL,	NULL,	NULL,	NULL,	NULL,	0);
              INSERT INTO "t8QjKjA_ConditionModelUser" ("id", "app_id", "local_id", "to_be_synchronized", "e_mail", "phone_number", "password", "server_id", "local_server_login", "local_server_key", "one_time_insertion_key", "server_one_time_insertion_key", "url_alias", "creation_date_timestamp", "server_creation_date_timestamp", "update_date_timestamp", "server_update_date_timestamp", "parent_id", "server_parent_id", "user_id") VALUES (2,	123,	2,	1,	'adfafaasdfasfafaasfasfsf2@gmail.com.debug',	NULL,	'r!igPn94#95',	2,	NULL,	NULL,	NULL,	NULL,	NULL,	12121212,	NULL,	NULL,	NULL,	NULL,	NULL,	0);
              INSERT INTO "t8QjKjA_ConditionModelUser" ("id", "app_id", "local_id", "to_be_synchronized", "e_mail", "phone_number", "password", "server_id", "local_server_login", "local_server_key", "one_time_insertion_key", "server_one_time_insertion_key", "url_alias", "creation_date_timestamp", "server_creation_date_timestamp", "update_date_timestamp", "server_update_date_timestamp", "parent_id", "server_parent_id", "user_id") VALUES (3,	123,	3,	1,	'adfafaasdfasfafaasfasfsf3@gmail.com.debug',	NULL,	'r!igPn94#95',	1,	NULL,	NULL,	NULL,	NULL,	NULL,	12121212,	NULL,	NULL,	NULL,	NULL,	NULL,	0);
            ''';
            String globalServerUsersCommand = '''
              INSERT INTO "Rzi3a7d_ConditionModelUser" ("id", "app_id", "local_id", "to_be_synchronized", "e_mail", "phone_number", "server_id", "password", "local_server_login", "local_server_key", "one_time_insertion_key", "server_one_time_insertion_key", "url_alias", "creation_date_timestamp", "server_creation_date_timestamp", "update_date_timestamp", "server_update_date_timestamp", "parent_id", "server_parent_id", "user_id") VALUES (1,	123,	3,	1,	'adfafaasdfasfafaasfasfsf3@gmail.com.debug',	NULL,	1,	'r!igPn94#95',	NULL,	NULL,	NULL,	NULL,	NULL,	12121212,	NULL,	NULL,	NULL,	NULL,	NULL,	0);
              INSERT INTO "Rzi3a7d_ConditionModelUser" ("id", "app_id", "local_id", "to_be_synchronized", "e_mail", "phone_number", "server_id", "password", "local_server_login", "local_server_key", "one_time_insertion_key", "server_one_time_insertion_key", "url_alias", "creation_date_timestamp", "server_creation_date_timestamp", "update_date_timestamp", "server_update_date_timestamp", "parent_id", "server_parent_id", "user_id") VALUES (2,	123,	2,	1,	'adfafaasdfasfafaasfasfsf2@gmail.com.debug',	NULL,	2,	'r!igPn94#95',	NULL,	NULL,	NULL,	NULL,	NULL,	12121212,	NULL,	NULL,	NULL,	NULL,	NULL,	0);
              INSERT INTO "Rzi3a7d_ConditionModelUser" ("id", "app_id", "local_id", "to_be_synchronized", "e_mail", "phone_number", "server_id", "password", "local_server_login", "local_server_key", "one_time_insertion_key", "server_one_time_insertion_key", "url_alias", "creation_date_timestamp", "server_creation_date_timestamp", "update_date_timestamp", "server_update_date_timestamp", "parent_id", "server_parent_id", "user_id") VALUES (3,	123,	1,	1,	'adfafaasdfasfafaasfasfsf1@gmail.com.debug',	NULL,	3,	'r!igPn94#95',	NULL,	NULL,	NULL,	NULL,	NULL,	12121212,	NULL,	NULL,	NULL,	NULL,	NULL,	0);            
            ''';

            debugPrint(
                'restoreMyChildren() of ConditionModelApp we want to directly insert into some example default users to the global and local server the commands for the local and global server are like this correspondingly:');

            debugPrint(localServerUsersCommand);
            debugPrint(globalServerUsersCommand);
            // for debug tests we want have driverGlobal ready now, local driver is ready already.
            // default settings should have global server != null:
            ConditionDataManagementDriverSql debugDriverGlobal = await driver
                .driverGlobal!
                .initCompleter
                .future as ConditionDataManagementDriverSql;
            debugPrint(
                'restoreMyChildren() of ConditionModelApp #etrwpoiejw#^%#^q3: 1');
            // !!! for sqlite3 plugin these operations are synchronous
            (driver as ConditionDataManagementDriverSql)
                ._db
                .db
                .execute(localServerUsersCommand);
            debugPrint(
                'restoreMyChildren() of ConditionModelApp #etrwpoiejw#^%#^q3: 2');
            debugDriverGlobal._db.db.execute(globalServerUsersCommand);
            debugPrint(
                'restoreMyChildren() of ConditionModelApp direct insert users success !!!');
          } catch (e) {
            debugPrint(
                'ConditionModelApp class, restoreMyChildren() method exception during inserting debug data, at this stage number 2 (verify if up-to-date info) users for both local and global server are to be created. The exception will be rethrown with it\' message that you are going to see after this message. Example command flutter run -d windows --debug -a debugging -a initDbStage=3 but this is stage 2');
            rethrow;
          }
        });
      }

      for (String loggedId
          in (currently_logged_users_ids as String).split(',')) {
        debugPrint(
            'reloginAllLoggedUsers(): let\'s re-create user model of id == $loggedId and ad it to the this.loggedUsers list.');
        // addChild desc this guarantiees that user will be inited when added using addChild
        // as for now [ConditionModelUser] objects must be inited == true to be added into the model tree.
        // as mentioned in readme and in ConditionConfiguration.maxNotLazyModelTreeRestorationLevel description
        // we may need to create all logged users and all the tree of ConditionModelContact of those
        // users - but all contacts only if the concept of data channels would be implemented.
        scheduleMicrotask(() async {
          // se earlier above command - this is to make sure that in debug mode and initing db with some data
          // this code was not performed before the above code where we insert to the db some test users
          // by using direct sql commands - so the users are in the db now and we restore them from the db
          if (ConditionConfiguration.debugMode &&
              ConditionConfiguration.initDbStage != null &&
              ConditionConfiguration.initDbStage! >= 2) {
            await driver.initCompleterGlobal!.future
                as ConditionDataManagementDriverSql;
          }
          final loggedIdInt = int.parse(loggedId);
          addChild(
              // BTW: this syntax dart language provides is just brilliant:
              await ConditionModelUser(
                      this,
                      currently_active_user_id != null &&
                              loggedIdInt == currently_active_user_id
                          ? true
                          : false,
                      {'id': loggedIdInt}).getModelOnModelInitComplete()
                  as ConditionModelUser);
        });
      }
    } else {
      // Universal page. Let's say there is 0, one or two logged users and you want to login next.
      setUpRegistrationLoginPage();
    }
    //ConditionModelUser(conditionModelApp, parentModel, {'id'});
  }

  // Universal page triggered in different ways - when there is no logged user out of many you could have logged-in, or you want to add register first or another user. at the same time. Let's say there is 0, one or two logged users and you want to login next.
  setUpRegistrationLoginPage() {
    throw Exception(
        'ConditionModelApp setUpRegistrationLoginPage() not impelmented');
  }

  /// all children must be added through an addChild method. However this is a custom addChild method implementation because [ConditionModelApp] extends the [ConditionModel] not the [ConditionModelParentIdModel] which all the rest of the model object use. It accepts only [ConditionModelUser]s because the app object can only have them as direct descendants. So at the moment of writing when you add [ConditionModelUser] child here it must be [inited] and addChild() of [ConditionModelParentIdModel] and if the parentModel (this in addChild()) is [ConditionModelUser] it must be already inited. The rest of classess are not required to be so. And there is some description there either
  @protected
  bool addChild(ConditionModelUser childModel) {
    // solved, here issue // non user widget allegedly has server_update_date_timestamp != null but it was not even created on the server side, not mentioning updating, but correctly there is no server create timestamp.
    // Also there is for this [To do 4#sf9q!!!gh49hsg9374:]
    // and temporarily solusions existed already and they are a bit improved until the to do will be taken care of
    // another problem is for global server - if there is no access to the internet
    // check if there is a risk that await for server_id can be long not finished
    // but in the meantime a function was called 1000 of times - there will be too much pending awaits
    try {
      if (childModel._parentModel !=
          null) {} // exception thrown when not initialized
    } catch (e) {
      childModel._parentModel = null;
    }

    // At the moment of writing this piece of code no retirement for ConditionModelUser was well thought of
    // Maybe no retirement for ConditionModelUser will ever be needed but...
    // See similar condition below compeletely comented for conditionmodelapp
    if (childModel.isRetired) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: The model cannot be added if it already has retired. Such model cannot be used and be unlinked - there should be no references left by the third-party programmer. The Condition library/framework also internally removes the remaining links as soon as it is able to.');
    } else if (childModel.isRetireMethodBodyAlreadyBeingExecuted ||
        childModel.isRetirementProcessPending) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: The model cannot be added when it is in the process of retirement. Add the model if it is not retired and the process triggered by the retire method finished with false result (more properties can be found to help, possibly synchronous too, but the more async completer/future returned by the retire method may be enough.)');
    }

    // At the moment of writing this piece of code no retirement for ConditionModelApp was planned
    // if (isRetired) {
    //   throw Exception(
    //       'ConditionModelParentIdModel addChild method: The parent model cannot accept another child if the parent already has retired. Such model cannot be used and be unlinked - there should be no references left by the third-party programmer. The Condition library/framework also internally removes the remaining links as soon as it is able to.');
    // } else if (isRetireMethodBodyAlreadyBeingExecuted || isRetirementProcessPending) {
    //   throw Exception(
    //       'ConditionModelParentIdModel addChild method: The parent model cannot accept another child if the parent is in the process of retirement. Add the model if it is not retired and the process triggered by the retire method finished with false result (more properties can be found to help, possibly synchronous too, but the more async completer/future returned by the retire method may be enough.)');
    // }

    // this is copied and slightly changed (Exceptions messages) from the original addChild of [ConditionModelParentIdModel] class (or so)
    if (!inited) {
      throw Exception(
          'ConditionModelApp addChild method: this object and at the same time [ConditionModelApp] object is not yet inited == true so it is not allowed to add a child/children to itself.');
    } else if (!childModel.inited) {
      throw Exception(
          'ConditionModelApp addChild method: a child (childModel) object and at the same time [ConditionModelUser] object is not yet inited == true so it cannot be added as a child to the model tree (cannot go into _children property).');
    } else if (childModel._parentModel != null) {
      throw Exception(
          'ConditionModelApp addChild method: The model cannot be added to a second place. It is already both in the proper tree and in the in\'s one unique place. However you can use the model outside the tree as a separete whole independent model or tree of models in some custom way, but not into the ConditionModelApp object\'s tree.');
    } else if (!identical(this, childModel.conditionModelApp)) {
      throw Exception(
          'ConditionModelApp addChild() method: You can only use two model belonging to The same [ConditionModelApp] - conditionModelApp property of [ConditionModelIdAndOneTimeInsertionKeyModel] (that was the name of the class at the time of writing this exception message)');
    } else if (_children.contains(childModel)) {
      // For errors is exception. But False ok - the model already is ont the [_children] list
      //childModel._changesStreamController.add(ConditionModelPropertyChangeInfoModelWontBeAddedBecauseItIsAlreadyInTheTreeNothingChanged(this, childModel));
      throw Exception(
          'ConditionModelApp addChild() method: you can\'t add the same child for the second time. If you do this it implies that a piece of code is written wrongly. If you really must have such an option check if the model you are trying to the tree is already in the tree');
      //return false;
      // throw Exception ('ConditionModel addChild method: You are trying to add a model that already exists in the tree. As for now it is considered a wrong design of a piece of code to do such a thing (but in your (developer) case that might be not the case). But you can catch the exception and it\'s fine, the model has been already there, it should\'t damage the app workings at all.');
    }

    _children.add(childModel);
    //  COPIED FROM OTHER ADD CHILD - DOES IT RELATE?
    // Warning !!! Don't change the order of stream events (_changesStreamController) because
    // the conditionModelApp object have all models streams and it reacts synchronously to
    // the [ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel]
    // that is just below in this method
    childModel._parentModel =
        null; // [ConditionModelUser]s never have parent id
    childModel._isModelInTheModelTree = true;
    childModel._changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree(
            this, childModel));
    // COPIED FROM OTHER ADD CHILD - DOES IT RELATE?
    // Warning !!! Don't change the order of stream events (_changesStreamController) because
    // the conditionModelApp object have all models streams and it reacts synchronously to
    // the [ConditionModelInfoEventModelTreeOperationModelHasJustBeenAddedToTheModelTree]
    // that is just above in this method
    _changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel(
            this, childModel));
    return true;
  }

  /// Caution! Some related stuff may be handled synchronously by the _changesStreamController stream event receipients. Some important info in [addChild]() of this class description and differences in implementation from [ConditionModelParentIdModel] class's addChild
  removeChild(ConditionModelUser childModel) {
    // See The exception message below and: child won't be retired or remove from conditionModelApp if model is not inited == true (or similar name)
    try {
      throw Exception(
          'Catched old exception. Problems solved, retire and removal from conditionModelApp impossible when local erver inited is false. Much if not all stuff was solved in this way or the other- probably. Old exception message: removeChild() of ConditionModelApp class: of See README.md[To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31] : related pretty much stuff not implemented. Especially ConditionModelApp model (not the parentModel) must make sure the child is inited on the locall server before it is removed and retired. The second it cannot be removed at this stage of the library/app development until the child is globally inited with it\'s children and further descentants too. the mentioned to do has steps to implement before this exception is removed');
    } catch (e) {
      debugPrint('$e');
    }

    if (!_children.contains(childModel)) {
      throw Exception(
          'ConditionModelApp removeChild() method: Model cannot be removed from the model tree, because it is not in the model tree.');
      //childModel._changesStreamController.add(ConditionModelPropertyChangeInfoModelWontBeRemovedBecauseItIsAlreadyNotInTheTreeNothingChanged(this, childModel));
      //throw Exception ('ConditionModel removeChild method: You are trying to remove a model (childModel) that is not in the tree. As for now it is considered a wrong design of a piece of code to do such a thing (but in your (developer) case that might be not the case). But you can catch the exception and it\'s fine, the model has been already there, it should\'t damage the app workings at all.');
      //return;
    }

    childModel._parentModel = null;
    _children.remove(childModel);
    // COPIED FROM OTHER ADD CHILD - DOES IT RELATE?
    childModel._isModelInTheModelTree = false;
    // Warning !!! Don't change the order of TWO stream events BELOW (_changesStreamController)
    // because the conditionModelApp object have all models streams and it reacts synchronously
    // to the [ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved]
    // NOT TO [ConditionModelInfoEventModelTreeOperationModelHasJustBeenRemovedFromTheModelTree]
    childModel._changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustBeenRemovedFromTheModelTree(
            this, childModel));
    _changesStreamController.add(
        ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved(
            this, childModel));
  }

  /// Used by initCompleteModel in two scenarios so the code is moved to the method here so that not to be used twice
  _requestGlobalServerAppKeyOnceAndThenPeriodically() async {
    try {
      debugPrint(
          'class [ConditionModelApp] _requestGlobalServerAppKeyOnceAndThenPeriodically() trying to set up the server_key value');
      String serverKeyTemp = await driver.driverGlobal!
          .requestGlobalServerAppKey()
          .timeout(const Duration(
              seconds:
                  12)); // leave 12 seconds for global server operations worst but successful case scenarion, f.e. sqlite3 db file was blocked by heavy trafic, three attempts of internal server operations to obtain the key for the app which are going to be performed in about 6 seconds for three internal method invokations + 6 seconds for internal db operations themselves

      debugPrint(
          'class [ConditionModelApp] _requestGlobalServerAppKeyOnceAndThenPeriodically() trying to set up the server_key - just now it is about to be set up server_key = $serverKeyTemp');
      a_server_key._fullyFeaturedValidateAndSetValue(
          serverKeyTemp, true, true, true);
      serverKeyReadyCompleter.complete(true);

      // FIXME: #oqx^oq8347x6q874t,
      // First, this happend only on FIRST SHIFT R HOT RELOAD, AND MAY NOT HAPPEN IN PRODUCTION IN REAL LIFE.
      // But before the first shift r reload the table exists.
      // SO JUST TO REMEMBER.
      // look like this error shouldn't ever happen and the cause of that is difficult to find.
      // run chrome --debug FIRST shift R/hot reload and local server only - all tables are created if not exist from scratch because t8QjKjA_ConditionModelClasses couldn't has been found
      // but the second shift R/hot reload is ok, no tables are "created" so the key of id = 2 is used every next hot reload
      // original command flutter run -d chrome --debug -a debugging -a initDbStage=3
      // from console:
      // SELECT count(*) FROM t8QjKjA_ConditionModelClasses;
      // table doesn't exist, so no relevant table with initial data exists, db wrapper exception thrown: SqliteException(1):
      // while preparing statement, no such table: t8QjKjA_ConditionModelClasses, SQL logic error (code 1)
      //   Causing statement:           SELECT count(*) FROM t8QjKjA_ConditionModelClasses;

      debugPrint(
          'class [ConditionModelApp] _requestGlobalServerAppKeyOnceAndThenPeriodically() trying to set up the server_key - just now should has been set up and is this[\'server_key\'] = ${this['server_key']}');
    } catch (e) {
      debugPrint(
          'class [ConditionModelApp] _requestGlobalServerAppKeyOnceAndThenPeriodically(), method initCompleteModel() error (async ExceptionType: e.runtimetype == ${(e is Exception) ? e.runtimeType.toString() : 'The error object is not an Exception class object.'}): After initiation of the model it revealed that server_key property is null, the key is needed to send and receive data (which means synchronize local server data with the remote global server), so setting server_key up failed. Not a big deal it will be set up at a later point in time as needed (now setting up cyclical checking out using Timer.periodic), and data synchronized. Exception thrown: $e');

      // INFO: SOME SOLUTIONS LIKE BELOW MIGHT NEED MORE SOPHISTICATED SOLUTIONS
      Timer.periodic(Duration(seconds: 13), (timer) async {
        try {
          debugPrint(
              'class [ConditionModelApp] _requestGlobalServerAppKeyOnceAndThenPeriodically() PERIODIC trying to set up the server_key value');
          String serverKeyTemp = await driver.driverGlobal!
              .requestGlobalServerAppKey()
              .timeout(const Duration(seconds: 12));
          // it probably might be that the method will be called one time too much
          a_server_key._fullyFeaturedValidateAndSetValue(
              serverKeyTemp, true, true, true);
          serverKeyReadyCompleter.complete(true);
          debugPrint(
              'class [ConditionModelApp] _requestGlobalServerAppKeyOnceAndThenPeriodically() PERIODIC to set up the server_key - just now should has been set up server_key = $server_key');

          if (timer.isActive) {
            timer.cancel();
          }
        } catch (e) {
          debugPrint(
              'class [ConditionModelApp], method initCompleteModel() trying to periodically get te server_key error (probably timeout, read more, async ExceptionType: e.runtimetype == ${(e is Exception) ? e.runtimeType.toString() : 'The error object is not an Exception class object.'}): After initiation of the model it revealed that server_key property is null, the key is needed to send and receive data (which means synchronize local server data with the remote global server), so setting server_key up failed. Not a big deal it will be set up at a later point in time as needed, and data synchronized. Exception thrown: $e');
        }
      });
    }
  }

  /// Read carefully, this entire "subcycle" is called here cyclically along with other method(s), the cycle is triggered in initCompleteModel() method. What does it mean that this method handles a subcycle, basically you are to asses the resources consuming actions and f.e. 10 actions try to divide in a way that you try to perform f.e. one action per call. Make sure that no action is started before another is in progress also make the same sure that the other methods cyclically called do not jam the whole process. Rethink how the timer intervall act and related async issues.
  _oneCycleOfGettingUpdatesFromOrToTheGlobalServer() {
    // to do :)
  }

  @override
  initCompleteModel() async {
    // yeah, just to await, for now din\'t plan what to do in case of exception
    // but at least for the !local driver it is like it will "always" work
    // you may block because you must have local server (static version of the models is in store),
    await driver.getDriverOnDriverInited();

    debugPrint('!!We\'ve entered the initCompleteModel() ');
    bool allowForUsersRelogin = false;
    try {
      // if the model is read successfuly from local server the server_key
      // want be set up normaly it will go to serverKeyHelperContainer setter
      // then if the global server still hadles it and considers valid
      // it will be set up as server_key

      await initModel(); // initModel returns "this". We just need to wait until it finishes it ofcourse is always true.
      bool isInited = true;
      debugPrint(
          'Custom implementation of initCompleteModel() the value of isInited == $isInited : Model of [ConditionModelApp] has been inited. Now we can restore or not f.e. last logged and last active user or whatever.');
      debugPrint('The value of model.inited is: $inited');
      debugPrint(
          'Let\'s try to automatically relogin all logged users and then to bring to screen\'s front the last active logged in user with some of his/her lazily logged widgets');
      allowForUsersRelogin = true;
      debugPrint('!!!!!!!!!!!!!!!!!!!!! 22222 WE ARE HERE ');
    } catch (e) {
      // ARE WE GOING TO USE NOT ENDLESSLY INVOKED TIMER TO invoke initModel() again with some addons if necessary? Some properties might has been set already.
      debugPrint('!!!!!!!!!!!!!!!!!!!!! 11111 WE ARE HERE ');
      debugPrint(
          'Custom implementation of initCompleteModel(): Model of [ConditionModelApp] hasn\'t been inited. The error of a Future (future.completeError()) thrown is $e');
      rethrow;
    }

    // Notification: You might want to change this timer so that manages it's subtimers. Now one timer makes it all.
    // While this is performed every 5 seconds the _oneCycleOfCyclicalRetiringAndUnlinkingModels() method has it's own clock
    // and the clock allows to execute fully the method after a 10 second break so the longest period might be 10 + 5 = 15 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) {
      // this is done in the method classed beoow if (!_allAppModelsScheduledForUnlinking.isEmpty) {
      if (ConditionModelApps
          ._allowForThisCycleOfOverallCyclicallyPerformedOperationsOnTheApp(
              this)) {
        _oneCycleOfCyclicalRetiringAndUnlinkingModels();
        _oneCycleOfGettingUpdatesFromOrToTheGlobalServer();
      }
      //}
    });

    /// ! Important: this part was previously at the bottom of the function. However global
    /// server cannot block the app rendering on the screen. All you have on you local server
    /// is enough to start rendering based on what you store in your local server.
    ///
    if (allowForUsersRelogin) {
      restoreMyChildren();
    }

    // INFO: SOME SOLUTIONS LIKE BELOW MIGHT NEED MORE SOPHISTICATED SOLUTIONS
    // ok, for now we need to have the server key if it is not set-ip because it is a new installation or completely new app object (two or more are possible)
    // bu we cannot wait for too long to get the global server app key, and
    // we assume that the server doesn't need to install itself creating tables
    // what takes some time - THE GLOBAL SERVER IS READY. So couple of seconds to finish the operation
    // In an emergency situation you need to wait for the internet connection or
    // server availability anyway so max ten second is not too long and balanced approach
    if (null != driver.driverGlobal) {
      try {
        await driver.driverGlobal!.getDriverOnDriverInited();
        // INFO: SOME SOLUTIONS LIKE BELOW MIGHT NEED MORE SOPHISTICATED SOLUTIONS
        // this may fail as the remote global server may be unavailable or there is no internet connetino at the moment
        // In an emergency situation you need to wait for the internet connection or
        // server availability anyway so max ten second is not too long and balanced approach
        debugPrint(
            'class [ConditionModelApp], method initCompleteModel() now awaiting for up to 12x2=24 seconds to get server_key from the global server of the [ConditionModelApp] object representing one app instance (may be one or more)');
        // Again: doing this one time await allows for quicker and smoother data updates/synchronisation to global server
        // because we can immediatelly use the server_key
        // otherwise the data to be updated will be read from the database in less efficient way
        // one change per some period, probably more dg table columns than only one changed for example
        // yet to be designed :)
        if (null != serverKeyHelperContainer) {
          if (serverKeyHelperContainer!.isEmpty) {
            debugPrint(
                'initCompleteModel(): [ConditionModelApp] class we are throwing error because canTheKeyBeUsed == false, no db operation caused this error. This particular exception is not a problem, it is an option to avoid more sophisticated approach');
            // must be error here because at the moment of writing this comment an exception would allow for generation new key, but first MUST the temporary key be check out properly
            throw Error();
          }
          // it means that read() from the local server has been engaged to restore the model
          // and serverKeyHelperContainer setter/getter has been set up
          // if we can use it we will set up the final server_key if
          // we cannot use it because it is invalid we create a new one

          try {
            debugPrint(
                'class [ConditionModelApp], method initCompleteModel() We are now going to check out if we can use the locally (in the local server) stored server_key canTheKeyBeUsed waiting for success or exception');
            bool canTheKeyBeUsed = await driver.driverGlobal!
                .checkOutIfGlobalServerAppKeyIsValid(
                    (serverKeyHelperContainer as String))
                .timeout(const Duration(seconds: 12));
            debugPrint(
                'class [ConditionModelApp], method initCompleteModel() can we use server_key? : canTheKeyBeUsed == $canTheKeyBeUsed ');
            if (!canTheKeyBeUsed) {
              debugPrint(
                  'class [ConditionModelApp], method initCompleteModel() result of checkOutIfGlobalServerAppKeyIsValid is that: because as already said we cannot use the key we need to get a new one and set it up for server_key property using _requestGlobalServerAppKeyOnceAndThenPeriodically');
              // reading the full condition this method will cause setting up a NEW value
              // to server_key in normal way - it will be synchronized with global server
              // IS THIS MODEL CLASS SYNCHRONIZED WITH GLOBAL SERVER? NO? DONT REMEMBER :)
              await _requestGlobalServerAppKeyOnceAndThenPeriodically();
            } else {
              debugPrint(
                  'class [ConditionModelApp], method initCompleteModel() SUCCESS  result of checkOutIfGlobalServerAppKeyIsValid is that:- The key can be used so we set up server_key with the value we can use, for some internals see comments where this printed message is in the code');
              // now we can set up the final property, and we can do it once for this object life cycle.
              // but!!! the model is already inited in this case it is from read() method (readRawer?)
              // and we have to set the !!! server_key value using different way
              // not to trigger any synchronization with global server but just validating beforehand
              a_server_key._fullyFeaturedValidateAndSetValue(
                  serverKeyHelperContainer as String, true, false, true);
              serverKeyReadyCompleter.complete(true);
            }
          } catch (e) {
            debugPrint(
                'initCompleteModel(): [ConditionModelApp] class exception during checking out if we can use serverKeyHelperContainer setter/getter key read using read() model data method. Another attempts to set up the server_key later will be made. The error was: $e');
          }
        } else {
          await _requestGlobalServerAppKeyOnceAndThenPeriodically();
        }
      } catch (e) {
        debugPrint(
            'initCompleteModel(): [ConditionModelApp] class, driver.driverGlobal!.getDriverOnDriverInited() not able to init global driver, error: $e only local server can be used');
      }
    }
  }

  void init(ConditionWidgetBase widget) {
    this.widget = widget;
  }

  /*ConditionWidgetBase get widget {
    return this._widget;
  }*/

  @override
  void operator []=(key, value) {
    debugPrint('yerttttt1____' + key);

    switch (key) {
      case 'server_key':
        server_key = value;
        break;
      case 'users_counter':
        users_counter = value;
        break;
      case 'currently_active_user_id':
        currently_active_user_id = value;
        break;
      case 'currently_logged_users_ids':
        currently_logged_users_ids = value;
        break;
      case 'users_ids':
        users_ids = value;
        break;
      default:
        super[key] = value;
        break;
    }

    //this.defValue[key] = value;
  }

  @protected
  set server_key(String? value) {
    debugPrint('server_key setter: stage 1');
    a_server_key.validateAndSet(value);
    debugPrint('server_key setter: stage 2');
    if (server_key != null && server_key!.isNotEmpty) {
      debugPrint('server_key setter: stage 3');

      serverKeyReadyCompleter.complete(true);
      debugPrint('server_key setter: stage 4');
    }
  }

  String? get server_key => defValue['server_key'].value;
  Future<bool> getServerKeyWhenReady() {
    return serverKeyReadyCompleter.future;
  }

  @protected
  set users_counter(int? value) => a_users_counter.validateAndSet(value);
  int? get users_counter => defValue['users_counter'].value;
  @protected
  set currently_active_user_id(int? value) =>
      a_currently_active_user_id.validateAndSet(value);
  int? get currently_active_user_id =>
      defValue['currently_active_user_id'].value;
  @protected
  set currently_logged_users_ids(String? value) =>
      a_currently_logged_users_ids.validateAndSet(value);
  String? get currently_logged_users_ids =>
      defValue['currently_logged_users_ids'].value;
  @protected
  set users_ids(String? value) => a_users_ids.validateAndSet(value);
  String? get users_ids => defValue['users_ids'].value;
}

/// all properties are not used in code
@Stub()
class ConditionModelUser extends ConditionModelWidget
    implements ConditionModelCompleteModel {
  // id property is defined in parent class

  /// email field as you can see
  @BothAppicationAndServerSideModelProperty()
  late ConditionModelFieldStringOrNull a_e_mail =
      ConditionModelFieldStringOrNull(this, 'e_mail',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  /// phone number field as you can see. contact with no e-mail nor phone number is a group to make matters simple, and this is left for this models's widget how to interpret it.
  @BothAppicationAndServerSideModelProperty()
  late ConditionModelFieldStringOrNull a_phone_number =
      ConditionModelFieldStringOrNull(this, 'phone_number',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  @BothAppicationAndServerSideModelProperty()
  late ConditionModelFieldString a_password = ConditionModelFieldString(
      this, 'password',
      propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
          .both_app_and_server_synchronized); // a field in DB can be null

  /// Each server is a local one and global one. You log in to the local aspect of the server always and only when you are connected to a local hotspot/network server (f.e. I.P. like 192.168...) or using bluetooth, or any similar direct device to device way (or directly device -> device -> device). Using this property you don't need to use login and password. Read to the end. If you don't refuse to log in this way, based on this key when you disconnect your devices you will be able send to eachother f.e. messages via the global server (the public globally accessed earthwide globa server). It is the most recommended way to log in using this property which first is negotiated and set up automatically by the host app. This should be completely enough to log in locally. But after app reinstall you loose this key so you can also set up your [_local_server_login] property using with standard [_password] property. Users/Models are attached to an app id/key on the global server side so when you login to global server this password doesn't work. Finally if client reinstalls his/her app he can use [_local_server_login] and [_password] if he is successful he gets the key [_local_server_key] and it is used for communication.
  @BothAppicationAndServerSideModelProperty()
  late ConditionModelFieldStringOrNull a_local_server_key =
      ConditionModelFieldStringOrNull(this, 'local_server_key',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  /// phone number field as you can see. contact with no e-mail nor phone number is a group to make matters simple, and this is left for this models's widget how to interpret it.
  @BothAppicationAndServerSideModelProperty()
  late ConditionModelFieldStringOrNull a_local_server_login =
      ConditionModelFieldStringOrNull(this, 'local_server_login',
          propertySynchronisation: ConditionModelFieldDatabaseSynchronisationType
              .both_app_and_server_synchronized); // a field in DB can be null

  /// Read all description carefully. You must specify it in the constructor with a reason. When "true" it tells user model to prepare it's models and widget (widget subtree), but if false it will should maintain some set of models to function properly (see not implemented constact data channels) because it is not active but logged in. ConditionModelApp (so no need to use changes stream events) only uses a setter/getter _isActive (one underscore) which also triggers some related actions. With this set true No need to check if an object is logged in or out only active, Because a parent model - in this case always [ConditionModelApp] will remove it's child when it is logged out then a removed child's method retire will be called. Then user model object knows it is logged out
  bool __isActive;

  set _isActive(bool value) {
    __isActive = value;
  }

  bool get _isActive => __isActive;

  ConditionModelUser(
    conditionModelApp,
    this.__isActive,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
  }) : super(conditionModelApp, null, defValue,
            hangOnWithServerCreateUntilParentAllows: false) {
    a_e_mail.init();
    a_phone_number.init();
    a_password.init();
    a_local_server_key.init();
    a_local_server_login.init();
    initCompleteModel();
  }

  restoreMyChildren() {
    // All stuff in debug mode is for educational purposes, this is set up in the main.dart main() method (see there) file and related to the commandline parram
    if (ConditionConfiguration.debugMode) {
      // READ IT FIRST: ALL BELOW SHOULD BE FOLLOWED BY THE PATTERN SET UP IN ConditionModelApp
      // version of the method - of course flexibly.

      // let's add a testing widget like contact and messages with local servr in mind

      //Watch// out READ THIS BELOW:
      // Edit: the problem is that you don't need to have server_id or server_contact_owner_id
      // NOT NOW you need to have it later so you can create part of a tree, where
      // it maybe that one part ot the part is not global server valid (no user found f.e)
      // and it is rejected asynchronously and you are invited to correct some stuff
      // but you can send to nobody your messages in the meantime which will be updated on the
      // global server with server_id etc.
      // BUT id local server object of the parent model because the internet may be off
      // then when ad new contact or other widget model is invalid it is not synchronized
      // and marked for changes or removal - think over again
      // for the app to create a contact ant put it into the tree
      // you need server_id or server_contact_owner_id or server_parent_id to send messages
      // i dont know what i was thinking about
      // !! it is related to addChild and removeChild (_children) property
      // THINK IT OVER AGAIN
      // =======================================

      // if we want to catch all the changes to a model we need to create out own stream controller
      // and to listen and get a stream subscription before a model is created.
      var contactChangesStreamController =
          StreamController<ConditionModelInfoStreamEvent>.broadcast();
      ConditionModelContact contactdebug;
      StreamSubscription<ConditionModelInfoStreamEvent>
          contactChangesStreamSubscription;
      contactChangesStreamSubscription =
          contactChangesStreamController.stream.listen(null);

      //model._completerInitModelGlobalServer.future
      //_changesStreamController.add(ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenInitedGlobalServer(this));

      // qw
      // as // far as i remember this waiting for server_id and more is implemented different way
      // with init model global server completer or something, it takes into account the
      // type of model class so it could be possibly solved in more than way
      // let's do in this commit/push more than one ways to train/educate ourselves.
      int operateOnTheModelCounter = 0;
      contactChangesStreamSubscription.onData((event) {
        // EDUCATIONAL. As for now instead of waiting  for contactChangesStreamSubscription stream events
        // AT PRESENT we could als use different if condition with awaits:
        // await a_server_id.firstValueAssignement() future
        // await a_server_owner_contact_id.firstValueAssignement() future
        // which may not be necessary because because some model architecture was updated
        // in the meantime.
        if (event
                is ConditionModelInfoEventPropertyChangeRegularChangeFirstChange &&
            ((this is ConditionModelContact && event.name == 'server_id') ||
                (this is ConditionModelBelongingToContact &&
                    (event.name == 'server_id' ||
                        event.name == 'server_owner_contact_id')))) {
          operateOnTheModelCounter++;
          // Some code is not necessary - for legacy debug purposes i will leave it now as it is
          // contactdebug ALWAYS IS NOT ConditionModelUser PROBABLY I MEANT IT AS A RULE TO SOMEWHERE ELSE usage
          if (this is! ConditionModelUser) {
            // when we create a typical model we need to pass parent model if it is not a top model widget
            // if the model is detected automatically parent/owner properties are to be set
            // contactdebug ALWAYS IS ConditionModelContact PROBABLY I MEANT IT AS A RULE TO SOMEWHERE ELSE usage
            if (this is ConditionModelContact) {
              // we never accept any new server_id we cancel the subscription
              // and  have one time opportunity to utylize the property
              //Nothing //goes to the stream yet but now we can have a subcontact or for else clause subwidget model
              contactChangesStreamSubscription.cancel();
              // we are waiting until server_id is available
              //await contactdebug.waitForServerId();
            } else {
              // we never accept any new server_id and server_owner_contact_id
              // we cancel the subscription
              // and  have one time opportunity to utylize the property
              if (operateOnTheModelCounter == 2) {
                contactChangesStreamSubscription.cancel();
                //Nothing //goes to the stream yet but now we can have a subwidget model
              }
              // we are waiting until server_id AND server_owner_contact_id is available
              //await contactdebug.waitForServerId();
              //await contactdebug.waitForServerOwnerContactIdFuture();
            }
          }
        }
      });

      if (ConditionConfiguration.debugMode &&
          ConditionConfiguration.initDbStage != null &&
          ConditionConfiguration.initDbStage! >= 3) {
        contactdebug = ConditionModelContact(
          conditionModelApp,
          this,
          // error and solutions to similar problems where reasonably possible: parent_id is required to be 0 because "this" is ConditionModelUser, but we could set it in addChild if hangOnWithServerCreateUntilParentAllows: true and isAllModelDataProvidedViaConstructor: false
          // at the same time we could set up owner_contact_id similarly if these properties are not set up somewhere !!!!!!! analyse what is and what should be
          <String, dynamic>{
            'title': 'waiting contact',
            'contact_e_mail': 'adfafaasdfasfafaasfasfsf3@gmail.com.debug',
            //'user_id': //id, is it// allowed when hangOnWithServerCreateUntilParentAllows: true see addChild?
          },
          changesStreamController: contactChangesStreamController,
          hangOnWithServerCreateUntilParentAllows: true,
          //no need to uncomment- this is informationally and default value, children are going to be restored from db for this object automatically
          //autoRestoreMyChildren: true,
        );

        // Development mode:
        // for normal widget we need locally server_parent_id and/or server_owner_contact_id
        // when do we 100% have it?
        // it is available after a model is synchronized for the fist time when it is created
        // (then server_id is set locally)
        // we seek the momet it is done and later:
        // if a model has server_id not-null we get it
        // else we asynchronously wait until (some future) until we have it
        // when we have it
        // so if internet is turned off we have a "tree" of non-synchronized widgets
        // Because all widgets lower in the tree depend on server_id of a parent widget
        // there is no problem that accidentally child/granchild widgets gets synchronized before
        // its parent - at least there must be a mechanizm making sure of that
        // let say whenever server_id and/or server_owner_contact_id OF A PARENT WIDGET is set up
        // A future completes with the value set.
        // And it happens when the value is restored from local server or when a new model just has
        // been synchronized.
        // If it is possible, that null is set - this must be detected and future is not completed
        // but no error is thrown.
        // In general it should be enforced that some properties can only be read locally not set.
        // like these two server_id and/or server_owner_contact_id OF A PARENT WIDGET
        // THEN YOU CAN START SYNCHRONIZING
        // Remeber that when storing locally data you also need to wait until the parent node
        // gets f.e. its own local id which is like an immediate operation, no internet needed!!!
        // Yet this time you don\t need to wait until it is done in the db - you can do it async too.

        // I think we need a systemic approach:
        // First important - all local storage operations are immediate by official definition
        // it means that changing a property, even using async/await is like real time event
        // like you store a variable in memory, and you have to ignore the fact that
        // there are some "little" storage delays while projecting an app
        // But for non-tree independent properties changing, they are done in memory and you
        // may live to the framework to save ot from memory to local storage, and work.
        // You need to get future for properties (or streams?):
        // 1. When a property is set up for the first time and/or (you choose) is not null
        // 2. When a property value changed

        // IMPLEMENTED ABOVE USING STREAMS!!!
        // move it somewhere intto ConditionModel class definition
        //if (this is! ConditionModelUser) {
        //  // when we create a typical model we need to pass parent model if it is not a top model widget
        //  // if the model is detected automatically parent/owner properties are to be set
        //  if (this is ConditionModelContact) {
        //    // we are waiting until server_id is available
        //    await contactdebug.waitForServerId();
        //  } else {
        //    // we are waiting until server_id AND server_owner_contact_id is available
        //    await contactdebug.waitForServerId();
        //    await contactdebug.waitForServerOwnerContactIdFuture();
        //  }
        //}

        addChild(contactdebug);
      }

      if (ConditionConfiguration.debugMode &&
          ConditionConfiguration.initDbStage != null &&
          ConditionConfiguration.initDbStage! >= 4) {
        // the previous contact was added synchronously, now in the debug settings we know we have (once had?) user_id
        // but we have to pass the parent_id but also wait for its id first asynchronously, this time with no autorestore children.
        var contactdebug2 = ConditionModelContact(
            conditionModelApp,
            this, // one constructor class try to take user_id from the user if no initial data supplied
            <String, dynamic>{
              //'user_id': this['id'],
              'title': 'non-waiting contact',
              // user_id if not supplied is taken from conditionModelUser param
              // educaionally parent_id must be null if it is a top level contact (which is checked in the addChild method) which can later be added
              // as it just below after here neccessary await is by addChild
              //'parent_id': null,
              // testing check if parent_id == null works for subcontact of this contact
              'contact_e_mail': 'adfafaasdfasfafaasfasfsf3@gmail.com.debug',
              //'user_id': //id, is it// allowed when hangOnWithServerCreateUntilParentAllows: true see addChild?
            },
            // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
            // changesStreamController: contactChangesStreamController, // a default object will be created
            hangOnWithServerCreateUntilParentAllows:
                false, // default value but here placed to see the difference from previous examples or following possibly
            autoRestoreMyChildren: false);

        scheduleMicrotask(() async {
          // f.e. contactdebug2.a_id.firstValueAssignement we could use it, howeve it is better to wait until all model is ready
          await contactdebug2.getModelOnModelInitComplete();
          addChild(contactdebug2);
        });
      }

      //
    }

    scheduleMicrotask(() async {
      // PRODUCTION NON TESTING/DEBUG CODE IN THIS ASYNC scheduleMicrotask() call:
      // This is user model we need to restore as children all it's top level contacts and groups, but not subcontacts or subgroups
      // and ofcourse no messages/tasks belonging to contacts here

      // Educationally: as you can see this restoreMyChildren method is called after this model is inited
      // and have it's id property. Apart from that the app already passes the id when creating ConditoinModelUser object
      // so this is why the next "await getModelOnModelInitComplete();" line is not necessary and commented
      // await getModelOnModelInitComplete(); // if assigned to a variable this method would return "this" object

      try {
        debugPrint(
            'restoreMyChildren() method. We are going to call local server driver.readAll() method to restore top level contacts.');
        // add constructor param that the object is fully restored from a full the map, thanks to it we wont make two requests to a db
        // add educational info on that here that an object can be fully created from a map or just you pass an id.
        // at the same time what if someone created an object with fake data but right id? hence think how hermetize itf
        // maybe it could be limited private methods or properties or some even more restricted stuff or just be reasonable and give freedom of imagination.
        // but no from outside of the api it should be "hacked"
        List<Map>? conditionMapList = await driver.readAll(
          "ConditionModelContact",
          ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon()
            ..add('parent_id', 0)
            ..add(
              'user_id',
              id,
              ConditionDBOperator.equal,
              false,
            ),
          limit:
              null, // returns all results - local server and don't expect many results while contacts aren't so resourcerul, are they?
          //columnNames: {'id'}, we want all db record not just a record with db solumn
          dbTableName: 'ConditionModelWidget',
          //below is commented - this is local server, local device/smartphone request, no key needed
          //globalServerRequestKey: globalServerRequestKey
        );

        debugPrint(
            'restoreMyChildren() method. A result of local server driver.readAll (that was invoked by requestGlobalServerAppKeyActualDBRequestHelper(key)) has arrived. Here how it looks like: conditionMapList == $conditionMapList and :');

        if (conditionMapList == null || conditionMapList.isEmpty) {
          debugPrint(
              'It is null or empty :( but it is NOT a db error! A new key will be obtained in a while or later');
        } else {
          debugPrint(
              'result: It is not null :) so we recreate the contact objects if fly');

          // fix the below;

          // not necessary: with very big data you could remove each element after creating an object. But be reasonable, not needed.
          for (int i = 0; i < conditionMapList.length; i++) {
            //!!!! Here
            // a_parent_id syntax the parent_id IN TWO PLACES is updated in the addChild so you need ANALYSE ALL THE PROCESS
            // ALSO !!! it maybe or not that it is in other cases also set up twice.
            // much analysis awaits
            //
            //
            //
            //
            //

            // when isAllModelDataProvidedViaConstructor: true and parent_id must be set up and ready always probably even with hangOnWithServerCreateUntilParentAllows = true
            // and by this not set up in the method
            //, some unexpected update - no change to parent id
            //this may have an impact: isAllModelDataProvidedViaConstructor: true - new property and new independent stuff in initModel()
            //but also thi hangOnWithServerCreateUntilParentAllows == false
            //copy/paste: UPDATE model == ConditionModelContact we are now in the ConditionDataManagement object invoking UPDATE method. let' see how the query looks like and then throw exception until it is ok:
            //flutter: UPDATE "t8QjKjA_ConditionModelWidget" SET parent_id = 0, update_date_timestamp = 1688861150751 WHERE id = 718;
            //-----------
            // And this not far i guess related - global server shouldn't do anything when model is created from full data isAllModelDataProvidedViaConstructor: true:
            // but trying to set parent_id = 0 may have revealed that global server was not inited properly or too early or something suprising.
            // So maybe there is a need if in this configuration all is inited properly an i can set description = 'text' and it will be updated on the local and global servers
            // Inside triggerLocalAndGlobalServerUpdatingProcess() a Timer invoked the performTheModelUpdateUsingDriver() which invoked update() and returned error, NOT updated, result error, depending on the type of error (two processess accessed the same db file (if sqlite3) at the same time, internet connection lost, etc) !!!we now are trying to update the model doing it once per some longer time!!!: C] Inside triggerLocalAndGlobalServerUpdatingPr

            addChild(ConditionModelContact(
                    conditionModelApp,
                    this, // this is inited at the moment user_id is available  one constructor class try to take user_id from the user if no initial data supplied
                    Map<String, dynamic>.from(conditionMapList[
                        i]), // see debug examples in this method when no-db compeletely new contacts are created
                    // FUNNY EDUCATIONAL STUFF: IF YOU UNCOMENT THE BELOW LINE: THE SAME STREAM CONTROLLER WAS USED IN TWO OBJECTS CAUSING THEM RECEIVING THE SAME EVENT TWICE AND AN ATTEMPT TO ASSIGN A FINAL PROPERTY TWICE WITH VALUE - WATCH OUT - ONE SEPARATE changesStreamController: OBJECT FOR one model
                    // changesStreamController: contactChangesStreamController, // a default object will be created
                    hangOnWithServerCreateUntilParentAllows:
                        false, // default value but here placed to see the difference from previous examples or following possibly
                    autoRestoreMyChildren: true,
                    isAllModelDataProvidedViaConstructor:
                        true // normally it is discouraged to use this property == true see the definition of it with it's all description
                    )
                // debug test (worked!) for non-debug/non-testing code it was with isAllModelDataProvidedViaConstructor : true in mind
                //..description = "descchange${DateTime.now().millisecondsSinceEpoch.toString()}"
                );
          }
          conditionMapList = null;
        }
      } catch (e) {
        // In the future here there will be some predefined ConditionApp standarized errors, to separate you from low-level implementation custom errors for different db engines.
        debugPrint(
            'checkOutIfGlobalServerAppKeyIsValidActualDBRequestHelper(key) Predefined error message, rather throw Excepthion custom class, There was a db_error,error $e');
        // now in debug it rethrows but it should seek a way for the app to recover itself from this situation?
        // normally it should never throw and catch here.
        rethrow;
      }
    });

    //model._completerInitModelGlobalServer.future
/*
      contactdebug.getModelOnModelInitComplete().then((model) {
        debugPrint(
            'B] We are in [ConditionModelUser]\'s restoreTreeTopLevelModelsOrMostRecentMessagesModels() in then() of getModelOnModelInitComplete() method of a ConditionModelContact model. the model just has been inited and is ready to use. Let\'s debug-update a field/property of the model. Each time the value will be different - timestamp');
        contactdebug.description =
            DateTime.now().millisecondsSinceEpoch.toString();
        debugPrint(
            'B] And the value now is contactdebug.description == ${contactdebug.description}');
      }).catchError((error) {
        debugPrint('catchError flag #cef14');

        debugPrint(
            'B] Error of: We are in [ConditionModelUser]\'s restoreTreeTopLevelModelsOrMostRecentMessagesModels() in then() of getModelOnModelInitComplete() method of a ConditionModelContact model, the error message ${error.toString()}');
      });

      debugPrint(
          'P] restoreTreeTopLevelModelsOrMostRecentMessagesModels(): let\'s get into a loop creating top lever models for later rendering widgets.');
      debugPrint(
          'P]restoreTreeTopLevelModelsOrMostRecentMessagesModels() conditionModelApp.currently_active_user_id ${conditionModelApp.currently_active_user_id} and currently processed user id is $id');
      if (conditionModelApp.currently_active_user_id == id) {
        debugPrint(
            'P]the currently processed user IS active and some of it\'s models are going to be restored now. Some other stuff yet may be done.');
      } else {
        debugPrint(
            'P]the currently processed user is NOT active and it\'s models are not going to be restored now. Some other stuff yet may be done.');
      }
    */
  }

  @override
  initCompleteModel() async {
    debugPrint(
        '!!We\'ve entered the initCompleteModel() of ConditionModelUser ');
    bool restoreSomeUsersWidgetModels = false;
    //The // exception should never occur (local server is assumed to always work) so any
    // exception maybe shouldn't be catched - redesign it better
    try {
      await initModel(); // it is always ok and returns the "this" model itself. It probably never throws error - checkit out.
      //pretty // much not sure if isInited or similar stuff is done in ConditionModel
      // so no need to use this. Model must be inited locally it could be fatal error
      // not a catched exception. To redesign?
      bool isInited = true;
      debugPrint(
          'initCompleteModel() of ConditionModelUser Custom implementation of initCompleteModel(): Model of [ConditionModelUser] has been inited. Now we can restore all tree tree top-level widget models belonging to the currently logged AND FRONT SCREEN ACTIVE user models like contacts, messages, probably not rendering anything yet. Possibly some other users related stuff is going to be performed');
      restoreSomeUsersWidgetModels = true;
    } catch (e) {
      debugPrint(
          'Custom implementation of initCompleteModel(): Model of [ConditionModelUser] hasn\'t been inited. The error of a Future (future.completeError()) thrown is ${e.toString()}');
      // ARE WE GOING TO USE NOT ENDLESSLY INVOKED TIMER TO invoke initModel() again with some addons if necessary? Some properties might has been set already.
    }

    if (restoreSomeUsersWidgetModels) {
      restoreMyChildren();
    }
  }

  @override
  void operator []=(key, value) {
    switch (key) {
      case 'e_mail':
        e_mail = value;
        break;
      case 'phone_number':
        phone_number = value;
        break;
      case 'password':
        password = value;
        break;
      case 'local_server_key':
        local_server_key = value;
        break;
      case 'local_server_login':
        local_server_login = value;
        break;
      default:
        super[key] = value;
    }
  }

  set e_mail(String? value) => a_e_mail.validateAndSet(value);
  String? get e_mail => defValue['e_mail'].value;
  set phone_number(String? value) => a_phone_number.validateAndSet(value);
  String? get phone_number => defValue['phone_number'].value;
  set password(String value) => a_password.validateAndSet(value);
  String get password => defValue['password'].value;
  set local_server_key(String? value) =>
      a_local_server_key.validateAndSet(value);
  String? get local_server_key => defValue['local_server_key'].value;
  set local_server_login(String? value) =>
      a_local_server_login.validateAndSet(value);
  String? get local_server_login => defValue['local_server_login'].value;
}

/// ??? Where is this or is going to be used??? Each widget has it's own configuration field which is a map, but it stores data in the configuration field in the app as json string, but in the backend you decide to put it into "configuration" field (by default) or to create a separate table for it
@Stub()
class ConditionModelConfigurationModel<ConditionModelEachWidgetModel>
    extends ConditionMap {
  /// ConditionModel class for the description and compatibility
  @Stub()
  late ConditionModel parent_model;

  ConditionModelConfigurationModel(this.parent_model, defValue)
      : super(defValue) {}
}
