import 'dart:io';
import 'package:flutter/foundation.dart';
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
import 'condition_data_management_driver_sql.dart'
    if (dart.library.html) 'condition_data_management_driver_sql.web.dart'; // especially for web (!now indexedDB) localStorage database _driver_temp (ConditionModelApp) or div tag database storage to be implemented later

import 'condition_data_management_driver_server.fallback.dart'; // condition_data_management_driver_server.web.dart probably in extended unchanged form uses it but when condition_data_management_driver_server.dart is not working properly this fallback one is to be used
import 'condition_data_management_driver_server.dart' // only dart or native like windows, android (not web)
    if (dart.library.html) 'condition_data_management_driver_server.web.dart'; // uses condition_data_management_driver_server.fallback.dart in a not changed form or as an extenstion of the class - yet to see.

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
@Stub()
abstract class ConditionDataManagementDriver {
  /// Not used Remove as quickly as possible, replaced by [db_name_prefix] and [table_name_prefix]. To solve some possible problems including security and possible naming conflicts, for overall compatibility reasons [ConditionDataManagementDriverServer] and [ConditionDataManagementDriverSql] like classess need the two replacing properties instead of this one. Kind of namespace prefix allowing you to store couple of separate databases in one overall database - you don't need to create two or five databases using this prefix all tables will be creaated from scratch with this prefix. !!! With this set up to not null and not empty, there would b two prefixes Prefix is only in development mode for simulating backend data storage and loading, see constructor desc. , see method [getNewDefaultDriver] code for backend driver
  //@Deprecated('Replaced by dbNamePrefix, tableNamePrefix')
  //final String prefix = '';

  late final ConditionModelApp conditionModelApp;

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
  final Completer<ConditionDataManagementDriver>? initCompleterGlobal;

  @protected
  bool inited = false;

  /// The form of this property may change but you need a list of pending completers/futures finish them with an error after to much time operations. It's existence in this unpolished form hints you about chalenges may appear.
  List<Completer> _storageOperationsQueue = [];
  List<ConditionModelListenerFunction> _changesListeners = [];

