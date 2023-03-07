//import 'package:flutter/foundation.dart'   show kIsWeb; // to know if it is web platform kIsWeb bool
import 'condition_configuration.dart';
import 'condition_data_management_driver_sql_settings.dart';

/// copy pasted from condition_configuration somewhere there - hope the below description is up to date
/// you use object of this class always in the constructor of [ConditionDataManagementDriverServer] class
/// the app connects globally to the server (i mean earth) - we are now in the development mode so this server will be set up locally, and it is the same as local server except working completely separately
/// apart from that condition_server_app.dart uses it to start the global server based on the setting
/// in development mode app may create the global server apart from condition_server_app.dart global server
/// !!! also web simulates all servers ignoring the settings, global and local server
class ConditionDataManagementDriverServerSettings {
  /// this is ignored and treated as true in early stages of development always, for easy testing. Later we will work on existing here condition_server_app.dart app which will be the independent global server We don't create a server within the driver if it is global server
  final bool has_own_server;

  /// like 'iZf832_' this must be set but if you don't there is no error - by this you can use couple of applications with independent not conflicting db names in one db. Also it might prevent some sql attacks. Setting this up might prevent error when you forget to assign db name then prefix could became the full db name
  final String db_name_prefix;

  /// like 'te2xTa_' this must be set but if you don't there is no error - by this you can use couple of applications with independent not conflicting table names in one db. Also it might prevent some sql attacks.
  final String table_name_prefix;

  /// For now probably only 'http://', but should be https://
  final String protocol;

  /// f.e. localhost, or an address like www.example.com or 192.168.x.x
  final String host;

  /// f.e. 8081,
  final int port;

  /// Caution! Have not much knowledge about it but scanning surrounding ports by a client app may be met with adverse server reation. If an attached server cannot start listening on a given port it seeks the closest port numbers available. For this reason if you create your own app you should set up the port number once and for all for all app versions. Probably not recommended to set to true because f.e in local network you would have to check adressess and scan ports - better one stable adress. Ignored for global servers because you have to connect always to the right port on f.e. www.example.pl only if there is created and attached 'personal' server to the driver. See desc for [has_own_server].
  final bool can_use_different_port;

  /// f.e. sqlite3, in the future f.e. mysql - see condition_configuration.dart, also implementation in [getDefaultSettings] constructor for real configuration examples
  /// Additionally for sqlite3: the web will use a smart alternative - don't care about it. Watch out! requests compatible both with sqlite3 and js indexdb "sqlweb" (on github, it is based on jsstore by the same author)
  final ConditionDataManagementDriverSqlSettings db_settings;

  /// Constructor must be const because it is passed as param in [ConditionDataManagementDriverServer] class which requires creating const objects withoug constructor body
  const ConditionDataManagementDriverServerSettings(
      {this.has_own_server = true,
      this.db_name_prefix = 'defpref5H1w_',
      this.table_name_prefix = 'defprefQ82c_',
      this.protocol = 'http://',
      this.host = 'localhost',
      this.port = 8083,
      this.can_use_different_port = true,
      this.db_settings =
          const ConditionDataManagementDriverSqlSettingsSqlite3()});

  static ConditionDataManagementDriverServerSettings getDefaultSettings(
      bool is_global_server) {
    if (is_global_server) {
      return ConditionDataManagementDriverServerSettings(
          has_own_server: ConditionConfiguration
              .global_http_server_settings['has_own_server'],
          db_name_prefix: ConditionConfiguration
              .global_http_server_settings['db_name_prefix'],
          table_name_prefix: ConditionConfiguration
              .global_http_server_settings['table_name_prefix'],
          protocol:
              ConditionConfiguration.global_http_server_settings['protocol'],
          host: ConditionConfiguration.global_http_server_settings['host'],
          port: ConditionConfiguration.global_http_server_settings['port'],
          can_use_different_port: ConditionConfiguration
              .global_http_server_settings['can_use_different_port'],
          db_settings:
              ConditionDataManagementDriverSqlSettings.getDefaultSettings(true)
          //logically not technically equivalent of ConditionConfiguration.global_http_server_settings['db_settings']);
          );
    } else {
      return new ConditionDataManagementDriverServerSettings(
          has_own_server: ConditionConfiguration
              .local_http_server_settings['has_own_server'],
          db_name_prefix: ConditionConfiguration
              .local_http_server_settings['db_name_prefix'],
          table_name_prefix: ConditionConfiguration
              .local_http_server_settings['table_name_prefix'],
          protocol:
              ConditionConfiguration.local_http_server_settings['protocol'],
          host: ConditionConfiguration.local_http_server_settings['host'],
          port: ConditionConfiguration.local_http_server_settings['port'],
          can_use_different_port: ConditionConfiguration
              .local_http_server_settings['can_use_different_port'],
          db_settings:
              ConditionDataManagementDriverSqlSettings.getDefaultSettings(false)
          //logically not technically equivalent of ConditionConfiguration.global_http_server_settings['db_settings']);
          );
    }
  }
}
