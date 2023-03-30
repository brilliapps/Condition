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
        this.whereClause =
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
                        : model['server_id'] != null
                            ? model['server_id']
                            : model['local_id'])
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
                        : model['server_id'] != null
                            ? model['server_id']
                            : model['local_id'])
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
  final Future<V> completerCreateFuture;
  final Future<V> completerModelIdByOneTimeInsertionKeyFuture;
  final Future<V>? completerServerCreationDateTimestampGlobalServerFuture;

  CreateModelOnServerFutureGroup(this.completerCreateFuture,
      this.completerModelIdByOneTimeInsertionKeyFuture,
      [this.completerServerCreationDateTimestampGlobalServerFuture])
      : super() {
    super.add(completerCreateFuture);
    super.add(completerModelIdByOneTimeInsertionKeyFuture);
    if (this.completerServerCreationDateTimestampGlobalServerFuture != null)
      super.add(
          completerServerCreationDateTimestampGlobalServerFuture as Future<V>);
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
    debugPrint('sqlite3CreateTableRegexString' +
        patterns.sqlite3CreateTableRegexString);

    return contents.replaceAllMapped(patterns.sqlite3CreateTableRegex, (m) {
      return '\nCREATE TABLE IF NOT EXISTS $tableNamePrefix${m[1]} ${m[2]}';
    });
  }

  String replaceAllCreateIndex(String contents) {
    debugPrint('sqlite3CreateIndexRegexString' +
        patterns.sqlite3CreateIndexRegexString);

    return contents.replaceAllMapped(patterns.sqlite3CreateIndexRegex, (m) {
      return '\nCREATE INDEX $tableNamePrefix${m[1]} ON $tableNamePrefix${m[2]} ${m[3]}';
    });
  }

  String replaceAllInsertInto(String contents) {
    debugPrint(
        'sqlite3InsertIntoRegexString' + patterns.sqlite3InsertIntoRegexString);

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
  late String _validation_exception_message =
      'The Integer value ConditionModelFieldInt must be in the range between ' +
          this.minValue.toString() +
          " and " +
          this.maxValue.toString();

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

  @override
  _fullyFeaturedValidateAndSetValue(int value,
      [bool isToBeSet = true,
      isToBeSynchronized = true,
      isToBeSynchronizedLocallyOnly = false]) {
    //!!!!! READ: you have model property here - you need it to finally validate the field

    if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
      throw ConditionModelModelNotInitedException(
          'A field of columnName/key: $columnName cannot be set');
    }

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
    if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
      throw ConditionModelModelNotInitedException();
    }

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

    if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
      throw ConditionModelModelNotInitedException();
    }
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

    if (isToBeSet == true && (!model.inited && isToBeSynchronized)) {
      throw ConditionModelModelNotInitedException();
    }

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
  //start properties db update system --------------------------------------
  //----------------------------------------------------------

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

  late final bool __inited;
  final Completer<ConditionModel> _initedCompleter =
      Completer<ConditionModel>();

  /// The property is treated in special way by setter/getter, "[]" operator, etc., all depending on the mode setting of "[ConditionModelApp] [conditionModelApp]" defined in [ConditionModelWidget] class property (the mode property changes the way all the deep tree of [ConditionModel] models which is also a [Map] ([Map] tree) is [jsonEncoded]/serialized), List of [ConditionModelEachWidgetModel] objects which are also [Map]s for easily jsonEncode and traversing the data and widget tree. F.e. maybe in some cases for LocalStorage this variable should return not list of objets but string of children ids "['5', '3', '20']" but in a away with their children "['5': ['8', ''40], '3', '20']" in effect ho   When widgets' layout order is changed this list also must be updated correspondingly, and vice versa when elements are changed here setState() is invoked to relayout the widgets in this list. This is all done down the widget tree.
  /// Below may is to do with initModel() method much.
  /// We are here:
  ////// [To do]
  ///Before reading the real to do based on the stuff we have
  ///and assuming we have full db structure with tables ready,
  ///but there is no data in it yet:
  ///---------------------------
  ///let's try:
  ///0. HERE WE START: ConditionModelApp in this of the other passess a future to ConditionModel parent
  ///super class; the future returns ConditionDataManagementDriver object. The ConditionModel waits
  ///until the future completes and then sets up the inited and ready to use late final _driver
  ///property with the driver returned by the future. Why using the future? Because it may be
  ///impossible to create and init a driver because f.e. a db sqlite3 file might be malformed or there
  ///may be some other error. So while the future is not completed a ConditionModelApp my attempt
  ///to create an alternative temporary driver based on diferent db engine - f.e. memory.
  ///-
  ///Having the driver ready the model as listed below either creates the models corresponding
  ///table row/entry, or reads it's data from the db table usually based on whether or not an id
  ///property of the newly created model has been set up. See more below.
  ///-
  ///1. Implement a ConditionModelApp initial data reading when the db is empty using
  ///   default settings from condition_configuration.dart if it is a good idea of course
  ///   with possible passing the initial data via the constructor (f.e. 5 apps at the same time
  ///   scenario)
  ///2. Only on model object creation, object constructor part: Let's implement creating
  ///   a new model db entry when id is null in the model but there is
  ///   data that passess validation process. Try to make as simple as you can with
  ///   temporary patching any stuff should be handled better.
  ///3. Only on model object creation, object constructor part: Let's implement
  ///   reading an existing model from db when there is an int id value set. Try to make as simple
  ///   as you can with temporary patching any stuff should be handled better.
  ///----------------------------
  ///We are here, all below is not about working with db, some rules of validation
  ///and settings values to variables i think
  ///now we need to workout and implement ConditionModelField object.value = something setting
  ///we need to override the value property to be int, String for now
  ///----------------------------
  ///Read all in this dashed part
  ///We need to make it final for this we need to extend classess and override the value property with final key word
  ///Optionally, not to create new ConditionModelField - like classes we can now if a field object is a final value one.
  ///Then we have two value properties instead of one value and late final valueFinal, and if a field object is final value,
  ///then valueFinal is used, then it can be set once and the most importat if you try to set-up the value for the second
  ///time you have a Visual Studio Express error or compile time error - that is the idea of this, that you can
  ///fixed the stuff before compilation and make the hyphothetical other programmers job easier.
  ///---------------------------
  ///We need to implement the detection that if id is not set a model object is new, but if id is set it's been created based on the db data, then it is fully validated.
  ///We need to think what to do when models like ConditionModelApp (maybe only this one) myabe cannot have initial values on it's creation that normally cannot be null. The only reason for that is that it must fetch it's data from the db first. Such model cannot be considered inited and ready to work.
  ///*/

  @AppicationSideModelProperty()
  @protected
  List<ConditionModel> children = [];

  Completer<bool> _completerInitModel = Completer<bool>();
  Completer<bool> _completerInitModelGlobalServer = Completer<bool>();

  @Deprecated(
      'All stuff will be managed differently i guess - ConditionDataManager is going to some changes like global server updates')
  List<ConditionModelListenerFunction> changesListeners = [];

  /// The data here will be distributed to the coresponding [ConditionModelField] objects and then set to null. Each [ConditionModelField] object has a final 'columnName' property (keys of the map below, and generally String or int/num value). After distributing the content of the map the data will be automatically validated. For example if a [temporaryInitialData] value should be notNull but is or is not set, an exception will be thrown. Later some other exceptions or errors can be thrown if f.e. there is an attempt of setting a value on a final columnName key.
  @protected
  Map temporaryInitialData = {};

  ConditionModel(this.temporaryInitialData, this.driver,
      {this.appCoreModelClassesCommonDbTableName: null})
      : super({}) {
    if (this is! ConditionModelCompleteModel)
      throw ConditionModelCompleteModelException();
  }

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

  /// Do the method private and pass to the [ConditionModelFields] fields as callback this cannot be called from outside, the fields themselves also pass something safaly as callback (_valueAndSet or something like that).  This is called from ConditionModelField object [validateAndSet](...) method. See mostly the [_fieldsToBeUpdated] property description
  @protected
  Future<bool> _triggerLocalAndGlobalServerUpdatingProcessGlobalServer(
      /*[String? columnName]*/) async {
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

    var completer = Completer<bool>();

    ConditionModelApp conditionModelApp =
        (this as ConditionModelIdAndOneTimeInsertionKeyModelServer)
            .conditionModelApp;

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
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!! This is the moment we can trigger the global server update (granted the [ConditionModelApp] object has its global server enabled)
        debugPrint(
            '?????????????? C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer()');
        completer.complete(true);
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
            debugPrint(
                'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() a Timer invoked the performTheModelUpdateUsingDriver() which invoked update() and returned error, NOT updated, result error, depending on the type of error (two processess accessed the same db file (if sqlite3) at the same time, internet connection lost, etc) !!!we now are trying to update the model doing it once per some longer time!!!: ${error.toString()}');
            // For the local server there is no attemptsLimitCountDownCounter localServer is supposed to work always in all circumstances, but for global server you can loose the internet connection, the server bandwitdh may be too much congested, etc.
            int attemptsLimitCountDownCounter = 2;
            Timer.periodic(const Duration(seconds: 5), (timer) {
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
                debugPrint(
                    'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer update attempt _fieldsNowBeingInTheProcessOfUpdateGlobalServer == $_fieldsNowBeingInTheProcessOfUpdateGlobalServer , _fieldsToBeUpdatedGlobalServer == $_fieldsToBeUpdatedGlobalServer : error: ${error.toString()}');
                // !!!!! Even if it works not much sure if something elsevhere was designed worse
                // than it should be - find out one day why the condition below shouldn't be here
                if (_fieldsNowBeingInTheProcessOfUpdateGlobalServer.isEmpty &&
                    _fieldsToBeUpdatedGlobalServer.isEmpty) {
                  timer.cancel();
                  completer.completeError(
                      'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer update _fieldsNowBeingInTheProcessOfUpdateGlobalServer.isEmpty && _fieldsToBeUpdatedGlobalServer.isEmpty. Not sure if it is an error but at best it may be not a well designed piece of code somewhere.');
                  return;
                }
              });
              if (attemptsLimitCountDownCounter-- == 0) {
                timer.cancel();
                completer.completeError(
                    'C] Inside _triggerLocalAndGlobalServerUpdatingProcessGlobalServer() cyclical timer updateattemptsLimitCountDownCounter-- == 0, we cannot update the model quickly and directly from the currently updated model. Probably, if already implemented, by design the model will be updated from local server db record in a cyclical slower way.');
              }
            });
            return false;
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
    scheduleMicrotask(() {
      if (columnName != null) {
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
        if (!isToBeSynchronizedLocallyOnly)
          _triggerLocalAndGlobalServerUpdatingProcessGlobalServer();
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // !!!!! This is the moment we can trigger the global server update (granted the [ConditionModelApp] object has its global server enabled)
        debugPrint('C]2:3!!!');
        return;
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
      Timer(const Duration(milliseconds: 8), () {
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
              debugPrint(
                  'C] Inside triggerLocalAndGlobalServerUpdatingProcess() cyclical timer update attempt _fieldsNowBeingInTheProcessOfUpdate == $_fieldsNowBeingInTheProcessOfUpdate , _fieldsToBeUpdated == $_fieldsToBeUpdated: error: ${error.toString()}');
              // !!!!! Even if it works not much sure if something elsevhere was designed worse
              // than it should be - find out one day why the condition below shouldn't be here
              if (_fieldsNowBeingInTheProcessOfUpdate.isEmpty &&
                  _fieldsToBeUpdated.isEmpty) {
                timer.cancel();
                return;
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
      ConditionModelApp conditionModelAppInstance) {
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
      working_driver.driverGlobal!
          .create(this,
              globalServerRequestKey: conditionModelAppInstance.server_key)
          .future
          .then((List<int?> result) {
        bool nullifyTheKey = false;
        if (result[0] != null && result[0]! > 0) {
          //this['id'] = result[0];
          //to do NOW
          //First no server_id set up on the server side (should be set up when record is created)
          //Second we need to then update the received id (is correct for now)
          //on local server with no update to the global server this should solve the problems
          //why there is no server_id both on local and global server
          debugPrint(
              '2:2:initModel() in _doDirectCreateOnGlobalServer() setting up server_id with no to global server update result[0] = ${result[0]}');
          columnNamesAndFullyFeaturedValidateAndSetValueMethods['server_id']!(
              result[0], true, true, true);

          debugPrint(
              '2:2:initModel() in _doDirectCreateOnGlobalServer() we did a successful create on global server and we will set up only on local server (already set up  on the global server and just now received) this model property this[\'server_creation_date_timestamp\'] = ${result[2]}');
          columnNamesAndFullyFeaturedValidateAndSetValueMethods[
              'server_creation_date_timestamp']!(result[2], true, true, true);

          nullifyTheKey = true;
        } else if (result[1] != null && result[1]! > 0) {
          debugPrint(
              '2:2:initModel() in _doDirectCreateOnGlobalServer() setting up server_id with no to global server update result[1] = ${result[1]}');
          //this['id'] = result[1];
          columnNamesAndFullyFeaturedValidateAndSetValueMethods['server_id']!(
              result[1], true, true, true);
          debugPrint(
              '2:2:initModel() in _doDirectCreateOnGlobalServer() we did a successful create on global server and we will set up only on local server (already set up  on the global server and just now received) this model property this[\'server_creation_date_timestamp\'] = ${result[2]}');
          columnNamesAndFullyFeaturedValidateAndSetValueMethods[
              'server_creation_date_timestamp']!(result[2], true, true, true);
          nullifyTheKey = true;
        } else {
          _completerInitModelGlobalServer.completeError(
              '2:initModel() in _doDirectCreateOnGlobalServer() working_driver.driverGlobal.create() error: With a list of one or two possible integers ${result.toString()} containing no int id a model initiation could\'t has been finished');
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
        _completerInitModelGlobalServer.completeError(
            '2:initModel() working_driver.driverGlobal.create() error: With a list of one or two possible integers containing no int id a model initiation could\'t has been finished. Exception thrown: error == $error');
      });
    }
  }

  /// See [ConditionModelCompleteModel] class desc. This method must be called in a complete model class that is not extended by other classess but is an object that is stored in the db
  @nonVirtual
  @protected
  Future<bool> initModel() {
    if (this is! ConditionModelCompleteModel) {
      throw Exception(
          'the ${this.runtimeType.toString()} model object extending ConditionModel class is not mixed with ConditionModelCompleteModel class marking, that the object is a complete ready to use model');
    }
    for (final String key in temporaryInitialData.keys) {
      if (!columnNamesAndTheirModelFields.containsKey(key)) {
        throw Exception(
            'A model of [${this.runtimeType}] class tries to set up a key (columnName) named ${key.toString()} that is not allowed - no ConditionModelField object has been defined or defined & inited for the model to handle the columnName with its value.');
      }
    }

    // this is to be removed when it is listened somewhere else and options for listening are added.
    // not that initModel returns just _completerInitModel.future
    // but nothing like that for the global server model initModelGlobal server or something
    _completerInitModelGlobalServer.future.catchError((error) {
      debugPrint(
          'initModel() _completerInitModelGlobalServer.future exception catched see code of initModel seek the debugPrint, and the async exception thrown is: $error');
      return false;
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
            working_driver.create(this).future.then((result) async {
              debugPrint(
                  '2:initModel() working_driver.create() success result: ${result.toString()}');

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

                if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
                  _doDirectCreateOnGlobalServer(working_driver,
                      conditionModelAppInstance as ConditionModelApp);
                }
              }
              _inited = true;
              // If during validation process no Exception was thrown:
              temporaryInitialData = {};
              // -----------------------------------
              // ??? So at the moment we have no exception
              // ??? So we can play with the db. But first some debugPrint
              debugPrint(
                  '2:initModel() working_driver.create() also the created Model has just been inited it\'s id of ${this['id']} has been set. _inited==true and the model looks like this');
              debugPrint(toString());
              _completerInitModel.complete(true);
            }).catchError((error) {
              debugPrint(
                  '2:initModel() working_driver.create() error result: ${error.toString()}');
              _completerInitModel.completeError(
                  'The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure creating a db record');
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

              _inited = true;
              _completerInitModel.complete(true);
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
            columnNamesAndFullyFeaturedValidateAndSetValueMethods['local_id']!(
                this['id'], true, false);

            // this will local_id on a local - if fails it will do it until it will success that the conde will execute further
            await _updateLocalId(working_driver);

            if (this is ConditionModelIdAndOneTimeInsertionKeyModelServer) {
              _doDirectCreateOnGlobalServer(working_driver,
                  conditionModelAppInstance as ConditionModelApp);
            }
          }

          _inited = true;
          _completerInitModel.complete(true);
          temporaryInitialData = {};
          // If during validation process no Exception was thrown:

          // -----------------------------------
          // ??? So at the moment we have no exception
          // ??? So we can play with the db. But first some debugPrint
          debugPrint(
              '1:initModel() working_driver.create() also the created Model has just been inited it\'s id of ${this['id']} has been set. _inited==true and the model looks like this');
          debugPrint(toString());
        }).catchError((error) {
          debugPrint(
              '1:initModel() working_driver.create() error result: ${error.toString()}');
          _completerInitModel.completeError(
              'The model of class ${runtimeType.toString()} couldn\'t has been inited because of failure creating a db record. The error result: ${error.toString()}');
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

      try {
        throw Exception(
            'ConditionModel not implemented method initModel - early stage of development');
      } catch (e) {
        debugPrint(e.toString());
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
    debugPrint(
        '_inited setter of this.runtimetype == ${runtimeType} and value == $value');
    __inited = value;
    if (value) {
      _initedCompleter.complete(this);
    } else {
      var message =
          'A model of ${runtimeType.toString()} couldn\'t has been inited (_init=false just has been performed). Several attempts might have been performed. By convention the model cannot be used in the app and should be removed, and all depending data and variables.';
      _initedCompleter.completeError(message);
      throw Exception(message);
    }
  }

  @protected
  bool get inited {
    debugPrint('_inited getter of this.runtimetype == ${runtimeType}');
    try {
      return __inited;
    } catch (e) {
      debugPrint(
          '_inited error error getter of this.runtimetype == ${runtimeType}');
      return false;
    }
  }

  Future<ConditionModel> getModelOnModelInitComplete() =>
      _initedCompleter.future;

  @override
  void operator []=(key, value) {
    debugPrint('yerttttt1____' + key);

    switch (key) {
      case 'children':
        children = value;
        break;
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
  // some old missed comment??: Null because the problem is conditionModelApp
  final ConditionModelApp conditionModelApp;

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
      this.conditionModelApp, this.conditionModelUser, defValue,
      {super.appCoreModelClassesCommonDbTableName})
      : super(defValue, conditionModelApp.driver) {
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
}

abstract class ConditionModelParentIdModel
    extends ConditionModelIdAndOneTimeInsertionKeyModel {
  /// Some validation difficult to say bat when parent_id is set parentModel should be present so that the current model's widget could be immediately placed into the tree. Models must not intependent on their parents, ancestors or children to be easily moved in the model tree. not final because you can move this model to another place in the model tree and by this change the immediate parent. You need the property to traverse up the tree to find some ancestor models (like in javascript DOM level 2 parentNode property) seek searching methods - All normal models along with ConditionModelUser have the property, except for the top ConditionModelApp
  ConditionModelParentIdModel? parentModel;

  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_parent_id =
      ConditionModelFieldIntOrNull(this, 'parent_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .both_app_and_server_synchronized,
          isFinal: false);

  ConditionModelParentIdModel(super.conditionModelApp, super.conditionModelUser,
      this.parentModel, super.defValue,
      {super.appCoreModelClassesCommonDbTableName}) {
    a_parent_id.init();
  }

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
  @ServerSideModelProperty()
  @protected
  late final ConditionModelFieldIntOrNull a_local_id =
      ConditionModelFieldIntOrNull(
          this, 'local_id',
          propertySynchronisation:
              ConditionModelFieldDatabaseSynchronisationType
                  .from_server_and_read_only,
          isFinal: true);

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
  ConditionModelIdAndOneTimeInsertionKeyModelServer(super.conditionModelApp,
      super.conditionModelUser, super.parentModel, super.defValue,
      {super.appCoreModelClassesCommonDbTableName}) {
    if (null == temporaryInitialData['id']) {
      // id is possibly set in the class extending but here
      temporaryInitialData['to_be_synchronized'] = 1;
      // this is called on top: f.e ConditionModelMessage: validateInitialData(this); // not implemented, maybe done with little delay
      //  _createAndSetOneTimeInsertionKeyServer();
    } else {
      temporaryInitialData['local_id'] = temporaryInitialData['id'];
    }
    a_local_id.init();
    a_app_id.init();
    a_to_be_synchronized.init();
    a_server_id.init();
    a_server_parent_id.init();
    // a_server_one_time_insertion_key.init();
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

  ConditionModelCreationDateModel(super.conditionModelApp,
      super.conditionModelUser, super.parentModel, super.defValue,
      {super.appCoreModelClassesCommonDbTableName}) {
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

  ConditionModelWidget(super.conditionModelApp, super.conditionModelUser,
      super.parentModel, super.defValue,
      {super.appCoreModelClassesCommonDbTableName}) {
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

/// Let's say: You've just loaded the app in the browser and just after that gotten offline (!!! BASE FOR THE DATA ARCHITECTURE). [ConditionModelId] id pseudo model class - just a [Map]. Example On login you get full model tree (data models of widget) which is a Map of [ConditionModel] extended class models (almost always data models of widgets) - it's a [Map]. A simplified mirror [Map] consisting of [ConditionModelId] class (also [Map]) is created and json encoded as is to LocalStorage. This ConditionModelId Map contains only ids of the widget f.e [5] : [24, 7, 19] widget id 5 has three widgets 24, 7, 19. You change order to [7, 24, 19]. You reload page but from the cashe (explained in readme file) you create final model map (you create app with this [ConditionModelApp](map?)). The final model has our [7, 24, 19] but in this simplified way [ConditionModelEachWidgetModel map, ConditionModelEachWidgetModel map, ConditionModelEachWidgetModel map] where each ConditionModelEachWidgetModel map is link to an object the mentioned original ConditionModel map tree - you don't want to (clone objects and waiste memory right?). Return to our local storage. We changed a widget, or added we now mark a [ConditionModelEachWidgetModel} widget model as changed you have getter for changed property it returns true now (change in comparison to the full widget model tree loaded from cashe in case there is no internet). We again create a new reflection the current working model and store it in localStorage. How? One by one we check each widget model and for local storage use only its id if it hasn't been changed (after change model.change property of the model == true) or added (after addition also true) as you already should know or the model serialized [ConditionModelEachWidgetModel jsonserializedmap]. Again we create all the model tree for the app as already explained - we seek models from the original first model tree created from the casche after offline reload gets links to them in the final model also deserialise new or changed models from localStorage and put them into final model. After we get online we synchronize all the data reload the app if app was successfully reloaded then we can clean the localstorage
@Stub()
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

  ConditionModelBelongingToContact(conditionModelApp, conditionModelUser,
      parentModel, this.conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel, defValue,
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
  @AppicationSideModelProperty()
  @protected
  late final ConditionModelFieldInt a_model_type_id = ConditionModelFieldInt(
      this, 'model_type_id',
      propertySynchronisation:
          ConditionModelFieldDatabaseSynchronisationType.app_only,
      isFinal: true);

  // !!! Widget id and server_id are defined in the parent class
  // !!! you don't need to have type_id because this is stored in the model class name - ConditionModelMessage has the information what table the information should be stored in. not the same with [link_type_id] and [server_link_type_id]

  /// The what a given type id represents you can recognize from [_ids_oa_model_class_names]. Also see [_link_id], [_server_link_type_id] [_server_link_id], desc - if type = 0 it is a contact [ConditionModelContact], 1 - message [ConditionModelMessage], 2 ... , etc.
  ///
  /// Howerver you don't need to have application side type_id because this is stored in the model class name - f.e. [ConditionModelMessage] has the information what table the information should be stored in. not the same with [link_type_id] and [server_link_type_id]
  @BothAppicationAndServerSideModelProperty()
  @protected
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

  ConditionModelEachWidgetModel(conditionModelApp, conditionModelUser,
      parentModel, conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, conditionModelContact,
            parentModel, defValue) {
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
  set link_type_id(int? value) => a_link_type_id.validateAndSet(value);
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
  ConditionModelContact(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelMessage(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelVideoConference(conditionModelApp, conditionModelUser,
      parentModel, conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelTask(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionTripAndFitness(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelURLTicker(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelReadingRoom(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelWebPage(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelShop(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelProgramming(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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
  ConditionModelPodcasting(conditionModelApp, conditionModelUser, parentModel,
      conditionModelContact, defValue)
      : super(conditionModelApp, conditionModelUser, parentModel,
            conditionModelContact, defValue) {
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

  final List<ConditionModelUser> loggedUsers = [];
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
  }) : super(
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

    this.driver.conditionModelApp = this;
    this.driver.driverGlobal?.conditionModelApp = this;

    this.driver.getDriverOnDriverInited().then((param) {
      // something like this
      debugPrint(
          'something went right! :) A this.driver.inited == ${this.driver.inited} driver has been inited different way via constructor');
      debugPrint(param.toString());
      _restoreLastLoggedUserModelTreeOrSetUpLoginPage();
    });

    //this['server_key'] = 'adsfadsf';
    //users_counter = 5;

    a_server_key.init();
    a_users_counter.init();
    a_currently_active_user_id.init();
    a_currently_logged_users_ids.init();
    a_users_ids.init();
    initCompleteModel();
  }

  /*ConditionDataManagementDriver get driver {
    return _driver;
  }*/

  reloginAllLoggedUsers() {
    debugPrint(
        'reloginAllLoggedUsers(): let\'s get into a loop creating last logged-in users.');
    //loggedUsers;
    //activeUser;
    for (String loggedId in (currently_logged_users_ids as String).split(',')) {
      debugPrint(
          'reloginAllLoggedUsers(): let\'s re-create user model of id == $loggedId and ad it to the this.loggedUsers list.');
      loggedUsers
          .add(ConditionModelUser(this, null, {'id': int.parse(loggedId)}));
    }

    //ConditionModelUser(conditionModelApp, parentModel, {'id'});
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
    await driver.getDriverOnDriverInited();

    debugPrint('!!We\'ve entered the initCompleteModel() ');
    bool allowForUsersRelogin = false;
    try {
      // if the model is read successfuly from local server the server_key
      // want be set up normaly it will go to _serverKeyHelperContainer
      // then if the global server still hadles it and considers valid
      // it will be set up as server_key
      bool isInited = await initModel();
      debugPrint(
          'Custom implementation of initCompleteModel() the value of isInited == $isInited : Model of [ConditionModelApp] has been inited. Now we can restore or not f.e. last logged and last active user or whatever.');
      debugPrint('The value of model.inited is: ${inited}');
      debugPrint(
          'Let\'s try to automatically relogin all logged users and then to bring to screen\'s front the last active logged in user with some of his/her lazily logged widgets');
      allowForUsersRelogin = true;
      debugPrint('!!!!!!!!!!!!!!!!!!!!! 22222 WE ARE HERE ');
    } catch (e) {
      // ARE WE GOING TO USE NOT ENDLESSLY INVOKED TIMER TO invoke initModel() again with some addons if necessary? Some properties might has been set already.
      debugPrint('!!!!!!!!!!!!!!!!!!!!! 11111 WE ARE HERE ');
      debugPrint(
          'Custom implementation of initCompleteModel(): Model of [ConditionModelApp] hasn\'t been inited. The error of a Future (future.completeError()) thrown is ${e.toString()}');
      rethrow;
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

    if (allowForUsersRelogin) {
      reloginAllLoggedUsers();
    }
  }

  void _restoreLastLoggedUserModelTreeOrSetUpLoginPage() {
    // getActiveUserId() at the time of writing this comment returns a Future returning int 4 - app is in early stages of developping
    getActiveUserId().then((user_id) {
      if (null != user_id) {
        debugPrint("_restoreLastLoggedUserModelTreeOrSetUpLoginPage, user_id:" +
            user_id.toString());
        restoreModelTreeLazily(user_id);
      } else {
        debugPrint(
            "_restoreLastLoggedUserModelTreeOrSetUpLoginPage, user_id, setUpLoginPage user_id:" +
                user_id.toString());
        setUpLoginPage();
      }
    });
  }

  // When there is no registered user or a front user has been logged out or maybe there was l logged user but it was not screen active at the time the app was turned off a proper screen of register/login/brigtofrontsecondactiveuser etc. is to appear where those situations are going to be handled properly
  void setUpLoginPage() {
    debugPrint('setUpLoginPage - last login user not found');
    throw Exception('setUpLoginPage - last login user not found');
  }

  /// Works with [restoreModelTree]() When you start the app you will be automatically logged or session restored of last user that was used/displayed on screen before the app was closed
  @Stub()
  @MustBeImplemented()
  Future<int?> getActiveUserId() {
    // Temporarily in debug mode example_data.dart had user id 4 most packed with data (at the time of writing of this comment)
    return Future<int?>(() {
      return 4;
    });
  }

  void init(ConditionWidgetBase widget) {
    this.widget = widget;
  }

  /*ConditionWidgetBase get widget {
    return this._widget;
  }*/

  /// Works with [getActiveUserId]() but it doesn't have to. Should return set of not fully inited models working independently. So you can have two trees if you want working fully and on server (better flexible approach for future ideas)
  void restoreModelTreeLazily(int user_id) {
    debugPrint('here we are restoreModelTreeLazily method');

    restoreFullTreeOfConditionModelObjects(user_id);
  }

  /// recursively traversing [jsonDecode] object based on which
  /// now we have tree of ids which we should traverse to recreate/restore all tree of ConditionModel (mainly ConditionModelWidget extending) objects
  /// in short (see example_data.dart) you find id user id, contact id (except it is a contact), model type id, widget id, based on this we create a key and try to retrieve value in _driver or _driver_temp
  /// ! But if we find one updated widget in _driver_temp we stop seeking the old one using _driver
  /// whatchout! asynchronous operation probably on futures! Futures - to avoid potential bottle necks
  void restoreFullTreeOfConditionModelObjects(int user_id) {}

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

  ConditionModelUser(conditionModelApp, parentModel, defValue)
      : super(conditionModelApp, null, null, defValue) {
    a_e_mail.init();
    a_phone_number.init();
    a_password.init();
    a_local_server_key.init();
    a_local_server_login.init();
    initCompleteModel();
  }

  restoreTreeTopLevelModelsOrMostRecentMessagesModels() {
    // let's add a testing widget like contact and messages with local servr in mind

    var contactdebug =
        ConditionModelContact(conditionModelApp, this, null, null, {
      'contact_e_mail': 'abcabcabcabc@gmail.com.debugging',
      'user_id': id,
    });

    children.add(contactdebug);

    contactdebug.getModelOnModelInitComplete().then((model) {
      debugPrint(
          'B] We are in [ConditionModelUser]\'s restoreTreeTopLevelModelsOrMostRecentMessagesModels() in then() of getModelOnModelInitComplete() method of a ConditionModelContact model. the model just has been inited and is ready to use. Let\'s debug-update a field/property of the model. Each time the value will be different - timestamp');
      contactdebug.description =
          DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint(
          'B] And the value now is contactdebug.description == ${contactdebug.description}');
    }).catchError((error) {
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
    try {
      bool isInited = await initModel();
      debugPrint(
          'initCompleteModel() of ConditionModelUser Custom implementation of initCompleteModel(): Model of [ConditionModelUser] has been inited. Now we can restore all tree tree top-level widget models belonging to the currently logged AND FRONT SCREEN ACTIVE user models like contacts, messages, probably not rendering anything yet. Possibly some other users related stuff is going to be performed');
      restoreSomeUsersWidgetModels = true;
    } catch (e) {
      debugPrint(
          'Custom implementation of initCompleteModel(): Model of [ConditionModelUser] hasn\'t been inited. The error of a Future (future.completeError()) thrown is ${e.toString()}');
      // ARE WE GOING TO USE NOT ENDLESSLY INVOKED TIMER TO invoke initModel() again with some addons if necessary? Some properties might has been set already.
    }

    if (restoreSomeUsersWidgetModels) {
      restoreTreeTopLevelModelsOrMostRecentMessagesModels();
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

/// Each widget has it's own configuration field which is a map, but it stores data in the configuration field in the app as json string, but in the backend you decide to put it into "configuration" field (by default) or to create a separate table for it
@Stub()
class ConditionModelConfigurationModel<ConditionModelEachWidgetModel>
    extends ConditionMap {
  /// ConditionModel class for the description and compatibility
  @Stub()
  late ConditionModel parent_model;

  ConditionModelConfigurationModel(this.parent_model, defValue)
      : super(defValue) {}
}
