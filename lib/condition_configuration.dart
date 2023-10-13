import 'package:flutter/foundation.dart'
    show kIsWeb; // to know if it is web platform kIsWeb bool
import 'condition_data_managging.dart';

//import 'condition_data_management_driver_sql_settings.dart'; // imported for some enums

/// Most probably what matter is only sql engines, other than that hive, shared_preferences are left for historical purposes
enum ConditionAppDataManagementEnginesEnum {
  sqlite3,
  postgres,
  mysql,
  http_proxy, // driver via http - as mentioned most probably based on any sql engine
  // The architecture changed hard to imagine non-sql engines, but...:
  hive,
  shared_preferences
}

/// Used followed by package [Platform] class naming convention (there is isAndroid for example), also not available there 'Web' (can be detected thanks to foundation package) and 'Dart' for commandline-like non graphic-interface-platform app
enum ConditionPlatforms {
  Android,
  Fuchsia,
  IOS,
  Linux,
  MacOS,
  Windows,

  Web,

  /// non flutter graphic standalone commandline like dart app
  Dart,
}

const bool condition_global_http_port = false; // never change it

enum ConditioDataManagementDriverBackendEnginesEnum { json, xml }

/// See the many coments and got to a conclusion, that all here should be strings to export the settings to json or anything else
class ConditionConfiguration {
  // in seconds - server side languages like php a script may be interrupted after 30 seconds. So if you haven't gotten a response from a server you know that there was an error - you may have gotten an answer from the global server or not. The point of the static property is that you possibly may have a php or other script performing an internal dart server http call from the php script. Just an example scenario. This means that you need to add a couple of seconds to the setting to make another call from the flutter app for example.
  static const int max_global_server_request_time = 30;

  /// there are two entry points for the app main.dart (client app with graphic interface) and condition_server_app.dart which is only server side. Of course each main.dart app has two aspects of data management - local storage and global server storage. condition_server_app.dart is to serve as global server backend (not entirely, implementing some keybord input or in/out pipelines also for local aspect may be even planned). If isClientApp is set to true, it tells the app's ConditionDataManagementDriver class derived classess to choose between  drier or driver._DriverGlobal object for performing data operations which also is important because any driver normally contains different database or table name prefixex to make them distinguished, or allowing to contain couple of apps using one db. You sould be able to understand it better when you analyse the driver classes code.
  static late final bool
      isClientApp; // set up later - in the frontend in main() function
  static late final bool
      debugMode; // set up later - in the frontend in main() function
  static late final int?
      initDbStage; // set up later - in the frontend in main() function
  static const bool isWeb = kIsWeb;

  /// Caution! Because ConditionModelContact may have implemeneted data channels or something they would have to be always rendered fully. This tells you how deeply it will restore model/widget tree after the app restart. So this is what you see/have on the screen without requiring user to click buttons like unfold and after that lazily another level/branch of models/widgets is loaded (models means level, widgets: for a one particular model a subtree of widgets may be involved)
  static const int maxNotLazyModelTreeRestorationLevel = 3;

  /// Used with [maxNotLazyModelTreeRestorationLevel], see the description of the property
  static const int maxNotLazyModelTreeRestorationLevelForStandaloneModels =
      2; // it should rather be 1 but in the development mode we need greater value for testing

  /// Speaking in SQL terms it is LIMIT 10 part of SQL query. It may be with regard to select query only.
  static const int maxNumberOfReturnedResultsFromDb = 10;

  static const ConditionAppDataManagementEnginesEnum defaultAppDataEngine =
      ConditionAppDataManagementEnginesEnum.sqlite3;
  static const ConditionAppDataManagementEnginesEnum defaultBackendDataEngine =
      ConditionAppDataManagementEnginesEnum.sqlite3;

  static const String fullSQLDbInitPath = './condition_full_db_init.sql';

  /// Caution: The code the path points to is a full db export to sql (db is in initial state for the app - with all tables and neccessary initial universal data). Although the sql the path property points to is for all db engines like slite3, mysql, postgres, sqlweb (js github library), it will be translated to particular engines automatically if not fully compatible. Used when sqlite3 not mysql, etc. db is used, for now for web a javascript code <script src='[full_db_init_path_native]'></script> will be created.
  static const String full_sqlite3_db_init_sql_code_path = kIsWeb
      ? 'sqlite3/condition_sqlite_init.js'
      : 'condition_full_db_init.sql';

  static const Map paths_to_sqlite_core_library = {
    ConditionPlatforms.Windows:
        './sqlite3.dll', // the web will use something else
  };

  // we have sqlite3 [ConditionDataManagement] driver, mysql driver, but the app as global server uses sort of proxy http driver
  static const useMysqlForDartCommandlineGlobalServer = true;

  static const dartCommandlineGlobalServerMySQLDBDefaultSettings =
      <String, dynamic>{
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'db': 'testdb',
    'password': 'secret'
  };

  /// the app connects globally to the server (i mean earth) - we are now in the development mode so this server will be set up locally, and it is the same as local server except working completely separately
  /// apart from that condition_server_app.dart uses it to start the global server based on the setting
  /// in development mode app may create the global server apart from condition_server_app.dart global server
  /// !!! also web simulates all servers ignoring the settings, global and local server
  static const Map global_http_server_settings = {
    'db_name_prefix': 'it3XQhQ_',
    'table_name_prefix': 'Rzi3a7d_',
    'has_own_server':
        false, // this is ignored in early stages of development, for easy testing. Later we will work on existing here condition_server_app.dart app which will be the independent global server We don't create a server within the driver if it is global server
    'protocol': 'http://',
    'host': 'localhost',
    'port': '8081',
    'can_use_different_port':
        condition_global_http_port, // always false, a stable remote global server cannot change it ports so easily
    'db_settings': {
      'type': ConditionAppDataManagementEnginesEnum
          .sqlite3, // the web will use a smart alternative - don't care about it. Watch out! requests compatible both with sqlite3 and js indexdb "sqlweb" (on github, it is based on jsstore by the same author)
      'native_platform_sqlite3_db_paths': {
        ConditionPlatforms
                .Windows: // possibly used for linux/mac/... if accidentally works
            './condition_data_management_driver_sql_global.sqlite', // the web will use something else
        ConditionPlatforms.Web:
            'condition_data_management_driver_sql_global', // the web will use something else
      },
      'login': 'admin6324',
      'password': 'admin258'
    }
  };

  /// see some comments for [default_http_global_server_settings] property this one is created by the front-end app works the same a global server
  static const Map local_http_server_settings = {
    'db_name_prefix': 'tiVx8x_',
    'table_name_prefix': 't8QjKjA_',
    'has_own_server':
        true, // this is ignored in early stages of development, for easy testing. Later we will work on existing here condition_server_app.dart app which will be the independent global server We don't create a server within the driver if it is global server
    'protocol': 'http://',
    'host': 'localhost',
    'port': '8082',
    'can_use_different_port': true,
    'db_settings': {
      'type': ConditionAppDataManagementEnginesEnum
          .sqlite3, // the web will use a smart alternative - don't care about it. Watch out! requests compatible both with sqlite3 and js indexdb "sqlweb" (on github, it is based on jsstore by the same author)
      'native_platform_sqlite3_db_paths': {
        ConditionPlatforms
                .Windows: // possibly used for linux/mac/... if accidentally works
            './condition_data_management_driver_sql_local.sqlite', // the web will use something else
        ConditionPlatforms.Web: 'condition_data_management_driver_sql_local',
      },
      'login': 'admin6324',
      'password': 'admin258'
    }
  };
}
