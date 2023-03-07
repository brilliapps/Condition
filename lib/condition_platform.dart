/// all is described in condition_platform_web.dart which is imported /// a tricky solution from dart you probably must maintain a full version of the classess in this file and a stub version with all classess properties and methods, because one of two files is imported: a conditional import in condition_data_managing.dart imports this if the app is web, or for non-web imports condition_platform.dart
class ConditionPlatform {
  static const bool? isWeb = null;
  static const Map? all_stuff = null;
}
