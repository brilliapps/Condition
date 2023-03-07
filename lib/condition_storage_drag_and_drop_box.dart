import 'dart:ui';
import 'dart:async';
import 'dart:developer'; // for inspect(myVar); like print_r var_dump in php
import 'package:flutter/material.dart';
import 'package:drop_cap_text/drop_cap_text.dart';
import 'condition_custom_annotations.dart';
import 'condition_data_managging.dart';
//import 'package:hive/hive.dart';
import 'condition_configuration.dart';
import 'condition_app_base.dart'; //empty informational and later etended class used by server and frontend/native/web

/// The architecture starts with this widget, each relevant widget of the architecture has its model and basically represends part of a layout
@ToDo(
    'See ConditionModel addListener(ConditionModelListenerFunction changes_listener',
    '')
class ConditionWidget extends StatefulWidget implements ConditionWidgetBase {
  ConditionModel _model;

  ConditionWidget(ConditionModel this._model, {Key? key}) : super(key: key);
  @override
  State createState() => _ConditionWidgetState();

  ConditionModel get model {
    return _model;
  }
}

class _ConditionWidgetState extends State<ConditionWidget> {
  bool _isFavorited = true;
  int _favoriteCount = 41;

  @override
  Widget build(BuildContext context) {
    return Text('data');
  }
}

class ConditionUser extends ConditionWidget {
  ConditionUser(ConditionModelUser model, {Key? key}) : super(model, key: key);

  @override
  _ConditionUserState createState() => _ConditionUserState();
}

class _ConditionUserState extends State<ConditionUser> {
  bool _isFavorited = true;
  int _favoriteCount = 41;

  @override
  Widget build(BuildContext context) {
    return Text('data');
  }
}

/// As in [ConditionModelEachWidgetModel] this widget is fully functional widget and base for all other widgets (except for) adding additional features.
class ConditionEachWidget extends ConditionDragTargetContainerWidget {
  ConditionEachWidget(ConditionModelEachWidgetModel model, {Key? key})
      : super(model, key: key);
}

/// Core functionality, a contact widget/entry or a group (a single contact is also an empty group), with nesting, anything else, like the tasks, messages, reading rooms belongs to a contact or a group - a message or task can be linked. A special contact - public gives you things visible on a your personal webpage, f.e. social-like. Groups and contacts can additionally be moved as links to other contact groups
class ConditionContact extends ConditionEachWidget {
  ConditionContact(ConditionModelContact model, {Key? key})
      : super(model, key: key);
}

/// Messages later can be of different sorts especially a message marked social is seen on a social page, can be public or belong to a group. A message can be automatically updated (like tickers, oil, gas prices, etc.)
///
/// A message social or not can also be of short announcement type, maybe related to sms format, emergency type with you localisation.
class ConditionMessage extends ConditionEachWidget {
  ConditionMessage(ConditionModelMessage model, {Key? key})
      : super(model, key: key);
}

/// Messages later can be of different sorts especially a message marked social is seen on a social page, can be public or belong to a group. A message can be automatically updated (like tickers, oil, gas prices, etc.)
class ConditionVideoConference extends ConditionEachWidget {
  ConditionVideoConference(ConditionModelVideoConference model, {Key? key})
      : super(model, key: key);
}

/// A widget is a task, a subwidget subtask percentage is counted. First widgets in a tree are groups like "to do", "archve"
class ConditionTask extends ConditionEachWidget {
  ConditionTask(ConditionModelTask model, {Key? key}) : super(model, key: key);
}

/// With group activity, With handlings maps and registering routes - subwidgets could be used in many ways for groups while main widget could collect data for everyone f.e. a trip may start but later some people in the group may join or start interesting part of the plan of the trip. Many ideas here welcomed.
class ConditionTripAndFitness extends ConditionEachWidget {
  ConditionTripAndFitness(ConditionModelTask model, {Key? key})
      : super(model, key: key);
}

/// Safe (!!!) way for api with outside url (widget contacts one or periodically like in tickers) - also f.e. filling in outside url forms (you have live updated json data status for this for this special id from the outside server) - you get ticker like status for url or form with one time return or ticker like with desired update time from the server. You need to agree to the conditionS of the server (RODO). At the beginning it is to be simple - just url got from somewhere according to accepted api by this Condition app. Such urls can be cofigured in outside partners website forms, etc, copied and just pasted to the widget. Condition must have protection against using too much resources or too often refresshing the widget and contacting the outside servers.
class ConditionURLTicker extends ConditionEachWidget {
  ConditionURLTicker(ConditionModelURLTicker model, {Key? key})
      : super(model, key: key);
}

/// Storing books and books/publications reader in the formats like epub or rtf
class ConditionReadingRoom extends ConditionEachWidget {
  ConditionReadingRoom(ConditionModelReadingRoom model, {Key? key})
      : super(model, key: key);
}

/// Simply webpages with inheriting rules. A widget embraces scaffolding, its construction and page contents.
class ConditionWebPage extends ConditionEachWidget {
  ConditionWebPage(ConditionModelWebPage model, {Key? key})
      : super(model, key: key);
}

/// Products and categories
class ConditionShop extends ConditionEachWidget {
  ConditionShop(ConditionModelShop model, {Key? key}) : super(model, key: key);
}

/// A widget on top of a tree is a project, the next is jus a file - code or resource. Code has it's editor.
class ConditionProgramming extends ConditionEachWidget {
  ConditionProgramming(ConditionModelProgramming model, {Key? key})
      : super(model, key: key);
}

/// Something like recorded podcasts and live radio streaming with broadcasted lists of podcasts and breaking in with live broadcasting
class ConditionPodcasting extends ConditionEachWidget {
  ConditionPodcasting(ConditionModelPodcasting model, {Key? key})
      : super(model, key: key);
}

