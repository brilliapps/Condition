// based on https://dart.dev/guides/language/language-tour
/// Some custom annotations, Most of the classes are annotations definitions
library ConditionCustomAnnotations;

/// This annotation informs, that a class defines an annotation
class AnnotationDefinition {
  const AnnotationDefinition();
}

@AnnotationDefinition()
class ToDo {
  final String who;
  final String what;

  const ToDo(this.who, this.what);
}

class ConditionMethodMustBeOverriden extends Error {}

/* @deprecated built in annotation causes Visual Express to gibe you some highlights (a deprecated property f.e. is stroke with line)
/// This tells that a method, property is obsolete, is not to be used will be removed as soon as possible
@AnnotationDefinition()
class Deprecated {
  const Deprecated([param]);
}
*/

/// This tells that mostly a method, but maybe class, property has especially body function written in an educational way, it sometimes work out-of-box, however often it does'not, but the way code was written and comments it tells you how to implement it in an extending class.
@AnnotationDefinition()
class EducationalImplementation {
  const EducationalImplementation();
}

/// This annotation indicates, that a method of the parent class (possibly abstract) must be implemented, more precisely overriden in an extending class. As a matter of convention the to be overriden method should contain intuitive indicative code helping in the implementation. If the method is not implemented, there will be an error, not exception thrown.
@AnnotationDefinition()
class MustBeImplemented {
  const MustBeImplemented([param]);
}

/// This annotation indicates that a class or a member is implemented fully, correctly because it works as expected (!) but in a primitive way, because you needed it ready and working right now, so it can be very slow, consume much resources (processor, memory), can throw too many exceptions while it shouldn't or be significantly lacking in many other ways, but still working the way it is exected of it.
@AnnotationDefinition()
class Makeshift {
  const Makeshift();
}

/// Standalone or in connection with @[MustBeImplemented] annotations in a extended class, this @[Stub] annotation indicates that especially a class was only initially declared, it is not but looks like an interface with just some variables or methods declared, it's development is planned for the future, so now it doesn't implement anything or not much, especially things required by the @[MustBeImplemented] annotation.
@AnnotationDefinition()
class Stub {
  const Stub();
}

/// Indicates that a method cannot be overriden. However technically this rule can be easily circumvented.
@AnnotationDefinition()
class NonOverridable {
  const NonOverridable();
}

/// This tells that a property is only in the app not in the server
@AnnotationDefinition()
class AppicationSideModelProperty {
  const AppicationSideModelProperty();
}

/// This tells that a property is server side only you get it from server, store in the app but you never can update or change it on the server
@AnnotationDefinition()
class ServerSideModelProperty {
  const ServerSideModelProperty();
}

/// This tells that the property that is stored in the app database (f.e. in the localStorage in a webbrowser) must also be synchronized with the server
@AnnotationDefinition()
class BothAppicationAndServerSideModelProperty {
  const BothAppicationAndServerSideModelProperty();
}

class ConditionCustomAnnotationsMessages {
  static String MustBeImplemented =
      '@[MustBeImplemented] : A method of an abstract class must be implemented by an Extending class';
}
