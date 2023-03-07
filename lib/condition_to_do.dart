import 'condition_data_managging.dart';

/// NOT UP TO DATE, LIKE NOT USED. this class is for documentation very practical purposes ("dart doc" command) is to manage to do/improvement stuff by using real classess/generics, etc. to make links to them easily. You can find the issues in the methods description/documentation
class ConditionToDo {
  /// ExtendableMap extends DelegatingMap (only extending this allows extending Map class without the necessity of overriding any operators), condition_data_managging.dart is importing  'package:collection/collection.dart'; which is different from "package:dart:collection" - DelegatingMap doeas the job of extending the Map class (List, Map) but imports to many other classess, and possibly imports the package:dart:collection. Try importing one neccessary class which is possible. The point of using the import/s is to easy convert a Map with sub lists and maps to json - full tree - creating kind of data models with data and kind of db schema.
  void mapExtensionTooMuchOverheadAfterCompilationIssue(ConditionMap one) {}
}
