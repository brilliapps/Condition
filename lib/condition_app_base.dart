import 'condition_data_managging.dart';
import 'package:flutter/foundation.dart'; // debugPrint f.e. but probably also for Platform detection - don't remember now.

/// Not dependent on Flutter framework. A signature function. A [ConditionWidget] widget from it's constructor registers a method of this type by calling [ConditionModel] model's [setUpNullifierOfModelContainerOfWidget] that sets the model's property [nullifierOfModelContainerOfWidgetcalls]. The model when basically has just retired (it's retire() method is successful) call's the method to set [ConditionWidget] [_modelContainer].value to null thus removing pointer to the model. The only way to set the property to null by an outside object is by this method; this is final so no one can replace the method or "hack" the solution. Some aspects of this entire libary require removing last pointer to an object for it not to consume devices resources. Apart from that when some pointers are set to null a [Finalizer] objects start doing their job. More can be understood when reading [ConditionModelApps] and [ConditionModelApp] description and possibly more from there.
typedef ConditionNullifierOfModelContainerOfWidget = Function();

/// Not dependent on Flutter framework. Read [modelContainerImplementationNotice] getter desc. You should use [ConditionWidgetBaseWithConstructor] whenever possible because the class enforcess all the properties to be correct,  just set up (as for now) _modelContainer = modelContainer in the constructor. However if you use this mixin you have to ensure that when a class is mixed with this mixin, in the class constructor you must ensure correct values as [ConditionWidgetBaseWithConstructor] indicates. The reason for this mixin is that a widget can extend [StatefullWidget] but no other additional class, so you have to mix the widget with this class. The default implementation of mixin or no mixin is already done for you. Implement or extend this empty class to be compatible (Type/runtimeType property). Used in [ConditionModel] widget property. The class is to help separate data from look but indicate there will be a "material app" widget attached in the front-end, but empty class when this library is imported for a separate server app, this class is shared by the material app but also by an independent backend data server(s) so this class indicates that in the material app true widget will be rendered on the screen, but for the server there will be used some empty class representing the value
mixin ConditionWidgetBase {
  /// Warning! Managed internally by the library. Get (getter "model"), never set new value on your own.
  /// See [ConditionModelOrNullContainer] desc. Always contains model or null. Any model can set it to null, widget won't do it.
  /// [ConditionModelApp] (+ [ConditionModelApp] overwritting getter have it explained, to simplify, that this property cannot be final only because when we want to attach a model to a Finalizer then the finalizer want trigger finalizing method when at least one referrence is left to a model.
  /// TODO: Should be @protected ? private?
  /// TODO: General topic. Wouldn't be sometimes a good idea to use token objects with unique identiy id (not hashcode) for those objects that have the token objects as private properties to get some access.
  @protected
  late final WeakReference<ConditionModel> modelContainer;

  /// FIXME: UPDATE DESC. Read carefully all desc here. The autor of the library would like to enforce some implementations for the best working of the library, but he couldn't. So this information.
  /// (because of dart and similar languages (java?) syntaxes). If possible use and extend [ConditionWidgetBaseWithConstructor] abstract class whenever possible, not this mixin [ConditionWidgetBase]. But if you use the mixin as you are unfortunately forced in the [StatefulWidget] to use this mixin because the [StatefulWidget] already extends another class so you cannot mix the class with this mixin (using with keyword) and it cannot force you to init it's properties in the class constructor with this.property. But there is a trick that if you won't implement this getter here you will be notified that it is missing and it is assumed that you will be reading the description here you are reading now.
  /// ! So the point is if you mix a class with this mixin you absolutely must copy all solutions from the [ConditionWidgetBaseWithConstructor] class. For example based on what is now (up-to-date?) the content of the class's constructor it could be like   YourClassConstructorWithThisMix(ConditionModel model) {modelContainer = ConditionModelOrNullContainer(model); modelContainer.value!.registerNullifierOfModelContainerOfWidget( nullifierOfModelContainerOfWidget); }
  WeakReference<ConditionModel> get modelContainerImplementationNotice;

  /// Public, returns the only model or null if the list is empty as List objects do. Warning! Remember, if you want to use this getter in a custom way, if you assign the model to a variable, remember to unlink the model from a pointer variable, set f.e. amodelvariable = null. [ConditionModelApps] with [ConditionModelApp] tries to sort of GC all stuff and much more. It is much better described there.
  ConditionModel? get model => modelContainer.target;
}

/// See [ConditionWidgetBase] desc.
abstract class ConditionWidgetBaseWithConstructor with ConditionWidgetBase {
  ConditionWidgetBaseWithConstructor(ConditionModel model) {
    // Default implementation of this library will never throw the below exception.
    modelContainer = WeakReference<ConditionModel>(model);
  }
}

/// Not dependent on Flutter framework. The only purpose of this class is informational. Each [ConditionModel] class ultimately has it's own widget. There is ConditionAppModel that is to have ConditionApp Widget ConditionApp class extends this ConditionAppBase class. Why it all? Because the backend (no real frontend and widgets) server uses all model classess structure by including condition_data_managing.dart, and all models cretaed on the server side must be supplied in this or the other way with widgets, however you don't have meterial design and true widgets in the backend, so fake widgets will be created/supplied. [ConditionAppBase] solves some issues with importing libraries, etc. so it works everywhere
abstract class ConditionAppBase extends ConditionWidgetBaseWithConstructor {
  ConditionAppBase(super.modelContainer);
}