/// Main Universal Widget to be inherited from. Each widget can be linked and/or copied anywhere to any even incompatible place - a main rule
@ToDo(
    'See ConditionModel addListener(ConditionModelListenerFunction changes_listener',
    '')
class ConditionDragTargetContainerWidget extends ConditionWidget {
  final GlobalKey DragTargetChildKey = GlobalKey(); // This is not

  //int widget_id; this is to be get from this.model
  //int condition_widget_type; this is to be get from this.model

  ConditionDragTargetContainerWidget(ConditionModelEachWidgetModel model,
      {Key? key})
      : super(model, key: key) {}

  @override
  _ConditionDragTargetContainerWidgetState createState() =>
      _ConditionDragTargetContainerWidgetState();
}

class _ConditionDragTargetContainerWidgetState
    extends State<ConditionDragTargetContainerWidget> {
  bool _isFavorited = true;
  int _favoriteCount = 41;

  @override
  Widget build(BuildContext context) {
    debugPrint('Are we in debug mode?');
    debugPrint(ConditionConfiguration.debugMode.toString());
    debugPrint('2 Are we in debug mode?');

    return DragTarget/*<T>*/(
        key: widget
            .DragTargetChildKey /*GlobalKey()*/, // for getting x and y and size of the widget
        builder: (context, candidateItems, rejectedItems) {
          return LongPressDraggable(
              data: ['nothing', candidateItems, rejectedItems],
              child: Text('___draggabledraggable___'),
              dragAnchorStrategy: pointerDragAnchorStrategy,
              feedback: const Icon(Icons.person_sharp)
              //childWhenDraggingThe widget to display instead of child when one or more drags are under way. [...]
              );
        },
        onAccept: (item) {
          debugPrint('onAccept: ' + item.toString());
        },
        onAcceptWithDetails: (item) {
          debugPrint('onAcceptWithDetails data: ' + item.data.toString());
          debugPrint('onAcceptWithDetails offset: ' + item.offset.toString());
          inspect(item);
        },
        onMove: (item) {
          debugPrint('#########');
          debugPrint('onMove: ' + item.toString());
          debugPrint('onMove data: ' + item.data.toString());
          debugPrint('onMove offset: ' + item.offset.toString());
          debugPrint('------------------------------------');

          debugPrint(
              'MUSISZ ZDEFINIOWAĆ KLASĘ ROZSZERZAJĄCĄ DragTarget wewnątrz niej te funkcje jak onMove i nie nadpisuj ich i wewnątrz jej odwołać się do this i będziesz miał offset tego thisa, teraz jest testowo widget (this to state, a this.widget to widget, który trzyma objekt klasy state), który stoi wysoko w hierarchii widgetów i jest on zastępczo, by nie było errorów');

          debugPrint('onMove this to string:' + this.toString());
          debugPrint('onMove this.widget to string:' + widget.toString());
          debugPrint(
              'onMove (this[_ConditionDragTargetContainerWidgetState].)context.size to string:' +
                  context.size.toString());
          //DragTarget widget key to get width and height
          debugPrint(widget.DragTargetChildKey.toString());
          debugPrint(widget.DragTargetChildKey.currentContext.toString());

          debugPrint('onMove context.size.width to string:' +
              (context.size?.width).toString());
          debugPrint('onMove context.size.height to string:' +
              (context.size?.height).toString());
          debugPrint(
              'onMove widget.DragTargetChildKey.currentState to string:' +
                  (widget.DragTargetChildKey.currentState).toString());
          debugPrint('onMove this to string:' + this.toString());
          debugPrint(
              'onMove this.context to string:' + this.context.toString());

          var widgetCursorIsOnWidget = widget.DragTargetChildKey
              .currentContext; // it is to be DragTarget widget which got it's GlobalKey key object from its parent widget ConditionDragTargetContainerWidget
          if (widgetCursorIsOnWidget != null) {
            // widget may not has been rendered yet or something; to avoid error: "Error: Method 'findRenderObject' cannot be called on 'BuildContext?' because it is potentially null."
            RenderBox box =
                widgetCursorIsOnWidget.findRenderObject() as RenderBox;
            Offset position =
                box.localToGlobal(Offset.zero); //this is global position
            double x = position.dx; //this is y - I think it's what you want
            double y = position.dy; //this is y - I think it's what you want

            debugPrint(
                'onMove: widget.DragTargetChildKey.currentState.size.width:' +
                    (widgetCursorIsOnWidget.size?.width).toString());
            debugPrint(
                'onMove: widget.DragTargetChildKey.currentState.size.height:' +
                    (widgetCursorIsOnWidget.size?.height).toString());

            debugPrint('onMove: position x:' + x.toString());
            debugPrint('onMove: position y:' + y.toString());
          }

          // if the cursor/touch pointer  is on the upper half of the DragTarget Widget then simulate a dropping box widget above the DragTarget widget so you would need to rebuild the DragTarget widget using set State of the context.findAncestorWidgetOfExactType<ConditionDragTargetContainerWidget>()  and the half height of the DragTarget is increased with the height of the widget on the top. The lower half is calculated accordingly.
          // !!!! size objexct center bottomCenter centerRight etc.
          // you then need the state (CONTEXTUALLY YOU ARE IN IT HERE!!! "this" object IS FOR THIS STATE) of DragTarget parent widget ConditionDragTargetContainerWidget and set state or alternatively you could use InheritedWidget and notify it somehow with a value to inform how to rebuild (value listener or changenotifier or something) rebuild - i don't remember now how to use it.
          //Probably one of theese and further stuff:

          //poniższe błąd chyba bo ten State jest tworzony właśnie i ...key.currentState jest niedostępny jeszcze, ale widget.DragTargetChildKey.currentContext i state jest inaczej dostępny
          // zaraz BARANIE, this jest state?????
          //var abcde= widget.key.currentState; // null safety ?. doesn't work it says about getter. Assume this State is being created - i guess compiler doesn't understand that it is not a problem - this value will be accessed later

          //debugPrint('onMove: state object of ConditionDragTargetContainerWidget:'+abcde.toString());
        },
        onWillAccept: (item) {
          debugPrint('onWillAccept: ');
          debugPrint('onWillAccept: ' + item.toString());
          //debugPrint('onAcceptWithMove data: '+item.data.toString());
          //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
          return true;
        });
  }
}

