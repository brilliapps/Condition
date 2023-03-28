// https://stackoverflow.com/questions/67937479/how-to-add-conditional-imports-across-flutter-mobile-web-and-window//import 'dart:developer'; // for inspect(myVar); like print_r var_dump in php
//if(kIsWeb){
//{
//     return WebPage();  //your web page with web package import in it
//}
//else if (!kIsWeb && io.Platform.isWindows) {
//     return WindowsPage(); //your window page with window package import in it
//    }

import 'dart:async';
import 'dart:isolate';
// somehow it imported for the web so i guess dart:html i can import in some special separate file for _driver (ConditionModelApp)

import 'dart:convert';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'condition_app_base.dart'; //empty informational and later etended class used by server and frontend/native/web
import 'condition_storage_drag_and_drop_box.dart';

import 'condition_data_managging.dart';

import 'example_data.dart';
import 'condition_to_do.dart';
import "condition_configuration.dart";
//import 'package:hive/hive.dart';
import 'condition_multi_types.dart';

///class abcdefghijk {
///  noSuchMethod(Invocation invocation) =>
///      'Got the ${invocation.memberName} with arguments ${invocation.positionalArguments}';
///}

///wereeee(abcdefghijk abc) {}

//flutter run -d chrome --web-renderer html
//flutter build web --web-renderer canvaskit
//flutter run ...... --enable-impeller...... html
//hard link to test db contents: mklink /h c:\www\condition_sqlite_dbs\condition_data_management_driver_sql_local_flutter_project_link.sqlite c:\flutterprojects\condition2\condition\condition_data_management_driver_sql_local.sqlite

//https://groups.google.com/a/dartlang.org/g/cloud/c/815uojKYXuA Dart runs in an event loop and all IO operations are non blocking, so I’d say it is very similar to Node in this regard.
//https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop except for alert(): A very interesting property of the event loop model is that JavaScript, unlike a lot of other languages, never blocks. Handling I/O is typically performed via events and callbacks, so when the application is waiting for an IndexedDB query to return or an XHR request to return, it can still process other things like user input.

///class TestSerializeOrJson extends ConditionMap {
///  //final delegate = {};
///  //late V defValue;
///  final Map defValu///e;

//////  TestSerializeOrJson(this.defValue)
//////      : super(defValue); // don't know why only this notation work//////ed

//////  @override
///  operator [](Object? key) =>
///      'abcasdfasdfasdf' + (defValue[key] ?? defValue[key]///);

//@override void operator []=(key, value) ///{}

///  //@override
//V operator [](key) { return 'key: $key, value:as you want' as V; }

/*@override
  String toString() {
    debugPrint('The current model looks like this:');
    debugPrint('this.runtimeType==${this.runtimeType}');
    //debugPrint('this.toString()==${this.toString()}');
    //debugPrint('jsonEncode==${jsonEncode(this)}');
    debugPrint('And it is fully iterable first for(var i...):');
    for (var key in keys) {
      //debugPrint('key==$key, value==${this[key]}');
    }
    return 'testing options: whatever result';
  }*/
///}

///Testing purposes class of how to implement toString and toJson which is not overriden but used by jsonEncode - it can return String or numeric value (encoded as no string!) or Map. Ju can imply what you are going to return hinting the return Type.
///class testwerwerwerwerwerwewerwer {
///  String toString() => 'toStringExample44444testwerwerwerwerwerwewerwer';
///
///  //operator [](key) { return 'key: $key, value:as you want'; }
///
///  /*testwerwerwerwerwerwewerwer.fromJson(Map<String, dynamic> json)
///      : name = json['n'],
///        url = json['u'];*/
///
///  String toJson() => "toJsonexample:44444testwerwerwerwerwerwewerwer";

/*Map<String, dynamic> toJson() {
    return {
      'n': name,
      'u': url,
    };*/
///}

class rrttyy {
  int eeee = 10;
  rrttyy();
  wwww() {
    debugPrint('rrttyy');
  }
}

class rrttyy2 extends rrttyy {
  rrttyy2() : super();

  @override
  wwww() {
    debugPrint('rrttyy2');
  }
}

class qqaazz {
  rrttyy objecttest;
  qqaazz(this.objecttest);
  printrrttyy() {
    objecttest.wwww();
  }
}

class TestPrivateProtectedChild2 extends TestPrivateProtected {
  TestPrivateProtectedChild() {
    debugPrint(rrrr); // it's ok - protected
    //debugPrint(_rrrr); //error - ok the twin TestPrivateProtectedChild defined in condition_managging.dart wouldn't throw error which is ok.
    //debugPrint(_wwww); //error - ok //error - ok the twin TestPrivateProtectedChild defined in condition_managging.dart wouldn't throw error which is ok.
  }
}

