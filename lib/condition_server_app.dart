/// ConditionDataManagementDriverServer should do it all here and, all the same as a part ot the front-end app - start server, receive requests
/// this is to be run or build like this flutter run -t condition_server_app.dart .......
/// this is full backend server that can be used globally (earch planed) or not locally when included in the frontend app (main.dart entry) - all is to be done by condition_data_management_driver_server.dart file - nothing else or not much else !!!!!!
import 'condition_data_managging.dart';
import 'condition_data_management_driver_server.dart'; // only dart or native like windows, android (not web)
import 'condition_data_management_driver_sql.dart';

void main() {
  // createDriver() NEEDS THIS PARAMS
  /*{ConditionDataManagementDriverServer? synchronizing_global_server_driver,
      required ConditionDataManagementDriverServerSettings
          http_server_settings}
*/
  Future<ConditionDataManagementDriverServer> driver_server =
      ConditionDataManagementDriverServer.createDriver();
  //driver_server.then(() {});
}