// APP WIDGET

class ConditionAppRouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('dwa kompy');
    print('ala ma kompa 5');
    return MaterialPageRoute(
        builder: (context) => MyHomePage(
            key: GlobalKey(), //widget testowo bierze x,y,width,height widgeta,
            title:
                'Condition') // You can also use MaterialApp's `home` property instead of '/'
        );
  }
}

/// Main app widget, it handles layout, server gets different widget also implementing [ConditionAppBase] empty informational interface. See more the classess description
/// Read the classess (it's state class) about importing some touch gestures for desktop mouse as param in Material App
class ConditionApp extends ConditionWidget implements ConditionAppBase {
  ConditionModel _model;
  ThemeMode? _themeMode;

  ConditionApp(
    ConditionModelApp this._model, {
    Key? key,
    //https://stackoverflow.com/questions/56304215/how-to-check-if-dark-mode-is-enabled-on-ios-android-using-flutter
    ThemeMode? themeMode = ThemeMode.system,
  })  : _themeMode = themeMode,
        super(_model, key: key) {
    debugPrint('And the mode is' + _themeMode.toString());
  }

  ConditionModel get model {
    return _model;
  }

  set themeMode(ThemeMode? value) => _themeMode = value;
  ThemeMode? get themeMode => _themeMode;

  @override
  State createState() => _ConditionAppState();
}

class _ConditionAppState extends State<ConditionApp> {
  final lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xF7105B75),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE1E0FF),
    onPrimaryContainer: Color(0xFF04006D),
    secondary: Color(0xFF208A83),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF6CF8EB),
    onSecondaryContainer: Color(0xFF00201D),
    tertiary: Color(0xFF79536A),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD8ED),
    onTertiaryContainer: Color(0xFF2E1125),
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    onError: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF410002),
    background: Color(0xFFFFFBFF),
    onBackground: Color(0xFF1C1B1F),
    surface: Color(0xFFFFFBFF),
    onSurface: Color(0xFF1C1B1F),
    surfaceVariant: Color(0xFFE4E1EC),
    onSurfaceVariant: Color(0xFF46464F),
    outline: Color(0xFF777680),
    onInverseSurface: Color(0xFFF3EFF4),
    inverseSurface: Color(0xFF313034),
    inversePrimary: Color(0xFFC0C1FF),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFF3F42F0),
    outlineVariant: Color(0xFFC7C5D0),
    scrim: Color(0xFF000000),
  );

  final darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFC0C1FF),
    onPrimary: Color(0xFF0C00AA),
    primaryContainer: Color(0xFF211DDA),
    onPrimaryContainer: Color(0xFFE1E0FF),
    secondary: Color(0xFF49DBCE),
    onSecondary: Color(0xFF003733),
    secondaryContainer: Color(0xFF00504A),
    onSecondaryContainer: Color(0xFF6CF8EB),
    tertiary: Color(0xFFE8B9D4),
    onTertiary: Color(0xFF46263B),
    tertiaryContainer: Color(0xFF5F3C52),
    onTertiaryContainer: Color(0xFFFFD8ED),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    onError: Color(0xFF690005),
    onErrorContainer: Color(0xFFFFDAD6),
    background: Color(0xFF1C1B1F),
    onBackground: Color(0xFFE5E1E6),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE5E1E6),
    surfaceVariant: Color(0xFF46464F),
    onSurfaceVariant: Color(0xFFC7C5D0),
    outline: Color(0xFF918F9A),
    onInverseSurface: Color(0xFF1C1B1F),
    inverseSurface: Color(0xFFE5E1E6),
    inversePrimary: Color(0xFF3F42F0),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFFC0C1FF),
    outlineVariant: Color(0xFF46464F),
    scrim: Color(0xFF000000),
  );

  set themeMode(ThemeMode? value) {
    setState(() {
      widget.themeMode = value;
    });
  }

  ThemeMode? get themeMode => widget.themeMode;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPrint('wir sind here');
    //!!! do not remove this is about importing some gestures for the mouse on windows desktop and anywhere desctop else.
    //scrollBehavior based on my answer https://github.com/flutter/flutter/issues/119386
    /*const Set<PointerDeviceKind> _kTouchLikeDeviceTypes = <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
      PointerDeviceKind.trackpad,
      // The VoiceAccess sends pointer events with unknown type when scrolling
      // scrollables.
      PointerDeviceKind.unknown,
    };*/
    debugPrint('The mode:' + themeMode.toString());
    //throw Exception('here');

    return MaterialApp(
      //colorSchemeSeed: Color.fromRGBO(188, 0, 74, 1.0)

      // !!! scrollBehavior based on my answer https://github.com/flutter/flutter/issues/119386
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(dragDevices: {...PointerDeviceKind.values}),

      title: 'Condition',
      theme: ThemeData(/*useMaterial3: true, */ colorScheme: lightColorScheme),
      darkTheme:
          ThemeData(/*useMaterial3: true, */ colorScheme: darkColorScheme),
      themeMode: themeMode,
      /*theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),*/
      /*home: MyHomePage(
          key: GlobalKey(), //widget testowo bierze x,y,width,height widgeta
          title: 'Flutter Demo Home PageFlutter Demo Home Page0'),*/
      //initialRoute: '/',
      //routes: /*<String, WidgetBuilder>*/ customRoutingMap

      //{
      //  '/qw': (BuildContext context) => MyHomePage(
      //      key: GlobalKey() /*widget testowo bierze x,y,width,height widgeta*/,
      //      title: 'Flutter Demo Home PageFlutter Demo Home Page 1'),
      //  '/signup': (BuildContext context) => MyHomePage(
      //      key: GlobalKey() /*widget testowo bierze x,y,width,height widgeta*/,
      //      title: 'Flutter Demo Home PageFlutter Demo Home Page 2'),

      routes: {
        '/qw': (BuildContext context) => MyHomePage(
            key: GlobalKey(), //widget testowo bierze x,y,width,height widgeta,
            title:
                'Condition 1'), // You can also use MaterialApp's `home` property instead of '/'
        '/foo': (BuildContext context) => MyHomePage(
            key: GlobalKey(), //widget testowo bierze x,y,width,height widgeta,
            title:
                'Condition 2'), // You can also use MaterialApp's `home` property instead of '/'
      },
      onGenerateRoute: ConditionAppRouteManager.generateRoute,
    );
  }
}