/// i didn't intended the main function to be async - now it is to load example data in debug mode when i am still learning dart's stuff
void main(List<String> args) async {
  var abc = TestPrivateProtectedChild();
  //error - ok debugPrint('set print1: ${abc._rrrr}');
  debugPrint('set print2: ${abc.rrrrrrrr}');
  //below error - ok but only after i changed the analysis_options.yaml
  //analyzer:
  //  errors:
  //    invalid_use_of_protected_member: error
  //debugPrint('set print3: ${abc.rrrr}');

  //throw Exception('tests');

  var tryqwq = qqaazz(rrttyy());
  tryqwq.printrrttyy();
  var tryqwq2 = qqaazz(rrttyy2());
  tryqwq2.printrrttyy();
  debugPrint(
      'So happily an rrttyy2 object assigned to rrttyy type printed the rrttyy2 version of the method.');

  ///  debugPrint('testing custom map:');
  ///  var serializetest = TestSerializeOrJson({
  ///    'ac': 'asdf',
  ///    'wer': 20,
  ///    'nullexamplekey': null,
  ///    'wrtyyu': testwerwerwerwerwerwewerwer()
  ///  });
  /// debugPrint('serializetest:' + serializetest.toString());
  /// debugPrint('serializetest jsonEncode:' + jsonEncode(serializetest));
  ///
  /// ///debugPrint('nosuchmethod:');
  ///dynamic ewqer = abcdefghijk();
  ///debugPrint('ewqer.runtimeType' + ewqer.runtimeType.toString());
  ///ewqer.id = 10;
  ///wereeee(ewqer);
  //debugPrint();
  ///Types<int, String> typestest1 = TypesV<int, String>(10);
  ///debugPrint('Types<int, String>1:' + typestest1.runtimeType.toString());
  ///debugPrint('Types<int, String>2:' + (typestest1 is Types).toString());
  ///debugPrint(
  ///    'Types<int, String>3:' + (typestest1 is Types<int, String>).toString());
  ///debugPrint(
  ///    'Types<int, String>4:' + (typestest1 is Types<int, Object>).toString());
  ///debugPrint(
  ///    'Types<int, String>5:' + (typestest1 is Types<int, Future>).toString());
  ///debugPrint(
  ///    'Types<int, String>6:' + (typestest1 is TypesW<int, Future>).toString());
  ///debugPrint('Types<int, String>7:' + (typestest1 is TypesV).toString());
  ///debugPrint('checkitout1');
  ///
  // it is ok ewerywhere (import foundation package)
  ///debugPrint(ConditionConfiguration.isWeb.toString());
  ///  debugPrint('checkitout2');

  ///debugPrint(jsonEncode(
  ///    jsonDecode(ConditionDebugDataForDevelopmentAndTesting.widget_tree_ids)));

  ///debugPrint('checkitout3');
  ///debugPrint('checkitout4');
  ///  debugPrint('checkitout5');
  ///debugPrint('checkitout6');
  //////debugPrint('checkitout7');
  /////  debugPrint(jsonEncode(    jsonDecode(ConditionDebugDataForDevelopmentAndTesting.widgets_configs))///);

  ///debugPrint('checkitout8');
  ///debugPrint(args.toString());
  ConditionConfiguration.debugMode = args.contains('debugging') ? true : false;
  ConditionConfiguration.isClientApp = true;
  //inspect(args);
  //debugPrint(jsonEncode(new ABCD()));

  ///int test3 = 50;
  ///Map rwer = {'id': test3, 'e_mail': 'takiemail'};
  ///
  ///debugPrint('rwer check - id after toString() is 50');
  ///debugPrint(rwer['id'].toString());

  //Hive.init('./'); //-> not needed in browser

  //var box = await Hive.openBox('cNd1');

  //var box = Hive.box("cNd1");

  //await box.put('cNd1_widget_tree_ids', ConditionDebugDataForDevelopmentAndTesting.widget_tree_ids);
  //await box.put('cNd1_widgets_configs',  jsonEncode(ConditionDebugDataForDevelopmentAndTesting.widgets_configs));

  ///debugPrint('P----------------------------------------------');

  //debugPrint(box.get('cNd1_widget_tree_ids'));
  //debugPrint(box.get('cNd1_widgets_configs'));
  ///
  ///// [Edit:] Some old desc stuff here - relevant? !!!!!!!!!!!!!!!!!!!!! this replaces the line var abcd = ConditionModelUser(rwer); because each app can have couple of users and full additional configuration. ConditionModelApp should alsho have all layout widget attached to it.
  ///// At the beginning one app is to be but thinking into the future: if more apps, each app has to have a unique namespce prefix like here "cNd1", next app f.e. "cNd2", There can be separated couple of apps managed in some way one day
  var conditionModelApp1 = ConditionModelApp();

  ///
  conditionModelApp1.init(ConditionApp(conditionModelApp1));

  ///
  ///// debugging because:
  ///// user models should be created inside ConditionModelApp class only - they will provide whaats necessary
  ///
  ///
  /////var abcd = ConditionModelUser(conditionModelApp1, null, rwer);
  ///
  ///debugPrint(
  ///    'abcd check - id id after toString()is NOT 50 and it should be - IT IS FULL abcd variable not abcd[\'id\']');
  ///debugPrint(abcd['id'].toString());
  ///
  /////great! this would throw exception - abcd was already set but final but this detects special validator object
  /////abcd['id'] = 60;
  ///debugPrint(abcd['id'].toString());
  ///
  ///debugPrint('testing model');
  ///debugPrint(abcd.id.toString());
  ///debugPrint('testing model 2');
  ///try {
  ///  abcd['soup'] = 'tomato';
  ///} catch (e) {
  ///  debugPrint(e.toString());
  ///}
  /////try {
  /////great! this would throw exception - abcd was already set but final but this detects special validator object
  /////abcd.id = 52;
  /////} catch (e) {}
  ///debugPrint(jsonEncode(abcd));
  ///debugPrint(jsonEncode(abcd.id));
  ///debugPrint('testing model 22223333');
  ///debugPrint(jsonEncode(abcd['id']));
  ///debugPrint('testing model 2222');
  ///debugPrint(
  ///    'SHOULD RETURN VALUE 52 of id key, BUT toSTring returnd IT RETURNS ALL VARIABLE abcd. However jsonEncode returns what expected for abcd or abcd[\'id\']');
  ///
  ///debugPrint(abcd['id'].toString());
  ///debugPrint(abcd.id.toString());
  /////debugPrint(abcd.email.toString());
  ///debugPrint('testing model 3');

  runApp(conditionModelApp1.widget as ConditionApp);
}
