//import 'package:flutter/foundation.dart'   show kIsWeb; // to know if it is web platform kIsWeb bool
import 'condition_configuration.dart';

/// Used by [ConditionDataManagementDriverSql] class. Read all this desc for compatibility SQL syntax f.e. sqlite3, in the future f.e. mysql - see condition_configuration.dart, also implementation in [getDefaultSettings] constructor for real configuration examples
/// Additionally for sqlite3: the web will use a smart alternative - don't care about it. Watch out! requests compatible both with sqlite3 and js indexdb "sqlweb" (on github, it is based on jsstore by the same author)
/// http_proxy_sqlite value - sql via http protocol, maybe implemented in the future - don't think how - it is not a [ConditionDataManagementDriverServer] server it is to be dummy sql driver via http protocol - some outside http server just cruds - by this you could - some encryption may be needed?
/// Let me remind you sqlite3, sql92, websql, and sqlweb (github indexedDB sql plugin) common syntax is required. For mysql, postgres and other drivers sql syntax must be universal and compatible - if not some translation is needed from this app common sql syntax.
abstract class ConditionDataManagementDriverSqlSettings {
  final ConditionAppDataManagementEnginesEnum type;

  const ConditionDataManagementDriverSqlSettings({
    required this.type, // the web will use a smart alternative - don't care about it. Watch out! requests compatible both with sqlite3 and js indexdb "sqlweb" (on github, it is based on jsstore by the same author)
  });

  static ConditionDataManagementDriverSqlSettings getDefaultSettings(
      [bool is_global_server = false]) {
    if (is_global_server) {
      return ConditionDataManagementDriverSqlSettingsSqlite3(
          native_platform_sqlite3_db_paths:
              ConditionConfiguration.global_http_server_settings['db_settings']
                  ['native_platform_sqlite3_db_paths'],
          login: ConditionConfiguration.global_http_server_settings['login'],
          password:
              ConditionConfiguration.global_http_server_settings['password']);
    } else {
      return ConditionDataManagementDriverSqlSettingsSqlite3(
          native_platform_sqlite3_db_paths:
              ConditionConfiguration.local_http_server_settings['db_settings']
                  ['native_platform_sqlite3_db_paths'],
          login: ConditionConfiguration.local_http_server_settings['login'],
          password:
              ConditionConfiguration.local_http_server_settings['password']);
    }
  }
}

/// Later make sure what to do if any param in the constructor is missing - f.e if you leave login and password but give some path to a sqlite3 file the default password may not work
class ConditionDataManagementDriverSqlSettingsSqlite3
    extends ConditionDataManagementDriverSqlSettings {
  final Map<ConditionPlatforms, String> native_platform_sqlite3_db_paths;
  final String? login;
  final String? password;

  /// read class description and constructor must be const because it is passed as param in [ConditionDataManagementDriverServerSettings] class which requires creating const objects withoug constructor body
  const ConditionDataManagementDriverSqlSettingsSqlite3(
      {this.native_platform_sqlite3_db_paths = const {
        ConditionPlatforms.Windows:
            './condition_data_management_driver_sql_default.sqlite', // the web will use something else
      },
      this.login,
      this.password})
      : super(type: ConditionAppDataManagementEnginesEnum.sqlite3);
}