enum ConditionAppThemes { light, dark }

class MyHomePage extends StatefulWidget {
  // It is not a key for this widget, but ror menu containing tabbs to get it's width, height you need this key
  final GlobalKey menuKey = GlobalKey();

  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TabDragTarget extends Tab {
  final int index;
  final TabController tabBarTabController;
  final Widget icon;

  TabDragTarget(this.tabBarTabController, this.index, this.icon)
      : super(icon: icon);

  @override
  Widget build(BuildContext context) {
    var conditionAppState =
        context.findAncestorStateOfType<_ConditionAppState>();

    return DragTarget/*<T>*/(
      hitTestBehavior: HitTestBehavior.deferToChild,
      builder: (context, candidateItems, rejectedItems) {
        return Tab(
            iconMargin: EdgeInsets.all(0),
            icon: Container(
                padding: EdgeInsets.fromLTRB(8, 3, 11, 4),
                child: this.icon,
                decoration: BoxDecoration(
                  //boxShadow: [
                  //  BoxShadow(color: Color(0xffc4377e), blurRadius: 8)
                  //],
                  //color: Theme.of(context).colorScheme.secondary,
                  color: conditionAppState!.themeMode == ThemeMode.light
                      ? Color(0xFF006A63)
                      : Color(0xFF004A43),

                  //border: Border.all(color: Color(0xffc4377e)),
                  /*border: Border(
                                right: BorderSide(
                                    width: 2, color: Color(0xffc4377e))),*/
                  borderRadius: BorderRadius.circular(12),
                ))

            //text: 'Messages'
            );
      },
      onAccept: (item) {
        debugPrint('11onAccept: ' + item.toString());
      },
      onAcceptWithDetails: (item) {
        debugPrint('11onAcceptWithDetails: ' + item.toString());
        debugPrint('11onAcceptWithDetails data: ' + item.data.toString());
        debugPrint('11onAcceptWithDetails offset: ' + item.offset.toString());
        inspect(item);
      },
      onMove: (item) {
        //debugPrint('#########');
        //debugPrint('onMove: ' + item.toString());
        //debugPrint('onMove data: ' + item.data.toString());
        debugPrint('11tabitem onMove offset: ' + item.offset.toString());
        //dragDropMenuScrollOnReachingMenuHorizontalEnds(item.offset);
        //debugPrint('------------------------------------');

        //debugPrint(  'MUSISZ ZDEFINIOWAĆ KLASĘ ROZSZERZAJĄCĄ DragTarget wewnątrz niej te funkcje jak onMove i nie nadpisuj ich i wewnątrz jej odwołać się do this i będziesz miał offset tego thisa, teraz jest testowo widget (this to state, a this.widget to widget, który trzyma objekt klasy state), który stoi wysoko w hierarchii widgetów i jest on zastępczo, by nie było errorów');

        //debugPrint('onMove this to string:' + this.toString());
        //debugPrint('onMove this to string:' + this.widget.toString());
        //debugPrint(this.widget.key.currentContext.toString());

        /*
                   RenderBox box = this.widget.key.currentContext.findRenderObject() as RenderBox;
                   Offset position = box.localToGlobal(Offset.zero); //this is global position
                   double y = position.dy; //this is y - I think it's what you want                   
                   debugPrint('onMove: position y:'+y.toString());
                   */
      },
      onWillAccept: (item) {
        tabBarTabController.animateTo(index);
        debugPrint('11onWillAccept: ');
        debugPrint('11onWillAccept: ' + item.toString());
        //debugPrint('onAcceptWithMove data: '+item.data.toString());
        //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
        return true;
      },
      onLeave: (item) {
        debugPrint('11onLeave: ');
        debugPrint('11onLeave: ' + item.toString());
        //debugPrint('onAcceptWithMove data: '+item.data.toString());
        //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
        //return true;
      },
    );
  }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;

  Widget? tabBar = null;
  Widget? tabBarClassObject = null;
  late final TabController tabBarTabController;
  bool _tabBarBeingScrolledLeft = false;
  bool _tabBarBeingScrolledRight = false;
  Timer? tabBarCurrentScrollingPerformer;

  late final boxWidth;
  late MediaQueryData mquerydata;
  RenderBox? box = null;

  set tabBarBeingScrolledLeft(bool value) {
    debugPrint('custom animation to te left');
    _tabBarBeingScrolledLeft = value;
    if (_tabBarBeingScrolledLeft == true && tabBarTabController.index > 0) {
      tabBarTabController.animateTo(tabBarTabController.index - 1);

      if (tabBarTabController.index > 0) {
        tabBarCurrentScrollingPerformer =
            Timer.periodic(Duration(milliseconds: 500), (timer) {
          if (tabBarTabController.index > 0) {
            tabBarTabController.animateTo(tabBarTabController.index - 1);
          } else
            timer.cancel();
        });
      }
      //tabBarTabController.animation!.drive(CurveTween(curve: Curves.ease));
      //tabBarTabController.offset = -1;
    } else {
      tabBarCurrentScrollingPerformer?.cancel();
      tabBarCurrentScrollingPerformer = null;
    }
    debugPrint('animation' +
        tabBarTabController.animation.toString()); //.drive(Tween(0.0, 1));
  }

  bool get tabBarBeingScrolledLeft => _tabBarBeingScrolledLeft;

  set tabBarBeingScrolledRight(bool value) {
    debugPrint('custom animation to te right');
    _tabBarBeingScrolledRight = value;
    if (_tabBarBeingScrolledRight == true &&
        tabBarTabController.index <= tabBarTabController.length) {
      tabBarTabController.animateTo(tabBarTabController.index + 1);
      if (tabBarTabController.index <= tabBarTabController.length) {
        tabBarCurrentScrollingPerformer =
            Timer.periodic(Duration(milliseconds: 500), (timer) {
          if (tabBarTabController.index <= tabBarTabController.length) {
            tabBarTabController.animateTo(tabBarTabController.index + 1);
          } else
            timer.cancel();
        });
      }
      //tabBarTabController.animation!.drive(CurveTween(curve: Curves.ease));
      //tabBarTabController.offset = -1;
    } else {
      tabBarCurrentScrollingPerformer?.cancel();
      tabBarCurrentScrollingPerformer = null;
    }
    debugPrint('animation' +
        tabBarTabController.animation.toString()); //.drive(Tween(0.0, 1));
  }

  bool get tabBarBeingScrolledRight => _tabBarBeingScrolledRight;

  /*dragDropMenuScrollOnReachingMenuHorizontalEnds(Offset offset) {
    debugPrint('merged position ${offset.toString()}');
    // Now prepare and pass the tabBar property a controller thanks to which you can scroll. It uses scroll to tab or something  not animateTo like in scrolling views
    // so at the end do slower smoother animations on scrolling
    // use boxWidth, and offset, offset.dx scroll when cursor is almost to the right of tabBar or to the left
    // scroll + one tab
    // prevent scrolling when a previous scrolling is being performed
    //in one onMove event there may be a not necessary code
    //here we stopped
  }*/

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  initState() {
    super.initState();
    tabBarTabController = TabController(
      initialIndex: 0,
      length: 9,
      vsync: this,
    );
  }

  /// initially initState was used the function below is called after initState, but when you change theme this method is called
  @override
  didChangeDependencies() {
    tabBarClassObject = AnimatedPadding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        child: TabBar(
            labelPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            controller: tabBarTabController,
            key: widget.menuKey,
            isScrollable: true,
            tabs: [
              TabDragTarget(
                  tabBarTabController,
                  0,
                  Row(children: [
                    const Icon(Icons.directions_car),
                    Text(' Messages')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  1,
                  Row(children: [
                    const Icon(Icons.directions_bike),
                    Text(' Trip & Fitness')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  2,
                  Row(children: [
                    const Icon(Icons.directions_bike),
                    Text(' Tasks')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  3,
                  Row(children: [
                    const Icon(Icons.directions_car),
                    Text(' Messages')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  4,
                  Row(children: [
                    const Icon(Icons.directions_bike),
                    Text(' Trip & Fitness')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  5,
                  Row(children: [
                    const Icon(Icons.directions_bike),
                    Text(' Tasks')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  6,
                  Row(children: [
                    const Icon(Icons.directions_car),
                    Text(' Messages')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  7,
                  Row(children: [
                    const Icon(Icons.directions_bike),
                    Text(' Trip & Fitness')
                  ])),
              TabDragTarget(
                  tabBarTabController,
                  8,
                  Row(children: [
                    const Icon(Icons.directions_bike),
                    Text(' Tasks')
                  ])),
            ]));

    tabBar = Stack(
      children: <Widget>[
        Container(
            width: double.infinity,
            //height: 100,
            color: Colors
                .transparent, //Theme.of(context).colorScheme.secondary, //Colors.red,
            child: DragTarget/*<T>*/(
              hitTestBehavior: HitTestBehavior.deferToChild,
              builder: (context, candidateItems, rejectedItems) {
                return tabBarClassObject!;
              },
              onWillAccept: (item) {
                debugPrint('55onWillAccept: ');
                debugPrint('55onWillAccept: ' + item.toString());
                //debugPrint('onAcceptWithMove data: '+item.data.toString());
                //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
                return true;
              },
              onMove: (item) {
                debugPrint('55 onMove offset: ' + item.offset.toString());
                //debugPrint(this.widget.key.currentContext.toString());
                //dragDropMenuScrollOnReachingMenuHorizontalEnds(item.offset);

                if (null == box) {
                  box = widget.menuKey.currentContext!.findRenderObject()
                      as RenderBox;
                } else {}

                Offset position =
                    box!.localToGlobal(Offset.zero); //this is global position
                double x = position.dx; //this is y - I think it's what you want
                debugPrint('55onMove: position x:' + x.toString());
                Size size = box!.size;
                debugPrint('55onMove: box width for scrolling:' +
                    size.width.toString());
              },
              onLeave: (item) {
                debugPrint('55onLeave: ');
                debugPrint('55onLeave: ' + item.toString());
                //debugPrint('onAcceptWithMove data: '+item.data.toString());
                //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
                //return true;
              },
            )),

        // Events for desktop and mouse to scroll the tabs in tabBar when there is no drag&drop dragging being performed right now.

        DragTarget/*<T>*/(
          hitTestBehavior: HitTestBehavior.deferToChild,
          builder: (context, candidateItems, rejectedItems) {
            return Listener(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      width: 25,
                      height: 48,
                      //color: Colors.green,
                      child: const Icon(
                          color: Color(0xFF006A63), Icons.arrow_back))),
              onPointerDown: (event) {
                debugPrint('88desktop mouse onPointerDown' + event.toString());
                tabBarBeingScrolledLeft = true;
              },
              onPointerUp: (event) {
                tabBarBeingScrolledLeft = false;
                debugPrint('88desktop mouse onPointerDown' + event.toString());
              },
            );
          },
          onAccept: (item) {
            tabBarBeingScrolledLeft = false;
            debugPrint('88onAccept: ' + item.toString());
          },
          onAcceptWithDetails: (item) {
            debugPrint('88onAcceptWithDetails: ' + item.toString());
            debugPrint('88onAcceptWithDetails data: ' + item.data.toString());
            debugPrint(
                '88onAcceptWithDetails offset: ' + item.offset.toString());
            inspect(item);
          },
          onMove: (item) {
            //debugPrint('#########');
            //debugPrint('onMove: ' + item.toString());
            //debugPrint('onMove data: ' + item.data.toString());
            debugPrint('88tabitem onMove offset: ' + item.offset.toString());
            //dragDropMenuScrollOnReachingMenuHorizontalEnds(item.offset);
            //debugPrint('------------------------------------');

            //debugPrint(  'MUSISZ ZDEFINIOWAĆ KLASĘ ROZSZERZAJĄCĄ DragTarget wewnątrz niej te funkcje jak onMove i nie nadpisuj ich i wewnątrz jej odwołać się do this i będziesz miał offset tego thisa, teraz jest testowo widget (this to state, a this.widget to widget, który trzyma objekt klasy state), który stoi wysoko w hierarchii widgetów i jest on zastępczo, by nie było errorów');

            //debugPrint('onMove this to string:' + this.toString());
            //debugPrint('onMove this to string:' + this.widget.toString());
            //debugPrint(this.widget.key.currentContext.toString());

            /*
                   RenderBox box = this.widget.key.currentContext.findRenderObject() as RenderBox;
                   Offset position = box.localToGlobal(Offset.zero); //this is global position
                   double y = position.dy; //this is y - I think it's what you want                   
                   debugPrint('onMove: position y:'+y.toString());
                   */
          },
          onWillAccept: (item) {
            tabBarBeingScrolledLeft = true;
            debugPrint('88onWillAccept: ');
            debugPrint('88onWillAccept: ' + item.toString());
            //debugPrint('onAcceptWithMove data: '+item.data.toString());
            //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
            return true;
          },
          onLeave: (item) {
            tabBarBeingScrolledLeft = false;
            debugPrint('88onLeave: ');
            debugPrint('88onLeave: ' + item.toString());
            //debugPrint('onAcceptWithMove data: '+item.data.toString());
            //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
            //return true;
          },
        ),

        DragTarget/*<T>*/(
          hitTestBehavior: HitTestBehavior.deferToChild,
          builder: (context, candidateItems, rejectedItems) {
            return Listener(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.centerRight,
                      width: 25,
                      height: 48,
                      //color: Colors.blue,
                      child: const Icon(
                          color: Color(0xFF006A63), Icons.arrow_forward))),
              onPointerDown: (event) {
                debugPrint('99desktop mouse onPointerDown' + event.toString());
                tabBarBeingScrolledRight = true;
              },
              onPointerUp: (event) {
                tabBarBeingScrolledRight = false;
                debugPrint('99desktop mouse onPointerDown' + event.toString());
              },
            );
          },
          onAccept: (item) {
            tabBarBeingScrolledRight = false;
            debugPrint('99onAccept: ' + item.toString());
          },
          onAcceptWithDetails: (item) {
            debugPrint('99onAcceptWithDetails: ' + item.toString());
            debugPrint('99onAcceptWithDetails data: ' + item.data.toString());
            debugPrint(
                '99onAcceptWithDetails offset: ' + item.offset.toString());
            inspect(item);
          },
          onMove: (item) {
            //debugPrint('#########');
            //debugPrint('onMove: ' + item.toString());
            //debugPrint('onMove data: ' + item.data.toString());
            debugPrint('99tabitem onMove offset: ' + item.offset.toString());
            //dragDropMenuScrollOnReachingMenuHorizontalEnds(item.offset);
            //debugPrint('------------------------------------');

            //debugPrint(  'MUSISZ ZDEFINIOWAĆ KLASĘ ROZSZERZAJĄCĄ DragTarget wewnątrz niej te funkcje jak onMove i nie nadpisuj ich i wewnątrz jej odwołać się do this i będziesz miał offset tego thisa, teraz jest testowo widget (this to state, a this.widget to widget, który trzyma objekt klasy state), który stoi wysoko w hierarchii widgetów i jest on zastępczo, by nie było errorów');

            //debugPrint('onMove this to string:' + this.toString());
            //debugPrint('onMove this to string:' + this.widget.toString());
            //debugPrint(this.widget.key.currentContext.toString());

            /*
                   RenderBox box = this.widget.key.currentContext.findRenderObject() as RenderBox;
                   Offset position = box.localToGlobal(Offset.zero); //this is global position
                   double y = position.dy; //this is y - I think it's what you want                   
                   debugPrint('onMove: position y:'+y.toString());
                   */
          },
          onWillAccept: (item) {
            tabBarBeingScrolledRight = true;
            debugPrint('99onWillAccept: ');
            debugPrint('99onWillAccept: ' + item.toString());
            //debugPrint('onAcceptWithMove data: '+item.data.toString());
            //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
            return true;
          },
          onLeave: (item) {
            tabBarBeingScrolledRight = false;
            debugPrint('99onLeave: ');
            debugPrint('99onLeave: ' + item.toString());
            //debugPrint('onAcceptWithMove data: '+item.data.toString());
            //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
            //return true;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    mquerydata = MediaQuery.of(context);
    double width = mquerydata.size.width;
    var conditionAppState =
        context.findAncestorStateOfType<_ConditionAppState>();

    Text title = Text(widget.title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: conditionAppState!.themeMode == ThemeMode.light
                ? Theme.of(context).colorScheme.secondary
                : Color(0xFF008A83), //Colors.black,
            fontSize: 22));

    Widget tabBarContainer = Container(
        padding: EdgeInsets.fromLTRB(
            width < 950 ? 26 : 0, 0, width < 950 ? 20 : 0, 0),
        //color: Theme.of(context).colorScheme.secondary,
        child: tabBar);

    Widget drawercontent = Container(
        color: Colors.transparent,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            Container(
                constraints: BoxConstraints(maxHeight: 15),
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xffc4377e),
                  ),
                  child: Text('abc'),
                )),
            ListTile(
              title: const Text('Contact Titleone',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      //color: Colors.black,
                      fontSize: 14)),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
                title: const Text('Buddy Titletwo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        //color: Colors.black,
                        fontSize: 14)),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                }),
            ListTile(
              title: const Text('Frank Sinatra New york, New York',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      //color: Colors.black,
                      fontSize: 14)),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ));

    bool appraisnot = true;
    var commonpadding = EdgeInsets.fromLTRB(
        width < 950 ? 32 : 28, 20, width < 950 ? 32 : 28, 20);

    //var conditionAppState = context.findAncestorStateOfType<_ConditionAppState>();

    return DefaultTabController(
        length: 9,
        child: Scaffold(
          backgroundColor: conditionAppState.themeMode == ThemeMode.light
              ? Colors.white
              : Colors.black,

          appBar: appraisnot
              ? null
              : AppBar(
                  // Here we take the value from the MyHomePage object that was created by
                  // the App.build method, and use it to set our appbar title.
                  title: title,
                  /*leading: IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'contacts',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This is a snackbar')));
                  }),*/
                  actions: <Widget>[
                      //tabBar,
                      IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: 'Show Snackbar',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('This is a snackbar')));
                        },
                      ),
                    ]),

          drawer: width < 950
              ? Drawer(
                  //backgroundColor: Colors.transparent,
                  //shadowColor: Colors.transparent,
                  //surfaceTintColor: Colors.transparent,
                  // Add a ListView to the drawer. This ensures the user can scroll
                  // through the options in the drawer if there isn't enough vertical
                  // space to fit everything.
                  child: drawercontent)
              : null,

          body: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return Row(children: [
              Column(children: [
                if (width >= 950)
                  LimitedBox(
                      maxWidth: 380, // - (width - 150),
                      maxHeight: viewportConstraints.maxHeight,
                      //constraints: BoxConstraints(maxWidth: 280, minHeight: double.infinity),
                      child: Container(
                          decoration: BoxDecoration(
                            //boxShadow: [
                            //  BoxShadow(color: Color(0xffc4377e), blurRadius: 8)
                            //],
                            //color: const Color(0xff7c94b6),
                            border: Border(
                                right: BorderSide(
                                    width: 12, color: Color(0xffc4377e))),
                            //borderRadius: BorderRadius.circular(12),
                          ),
//              color: Colors.green,
                          child: drawercontent)

                      //Container(color: Colors.green, child: drawercontent),
                      )
              ]),
              Expanded(
                  child: Column(children: [
                Row(children: [
                  SizedBox(
                      width: width < 950
                          ? viewportConstraints.maxWidth
                          : viewportConstraints.maxWidth - 380,
                      child: Container(
                        padding:
                            EdgeInsets.fromLTRB(width < 950 ? 11 : 0, 0, 0, 0),
                        child: AppBar(
                            backgroundColor: Colors.transparent,
                            bottomOpacity: 0.0,
                            elevation: 0, // removing box shadows
                            iconTheme:
                                const IconThemeData(color: Color(0xFF006A63)),
                            /*leading: Container(
                          child: const Icon(
                              color: Color(0xFF006A63), Icons.settings),
                        ),*/
                            // Here we take the value from the MyHomePage object that was created by
                            // the App.build method, and use it to set our appbar title.
                            title: Container(
                                transform: Matrix4.translationValues(
                                    width < 950 ? -10.0 : 0, -2.0, 0.0),
                                padding: EdgeInsets.fromLTRB(
                                    width < 950 ? 0 : 11, 0, 0, 0),
                                child: title),
                            /*leading: IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'contacts',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This is a snackbar')));
                  }),*/
                            actions: <Widget>[
                              //tabBar,
                              IconButton(
                                //color: Colors.black54,
                                color: conditionAppState.themeMode ==
                                        ThemeMode.light
                                    ? Colors.black54
                                    : Colors.white,
                                icon: const Icon(Icons.brightness_4_outlined),
                                tooltip: 'Show Snackbar',
                                onPressed: () {
                                  if (conditionAppState.themeMode == null ||
                                      conditionAppState.themeMode ==
                                          ThemeMode.light) {
                                    conditionAppState.themeMode =
                                        ThemeMode.dark;
                                  } else {
                                    conditionAppState.themeMode =
                                        ThemeMode.light;
                                  }
                                },
                              ),
                              IconButton(
                                //color: Colors.black54,
                                color: conditionAppState.themeMode ==
                                        ThemeMode.light
                                    ? Colors.black54
                                    : Colors.white,
                                icon: const Icon(Icons.person_sharp),
                                tooltip: 'Show Snackbar',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('This is a snackbar')));
                                },
                              ),
                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                                  child: IconButton(
                                    color: conditionAppState.themeMode ==
                                            ThemeMode.light
                                        ? Colors.black54
                                        : Colors.white,
                                    icon: const Icon(Icons.settings),
                                    tooltip: 'Show Snackbar',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('This is a snackbar')));
                                    },
                                  )),
                            ]),
                      ))
                ]),
                Row(children: [
                  SizedBox(
                      child: tabBarContainer,
                      width: width < 950
                          ? viewportConstraints.maxWidth
                          : viewportConstraints.maxWidth - 380),
                ]),
                Expanded(
                    child: TabBarView(
                        controller:
                            tabBarTabController, //tabBarClassObject.controller,
                        children: [
                      Container(
                        padding: commonpadding,
                        //color: const Color(0xFFFFf7d0),
                        child: Row(children: [
                          Column(
                            children: <Widget>[
                              const Text(
                                'You :',
                              ),
                              const Text(
                                'have :',
                              ),
                              // THIS MUST BE RETHINKED MODELS RETURN THEIR OWN WIDGETS (A POSSIBLY SUBTREE OF WIDGETS)
                              // THIS MUST BE RETHINKED MODELS RETURN THEIR OWN WIDGETS (A POSSIBLY SUBTREE OF WIDGETS)
                              // THIS MUST BE RETHINKED MODELS RETURN THEIR OWN WIDGETS (A POSSIBLY SUBTREE OF WIDGETS)
                              //ConditionDragTargetContainerWidget(
                              //    ConditionModelEachWidgetModel(
                              //        /*!!!!! TRUE USER MODEL MUST BE PASSED IT'S DEBUG MODE NOW*/ ConditionModelUser(
                              //            {}),
                              //        {}),
                              //    key: GlobalKey()),
                              /*
                 DragTarget<T>(
                 key: GlobalKey(),   // for getting x and y and size of the widget
                 builder: (context, candidateItems, rejectedItems) {
                   return  LongPressDraggable(
                                        data: ['nothing', candidateItems, rejectedItems],
                                        child: Text('___draggabledraggable___'),
                                        dragAnchorStrategy: pointerDragAnchorStrategy,
                                        feedback: const Icon(Icons.person_sharp)
                                        //childWhenDraggingThe widget to display instead of child when one or more drags are under way. [...]                    
                               );
                 },
                 onAccept: (item) {
                   debugPrint('onAccept: '+item.toString());
                 },
                 onAcceptWithDetails: (item) {
                   debugPrint('onAcceptWithDetails: '+item.toString());
                   debugPrint('onAcceptWithDetails data: '+item.data.toString());
                   debugPrint('onAcceptWithDetails offset: '+item.offset.toString());
                   inspect(item);
                 },
                 onMove: (item) {
                     
                   debugPrint('#########');
                   debugPrint('onMove: '+item.toString());
                   debugPrint('onMove data: '+item.data.toString());
                   debugPrint('onMove offset: '+item.offset.toString());
                   debugPrint('------------------------------------');
                   
                   debugPrint('MUSISZ ZDEFINIOWAĆ KLASĘ ROZSZERZAJĄCĄ DragTarget wewnątrz niej te funkcje jak onMove i nie nadpisuj ich i wewnątrz jej odwołać się do this i będziesz miał offset tego thisa, teraz jest testowo widget (this to state, a this.widget to widget, który trzyma objekt klasy state), który stoi wysoko w hierarchii widgetów i jest on zastępczo, by nie było errorów');
                   
                   debugPrint('onMove this to string:'+this.toString());
                   debugPrint('onMove this to string:'+this.widget.toString());
                   //debugPrint(this.widget.key.currentContext.toString());
                   
                   
                   RenderBox box = this.widget.key.currentContext.findRenderObject() as RenderBox;
                   Offset position = box.localToGlobal(Offset.zero); //this is global position
                   double y = position.dy; //this is y - I think it's what you want                   
                   debugPrint('onMove: position y:'+y.toString());
                   
                   
                 },
                 onWillAccept: (item) {
                   debugPrint('onWillAccept: ');
                   debugPrint('onWillAccept: '+item.toString());
                   //debugPrint('onAcceptWithMove data: '+item.data.toString());
                   //debugPrint('onAcceptWithMove offset: '+item.offset.toString());
                   return true;
                 },
                ), 
                
                */

                              Text(
                                '$_counter',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              const Text(
                                'You :',
                              ),
                              const Text(
                                'have :',
                              ),
                              LongPressDraggable(
                                  data: "White",
                                  child: Text('___draggabledraggable___'),
                                  dragAnchorStrategy: pointerDragAnchorStrategy,
                                  feedback: const Icon(Icons.person_sharp)
                                  //childWhenDraggingThe widget to display instead of child when one or more drags are under way. [...]
                                  ),
                              Text(
                                '$_counter',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ],
                          )
                        ]),
                      ),
                      Container(
                        padding: commonpadding,
                        child: DropCapText(
                          'tabbar view 3. example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;example logo loaded from network to the left like float: left;',
                          dropCapPosition: DropCapPosition.end,
                          textAlign: TextAlign.justify,
                          dropCap: DropCap(
                              width: 100,
                              height: 100,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(8, 3, 11, 4),
                                child: Container(
                                  constraints: BoxConstraints(
                                      minWidth: 100, minHeight: 100),
                                  child: Icon(Icons.settings,
                                      size: 100,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                //child: Image.network( 'http://localhost://logo.png')
                              )),
                        ),
                      ),
                      Container(
                          padding: commonpadding, child: Text('tabbar view 3')),
                      Container(
                          padding: commonpadding, child: Text('tabbar view 4')),
                      Container(
                          padding: commonpadding, child: Text('tabbar view 5')),
                      Container(
                          padding: commonpadding, child: Text('tabbar view 6')),
                      Container(
                          padding: commonpadding, child: Text('tabbar view 7')),
                      Container(
                          padding: commonpadding, child: Text('tabbar view 8')),
                      Container(
                          padding: commonpadding, child: Text('tabbar view 9')),
                    ]))
              ]))
            ]);
          }),

          //Row(children: mainrowcolumns),

          floatingActionButton: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