  /// !!! Prefix is only in development mode for simulating backend data storage and loading, see the [_prefix] property desc, see method [getNewDefaultDriver] code for backend driver
  ConditionDataManagementDriver(
      {initCompleter,
      String? dbNamePrefix,
      String? tableNamePrefix,
      bool isGlobalDriver = false,
      bool hasGlobalDriver = false,
      ConditionDataManagementDriver? driverGlobal,
      Completer<ConditionDataManagementDriver>? initCompleterGlobal,
      ConditionModelApp? conditionModelApp})
      : initCompleter =
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
                    conditionModelApp: conditionModelApp,
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
                Completer<ConditionDataManagementDriver>()
                    as Completer<ConditionDataManagementDriver>?) {
    // In the extending class we call initStorage function - see description - the function must be overriden it is left in this class definition for learning purposes only
    // _initStorage(prefix, onInitialised);

    if (null != conditionModelApp) {
      this.conditionModelApp = conditionModelApp;
    }

    driverGlobal?.getDriverOnDriverInited().then((driver) {
      this.initCompleterGlobal!.complete(driver);
    }).catchError((error) {
      debugPrint('catchError flag #cef1');
      debugPrint(
          'global driver couldn\'t has been inited the error message is:${error.toString()}');
      this.initCompleterGlobal!.completeError(false);
    });
  }

  int createCreationOrUpdateDateTimestamp() =>
      DateTime.now().millisecondsSinceEpoch;

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
      {ConditionModelApp? conditionModelApp,
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

    if (!ConditionConfiguration.isWeb) {}

    if (ConditionConfiguration.defaultAppDataEngine ==
        ConditionAppDataManagementEnginesEnum.sqlite3) {
      return ConditionDataManagementDriverSql(
        conditionModelApp: conditionModelApp,

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
      {String? globalServerRequestKey = null}) {
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
  Future<List<ConditionMap>?> _____________________________readAll(
      String dbTableName,
      ConditionDataManagementDriverQueryBuilderPartWhereClauseSqlCommon
          whereClause,
      {int? limit,
      List<String>? columnNames}) {
    if (!inited) throw const ConditionDataManagementDriverNotinitedException();
    Completer<List<ConditionMap>?> completer = Completer<List<ConditionMap>?>();
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

/// Possibly to be removed, hard to reimplement in new realities, but the class is left, just need to uncomment some stuff in _initStorage. Based on how classess of Sql and Server dirvers are implemented there should be ConditionDataManagementDriverHiveSettings class created and accepted as a parameter. and and implements ConditionDataManagementDriver for working with hive plugin
@deprecated
@Stub()
class ConditionDataManagementDriverHive extends ConditionDataManagementDriver {
  late final _box;

  /// watch out, see the description of this variable prefix
  ConditionDataManagementDriverHive(
      {Completer<ConditionDataManagementDriver>? initCompleter,
      String dbNamePrefix = '',
      String tableNamePrefix = ''})
      : super(
          initCompleter: initCompleter ?? Completer(),
          dbNamePrefix: dbNamePrefix,
          tableNamePrefix: tableNamePrefix,
        ) {
    //obsolete and probably removed already if (null == prefix) prefix = '';
    //debugPrint('initStorage 333' + prefix);
    _initStorage();
  }

  @override
  static Future<ConditionDataManagementDriverHive> createDriver(
      {String dbNamePrefix = '', String tableNamePrefix = ''}) {
    Completer<ConditionDataManagementDriverHive> initCompleter =
        new Completer();
    // !!! Whach out! Commented the line below because you cannot use contructor on abstract class / interface
    ConditionDataManagementDriverHive(
        initCompleter: initCompleter,
        dbNamePrefix: dbNamePrefix,
        tableNamePrefix: tableNamePrefix);
    UnimplementedError(ConditionCustomAnnotationsMessages.MustBeImplemented);
    return initCompleter.future;
  }

  @override
  void _initStorage() {
    debugPrint('initStorage 1');
    debugPrint('initStorage 1' + dbNamePrefix);
    debugPrint('initStorage 1' + tableNamePrefix);
/*
    Hive.init('./'); //-> not needed in browser
    Hive.openBox(dbNamePrefix).then((box) {
      debugPrint('initStorage2');
      _box = box;
      debugPrint(box.toString());
      debugPrint('initStorage2');
      initCompleter?.complete(this);
      
    });
    */
  }

  @override
  Future<bool> updateOnTheDb(
      Function completeCallback, Function errorCallback) {
    // here you register a callback when the operation is over, and error_callback
    // ....
    return Completer<bool>().future;
  }

  /// Read this is deprecated in extended abstract class As far as i can see [Hive] gven box.get returns value not Future, so we have to create Future on our own. Using futures is neccessary for consistency with different kinds of [ConditionDataManagementDriver] classess especially those for backend which take time to complete and need futures more sofisticated management is possible when one day we find out this [Hive]'s get() function may once work wonce not
  @override
  @deprecated
  Future<String?> getValue(String key) {
    /*debugPrint('erqpeoruqpoieruqpoeiruqpeourqperu');
    debugPrint(_box.toString());

    debugPrint('erqpeoruqpoieruqpoeiruqpeourqperu');
    debugPrint(_prefix + key);

    //var werwerwer = _box.get(_prefix + key);
    debugPrint(_box.get(_prefix + key));
    debugPrint('erqpeoruqpoieruqpoeiruqpeourqperu');
*/
    //var completer = new Completer();

    return Future<String?>(() {
      return _box.get(this.tableNamePrefix + key);
    });

    //return completer.future<String?>;
  }
}

/// When for some reasons you don't have access to any storage: [Hive] plugin / files / localStorage in the browser, etc. this driver will be created, "Fallback" in the name implies it is not to be used normally, it is last resort solution - more in the [ConditionModelApp] model class definition.
class ConditionDataManagementDriverMemoryFallback
    extends ConditionDataManagementDriver {
  ConditionDataManagementDriverMemoryFallback(
      Completer<ConditionDataManagementDriver> initCompleter,
      [String? prefix])
      : super(initCompleter: initCompleter /* deprecated: prefix: prefix*/) {
    prefix ??= '';
    debugPrint('initStorage 333prefix');
    // incompatible function name and implementation
    _initStorage(//prefix, init_completer
        );
  }

  /// See Hive, Sql or other impelentations, wrong implementation - different name with inderscore
  @override
  void _initStorage(//String? prefix, Completer init_completer
      ) {
    //prefix ??= '';
    //debugPrint('initStorage 1fallbackmemorydriver');
    //debugPrint('initStorage 1fallbackmemorydriver' + prefix);
    // in case of driver which stores data in memory we can complete the completer now,
    // also it's future completer.future property never should throw error (future.then().catchError())
    //init_completer.complete(this);
  }
}

/// See description of similar [ConditionModelListenerFunction] in relation to [ConditionModel] class. Any model registers a Listener function [ConditionDataManagementDriverFunction] in the [ConditionDataManagementDriver]. This listener is invoked with a [Future] anytime a longer asynchrous operation starts. When operation and the [Future] finishes the model takes some actions. F.e. A widget attached to the model registered in the model it's own listener [ConditionModelListenerFunction], The widget changed a property in the model, with that the model called the listener with another [Future]. So for any model has it's own [Future] (waiting for the [ConditionDataManagementDriver] object to finish it's data operation) and the widget another [Future] which is completed by the model. The widget finally receives the data and updates it's look.
typedef ConditionDataManagementBackendDriverListenerFunction<
        ConditioDataManagementDriverBackend, Future>
    = bool Function(Future future);

/// javascript ajax like remote url data management for the backend working however the same as [ConditionDataManagementDriver] using urls for backend data management. Temporarily, in the makeshift implementation you can somethow use [ConditionDataManagementDriverHive] for workaround, and then impelemnt real kind of javascript AJAX requests.
@Stub()
@ToDo('Don\'t forget about ConditioDataManagementDriverBackendListenerFunction',
    '')
class ConditioDataManagementDriverBackend
    extends ConditionDataManagementDriver {
  /// watch out, see the description of this variable prefix
  ConditioDataManagementDriverBackend(
      Completer<ConditionDataManagementDriver> initCompleter,
      [String? prefix])
      : super(
          initCompleter: initCompleter, /* deprecated: prefix: prefix*/
        );
}

/// Translates Models to DB tables it takes object implementing ConditionBackendCodeGeneratorDB interface (f.e. ConditionBackendCodeGeneratorDBSimpleUniversalSQL) and similarly for backend language ConditionBackendCodeGeneratorBackendLanguage (f.e. ConditionBackendCodeGeneratorBackendLanguagePHP)
@Stub()
abstract class ConditionBackendCodeGenerator {}

/// See ConditionBackendCodeGenerator interface first. Interface for creating DB structure may it be SQL, Mysql, Postgress, file reading, writing, etc.
@Stub()
abstract class ConditionBackendCodeGeneratorDB {}

/// See ConditionBackendCodeGenerator interface first. Interface for creating Backend language structure (php, c#, etc) for working with data models, writing, etc.
@Stub()
abstract class ConditionBackendCodeGeneratorBackendLanguage {}

/// SQL implementation independent SQL code generator
@Stub()
class ConditionBackendCodeGeneratorDBSimpleUniversalSQL
    implements ConditionBackendCodeGeneratorDB {}

/// PHP code generator
@Stub()
class ConditionBackendCodeGeneratorBackendLanguagePHP
    implements ConditionBackendCodeGeneratorBackendLanguage {}

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

/// Issued only when the model in all ways is not in the main model tree already. Only child model is passed which his [_retireModelWhenWhenRemovedFromTheModelTree] property has just changed. Whenever the always boolean value is changed (so no constructor init involved) _retireModelWhenWhenRemovedFromTheModelTree (@protected/public setter/getter) property is changed from false to true the model itself emits this event and ConditionModelApp check out if the model is in the tree and if not it schedules removal of the model from its list of mantained models so that there is no link to the model and ALL RESOURCES RELATED TO THE MODEL OBJECT ARE RELEASED (THATS THE MAIN POINT);
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

/// If a [ConditionModel] class mixes with this mixin it informes [ConditionModel] class, which is at the root of any model class, that a model have one entry in the database, it has always id =] 1, no id == 2 or 3 or null can be. This is useful for example when you store the entire app setting in one place which is the case with ConditionModelApp model object corresponding to entire right now working app.
mixin ConditionModelOneDbEntryModel {}

/// Really see [ConditionModelDynamic] class too. [!READ and see for "[To do]""] Important rules: all tables must have id column, if a newly created model object has only 'id' (so with .id) property set-up, the data is fetched and only the validated and the all model's properties are set up. If a newly created model has some or all properties set up except for id property - the model completely new, it doesn't have it's row in the sql db (speaking in sql language terms), so the models properties except for id are validated and send into db, if all is successful, the db returns inserted id. Then updates of single or more properties are done automatically when they are changed. Seek for more properties related to automatic or less automatic changes. You could even do the id stuff automatically even if a model doesn't have the id column defined - rethink it well.
abstract class ConditionModel extends ConditionMap {
  // it is always set up in the constructor body properly or exception is thrown that something went wrong
  late final ConditionModelApp conditionModelApp;

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

  /// ! Use getter setter doing additional stuff. Any non constructor change of the model to the "true" (if the previous value was false of course) emits [ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree] event (read more important details in the event class description). Let's say for now, it is @protected and not final but has a public getter. Default == true, When a model is 1: attached to the model tree via ([addChild], [_addParentLinkModel]) and after that removed from the tree (remove versions of the mentioned methods), then if this [_retireModelWhenWhenRemovedFromTheModelTree] == true, the model among other things will have it's descrtoy() method called adn conditionModelApp will remove the model from it's internal Set [_allAppModels] of models (not the same as the model tree) (seek the special property and it's description). Then there is no existing reference to the model in the entire app (this is assumed so). If, however, any reference is left it is considered a mistake of any random programmer making changes to the library/app and a fatal error is thrown (not Exception if different decision was taken), because it is an error in the app development stage. However when a programmer or original developer(s)? set [_retireModelWhenWhenRemovedFromTheModelTree] = false it points out that the model after removal from the tree still exists on the conditionModelApp list ([_allAppModels] Set object) which allows not only for reataching and reusing an existing model but also using it in different way, like for example rendering it sort of completely outside the application/main model tree in some completely custom way. The major point of removing unused models is to save memory, processor, etc. (f.e. lazy loading of models, removing big data models, preventing models from sending events to the changesStreamController.stream or receiving any event and possibly much more),  At one point a readme file of one of the commits contained or still contains more detailed explanations.
  bool _retireModelWhenWhenRemovedFromTheModelTree;

  @protected
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

  @Deprecated(
      'Probably changesStreamController does what was initially expected of this property. Old of the "deprecated" info: All stuff will be managed differently i guess - ConditionDataManager is going to some changes like global server updates')
  List<ConditionModelListenerFunction> changesListeners = [];

  /// The data here will be distributed to the coresponding [ConditionModelField] objects and then set to null. Each [ConditionModelField] object has a final 'columnName' property (keys of the map below, and generally String or int/num value). After distributing the content of the map the data will be automatically validated. For example if a [temporaryInitialData] value should be notNull but is or is not set, an exception will be thrown. Later some other exceptions or errors can be thrown if f.e. there is an attempt of setting a value on a final columnName key.
  @protected
  Map<String, dynamic> temporaryInitialData = {};

  ConditionModel(ConditionModelApp? conditionModelApp,
      this.temporaryInitialData, this.driver,
      {this.appCoreModelClassesCommonDbTableName,
      StreamController<ConditionModelInfoStreamEvent>? changesStreamController,
      retireModelWhenWhenRemovedFromTheModelTree = true})
      : _retireModelWhenWhenRemovedFromTheModelTree =
            retireModelWhenWhenRemovedFromTheModelTree,
        changesStreamController = changesStreamController ??
            StreamController<ConditionModelInfoStreamEvent>.broadcast(),
        super({}) {
    if (this is ConditionModelApp) {
      if (conditionModelApp != null) {
        throw Exception(
            'ConditionModel constructor exception: this is ConditionModelApp and conditionModelApp!=null');
      } else {
        this.conditionModelApp = this as ConditionModelApp;
      }
    }
    // The next extending class enforce ConditionModelApp not to be null, but in case
    // there is a second extending class this condition is checked
    // The condition is almost unnecessary
    else if (this is! ConditionModelApp) {
      if (conditionModelApp == null) {
        throw Exception(
            'ConditionModel constructor exception: this is! ConditionModelApp && conditionModelApp==null');
      } else {
        this.conditionModelApp = conditionModelApp;
      }
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
      if (temporaryInitialData.containsKey(key)) {
        //field.value = temporaryInitialData[key];
        columnNamesAndFullyFeaturedValidateAndSetValueMethods[key]!(
            temporaryInitialData[key], true, false);

        debugPrint(
            'just assigned: columnNamesAndTheirModelFields[key].value = ${field.value}');
      }
    }
  }

  /// If the getter is to be compatible with map it must return null on a not found value of key
  @override
  operator [](key) {
    try {
      return defValue[key]?.value;
    } catch (e) {
      debugPrint(
          'ConditionModel [] getter CATCHED exception: key == $key, error: $e');
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
          _performTheModelUpdateUsingDriverGlobalServer(conditionModelApp)
              .then((int? result) {
            //result won't be null for global server request - always int
            //this will update on local server only what was returned from global server
            debugPrint(
                'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() we did a successful update on global server and we will set up only on local server (already set up  on the global server and just now received) this model property this[\'server_update_date_timestamp\'] = $result');
            columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                'server_update_date_timestamp']!(result, true, true, true);
          }).catchError((error) {
            debugPrint('catchError flag #cef4');

            debugPrint(
                'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() a Timer invoked the performTheModelUpdateUsingDriver() which invoked update() and returned error, NOT updated, result error, depending on the type of error (two processess accessed the same db file (if sqlite3) at the same time, internet connection lost, etc) !!!we now are trying to update the model doing it once per some longer time!!!: ${error.toString()}');
            // For the local server there is no attemptsLimitCountDownCounter localServer is supposed to work always in all circumstances, but for global server you can loose the internet connection, the server bandwitdh may be too much congested, etc.
            int attemptsLimitCountDownCounter = 12;
            Timer.periodic(const Duration(seconds: 5), (timer) {
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
              _performTheModelUpdateUsingDriverGlobalServer(conditionModelApp)
                  .then((result) {
                // result must be always true or throw error (catch error of future)
                // you dont need to do anything special here _performTheModelUpdateUsingDriver() does the job.
                timer.cancel();
                //result won't be null for global server request - always int
                //this will update on local server only what was returned from global server
                debugPrint(
                    'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer, we did a successful update on global server and we will set up only on local server (already set up  on the global server and just now received) this model property this[\'server_update_date_timestamp\'] = $result');
                columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                    'server_update_date_timestamp']!(result, true, true, true);
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
  Future<bool> _performTheModelUpdateUsingDriver() {
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
        triggerLocalAndGlobalServerUpdatingProcess(null);
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
      [String? columnName, bool isToBeSynchronizedLocallyOnly = false]) {
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
    scheduleMicrotask(() async {
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
        columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                'update_date_timestamp']!(
            driver.createCreationOrUpdateDateTimestamp(), true, false);
        // and we are adding the field to list of fields to be updated which in case the global
        // server is defined it will send the local server update date to the global server
        _fieldsToBeUpdated.add('update_date_timestamp');

        if (!isToBeSynchronizedLocallyOnly) {
          _fieldsToBeUpdatedGlobalServer.add(columnName);
          _fieldsToBeUpdatedGlobalServer.add('update_date_timestamp');
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
        if (!isToBeSynchronizedLocallyOnly) {
          _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(true);
        }
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!! This is the moment we can trigger the global server update (granted the [ConditionModelApp] object has its global server enabled)
        debugPrint('C]2:3!!!');
      }
    });

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
          'C]V Inside triggerLocalAndGlobalServerUpdatingProcess(): model _modelIsBeingUpdated == $_modelIsBeingUpdated and _triggerServerUpdatingProcessRetrigerAfterFinish == $_triggerServerUpdatingProcessRetrigerAfterFinish');
      // this should be set up now not in event loop asynchronous method read just below Timer() comments:
      _modelIsBeingUpdated = true;
      _changesStreamController
          .add(ConditionModelInfoEventPropertyChangeModelToLocalServerStart());

      Timer(const Duration(milliseconds: 8), () async {
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
        _performTheModelUpdateUsingDriver().catchError((error) {
          debugPrint('catchError flag #cef7');
          debugPrint(
              'C] Inside triggerLocalAndGlobalServerUpdatingProcess() a Timer invoked the performTheModelUpdateUsingDriver() which invoked update() and returned error, NOT updated, result error, depending on the type of error (two processess accessed the same db file (if sqlite3) at the same time, internet connection lost, etc) !!!we now are trying to update the model doing it once per some longer time!!!: ${error.toString()}');
          Timer.periodic(const Duration(seconds: 5), (timer) {
            debugPrint(
                'C] Inside triggerLocalAndGlobalServerUpdatingProcess() cyclical timer update attempt: A cyclical attempts to update the model of class [${this.runtimeType.toString()}] on the local server are being performed. This is invokation');
            _performTheModelUpdateUsingDriver().then((result) {
              // result must be always true or throw error (catch error of future)
              // you dont need to do anything special here _performTheModelUpdateUsingDriver() does the job.
              timer.cancel();
            }).catchError((error) {
              debugPrint('catchError flag #cef8');

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

      /// we use this variable to get some convenient properties (futures) and make code clearer
      CreateModelOnServerFutureGroup<int?> createGlobalServerFutureGroup =
          working_driver.driverGlobal!.create(this,
              globalServerRequestKey: conditionModelAppInstance.server_key);

      createGlobalServerFutureGroup.future.then((List<int?> result) async {
        bool nullifyTheKey = false;

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
                await createGlobalServerFutureGroup.completerServerUserIdFuture,
                true,
                true,
                true);
          }
          // if serverId valid is ok we need to validate more for some classess
          if (this is! ConditionModelContact &&
              this is ConditionModelBelongingToContact) {
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
      }).catchError((error) {
        debugPrint('catchError flag #cef9');
        debugPrint(
            'Debugprint: 2:initModel() working_driver.driverGlobal.create() error: With a list of one or two possible integers containing no int id a model initiation could\'t has been finished. Exception thrown: error == $error');
        //Here // exactly this line below is causeing the second excepton all catchError and async try catch need to be checke
        _completerInitModelGlobalServer.completeError(
            '2:initModel() working_driver.driverGlobal.create() error: With a list of one or two possible integers containing no int id a model initiation could\'t has been finished. Exception thrown: error == $error');
      });
    }
  }

  /// A funny method.
  giveTheAlreadyRetiredModelPensionerSomePartTimeJobOrLetItSpendTimeWithItsGrandChildrenModel() {}

  /// See [ConditionModelCompleteModel] class desc. This method must be called in a complete model class that is not extended by other classess but is an object that is stored in the db
  @nonVirtual
  @protected
  Future<ConditionModel> initModel() {
    //as far as i remember this method shouldn't be async.
    if (this is! ConditionModelCompleteModel) {
      throw Exception(
          'the $runtimeType model object extending ConditionModel class is not mixed with ConditionModelCompleteModel class marking, that the object is a complete ready to use model');
    }
    for (final String key in temporaryInitialData.keys) {
      if (!columnNamesAndTheirModelFields.containsKey(key)) {
        throw Exception(
            'A model of [$runtimeType] class tries to set up a key (columnName) named ${key.toString()} that is not allowed - no ConditionModelField object has been defined or defined & inited for the model to handle the columnName with its value.');
      }
    }

    // this is to be removed when it is listened somewhere else and options for listening are added.
    // not that initModel returns just _completerInitModel.future
    // but nothing like that for the global server model initModelGlobal server or something
    _completerInitModelGlobalServer.future.catchError((error) {
      debugPrint('catchError flag #cef10');
      debugPrint(
          'initModel() _completerInitModelGlobalServer.future exception catched see code of initModel seek the debugPrint, and the async exception thrown is: $error');
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
                      '2:initModel() working_driver.create() error: With a list of one or two possible integers ${result.toString()} containing no int id a model initiation could\'t has been finished');
                  return;
                }

                if (this is ConditionModelIdAndOneTimeInsertionKeyModel) {
                  // this one must work, even with timers to try again
                  columnNamesAndFullyFeaturedValidateAndSetValueMethods[
                      'local_id']!(this['id'], true, false);

                  // this will local_id on a local - if fails it will do it until it will success that the conde will execute further
                  await _updateLocalId(working_driver);

                  if (this
                      is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
                    _doDirectCreateOnGlobalServer(working_driver,
                        conditionModelAppInstance as ConditionModelApp);
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
                    '2:initModel() working_driver.create() error result: ${error.toString()}');
                _completerInitModel.completeError(
                    'The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure creating a db record');
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
                'The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure creating a db record. The error result: ${error.toString()}');
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
    //?????Is this still important?: Whenever // model is _inited and probably 'server_id' (the to-non-null-value-change you
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
      return __inited;
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
    super.retireModelWhenWhenRemovedFromTheModelTree,
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
                childModel is ConditionModelBelongingToContact) &&
            childModel['owner_contact_id'] == null
        // task, message, but no contact (for now contact too but as written earlier it should change in the future)
        ) {
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
          this is ConditionModelContact ? this['id'] : this['owner_contact_id'],
          true,
          false);
      //this is done elsewhere somewhere just below: if (childModel.hangOnWithServerCreateUntilParentAllows) {childModel._hangOnWithServerCreateUntilParentAllowsCompleter!.complete();}
      //this is done elsewhere somewhere just below: childModel._changesStreamController.add(ConditionModelPropertyChangeInfoModelHasJustBeenUnlockedByParentModel(this));
    }

    /// The condition used here is simpler because there are exceptions in the addChild for this and also [ConditionModelUser] as form now must already be inited (so its has it's own 'id'), but other models don\'t have to.
    if (childModel['user_id'] == null) {
      debugPrint(
          'ConditionModelParentIdModel addChild() method called _performValidatingSettingUnlockingSendingEvent(): info: point #B3 this[\'id\'] = ${this['id']}, this[\'user_id\'] = ${this['user_id']},');
      childModel.a_user_id._fullyFeaturedValidateAndSetValue(
          this is ConditionModelUser ? this['id'] : this['user_id'],
          true,
          false);
    }

    childModel.a_parent_id
        ._fullyFeaturedValidateAndSetValue(this['id'], true, false);
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
    return;
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

    //!!!here // Most probably you must compare if childModel has the same conditionModelApp
    // as _parentModel you don't need it for removeChild the child was ok when it was added
    // it guarantees that conditionmodelapp has this model on a list even if a model is not
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

    debugPrint(
        'ConditionModelParentIdModel addChild() method: info: control point #L1; childModel.hangOnWithServerCreateUntilParentAllows = ${childModel.hangOnWithServerCreateUntilParentAllows}, childModel = $childModel ;');

    if (childModel.hangOnWithServerCreateUntilParentAllows == true &&
        (childModel['parent_id'] != null ||
            childModel['id'] != null ||
            childModel['owner_contact_id'] != null)) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: Condition causing the exception: childModel.hangOnWithServerCreateUntilParentAllows == true && (childModel[\'parent_id\'] != null || childModel[\'id\']!=null) || childModel[\'owner_contact_id\'] != null');
    } else if (childModel.hangOnWithServerCreateUntilParentAllows == false &&
        (childModel['parent_id'] == null ||
            childModel['id'] == null ||
            (this is! ConditionModelContact &&
                this is ConditionModelBelongingToContact &&
                childModel['owner_contact_id'] == null))) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: Condition causing the exception: childModel.hangOnWithServerCreateUntilParentAllows == false && (childModel[\'parent_id\'] == null || childModel[\'id\']==null)');
    } else if (childModel['parent_id'] != null &&
        childModel['parent_id'] != this['id']) {
      throw Exception(
          'ConditionModelParentIdModel addChild method: ConditionModelParentIdModel parent_id property of the model passed as a parameter of addChild is integer but is not the same as the id property of the model the child was intended to be added to.');
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

      if (childModel['parent_id'] != null) {
        // good to know that it might has been decided in the meantime that
        // a ConditionUserModel can have parent_id != for special local app global server purposes.
        // it is not yet decided for sure
        throw Exception(
            'ConditionModelParentIdModel addChild method after if (this is ConditionModelUser || this is ConditionModelApp) == true:  childModel[\'parent_id\'] must be null for parentModel (_parentModel ?) classes like ConditionModelUser, ConditionModelApp.');
      } else {
        // But the problem is that basically the parent_id might be set to int after that.
        // Let's prevent it from that by setting value to null manually
        // if it has been set already an exception will be thrown because the value is final.
        // And that's fine. It will be catched. (also could be done without try, catch using "inited" like property of a_parent_id)
        try {
          childModel.a_parent_id
              ._fullyFeaturedValidateAndSetValue(null, true, false);
        } catch (e) {
          debugPrint(
              'ConditionModelParentIdModel addChild method after if (this is ConditionModelUser || this is ConditionModelApp) == true: Catched exception, parent_id cannot be set up twice');
        }
        debugPrint(
            'ConditionModelParentIdModel addChild() method: info: point #A1');

        _performValidatingSettingUnlockingSendingEvent(childModel);
        _performAddingChildToParentModel(childModel);
        return true;
      }
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
  }

  /// You can call the method any time you want. If you use models customarily then after the future is complete you can set any remaining pointer to it to null. If however a model is in the model tree. The retire method will not work and will throw an asynchronous exception (completeError). May be in Readme more desc. This must be somehow implemented however difficult it might be. Not going here into details here but there may be model removed from the model tree, there may be no other reference active to the model except for a special List of models in the ConditionModelApp class. When a model is nowhere else except for this list it must be removed. It could be implemented with some delay - if it is not in the tree and no property change induced by app user has taken place, the model can be detached and send some locking if accidentally it is suprisingly linked somewhere, and in the development process such places will be gradually corrected, some log messages, errors (no exceptions - wrongly constructed piece of code). No unused link to the model can be left
  @protected
  Future<ConditionModelParentIdModel> retire() {
    try {
      throw Exception('retire()');
    } catch (e) {
      debugPrint(
          'ConditionModelParentIdModel retire() method, an always catched exception: not implemented in reality, add late final _retired property as described in the method retire();');
    }

    //????!!!!!!!!!!!!!!!!!! not//implemented yet
    Completer<ConditionModelParentIdModel> completer =
        Completer<ConditionModelParentIdModel>();
    if (conditionModelApp._isModelInTheTreeOrInsideAParentLinkModel(this)) {
      //we // lock the model so it cannot be used at all, throw exceptions if any property
      // was to be set, because it is considered programmers mistake to leave any pointer
      // to the model and still use it
      //implement // better, f.e. synchronous locking model, waiting or not until some
      // synchronizaton or fetching data modelisintheprocesofbeingupdated, or maybe more.
      // If so you will finally know what to do and after that you complete the completer.
      // if you set a standalone (retireModelWhenWhenRemovedFromTheModelTree == false) pointer
      // to null too early it may bring some damage. In this method you focus on this model only
      completer.complete(this);
    } else {
      completer.completeError(
          'ConditionModelParentIdModel retire() method asynchronous exception (completer.completeError()): A model is still in the model tree and cannot go retired and take pensions until it is still in the model tree.');
    }
    return completer.future;
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
    super.retireModelWhenWhenRemovedFromTheModelTree,
    this.hangOnWithServerCreateUntilParentAllows = false,
  }) : _hangOnWithServerCreateUntilParentAllowsCompleter =
            hangOnWithServerCreateUntilParentAllows == false
                ? null
                : Completer<void>() {
    if (hangOnWithServerCreateUntilParentAllows) {
      if (defValue['id'] is int) {
        // no need to check for null or < 1
        throw Exception(
            'A completely new model of descendant class of ConditionModelParentIdModel, that is new with no "id" set up must have no initial thid["id"]. it must be null. Improve the exception message :) ');
      }
      _changesStreamController.add(
          ConditionModelInfoEventModelInitingAndReadinessModelHasJustBeenLockedAndWaitingForParentModelToUnlockIt(
              this));
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
        defValue['id'] != null) {
      throw Exception(
          'ConditionModelBelongingToContact constructor exception: To my humble knowledge condition if (hangOnWithServerCreateUntilParentAllows==true&&defValue[\'id\']!=null cannot be true');
    }
    debugPrint('ConditionModelIdAndOneTimeInsertionKeyModelServer #B3');

    // Based on [To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31] in README.md
    // childModel cares to get its server_id or if needed server_owner_contact_id.
    // This is important that the stuff here is done before the initModel();
    // So i can listen to the changes stream
    // it is assumed that when [hangOnWithServerCreateUntilParentAllows]==false, [parentModel] is inited and has all needed local properties
    // also == true id = null - a new model right now - see earlier exception in the constructor
    if (hangOnWithServerCreateUntilParentAllows == true) {
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
          this['server_parent_id'] = event.parentModel!['server_id'];
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
  }) {
    if (null == temporaryInitialData['id']) {
      temporaryInitialData['creation_date_timestamp'] =
          createCreationDateTimestamp();
    }
    a_creation_date_timestamp.init();
    a_server_creation_date_timestamp.init();
    a_update_date_timestamp.init();
    a_server_update_date_timestamp.init();
  }

  int createCreationDateTimestamp() => DateTime.now().millisecondsSinceEpoch;

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
    super.conditionModelUser,
    super.defValue, {
    super.appCoreModelClassesCommonDbTableName,
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
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
    conditionModelUser,
    this.conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
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

  /// Each widget has it's custom configuration which is a [Map], f.e. a message has it's message text
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
    conditionModelContact,
    defValue, {
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
    super.hangOnWithServerCreateUntilParentAllows,
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
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
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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
  }) : super(conditionModelApp, conditionModelUser, conditionModelContact,
            defValue) {
    // dont forget of doing validation of [ConditionModelField]... fields like this:
    //_contact_e_mail.init();
    initCompleteModel();
  }
  @override
  initCompleteModel() {
    initModel();
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

/// App Configuration (also see [_driver] property). Among others it tells what users are logged preserving their ids in the app (not in the server). Tells what id can be assigned to a new user
@Stub()
class ConditionModelApp extends ConditionModel
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
  /// Signalling an intent for the future. code generators are to generate initial code for the application in this case f.e. the structure of a sql database (other implementations seem possible)
  late final ConditionBackendCodeGeneratorDB? _code_generator_db;

  /// Signalling an intent for the future. Code generators are to generate initial code for the application in this case f.e. creating full backend code. While the dart language seems to be the easiest, creating full server side PHP, nodejs, etc. code is taken into consideration. At the time of writing a condition_server.dart script is planned for a sandalone http server using many existing libraries of this app. Yeah among other all in this file condition_dara_managging.dart)
  late final ConditionBackendCodeGenerator? _code_generator_backend;

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

  /// Se also helper property [_serverKeyHelperContainer] desc. each app has it's id on the global server, each user belongs to this id - this helps to synchronize data between app installations of the same user, between different users. Difficult to explain see especially README.me file for overall up-to-date architecture. Each app that uses your app (with it's local server always running) as a it's global server has the key which is stored in [ConditionModelApp]s (Apps not App) db table, and the first mentioned app has it's own id all data is stored mainly this way app_id -> user id -> contact id -> anything else.
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldStringOrNull a_server_key =
      ConditionModelFieldStringOrNull(this, 'server_key',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType.app_only,
          isFinal: true);

  Completer<bool> serverKeyReadyCompleter = Completer<bool>();

  /// This variable stores the key from local server, checks if it is still valid, if not
  /// the app will get a new one and all old synchronized data will be lost, new synchronizing
  /// should begin, FOR WHATEVER REASON - YOU CHANGED GLOBAL SERVER SETTINGS - not now such an option or in development mode you clean a db of global server
  /// it would be awfully configurable, it\'s probably going unnecessaryly far.
  /// But developers might have more flexible approaches - the main approach is STABILITY!!!
  @protected
  late String? _serverKeyHelperContainer;

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

  /// Read also [_allAppModelsScheduledForUnlinking] description. Models are added using [_changesStreamControllerAllAppModelsChangesControllers].stream event handling probably something is prepared or a method is called in the constructor body. Represents all models getting a ConditionModelApp object into their constructor. They then belong to the app. Warning it is not the same as when you have a model ad add childs to it using addChild (or _addParentLink()) method for example. A model can be removed from the tree but Remain in this set here ([_allAppModels]) if a constructor param/property retireModelWhenWhenRemovedFromTheModelTree == false, more on that can be found in relevant ConditionModel properties description.
  final Set<ConditionModel> _allAppModels = {};

  /// Read also [_allAppModels] description. Models in this set are models that have had their method retire() called. They are immediately moved (the order of actions is yet to be established) to this list (class Set), when the model finished it's stuff, it is removed from the list here, and as it is supposed there souldn't be (MUST NOT BE!) any link to it left in the entire app. This will cause removing the object from the app memory with no unpredicted damage to the app.
  final Set<ConditionModel> _allAppModelsScheduledForUnlinking = {};

  /// the same as _children of [ConditionModelParentIdModel], ConditionModelApp dont't extend [ConditionModelParentIdModel] so the need for additional implementation. But the children themselves are [ConditionModelParentIdModel] only. Usage, adding, removing children or implementing or not implementing some metods is done differently than in the case of [ConditionModelParentIdModel].
  @AppicationSideModelProperty()
  final Set<ConditionModelUser> _children = {};

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
    ConditionBackendCodeGeneratorDB? code_generator_db,
    ConditionBackendCodeGenerator? code_generator_backend,
    Completer<ConditionDataManagementDriver>? driver_init_completer,
    super.changesStreamController,
    super.retireModelWhenWhenRemovedFromTheModelTree,
  }) : super(
            null,
            /*quick example debugging map: 
            // for debugging we add somthing that the map is not empty:
            //UNCOMMENT IT LATER: map,
            {
              'users_ids': '4,3,1',
              'users_counter': 5,
            },*/

            map ?? {},
            driver ??
                ConditionDataManagementDriver.getNewDefaultDriver(
                  //initCompleter: driver_init_completer, added in the constructor body
                  hasGlobalDriver: true,
                )) {
    //super.driver.addInitCompleter(this.driver_init_completer);

    _prepareActionsToTheModelTreeModelAddingRemovingStreamEvents();

    this.driver.conditionModelApp = this;
    this.driver.driverGlobal?.conditionModelApp = this;

    //this['server_key'] = 'adsfadsf';
    //users_counter = 5;

    a_server_key.init();
    a_users_counter.init();
    a_currently_active_user_id.init();
    a_currently_logged_users_ids.init();
    a_users_ids.init();
    initCompleteModel();
  }

  bool _isModelInTheTreeOrInsideAParentLinkModel(
          ConditionModelParentIdModel model) =>
      model._isModelInTheModelTree ||
              (model is ConditionModelEachWidgetModel &&
                  model._hasModelParentLinkModels)
          ? true
          : false;

  _triggerModelRemovalProcess(conditionModelAppDescendantModel) {
    _allAppModelsScheduledForUnlinking.add(conditionModelAppDescendantModel);
    _allAppModels.remove(conditionModelAppDescendantModel);
    // retire was not implemented at some point (is it?) the order of actions is important
    conditionModelAppDescendantModel.retire().then((ConditionModelParentIdModel
        conditionModelAppDescendantModelNotUsedProperty) {
      _allAppModelsScheduledForUnlinking
          .remove(conditionModelAppDescendantModel);
    });
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
      if (event is ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel ||
          event
              is ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel) {
        // See the above comments at the beginning of this if, the event order is important
        // app models is set, no need to check if _allAppModels.contains(event.childModel)
        // BELOW casting because as it seems linter couldn't make it
        // (or not resolved syntax error caused it to show errors)
        _allAppModels.add(event
                is ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel
            ? event.childModel
            : (event
                    as ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel)
                .childModel);
      } else if (
          // See the above comments at the beginning of this if, the event order is important
          event is ConditionModelInfoEventModelTreeOperationModelHasJustHadHisChildModelRemoved ||
              event
                  is ConditionModelInfoEventModelTreeOperationChildModelHasJustHadHisParentLinkModelRemoved ||
              event
                  is ConditionModelInfoEventModelTreeOperationRetireModelWhenWhenRemovedFromTheModelTree) {
        final childModel = event
                is ConditionModelInfoEventModelTreeOperationModelHasJustReceivedChildModel
            ? event.childModel
            : (event
                    as ConditionModelInfoEventModelTreeOperationChildModelHasJustReceivedParentLinkModel)
                .childModel;

        // See the above comments at the beginning of this if, the event order is important
        // app models is set, no need to check if _allAppModels.contains(event.childModel)
        //abc //and dont forget about this:
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
                !_isModelInTheTreeOrInsideAParentLinkModel(childModel)) {
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
          for (final descendantModel in childModel
              ._getModelDescendantsFlatListInTheOrderOfTraversing()) {
            if (_isModelInTheTreeOrInsideAParentLinkModel(descendantModel) &&
                descendantModel.retireModelWhenWhenRemovedFromTheModelTree) {
              _triggerModelRemovalProcess(descendantModel);
            }
          }
        }
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
    // NOw it is level "1" because this is ConditionModelApp object, user = 2 - also renders all
    // so no need to use or implement parentMode.parenMode... checking
    // and by this we must render children
    const int level = 1; // we use it or no let it be here not to get confused

    //Here // It is also in Readme.md We have a problem to solve a model may be in the tree or not.
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
          'ConditionModelParentIdModel, restoreMyChildren() override method: To restore this model\'s children models the _children property must be empty - must be this._children.isEmpty == true');
    }

    debugPrint(
        'reloginAllLoggedUsers(): let\'s get into a loop creating last logged-in users.');
    //_children (users);
    //activeUser;
    if (currently_logged_users_ids != null &&
        currently_logged_users_ids!.isNotEmpty) {
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

  /// Some important info in [addChild]() of this class description and differences in implementation from [ConditionModelParentIdModel] class's addChild
  removeChild(ConditionModelUser childModel) {
    throw Exception(
        'removeChild() of ConditionModelApp class: of See README.md[To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31] : related pretty much stuff not implemented. Especially ConditionModelApp model (not the parentModel) must make sure the child is inited on the locall server before it is removed and retired. The second it cannot be removed at this stage of the library/app development until the child is globally inited with it\'s children and further descentants too. the mentioned to do has steps to implement before this exception is removed');

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
          'class [ConditionModelApp] _requestGlobalServerAppKeyOnceAndThenPeriodically() trying to set up the server_key - just now should has been set up server_key = $server_key');
      a_server_key._fullyFeaturedValidateAndSetValue(
          serverKeyTemp, true, false, true);
      serverKeyReadyCompleter.complete(true);
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
              serverKeyTemp, true, false, true);
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
      // want be set up normaly it will go to _serverKeyHelperContainer
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
        if (null != _serverKeyHelperContainer) {
          if (_serverKeyHelperContainer!.isEmpty) {
            debugPrint(
                'initCompleteModel(): [ConditionModelApp] class we are throwing error because canTheKeyBeUsed == false, no db operation caused this error. This particular exception is not a problem, it is an option to avoid more sophisticated approach');
            // must be error here because at the moment of writing this comment an exception would allow for generation new key, but first MUST the temporary key be check out properly
            throw Error();
          }
          // it means that read() from the local server has been engaged to restore the model
          // and _serverKeyHelperContainer has been set up
          // if we can use it we will set up the final server_key if
          // we cannot use it because it is invalid we create a new one

          try {
            debugPrint(
                'class [ConditionModelApp], method initCompleteModel() We are now going to check out if we can use the locally (in the local server) stored server_key canTheKeyBeUsed waiting for success or exception');
            bool canTheKeyBeUsed = await driver.driverGlobal!
                .checkOutIfGlobalServerAppKeyIsValid(
                    (_serverKeyHelperContainer as String))
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
                  _serverKeyHelperContainer, true, false, true);
              serverKeyReadyCompleter.complete(true);
            }
          } catch (e) {
            debugPrint(
                'initCompleteModel(): [ConditionModelApp] class exception during checking out if we can use _serverKeyHelperContainer key read using read() model data method. Another attempts to set up the server_key later will be made. The error was: $e');
          }
        } else {
          await _requestGlobalServerAppKeyOnceAndThenPeriodically();
        }
      } catch (e) {
        debugPrint(
            'initCompleteModel(): [ConditionModelApp] class, driver.driverGlobal!.getDriverOnDriverInited() not able to init global driver, error: $e only local serve can be used');
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

//qw
    //  as // far as i remember this waiting for server_id and more is implemented different way
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

    contactdebug = ConditionModelContact(
        conditionModelApp,
        this,
        null,
        <String, dynamic>{
          'contact_e_mail': 'abcabcabcabc@gmail.com.debugging',
          //'user_id': //id, is it// allowed when hangOnWithServerCreateUntilParentAllows: true see addChild?
        },
        changesStreamController: contactChangesStreamController,
        hangOnWithServerCreateUntilParentAllows: true);

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
