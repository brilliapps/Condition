/// Classes implement or extend this empty class to be compatible (Type/runtimeType property). Used in [ConditionModel] widget property. The class is to help separate data from look but indicate there will be a "material app" widget attached in the front-end, but empty class when this library is imported for a separate server app, this class is shared by the material app but also by an independent backend data server(s) so this class indicates that in the material app true widget will be rendered on the screen, but for the server there will be used some empty class representing the value
abstract class ConditionWidgetBase {}

/// The only purpose of this class is informational. Each [ConditionModel] class ultimately has it's own widget. There is ConditionAppModel that is to have ConditionApp Widget ConditionApp class extends this ConditionAppBase class. Why it all? Because the backend (no real frontend and widgets) server uses all model classess structure by including condition_data_managing.dart, and all models cretaed on the server side must be supplied in this or the other way with widgets, however you don't have meterial design and true widgets in the backend, so fake widgets will be created/supplied. [ConditionAppBase] solves some issues with importing libraries, etc. so it works everywhere
abstract class ConditionAppBase extends ConditionWidgetBase {
  ConditionAppBase() {}
}
