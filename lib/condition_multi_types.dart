/// Yeah, yeah , the name looks catchy, but...
/// You should be able to find usage examples here https://github.com/brilliapps/multitypes-multivalues
/// This library solves the simplest way the problem of not having union types in dart like in TypeScript for example
/// Below all you need to have an object which carries one of two generically hinted types. If there is any type mismatching you editor should inform you about error.
/// Examples show how to use it. At your disposal there is [Types] and [Types3] abstract classess, but the object itself you create using [TypesV], [TypesW] for two types [Types] object.
/// There is .v property (value) which you can change but according to it's type (you can change the behaviour by changing class content)
/// You have an example [types_example_test_method]([Types]<[int], [String]> string_or_int) method (and probably [values_example_test_method] now in a stub stage), if you pass as an argument in this example which is not exactly [int] or [String] you have compilation time or in-editor error. The value you get from the .v property.

/// Testing class: Before we start, an insteresting class:
//class TypeOf<T, U> extends Type {
//  TypeOf() : super();
//}
//
//// now we start
//
//abstract class Types<V, W> {}
//
//class TypesV<V, W> extends Types<V, W> {
//  V v;
//  TypesV(this.v);
//}
//
//class TypesW<V, W> extends Types<V, W> {
//  W v;
//  TypesW(this.v);
//}
//
//// ----------------------------------
//
//abstract class TriTypes<V, W, U> {}
//
//class TriTypesV<V, W, U> extends TriTypes<V, W, U> {
//  V v;
//  TriTypesV(this.v);
//}
//
//class TriTypesW<V, W, U> extends TriTypes<V, W, U> {
//  W v;
//  TriTypesW(this.v);
//}
//
//class TriTypesU<V, W, U> extends TriTypes<V, W, U> {
//  U v;
//  TriTypesU(this.v);
//}
//
//// -----------------------------------
//
//abstract class MTypes<V, W> {}
//
//class MTypesV<V, W> extends MTypes<V, W> {
//  dynamic _v;
//  final Type type;
//  MTypesV(V this._v)
//      : this.type = _v is MTypesV
//            ? _v.v.runtimeType
//            : _v is MTypesW
//                ? _v.v.runtimeType
//                : V;
//
//  set v(value) {
//    if (type is! MTypesV && type is! MTypesW) {
//      _v = value;
//    } else {
//      _v.v = value;
//    }
//  }
//
//  dynamic get v {
//    return type is! MTypesV && type is! MTypesW ? _v : _v.v;
//  }
//}
//
//class MTypesW<V, W> extends MTypes<V, W> {
//  dynamic _v;
//  final Type type;
//  MTypesW(W this._v)
//      : this.type = _v is MTypesV
//            ? _v.v.runtimeType
//            : _v is MTypesW
//                ? _v.v.runtimeType
//                : W;
//
//  set v(value) {
//    if (type is! MTypesV && type is! MTypesW) {
//      _v = value;
//    } else {
//      _v.v = value;
//    }
//  }
//
//  dynamic get v {
//    return type is! MTypesV && type is! MTypesW ? _v : _v.v;
//  }
//}
//
//void types_example_test_method(Types<int, String> string_or_int) {
//  //return 'abc';
//}
//
///// Stub, not a solution but a convention/pattern of doing something: this is interface, not detecting compile time errors like [Types] class, but just hinting you create object with the list of values acceptable but one can be used and stored also in .v property like in TypesV or TypesW for example
///// However this time it is a static property of an extending class which must contain the values acceptable.
///// Additionally This should contain testing capability before an object is created and throwing exception if there is a try to assign a wrong value. Or possibly some other way to avoid runtime errors/exceptions so that you can code with this in mind that the app will work after compilation.
//abstract class Values {}
//
//// Stub : and this is implementation
//class ValuesFancyValues extends Values {}
//
///// Stub
//void values_example_test_method(ValuesFancyValues string_or_int) {}
//

abstract class Types<V, W> {}

class TypesV<V, W> extends Types<V, W> {
  V v;
  TypesV(this.v);
}

class TypesW<V, W> extends Types<V, W> {
  W v;
  TypesW(this.v);
}

// -----------------------------------

abstract class MTypes<V, W> {}

class MTypesV<V, W> extends MTypes<V, W> {
  dynamic _v;
  final Type type;
  MTypesV(V this._v)
      : this.type = _v is MTypesV
            ? _v.v.runtimeType
            : _v is MTypesW
                ? _v.v.runtimeType
                : V;

  set v(value) {
    if (type is! MTypesV && type is! MTypesW) {
      _v = value;
    } else {
      _v.v = value;
    }
  }

  dynamic get v {
    return type is! MTypesV && type is! MTypesW ? _v : _v.v;
  }
}

class MTypesW<V, W> extends MTypes<V, W> {
  dynamic _v;
  final Type type;
  MTypesW(W this._v)
      : this.type = _v is MTypesV
            ? _v.v.runtimeType
            : _v is MTypesW
                ? _v.v.runtimeType
                : W;

  set v(value) {
    if (type is! MTypesV && type is! MTypesW) {
      _v = value;
    } else {
      _v.v = value;
    }
  }

  dynamic get v {
    return type is! MTypesV && type is! MTypesW ? _v : _v.v;
  }
}

// ----------------------------------

abstract class Types3<V, W, U> {}

class Types3V<V, W, U> extends Types3<V, W, U> {
  V v;
  Types3V(this.v);
}

class Types3W<V, W, U> extends Types3<V, W, U> {
  W v;
  Types3W(this.v);
}

class Types3U<V, W, U> extends Types3<V, W, U> {
  U v;
  Types3U(this.v);
}
