/// Yeah, yeah , the name looks catchy, but...
/// First of all in my opinion in a scrictly typed language capability of using
/// two or more types for a variable is a must be, especially that in dart
/// you cannot at the moment create two methods with the same name but different type params
/// So you are deprived of at least one neccessary tool in my opinion
/// again: for a strict type oriented language like dart in 2023 (basically)
/// Here are defined new types consisting of two or more basic types whose classes you cannot extend,
/// in dart like int, String. Also you can, but *fully*, extend those types like this extension NumberParsing on String {
/// So you can't do a fully working type like this StringOrint and assign int or String to a variable with such a type
/// You can't also assign like this Type my_type = String | int like in TypeScript
/// It seems that incoming dart 3 macros won't give you a good looking code and convenient tool to achieve the multitype result
/// Doing any form of code generation is too much tricky.
/// Finally, after some research, to achieve the closest result you have to use functions like such types
/// In the example below you can invoke text function with a StringOrInt param - function that returns a String value or Integer
/// It's kind of a temporary hack. The example below could be more efficient, but it gives you the idea behind it.
/// Important ! If i am correct try to define constant type Function for StringOrInt-like type in defined with const keyword "everywhere". This might make it faster. Understand how dart works to know what and how to do it exactly.
///```String test_method(StringOrInt string_or_int) {
///  // var final_one_tye_value=string_or_int() - dart decide it's String
///  // or int - the closest you can get to multitypes - results similar to [FutureOr]<T>, [Type]?
///  return string_or_int().runtimeType == int
///      ? string_or_int().toString()
///      : string_or_int();
///}
///
/////using:
///StringOrInt my_method = () => 10;
///
///const String my_variable = 'some text';
///StringOrInt my_method_2 = () => my_variable;
///
///String some_string = test_method(my_method); // not tested but should be '10'
///String some_string_2 =
///test_method(my_method_2); // not tested but should be '15'
///```
///
///

/// This class is a carrier of one value of two acceptable generic types, it is as close as it can be to union types, however the value you can get from final v property (is it still final? Can it be changed to one of the two types? Any setter for that?)
/// The purpose of this class is to show you errors in your Visual Studio Code before code compilation except for one thing you have to always do manually/personally:
/// When V or W cannot be null (f.e. Types<int, String>) you cannot pass null as argument like this Types<int, String>(v: null);
/// If you actually do, there is no error in your editor like Visual Studio Code, but an Exception will be thrown during app execution time. This is what dart syntax allow for now.
abstract class Types<V, W> {
  //final v;

  /// The proble described below has been resolved by using two extending classess of this class: TypesV<V> and TypesW<W> and this class is abstract.
  /// For educational purposes this old desc presents the problem: When v is of V or W it cannot be null, but due to some syntax i have to allow assigning null value to is
  /// For this is additional type checking done in the constructor - no error or exception is thrown
  /// because it wouldn't be detected before compilation in your editor or during compilation time
  /// You just need to be aware of the limitations and use is_type_valid
  Types({V? v, W? w});
  /* : this.v = v.runtimeType == V
            ? v
            : w.runtimeType == W
                ? w
                : null;*/ // Actually it won't ever be null because forcing to use classes TypesV<V> and TypesW<W> solves this (this class is abstract)
/*
        ,this.is_type_valid =
            v.runtimeType != V && w.runtimeType != W ? false : true {
    // The only thing can happen after compilation when the app actually works.
    if ((V != v.runtimeType && v == null) ||
        (W != w.runtimeType && w == null)) {
      throw Exception('class Types<V, W> - constructor param cannot be null');
    }

*/

}

class TypesV<V, W> extends Types<V, W> {
  V v;
  TypesV(V this.v) : super(v: v);
}

class TypesW<V, W> extends Types<V, W> {
  W v;
  TypesW(W this.v) : super(w: v);
}

typedef intOr<V> = Function;
typedef StringOr<V> = Function;

String test_method(Types<int, String> string_or_int) {
  return 'abc';
}

Types<int, String> abcty = TypesV<int, String>(10);
Types<int, String> abcde = TypesW<int, String>('qwe');
var abcdek = TypesW<int, String>('qwe');
//error: Types<int, String> abc = TypesV<int, String>(10.4);
//var rtet = test_method(abc);
//error: Types<int, String> abca = TypesV<double, String>(10.4);
//error: Types abcdek = TypesW<int, String>('qwe');
//error:var abcdek = TypesW('qwe');

var rtetde = test_method(abcde);
var rtetdef = test_method(abcty);
var rtetdefp = test_method(abcdek);
