Condition, makeshift README
At the moment of writing of this paragraph, there is some example dbs with initial debug data so all you need is to run
"flutter run -d windows --debug -a debugging" with allowed chrome device that is maybe starting but lagging behind. The -a debugging should activate code that is run when condition if (ConditionConfiguration.debugMode) is met. This let's you see in the two sqlite files how some debug records are added. Most interesting test stuff should be seen in the lib\condition_data_managging.dart file in restoreMyChildren() methods, when
debug objects are created, especially when new contact is created then in another restoreMyChildren() method message objects are created with a message that has a parent message. I try for now to present. restoreMyChildren() should restore model's children but in debug mode it creates new object for testing. For now not debug part of the code restore children models based on just ids passed to a models constructor. But when also the debug code is activated the following scenarious of creating new objets is tested. When completely model is not inited in the db until parentModel allows, it allows for that when parent_id (or more properties when neccessary) is passed to the child model, then child initing is unlocked. The second a new child model is not locked until parent allows but it has to set up neccessary properties and get inited until it will be added to it's parent via addChild. If a new model hasn't had it's parent_id set up yet it will be added when the child model is added via addChild. Also global server init will be unlocked when server_parent_id is set up by a parent model if the server_parent_model was not set up yet. If something else goes wrong an exception may be throw. If there are more scenarious in the debug mode tested you can find in the restoreMyChildren methods. The pattern shown there could be used by you on your own. !!!!!! The point of initing a new child until a parent allows but adding the child before it's initing in the db is to use synchronously the models in as fast way as when you create a new map, f.e {1:{2,3:{4,5}}}. Of course the map is to be different and you have to wait until all models in such a nested map is inited but you can use it synchronously and all the stuff with writing and updating on the global serve is done in the background. So this is the main concept of
nested models resembling maps however map is to be like this for you model['id'] = 10, model.id=10, model.children[0].id=20. We don't set up id this way ofcourse bacause the id is in the sql db row. but it is to show you what this is going to be like for a single programmer that is not going to care of anything but setting such properties of models. Ofcourse it may not be as fantastic as described, but this is where it is heading to.


condition
Welcome to a messy, draft documentation, not-consistent, reflecting changing decisions during the development process. This is still early work-in-progress. All however unimaginable it may seem this app/library/whatever is going to work on all platforms including web with possible http backend server (global driver) simulation or proxy.
This may be fully tree like messenger (with deep tree of groups of contact), might be something like the "ultimate" fourth layer next and somewhat thinking-compatible to the flutter three layers 1. widget, 2. element, 3. render object, remembering ofcourse that more and much better concepts for the so called "ultimate" layer can be implemented. The model layer ofcourse also is to separate logic and data from the view. On the backend side the 4th layer is going to run independently from flutter (obviously no graphics) reusing the same model stuff and model-data validation code. In a model like message you might run a fully independent app. These are example goals, not scratching even the surface of possible usage cases (if the library is ever "finished"). Each tree of models is stored immediately on the local server of the app compatible with SQL thinking and typically each local server tree of models is synchronized on the local server. There is permanent storage and f.e. for app in model may be in memory, etc. 
FIXME: #oqx^oq8347x6q874t, maybe ok in production, to be remembered in chrome debug need 0 or 2 hot reloads to work properly.
Debug mode commands by stages with desc. The app/library automatically creates what's needed for backend and frontend from scratch. Example commands in debug mode. CUSTOM PARAMS LIKE -a debugging doesn't work for web/chrome, only native. However the same effect for web (tested sucessfully at the time of writing) you can achieve in the main file setting up f.e. ConditionConfiguration.debugMode = true;  ConditionConfiguration.initDbStage = 3; somewhere after the code block setting these variables. At least try to find the place for the code  
Tested on windows (focus on this one) platform maybe web/chrome too
Also these commands are expected to work in default settings, like using default both local and global driver, where both of them are enabled. So if not modified, this library should be able to perform the tests on all platforms.
WARNING!!!: params like -a initDbStage=3 are one time commands. After successful init of the db with data you should restart the app with no initDbStage param. If you want start with empty db you need to remove the db files (or remove tables manually) which are condition_data_management_driver_sql_local.sqlite and condition_data_management_driver_sql_global.sqlite in the main app directory (not the lib directory but the one higher). For web each time you close your quit the app the dbs are cleared so you don't need to perform anything else but to start the app with the new command flutter run ...
Also as localServer is normally expected to be sqlite3 local device storage, but for these debug commands to work properly (native/web) also globalServer is to be local device storage. By being non-proxy drivers these allow for direct accessing sql commands, f.e. driver._db.db.execut('some sql here');
Good to remember that some debug code (not only) uses some "educational" (for you and with my dementia for me too :) ) alternatives of doing stuff, doing sometimes the same thing like creating models but in different ways, with educational descriptions.
If not mentioned. for the local server and global server only users are created by using direct sql insert, but the rest of models like contacts/contactgroups/messages are created new with no id using model constructors. They are created on the local server and then synchronized to the local server. The next part possibly soon will be reading messages from another user directed to my user saing simply.
0. The app is completely auto configuring by default. SQL db is created if not exists or/and tables are created if not exist.
flutter run -d windows --debug -a debugging
flutter run -d windows --debug
-----
Insert some initial data bypassing otherwise some windows/pages/stages requesting you some initial data:
-----
1. NATIVE ONLY, NOT WEB, UPDATE !!!!! see intro - for web use ConditionConfiguration.debugMode = true;  ConditionConfiguration.initDbStage = 1 in the main.dart file;. Pass to the main [ConditionModelApp] model object some predefined properties value, and the library should get the app instance ConditionModelApp.server_key/ConditionModelApp['server_key']
flutter run -d windows --debug -a debugging -a initDbStage=1
This stage is lacking f.e. example users in the db
2. NATIVE ONLY, NOT WEB (see 1. and intro). Not implemented ? 
Create correct testing users (or not correct to?, the library must deal with it if wanted), insert into the local db (it must be synchronized with the global db automatically by the library)
flutter run -d windows --debug -a debugging -a initDbStage=2
This stage is lacking f.e. example contacts and/or models like messages, tasks, etc.
3. NATIVE ONLY, NOT WEB (see 1. and intro). Not implemented ? 
Now let's insert f.e. some correct (?) example contacts/messages of these contacts.
flutter run -d windows --debug -a debugging -a initDbStage=3
With initDbStage=4 you have the same level with even more data.
---------------
[Fun Fact, and it's good] An interface class can be extended in the library it was defined, which probably means in the file it was defined, but outside the file it can be implemented which is flexible approach and great.
Oh, joy, another fun fact. If you have interface "B" that extend an abstract "A" class, then in the "class C extends B" you have to implement also stuff from the "A" class. But you can do it very simple. "class C extends A implements B" - no compile time error A is abstract not an interface you can simple extend it if no-syntactical circumstances ofcourse allow for it.
[To do: #dlkj2fhpeg8nqxwpiu]
[To do : #WpEmwxpQm346q$u] some thougts there may be important
[To do:] After those with the "ids" Use also conclusion from the discord.com discussion for the following: Make an auto-close action on last-pointer-to-object-lost stream classes for controller class and subscription, and auto-remove pointer for such closed objects. Extending a class may be too-much-time-consuming. https://pub.dev/documentation/async/latest/async/CancelableCompleter-class.html
may be useful which could possibly allow for not unlocking some operations on a retired model and allow for garbage collecting.
I needed this at leas once and must have done some workaround: ResultFuture<T> class, 

implement like now // [TO DO: #AP9EWHP98HQ748TGPF] throw exception if model is in the conditionModelApp, think over what to do if a model is scheduled for unlinking but not retired
// we make sure if one part of code is made synchronously in the event loop, not parallel synchronous action is performed to avoid changing state like we start checking model is not being retired but after half of a method body the situation change we think not and get a model that will be retired and removed in a while
// conditionModelApp method must return synchronically such an object if exists but
// but if it is scheduled for unlinking we make sure retire method is not being executed now and won't be if the model will be returned
// at the same time we move the model from scheduled for unlinking to the normal list 
// For this we need to define a method in conditionModelApp maybe also with information sort of "it is scheduled for retirement"
// can you 100% stop retiring such a model and return it? We want to do it synchronously if possible but
// IMPLEMTING IT IS ABOUT AN EXISTING ID NOT A NEW MODEL - THIS IS NOT AN ISSUE WITH A NEW MODEL
// test it by creating two such objects, etc. that in now way something is missed and delayed and two objects are added at once or in time period apart

[HIGH PRIORITY TO DO:] As pointed in the retire() method. If a model has getter isRetired == true it is to immediately to be unlinked (any existing pointers to object model = null) conditionModelApp objects also removes a pointer to the model as soon as it can (it waits for the model to retire first so no read write operation is interrupted incorrectly or important model data and changes are mishandled or lost). If a model is created as new and was not properly unlinked from conditionModelApp an exception must be thrown so there must be a way to check this out first. 
for that situation now cannot accept any changes to itself, no properties can be set/get, methods used or start any local or global server stuff.
[HIGH PRIORITY TO DO:] Do not shift it lower, so that not to forget: in app settings we have new useMysqlForDartCommandlineGlobalServer, dartCommandlineGlobalServerMySQLDBDefaultSettings which are related to stub class ConditionRawSQLDBDriverWrapperMySQL in condition_data_management_mysql_db_object.dart file. Probably the entire class will get the similar custom settings object like ConditionRawSQLDBDriverWrapperMySQL gets (OR NOT! READ ALL), that could be used in multiple app objects. However if time is limited only one scenario as the real "command-line" backend "global server" - local data is stored on 'local server'. Yeah, for global server you use only one mysql server, no need to complicate it this time. But local smartphone app can define couple of app objects and use different settings for local server and the "proxy http" global servers, the proxy servers may be more sophisticated then.
[TO DO]: Is there any room to simply compile the common and shared server-side part of the project to nodejs/npm with remote mysql? There is a github package node_interop for that but... If successful it would be possibly huge because php hosting sometimes is offered with nodejs running (don't know of limitations). Dreamt of php implementation for server but this would simplify the stuff and would run "everywhere" in the backend.

At the moment of writing of this paragraph, there is some example dbs with initial debug data so all you need is to run
"flutter run -d windows --debug -a debugging" with allowed chrome device that is maybe starting but lagging behind. The -a debugging should activate code that is run when condition if (ConditionConfiguration.debugMode) is met. This let's you see in the two sqlite files how some debug records are added. Most interesting test stuff should be seen in the lib\condition_data_managging.dart file in restoreMyChildren() methods, when
debug objects are created, especially when new contact is created then in another restoreMyChildren() method message objects are created with a message that has a parent message. I try for now to present. restoreMyChildren() should restore model's children but in debug mode it creates new object for testing. For now not debug part of the code restore children models based on just ids passed to a models constructor. But when also the debug code is activated the following scenarious of creating new objets is tested. When completely model is not inited in the db until parentModel allows, it allows for that when parent_id (or more properties when neccessary) is passed to the child model, then child initing is unlocked. The second a new child model is not locked until parent allows but it has to set up neccessary properties and get inited until it will be added to it's parent via addChild. If a new model hasn't had it's parent_id set up yet it will be added when the child model is added via addChild. Also global server init will be unlocked when server_parent_id is set up by a parent model if the server_parent_model was not set up yet. If something else goes wrong an exception may be throw. If there are more scenarious in the debug mode tested you can find in the restoreMyChildren methods. The pattern shown there could be used by you on your own. !!!!!! The point of initing a new child until a parent allows but adding the child before it's initing in the db is to use synchronously the models in as fast way as when you create a new map, f.e {1:{2,3:{4,5}}}. Of course the map is to be different and you have to wait until all models in such a nested map is inited but you can use it synchronously and all the stuff with writing and updating on the global serve is done in the background. So this is the main concept of
nested models resembling maps however map is to be like this for you model['id'] = 10, model.id=10, model.children[0].id=20. We don't set up id this way ofcourse bacause the id is in the sql db row. but it is to show you what this is going to be like for a single programmer that is not going to care of anything but setting such properties of models. Ofcourse it may not be as fantastic as described, but this is where it is heading to.

I don't recommend reading the stuff below now, i do not know why i decided to put all messy to do stuff here. It is convenient now. The readme file probably will look normal one day :) .

Something copied from below :)

Welcome to a messy, draft documentation, not-consistent, reflecting changing decisions during the development process. This is still early work-in-progress. All however unimaginable it may seem this app/library/whatever is going to work on all platforms, so f.e. a replacement of a http server in the browser might be implemented also for web. The only way you can possibly run is on windows platform flutter run -d windows --debug -a debugging however a web might also be able to start (tested maybe one or two month ago and many things changed since then and the web doesn't catch up in a week or two it may change) BTW: Why these letter below are so big? 

[Overal To do] in the order of future implementing:
1. In conditonmodeluser restoremychildren() there are some scenarious of adding contacts Probably we need to test all the scenarious from there adding non-contact nested widgets in non-blocking mode. F.e. like hangonwithuntileparentallows or sth, all data passsed to the constructor or just id.
2. Handling the situations where model is removed from the tree, added when it is on the all-models conditionmodelapp list, is it to be retired or no, or prevent retirement is a constructor property is or was, prevent removing from the special conditionmodelapp list and many more. model cannot be retired if a db operation is in place. Quite a few scenarios.
3. Remembering the previous point 2. : Syncing from local server to the global. For this you need to recreate a standalone model and have in mind using the solutions here to creating standalone server-side models. - in another point. First you find first row in the local db where to_be_synchronized == 1 when you seek if there is model with id on conditionmodelapp list. if it is the model will update itself when it can. But if no you create a standalone model which is added to the conditoinmodelapp list, updates itself globally then retires and is removed from the conditionmodelapplist. In brief ofcourse :) .
4. Now we seek for all updates from the global server and update on the local server - tons to do.
5. Now we can implement ConditionModelDriver for global server that performs the actual remote connection to a global server. Make it simple and 100%. send error text in answer when there is completeError or any throw exception.
--------------
6. Now we can go to the UI. Which is a different topic. Not embraced by this list or to do. Apart from UI, more backend like stuff was planned to be done, but this list focuses on bear minimum.



[To do:#aDcN9a!8e9d] server_parent_id is to make search for the record in the global server faster, if the id is wrong no record is returned. So if you set up a wrong value incompatible with the local server it's the fault of the programmer and global server will be intact. IMPLEMENT CONDITION WHERE SUCH PROPERTIES WHEN NOT NULL MUST BE FIRST IN THE SQL WHERE CONDITION THEN SUCH STUFF LIKE app_id parent_id, etc. This will make search faster. And rethink it well so that server_parent_id like variables are always supplied where it should be expected and possible.

[To do:] Think over and Add // a top_owner_contact_id - server_top_owner_contact_id - top_parent_id and server_top_parent_id too? It is preliminary assumed it will help searching the tree in the db from top to bottom or at least it will allow render all contact tree even if you subgroup is somewhere in the middle.

[To do 4#sf9q!!!gh49hsg9374:] Lower priority but there are scenarious that it must be somehow queued if you think. But There are mechanisms allowing CRUD operation to be performed when sqlite3 file is blocked by another process (as far as i know on the event loop if you have two synchronous methods for f.e. create called at the same time for two models, they will both wait until another process finishes so for now it is ok. if you use sqlite3 not web storage sqlweb github plugin - it is also synchronous - so kind of solved temporarily) - 3 to for attempts as far as i remember but for local server maybe even endless? Normally you have one process for local server and for global server - this is how it is designed - too much work and also for now no application v 1.0 is in sight. Probably due to locking issues for sqlite3 db you won't be able to open the db for writing for two processes. Thats not a big deal. So you would need to implement opening and closing a db for one writing operation with waiting for the db file to be released (create,update,delete) by another process. It is not expected ever to happen in production only you can use two processes for testing. Global server normally should have one process per db. However if stdin/out version of the server is implemented the process can be started for one proxy request. It seems that it can be implemented later
Another 2 Do itLater 1. Things implement by ConditionModelApp queing ConditionDataManagemnt driver updates on models - you just do locking when another operation is in progress, 2. Implement ConditionDataManagement out of order for global server, however the rule is that for local server it is forced to be false and always the driver works; if so it changes isDriverAvailable = false; when the connection is reinstated == true. It will emit an event to the changes stream when availability changes. It could be checked ever piece of time. However, writing code depending on this make sure that when you !start! listen to the changes the isDriverAvailable didn't change in the meantime checking the property again just after starting to listen to the changes. Of course suspend the code while waiting for the event. Also make sure that suspending won't cause calling some depending methods many times and suspending them all. See how it is already reasonably but efficiently solved in _triggerLocalAndGlobalServerUpdatingProcessGlobalServer (it initially is but finally, finally, is it?).
[To do:] see restoreMyChildren 2687 line. the try catch
[To do:] ConditionModelDriver update/updateAll(?). Add exceptions for attempts to update properties that are crucial to the property working and stability of the app and that were already set up and cannot be changed, f.e. server_id, local_id, etc. This is to be independent to the ConditionModelField validation and stabilisation tools.
[Info:] package html od tools.dart.dev - html5 parser - this you could use for html to model/widgets tree. Compare also universal_html (+xml and server side)
[To do id:#sf3fq7pnj86rc#^ creation_date:2023.05.31]  
        // in else we just wait for the parentModel to be global server inited
        // if a model doesn't have server_id or server_owner_contact_id, etc.
        // it is because it was not yet globally inited so we wait until the model i added to the 
        // tree.
        // So scenarious and conditions for them below:
        // 1. we have server_id - it is assumed that when we do we have server_owner_contact_id
        //    - earlier mechanisms assure that. it's ok we don't do anything
        // 2. We don't have server_id, server_owner_contact but
        //  the model has local parent_id or owner_contact_id
        //  a: we wait until our init == true (there is some future for that)
        //  b: we seek if there is a parentModel currently on the ConditionModelApp flat list (Set)
        //  c: if so get parentModel ~initmodelglobalserver (?) future (WARNING! Again make sure that models that already were created on the global server are inited )
        //    --! dont use addChild and similar stuff
        //  d: If the model is not on the global list restore the model from the db as standalone and retire it when no longer needed and remove it from the ConditionModelApp
        //  e: Remember that the parent model may need to restore it's parent.

This is important while you can addChild model synchronously do Exception when it is removed
from the tree when not inited (it doesn't have its local 'id') without it the model. Or maybe it is not necessary? At least prevent removing the model from the ConditionModelApp until it is _inited (or similar property name and it's getter)
Global server update: First add chekcing if a model has id but NOT server_id. If so according to the "one step at a time rule" and point "1." below we have a model that is going to be in the model tree in a while. If it is we wait for properties of a parent model like server_id, server_owner_contact_id, server_user_id and maybe some more. Then we can create the model on the global server.
One step at a time - too difficult not focusing entirely.
1. For now we assume global server is enabled alway we render !all models! and never remove.
  a: lock removal, always throw Exception.
  b: if the parentModel has the necessary properties it ok if not: we implement sniffing if parent model (which you are always added to via addChild) has server_id (! important not sure if for now inited globally works properly when model has it's id, server_id) or if not been global inited (init and await Future global server conterparts of local server stuff). If so
  it has all you need to set your initial server properties and you do update the childModel on the global server.
  Unfortunately you have to do some preventing models/parentmodels from being retired and/or removed from the ConditionModelApp list until all the globalserver updateprocess is finished.
  For this a parentModel may check if any of it's children isn't global inited yet.
  c: then unlock removal only if all your child are global server updated 
2. Then accepting removal but throw Exceptions when models are removed when one of a model's descendant (not necessarily child but grand-...-child) is not created on the global server. (if updated not the problem, because a model can be recreated as standalone to be updated in both directions - to and from global server)
3. We accept model tree-removals at any moment (maybe except it has to be inited and possibly not in the process of being inited/updated, etc.). BUT We need to create a anynchronous synchronizer object. We sparingly traverse all the db from top (? not bottom sniffing?) of the tree to it's bottom seeking all not updated models. We do it recreating only branches of STANDALONE models not the full tree, STANDALONE means we don't add a model to a model via addChild. And we create/update models to the global server one by one. using data from the parent model when necessary. Quite tricky.
on the local server where server_id == null (a general rule)
[To do] Notice that some model properties you must assign !!!even they are null!!! like server_parent_id for a model to be created on the global server. This is to make sure a model
is created on purpose with a given property == null (a developing story).
[To do] IMPORTANT ABOUT THIS TO DO: You know, the problem is, that it would be done the fastest if it was done by the global server - it just look up for our server_owner_contact_id. But
doing it on the local server side only is tricky. So reasonable abandon the below solution and
try to do it simpler on the global server side which will be however more resources consuming.
In the future you could do it fully locally. Period.
This to do should be inside of the next one but it is here to help me to focus on the current issue, not loosing track... 
      // For ConditionModelBelongingToContact to be CREATED on the global server   
      // it needs to have it's server_owner_contact_id != null or wait until it's parent
      // has this property set up (for new) - if the parent added this model via addChild
      // the child uses parentModel.a_server_id.firstValueAssignement future which always work
      // So this is the fastest way to do this.
      // To remind me a completely new model can be added to the tree by addChild only if it has
      // option == childModel.hangOnWithServerCreateUntilParentAllows == true: 
      // and for false or true in addChild properties parent_id, id, owner_contact_id are checked
      // maybe more
      // if not already in the tree the child must have the server_owner_contact_id != null
      // or read server_owner_contact_id from the local server finding a record in the db
      // looking up owner_contact_id which it already has checking it's server_id
      // if not null it can set it up child.server_owner_contact_id = parentModel.server_id
      // OR SOMETHING LIKE THAT
      // And this is also true when a model will be added to the tree and removed before it 
      // receives server_owner_contact_id, but is standalone and works anywhay (cannot imagine
      // scenario for that but it is possible)
[To do NOW:] The following is about some models to be suspended from being created on the global server until... . When you (me?) add with addChild a model you check if it has to have f.e. server_owner_contact_id to be f.e. synced on global server, and check if it doesn't have it (can it ). If it doesn't have to have the server_owner_contact_id IT IS KIND OF NEW MODEL. So the added model must listen to a new kind of future that isn't or is at the moment of using it already completed (!to do) or you can even use the "changes..." event stream to wait until the property is set for the first time to non-null value, then you can allow the child model to be updated on the global server where it already needs to have the server_owner_contact_id. And the following [To do:] problem adreses some broader vulnerability which is to be solved some time.
But the unlocking of global server init might be done in the initModel method after _inited is set true but before that method related to global server is invoked. To remind this is only in the new mdoel create process. But after app restart the model might not has been updated so the checking should be one not in the initModel but somewhere deeper - in the _doDirectCreateOnGlobalServer as i've already slightly started to do it there. 
[To do:] when you have server_owner_contact_id and owner_contact_id it should be verified if
both are the same (to do some time later) and maybe more properties like this to prevent
some exploits (this is early stages of development, such things aren't very important now)
[To do:] Ok restoreMyChildren() pattern.
    A DRAFT FROM restoreMyChildren() itself: // It is also in Readme.md We have a problem to solve a model may be in the tree or not.
    // [retiremodel... event is issued and handled:] which is determined by a constructor property retireModelWhenWhenRemovedFromTheModelTree
    // One scenario: a model was just properly added by addChild() method
    // related to ConditionConfiguration.maxNotLazyModelTreeRestorationLevel = 3 (?)
    // it's current level in the tree is by parentModel only parentModel.parentModel = null
    // it means my level == 2, so i will restoreMyChildren(), but my child will not (or so)
    // the level may change however when a model will be detached but used elsewhere without
    // a parent if it is allowed to do so (~standalone constructor property setter retireModelWhenWhenRemovedFromTheModelTree)
    // [eIDT:] conclusion !!!!!!!!!!!!!!!!!!!!!!!!
    // the properties decide initial number of levels, NEW PROPERTY IS NEEDED - BELOW:
    // So WHEN IT IS USED ALSO STANDALONE, WHENEVER IT CHANGES TO TRUE (CAN IT?)
    // a property ConditionConfiguration.maxNotLazyModelTreeRestorationLevelForStandaloneModels
    // will is used for the model as initial number of levels that are going to be restored on
    // start
    // IT WILL RENDER ALL IT'S LEVELS AS IT WAS THE TOP LEVEL MODEL. 
    // AND IF IT IS A CONACT IT WILL RESTORE ALL ITS SUBCONTACTS. tHIS DOESNT CONSIDER LEVELS
  - Focus on data models only now, then on the current widget tree restoration, when models
    work as expected
  - initCompleteModel();
  - inside initCompleteModel(); you call restoreMyChildren()
  - when a child from possibly many in _children Set object completes future of its  getModelOnModelInitComplete() then the childModel calls it's parent setState (probably),
  and when its child changes it calls the parents setstate again. Not sure of that, needs to get to the idea of setState again.
[To do:] This is related to async/await locking, that may happen in different places. Let's notice for example initCompleteModel() of ConditionModelApp class. 
    await driver.getDriverOnDriverInited();
    And this is ok. It is assumed that local server always must work, but what with locking
    await for global server request in that method? Taking into accout the aforementioned, 
    let's get to what is to do and natural compatible initial proposition how to solve it:
 Implementing static version of the app model/ tree model. It might be done in some simple moves whithout touching much the model classes. You would need to do a [DataManagementDriver] object class that would convert f.e. html/xml/json and the app using [DataManagementDriver] object would use read() method of the object and that specially prepared method would return Maps that are used for creating models. Doint so wouldn't require to do two versions of some methods or classes but maintain universal code. It could be, or not, that ConditionModelUser, ConditionModelContact, ConditionModelMessage classes, just would be treated all the same, but some properties of models would be interpreted, f.e. body is ConditionModelContact id = 1, and in description or settings of a model property would be the name of the tag, etc. 
 Also a xml/html/json could be converted into a sqlite db stored in memory.  
[To do:] delegate adding/removing children to each model, so that it is not done by the
ConditionModelApp object, ConditionModelApp app cares only for probably its own children but
most of all _allAppModels and _allAppModelsScheduledForUnlinking properties. And when a model
is removed it notifies its ConditionModelApp about it through stream events.
[To do:] [Done, not tested, user must be inited and have id:] add checking if each model to the tree belongs to the same user, taking into account that a user can be new and not yet has it's own id. 
BUT In the more distant future: Think over if a model of ahother user could be added as a link to a parentLinkModel carrier. For now it is to difficult to manage all these changes (to much to bear in mind).
model of another user can be linked
[To do idea:] Maybe not to be implemented. If you can add a not inited model to a not inited model, etc. You could possibly create an app from start which is completely not inited and add
full set of models to it. But this could be done at the end. However This should assume, that
always there is a main app, and that app could contain settings for those other apps. Really far
reaching. While going into giving much freedom to a third-party developer as possible, now it
is better to stop on this that an app internally inits itself then adds it's own logged users,
but allows adding newly created users that are yet not inited (the assumptions are fluid/dynamic now)
[To do:] 
This maybe very important (Flutter Team, first-party):
https://github.com/flutter/packages 
Apart from that enhanced version on the aforementioned (flutter favorite, don't know if flutter team maintained):
https://github.com/fluttercommunity/plus_plugins


For developers to do enable custom programming
Add data channel for contacts - posiibly two fields one for sending one for receiving.
[Edit:] May involve restoring and maybe rendering all contacts from the db. Then ConditionConfiguration.maxNotLazyModelTreeRestorationLevel wouldn't apply to contacts. 
This barely have in mind two or more instances of the same app receiving such data. One app
might not be able to catch it so A developer may have to deal with it.
A developer might choose #how to create its own protocol and different rules for this# and clean "himself" the properties when they were read by a receipient. F.e "@F1SF#$Q#FCS WAS READ BY APP_ID 10" BUT NOT OTHER APP. APP_ID is READY - some adding to the fields might help. Limited data for the fields f.e. 5 kb, etc.
[To do:] 
First noticed in conditinoModelApp constructor, here is the comment from there
        problem? // parent model may be not in the main tree. When such a standalone parent model 
        //is retire() ed // it must trigger removing and detaching all it's child models.
        //it means not only detaching all children but olso fully removing parentLink Related stuff
        //And in the right order. Is this really so?
IMPORTANT: FOR NOW IT IS SHOULD HAVE ITS _changesStreamControllerAllAppModelsChangesControllers (implement stuff when any streams finishes when model is retired so that dead streams are removed and release resources)
STREAMS ATTACHED. But conditionModelApp itself doesn't have all child model stuff implemented yet
VERY IMPORTAT: to implement and it is strictly related to methods addChild _addParentLinkModel
and their removal counterparts:
READ IT NOW !!! IN MY OPINION A MODEL TO BE REMOVED OR NOT CONTAINS ALL THE INFORMATION NEEDED IN parentNode, children properties parentLink child or childlinkmodel or so these four, and also
what to do can be decided based on the mentioned belo [retireModelWhenWhenRemovedFromTheModelTree]
RELATED V.ERY IMPORTANT - WHICH IS OK TEMPORARILY FOR NOW: (Also IT IS STRICTLY TO [ConditionModel] [retireModelWhenWhenRemovedFromTheModelTree] if it's name hasn't changed in the meantime, see the property description) once object is added to the special
conditionModelApp list [_listOfAppModels] it is never removed ######!!!!LEVE IT UNTIL AFTER YOU IMPLEMENT ADDCHILD() AND SIMILAR METHODS AND the global server returning server_id, etc, AND LINK MODELS.!!!!######### UNTIL THE FOLLOWING IS IMPLEMENTED IF NOTHING
BETTER WILL BE INVENTED. AND TO REMEMBER, ONCE a model IS ATTACHED TO THE TREE (in couple of places - one in the tree but zero, one or more places as a link in a different model container), AFTER REMOVAL from all places in the main model tree IT WILL BE REMOVED synchronously (if not
necessary you can get removal events from changesStreamController - a global app merging all models event streams (changesStreamController multiplied many)) immediately (retire()) after that FROM conditionModelApp special list [_listOfAppModels] immediately except for
a method preventing doing that and calling retire also in the constructor body a property creating an object that won't be removed except for it will ask for calling remove informing
it will have no reference to itself in a while. To think over thoroughtly.
AND DON'T forget that a model may be removed/retired while it is not inited yet (wil it ever be?) or updating - is it a potential problem, however when a data driver finishes it's crud method the model has no link to itself. looses it's link, the model shouldn't
should it wait?
I think ConditionModel retire (or similay) method desc put it this way:
  /// This (retire) must be somehow implemented however difficult it might be. Not going here into details here but there may be model removed from the model tree, there MUST NOT BE other reference(s) active to the model except for a special List of models in the ConditionModelApp class. When a model is nowhere else except for this list it must be removed. It could be implemented with some delay (Timer) - if it is not in the tree and no property change induced by app user has taken place, the model can be detached and send some locking if accidentally it is suprisingly linked somewhere, and in the development process such places will be gradually corrected, some log messages, errors (no exceptions - wrongly constructed piece of code). No unused link to the model can be left. Also helping conditionModelApp to be notified
  about relevant changes is pretty well designed stream of changesStreamController which
  notifies about relevant changes. I see possible problem, but the problem: a model doesnt need
  to be in the conditionModelApp model tree, for this might be ConditionModel private(?) property
  inited in the contructor area.
  to inform, that a given model not attached to the ancestor conditionModelApp won't be scheduled
  for some automatic removal, but it might request for it's removal. Such object could be added manually or statically so to speak. These solution could prevent from draining resources and memory wouldn't be flooded by unused models with their data.  
  model receives conditionModelApp, so the model is just unremovable
_parentLinkModels - implement it once.
[To do:] method addChild and ConditionModelBelongingToContact/ConditionModelContact logical issues //also // make sure if you do changes to this or to childModel 
          // To do also in ConditionModelBelongingToContact desc marked as to do later.
          // ConditionModelContact is ConditionModelBelongingToContact but logically it shouldn't
          // So check for possibility to make ConditionModelBelongingToContact class mixin.
          // but it's alrright: !!! here in this method we can use ConditionModelContact instead

Local [To do:] Take in to account of also adding : model was added to the tree or removed - then widgets 
could be removed also from not model BUT widget tree (lazy loading/removing etc.)
BTW this probably is done already isn't it: (addChild()) add event for unlocking 
child model (is initmodel and global also in the event stream?)
Local [To do:] I don't remember where it was here below but if you want to make some model
db related property setters like for model.id, model.server_id private or @protected, remember
that it can be probably bypassed by setting model[server_id] = 1 for example. 
Local [To do:] There is probably a loophole, might be ignored if you pass initial values 
"defValue"(?) map of a model to the constructor you may need to use a copy of them, because there
is an outside of the class of the model the "defValue" reference. Someone might change the values
in the meantime. But basically there is no point of protecting the data integrity from developers.
It is just to help them not to experiment and damage the library in some way or the other. 
Local [To do:] I think _completerInitModelGlobalServer for read can complete like local.
_initedGlobalServer (__initedGlobalServer double underscore) are implemented?
Local [To do:] We have _completerInitModel and _initedCompleter, also global stuff, and there is used
_initedCompleter in _inited setter (setter for __inited (Watch out: double underscore)). Review what is 
used, what duplicates, etc. also for the global server counterpart properties. Also when the
ONE AND ONLY _inited variable is set it is to do these things IN THE SETTER!:
               _completerInitModel.complete(true);
    changesStreamController.add(ConditionModelPropertyChangeInfoModelHasJustBeenInited(this));
Local [To do:] _completerInitModelGlobalServer is only completes with error - i missed to complete it
is this used by something causing potentially to stop some code to be executed?
Local [To do:] Related to the "to do" after this one. There may be a loophole in the global server: while local server is protected,
for the global aspect when you do async not await (good!) _doDirectCreateOnGlobalServer() create,
there may be no mechanizm preventing global update to the model, possibly there may be an attempt
to do the update globally before global server create was finished.  
Local [To do:] Outline, it may change much. We have some stuff, when a model 
is considered inited now? (not once then... it was simpler)
for now: __initedGlobalServer model will can ever be true until after __inited == true (related to _initedCompleter.future, and _initedCompleterGlobalServer.future)
local server, maybe 
if (this is ConditionModelParentIdModel)
parent_id
or normal inited initing can be left as is because it works for now before changes
? is it needed: if (this is ConditionModelBelongingToContact)
owner_contact_id
global server as above but simpified class and needed properties:
ConditionModelIdAndOneTimeInsertionKeyModelServer
    server_user_id
    server_id
    server_parent_id
ConditionModelBelongingToContact
    server_owner_contact


Local [To do:] [Edit: ConditionModel parentModel in constructor - maybe only should be added by addChild() when it gets into a tree is it final? should it be final?]. Related to a series of to dos below. You probably need to implement not allowing
for "outside" changes to the properties marked as read from the server. This should be done
in a systemic way - Each [ConditionModelField] or someting has not fully implemented tools for that (is_app_only, is_both...).
Local [To do:] AS PART OF SOMETHING MAJOR BELOW ONE OF THE FOLLOWING ABOUT 2 [TO DO]s
We have the following situations needed to be addressed:
THE POINT
To be totally flexisble we need to allow for realtime speedy creation of a tree or of a subtree
of models probably of the same type, however, after creation you may be not be able to change
the values of any model untile a model is inited and its LOCAL SERVER id is set up. However
for speedy tree or subtree creation this is possible then from top to the bottom such a tree is
stored one by one on the local server side. We don't want touch the global serve side very much
So knowing this: 
1. Existing children models must be added internally not from outside - that is easy all parent_id parent whatever properties 
    are already set-up, at least the necessary local ones.
    But this is going to be togher.
2. Adding a new model (no id set) from outside into a tree using add... i dont remember
    a: This operation allows for ignoring inited/_inited 
    (Edit: maybe remove requirement that you must wait for the model to be inited before it can be used after its creationg
    with initial values, you just won't allow some systemic properties to be set up - the reason behind that 
    is that you don't need to use asynchronic programming before you start using the model after it is created and maybe not inited yet)
    it is going to a waiting list of child models to be processed when
    the parentModel and added child model is inited (which happens when local server create was performed with success).
    However such a model on both local and global server (if already in-sync) has no f.e. proper parent id like properties set-up.
    ! We could do it in one or two ways - hang on with create (in local db) operation until 
    parent_id or other local properties
    WATCH OUT: the default value is now false, instead exception is thrown when needed (when it should be true).
    We have no option but to make a prop. hangOnWithServerCreateUntilParentAllows = false by default.
    AND THIS OPTION THE APP/FRAMEWORK WOULD USE AS IT NEEDS, 
    AND THIS OPTION WORKS ONLLY WITH COMPLETELY NEW MODELS
    passed and accepted by addChild method of a
    Which would be taken into account only starting with parent_id like class and probably excluding ConditionModelUser and ...App
    A property to each model having parent_id and or contact_owner_id (for global counterpart properties may be done elsewhere)
    b: when both a ready a parent model
    The rule is it must be a model of the same class as its parent (such model can be a link to a model of different class)
    YOU MUST create a new model using getter which will set
You have nothing, but a fresh model you put it as a child, but maybe you have na id in the meantime.
    -> the app sets its parent_id, and when it can server_id, owner_contact_id, server_owner_contact_id

Local to do: you don't want to miss implementing the funcionality related to models changes strem: classes [ConditionModelPropertyChangeInfoGlobalServerToLocalServerToModelSuccess] and
[ConditionModelPropertyChangeInfoRegularChangeGlobalServerInducedFirstChange]. Such short term local reminder.

Another local stuff to do copied and maybe not up to date here from condition_data_managging.dart
the most probably double // commented in [ConditionModel] class body so you better seek there but you need to know what is to be implemented AND REMINDER: this stuff is needed to be done before i return to [ConditionModelPropertyChangeInfo] stream related stuff implementation mentioned also earlier here, 
  /// [to do:] A model can be created in validation mode, especially for the global server operations,
  /// if it is then it cannot be accepted as a child into the model tree and should have some
  /// other limitations, and but the advantages is that it should be passed easier during some 
  /// initiation process ([initModel() related stuff) 
  /// NOT TO FORGET AND REMINDER: this stuff BELOW is needed to be done before i return to [ConditionModelPropertyChangeInfo] stream related stuff
  /// and i also got to a point where tested in the code in this file for server_id being set up 
  /// for the first time for being use by a child widget model [ConditionModelContact] in this case
  /// so those logic there could be implemented with the following stuff to be implemented now:
  /// to Do related to _parentNode: 
  /// a model is in the tree when it has a parentModel set up
  /// but a model in a link model could have a list of link _parentLinkModels 
  /// (which with related stuff for now should be implemented in ConditionModelWidget class) 
  /// but updated realtime according to how many such links exist in the model tree
  /// any fully functinal model can be created fully independently and never placed in a tree
  /// as designed - independently even if it has a parent model.
  /// however:
  /// one model can be in one and only right place of a tree but a model can be linked by many link models:
  /// by right place means a widget model has or doesn't have a parent model (f.e. parent_id property)
  /// so this and other possible stuff like (contact_owner_id ?) must agree when model is placed into a model tree
  /// but a model can find itself in other places indirectly especially,
  /// f.e. there is a model that is a link model to another model and the latter model may be placed in
  /// some variable of the first "link" model for rendering purposes.
  /// and the latter model is fully functional and independent with it's own children and ancestor
  /// see the description in some extending class a_parent_id property which is not exactly the same in function like [parent_id]/[a_parent_id]. parent_id is when a model of the same type is low in hierarchy in a model tree like a contact belongs to contact group or you give an answer to a message - it is submessage, but the [_parentModel] property may be f.e a contact [ConditionModelContact] model belonging to a _parentModel [ConditionModelUser] model and the user model has its child contact in its [children]/[_children] property
  /// Update: not to get confused: parent    Some validation difficult to say bat when parent_id is set _parentModel should be present so that the current model's widget could be immediately placed into the tree. Models must not intependent on their parents, ancestors or children to be easily moved in the model tree. not final because you can move this model to another place in the model tree and by this change the immediate parent. You need the property to traverse up the tree to find some ancestor models (like in javascript DOM level 2 parentNode property) seek searching methods - All normal models along with ConditionModelUser have the property, except for the top ConditionModelApp
  think over/work out // with children property - on adding a child model a property a _parentModel (maybe @protected) would be set/changed and _children + @protected or public (yeah maybe public) children setter and getter would be put in place
  /// To simplify when a model is not [ConditionModelApp] then it's _parentModel is null, the model 
  /// is not in the model tree, it is kind of standalone and independent
  /// INFO: The related [_parentLinkModels] property was moved into a model class that handles link property
  Some informative [ConditionModel] some extending class's [_children] property's description
    /// To understand the model tree architecture [ConditionModel] class's _parentModel property's description and found in some extending class a property called [_parentLinkModels] description - not without a reason you always check if you can do somehting using related method or getter first, because any adding or removing of an element may involve additional stuff like sending a notification by adding an event to a certain [Stream] object or something else!. it is worth to see Read it all: You do not add or remove anything using this property - use @protected children addChild removeChild getters and setters which are used to adding/removing things internally, especially when you add a child model to a parent model, the parent model sets up the [_parentModel] value. Such things need to be protected from chanding like model._parentNode = othermodel like assignement - read parentMode and related descriptions.

  //   



In short not entirely knowing what it finally the app/library can be. Let's imagine it could be mutltipurpose: messenger, task manager, fitness app. It could be for some data channels like: a model of one user "communicate" with the same or another user that belongs to a contact or contact group, while in a messenger app you know how you add users, contact/contact groups manually, so in this case you can have fixed users, contacts/contact groups and an app that is not an messenger app but something completely else. You change a property of some fixed model  of a certain id (model.description = 'company stock = 1.50%'), and another app reads it. That\'s the idea. You might be only limited by your imagination how to use the still-work-in-progress library.

Welcome to a messy, draft documentation, not-consistent, reflecting changing decisions during the development process. This is still early work-in-progress.
All however unimaginable it may seem this app/library/whatever is going to work on all platforms, so f.e. a replacement of a http server in the browser might be implemented also for web. The only way you can possibly run is on windows platform flutter run -d windows --debug -a debugging however a web might also be able to start (tested maybe one or two month ago and many things changed since then and the web doesn't catch up in a week or two it may change)
BTW: Why these letter below are so big?
https://www.bam.tech/article/how-to-create-a-custom-lint-in-flutter-with-custom-lints
To understand private class:
https://stackoverflow.com/questions/53495089/dart-should-the-instance-variables-be-private-or-public-in-a-private-class
TO DO: NOW FOCUSING ON:
CREATE, UPDATE AND THE REST ON GLOBAL SERVER
======
Snap aspec


=====
For now :
It is basically assumed that local server works in all circumstances and on update failed a model itself tries to reupdate itself in the db. but:
But: For Global server only: Focus on create and update only:
FOCUS ON MODEL ONE TIME GLOBAL CREATE/UPDATE, THEN CYCLICAL STUFF, AS BOTH DESCRIBED BELOW
1. A model after being sent locally to db fully with id returned, etc. or model updated.
2. It just sends itself to global db. You get server_id probably server creation/ update date. Maybe anything else.
    You make sure to_be_synchronized is set to false
3. !!! But On fail async exception/or future.catchError, etc. property to_be_synchronized stays 1 (corresponding to true).
4. Now we have to check on any failed synchronization attempt. 
    a: If one occured we set a "flag" on global driver = true and start an almost immediate
        one time! Timer (maybe something recursive) that checks the db for to_be_synchronized = 1 rows 
        - (after a month you want to check the server value first). 
    b: And then you make the map of model names or something and id to be synchronized
        in the meantime and you update just the list - in the meantime a model may try to synchronize like in 1. 2. points 
        you don't care 
        BUT: this time you cannot create new to_be_synchronized = 1 list read further
    c: You set flag = 0 - only a new problem can fire the flag to true, which you check at the end of the cycle.
    d: You try to synchronize - because of possible problems after we but experenced one - we check one model at a time 
        Remembering that we use the same table for global server and local server and that each server is both local and global
        technically:
        - before we start one thing to mention not create/update when you have two applications one app_id must be used for update
          the second has link on it's device - not a copy, when you edit on one -
            the second must check for changes cyclically:
               : but when you changed something in you app the change is sent to the global server without prior checking for
                 changes, why? Because you may sent an emergency message - cyclical checking for changes should normally
                 do the job - we speak about updating not synchronizing using creating a record in the db
               : later to do: some other users could have rights to edit some tasks or messages, they too edit the same record
                but, but have link to it on their list.
        - you read all the record from the db (later To do: or later you contact the model if it still exists in the app - you update 1 changed field for example, if not exist you read the field from the db) 
        - you sent the the record to the global server "as is" not nowing which fields were changed
        - the global server must recreate model to validate the data, being careful and rethinking the process we 
          use also local_id which is the same as id on the local server - see the field description
        - based on field properties like "app_only" "both_app_and_server_synchronized" global server should decide what to put 
          to the db record
        - having update the server don't throw error optionally we have server_one_time_insertion_key on create and create/update dates to confirm the data is synchronized


========================================================================================



See if @protected set id_protected(int? value) of [ConditionModelIdAndOneTimeInsertionKeyModel] throws an error, as it is exptected to, on an assignement attempt. Also anywhere else.

Important! Is List always passed by reference [ConditionDataManagementDriverQueryBuilderPartWhereClause] in preparing possible long sql statements from Lists might cause existing up to two long Lists. I treat it as reference to the same object in a function

Found also official wasm file and js api https://www.sqlite.org/download.html but it uses localstorage, so not usable. But there are libraries you
have to have for android, windows, linux, mac, android - i use 64-bit library for windows for now.
Ugly important - For all data operations on db one universal sql syntax must to be used so it means object of [ConditionDataManagementDriver] class are to use it. Then after the app and libraries are well established some optimization classess can be made but with not changing the original ones. Those optimised classess can f.e. extend like ...Sqlite3Optimised or whatever. All the stuff is here to be multiplatform, multi db engines, multi server techniques like dart, php. 
under the hood everywhere sql is used to store data. Probably, for every future
db driver in the app, including based on mysql, postgres, etc. Sqlite and probably approximately sql92 syntax will be used. Bear especially in mind that you cannot (you probably could, but it is strongly discouraged for availability) use queries incompatible with
sqlite/websql and similar sqlite approaches like duckDB (implementation planned), but also with sqlweb github library (based on isstore (github) engine that in turn uses indexedDB storage). However some of the sqlite syntax is translated to sqlweb when it is used instead of websql that can be turned off in the not long future (translated is: insert, create database). Many queries in sqlweb library seem to be compatible with standard sql and sqlite in general. If possible use php adminer script to export database into sql, and in turn in js all queries are translated to sqlweb sql dialect. You can't use (at the moment of writing) column names in any kind of quotes (which may change in the future).
huge imact on sqlite performance (transactions) i don't predict to implement transactions any time soon, but i will have to: https://stackoverflow.com/questions/1711631/improve-insert-per-second-performance-of-sqlite?rq=1
----------------------------

How to run or build not with main.dart, but any other file.dart:
https://stackoverflow.com/questions/55510244/flutter-how-do-i-change-main-dartentry-point-to-some-other-page-in-flutter
flutter run -t lib/my_other_main.dart
flutter build apk -t lib/config/main_production.dart

Simplified all architecture - update. For web and native (f.e. windows, android) you do everything connecting to a local http server - it is you database (for web this server is emulated and works exactly the same way like in native). Your local server consists of two aspects: local server (bluetooth, local wifi with ip 192.168, etc) and global - when client devices connect to your global i.p. if you have any. ###!!! YOU NEED TO UNDERSTAND ABOVE AND BELOW AND DO ONLY THE GLOBAL ASPECT, PREPARING AND NOT DAMAGING THE CONNECTION TO A SECOND DEVICE WITH IT'S OWN SERVER - ANALYZE ALL WRITTEN HERE - NOT A SIMPLE THING### So starting from the top the architecture with data look like this: you local server automatically has a unique key you get from the earthwide global server and this key is related to id of your application on the global server. Any user registered in you local server belongs to this global app id. Your app (See [ConditionModelUser] class) registers user or more users, a connected device registers his user on your local server (the mentioned unique key with no password or in case someone reinstalled his application and lost the key there is additional option of using only locally non-email or non-phone login and with password. After login the key is retrieved and all communication is however based on the key). All your local server is sent or synchronised to the global server - all with this app id in mind - send as is. So if you install or reinstall the app you have many new app ids for each installation. So if a connected device to me try to sent me a message locally but disconnected before he was able to do it? Based on the unique key he connected - you have the key and he has the key - which is stored on global server and using this key on the global server can find his (and he yours) user id and send you messages globally via internet when you lost your local connection. But if you are on different continents and he reinstalled his app - he lost his key and cannot write to you. And it is ok, because those things is to protect your privacy when you are connected locally. However one day an option will be addedd - "store my key using this or these user accounts" - because each app and in effect local server can store more your users, not mentioning lobal and globally connected users. You will be able to see the keys with maybe some descriptions and restore the local user. But it is for a more distant future. We said about the global earthwide server with fixed ip or domain. However remember that technically your app that as you know has its local server is also a global server (this second aspect of your server). So if your settings or firewall allows it then any user on the earth can set up non-default global server which can be your smartphone/device and register using this time only e-mail or phonenumber which will be verified and password. So it is different to login locally using the key or in order to retrieve the lost key using local (!) non-email login/phone number and password - all was already said so it is repeated for making it clear.  
So to send a text message to any user on the global server (the second aspect of any server) you always need your app key got from the server so that the server finds the app id and your user id (you don't now it server knows it from global email/phone +password and session) on the server you need to send to a destination user contact id or group id. And (it techically maybe done a little differently - this is just to understand) when you receive the answer to the message the global server on it's part based on the contact settings searches all app ids of the user you got the anwer from (he reinstalled app many times as you know or uses on many defices the same user - so many app ids) it (the server) searches using e-mail and/or phone number - it checks if there is any new message and you fetch one or more if there is any based on timestamps and last update timestamp. Not going into more detail now, because there maybe some stuff to take into account. But this is going to be the overall architecture. 
WARNING, WHEN YOU LOCALLY CONNECT TO A DEVICE THREE SERVERS, NOT TWO WOULD NORMALLY BE INVOLVED, BECAUSE YOU CONNECT TO A DEVICE LIKE TO A GLOBAL SERVER. THINK HOW TO SOLVE IT - PROBABLY YOU HAVE TO USE THEM THREE. FOR TWO SERVERS YOU STORE A MESSAGE THING ON YOUR LOCAL SERVER THEN SEND IT TO THE GLOBAL. FOR THREE YOU STORE ON YOUR LOCAL SERVER SERVER USING THE USER KEY (AS IN ANY CASE) THEN LET'S SAY YOU SEND IT TO THE SECOND DEVICE AND THAT SECOND DEVICE UPDATES IT ON THE GLOBAL SERVER BUT NOT YOUR FIRST DEVICE. THEN IF YOU REINSTALL THE APP AND YOU ARE NOT CONNECTED TO THE SECOND DEVICE YOU FETCH ALL THE DATA FROM THE GLOBAL SERVER BASED ON YOUR KEY, BUT IF YOU ALSO OR ONLY CONNECT FINALLY TO THE SECOND DEVICE YOU ALSO FETCH ALL THE OLD AND NEW DATA FROM THE SECOND DEVICES SERVER. MESSAGES WOULD NEED TO BE MERGED BASED ON UNIQUE MESSAGE KEY WHICH IS LOCAL SERVER CREATED DATE TIMESTAMP (creation_date_timestamp IF NOT MILISECONDS, AT LEAST LESS LIKE MICROSECONDS IF COMPATIBLE WITH ALL PROGRAMMING LANGUAGES ESPECIALLY PHP, JS, DART), BECAUSE NO TWO MESSAGES CAN'T BE CREATED AT THE SAME TIME - YOUR HAVE TO FORCE THAT. BECAUSE YOU HAVE creation_date_timestamp ON YOUR LOCAL SERVER THEN THE SECOND DEVICE HAS TO HAVE THE SAME DATE AND VICE VERSA IF HE SENDS MESSAGE TO YOU LOCALLY YOU TAKE HIS creation_date_timestamp. THEN BY THIS WHEN YOU UPDATE DATA FROM BOTH OR ONE OF THE SERVERS YOU FIND DUPLICATES BY THE AUTHOR'S creation_date_timestamp LOCAL TIMESTAMP. IF TIMESTAM SEEMS NOT TO WORK PROPERLY APP SHOULD REFUSE USING TWO DEVICES CONNECTION, BUT GLOBAL CAN. AND IN THE MEANTIME A MESSAGE MIGHT HAVE CHANGED/BEEN EDITED SO YOU HAVE TO FINALLY COMPARE MESSAGE FROM THE GLOBAL SERVER AND THE SECOND DEVICE PLUS EDITING. BUT BUT! YOU AS I GUESS TAKE INTO ACCOUNT ONLY THE MESSAGE VERSION FROM THE DEVICE BECAUSE IT IS ALWAYS THE NEWEST VERSION. SO FOR USER USING KEY FOR CONNECTION TO LOCAL DEVICE YOU HAVE TO FETCH DATA FROM TWO SOURCES FIRST FROM THE SECOND DEVICE LOCAL SERVER AND SECOND THE GLOBAL - BOTH CONNECTIONS CAN BE UNSTABLE SO YOU NEED TO BE FLEXIBLE AND DO SOME MORE SOPHISTICATED MERGING. THIS IS DEFAULT OPTION - OFCOURSE YOUR AND/OR SECOND DEVICE HAS RIGHT NOT TO UPDATE ANYTHING ON THE GLOBAL SERVER - YOU THEN WON'T GET ANYTHING FROM IT AS REGARD TO A KEY BASED LOCAL USER (ESPECIALLY)

May be not up-to-date this paragraph.
For server packages shelf and sqlite3/"github sqlweb for web/js" (sqlite only) should be completely enough. Much later mysql (with php in mind). With this approach i can write the same code for server/backend and web probably, and then cleanup web from sqlite sqlite3/sqlweb and shelf. Also thanks to sqlite this app is going to be client of a global server, but it will use the same server to serve localy devices/smartphones connected to your smartphone via wi-fi local network (192.x.y.z, etc.) for example. 

==================================================
How to synchronize local server data with the global server. 
We have to use login (to register/login) by e-mail, phone-number, but also a key we are talking about below. You can login by key only for a local server, but the servers are the same
For now focus on one currently logged and front-screen active user of any device. 
There maybe many users on one device/app installations. But one active now.

0. Your local server works the same as the global one, someone may register normally, 
    but below WE FOCUS ON A TWO DEVICES CONNECTED TO YOUR SERVER BY YOUR PHONE ROUTER OR BY F.E. BLUETOOTH, YOU HAVE TO DETECT THAT SOMEONE CONNECTED TO YOU HAS YOUR LOCAL IP 192.... AND NOT GLOBAL IP NOR DIDN'T WENT FROM OUTSIDE I HE ARRIVED FROM OUTSIDE YOUR LOCAL SERVER HE/SHE CAN REGISTER NORMALLY - ALL YET TO BE PRECISELY FIGURED OUT - YOU WOLD LIKE TO HAVE CONTROL ABOUT OUTSIDE INFLUX, ESPECIALLY BY A SWITCH FOR THE SERVER IN THE FRONTENT-APP VERSION. WEB IS TO WORK THE SAME AS NATIVE APPS IN THIS THAT IT USES AS NATIVE ALSO CAN A FULL-FEATURED COMPATIBLE EMULATION OF THE LOCAL SERVER - AT SOME POINT IN TIME THERE CAN BE SITUATIONS LIKE COMMUNICATION BETWEEN TABS OF THE SAME BROWSER OR ANYTHING ELSE I HAVEN'T THOUGHT OF YET.

1. We went offline, app just has been installed. Local application server just started - it is to work fully like default global but it's local.
2. We are registered globally but the app yet doesn't know of it. We are offline.
3. So we create a user on login and password like for global.
4. New user created. We are waiting to go online.

5. An outside device different person/user connects to our device. That second user request to login. Introduces himself name, surname.
6. We cannot confirm the global identity of the user - he/she may also be offline/unregistered on global server whatever. We are still offline.
7. For now the second user creates unique big safe random key and stores it. The key is permanently attached to the user.
8. You allow him in and register the user on your local server using the key. 
9. However your contact list "don't know" yet about this user so for now also the user is also added to your contact list automatically. If it is removed from you contact list he as the rest of all your local server users however stay for now and should be managed separately. Why - because your app with local server may fulfill the same function as global server so it may be important to remove users carefully. Sometimes information users store can be vital.

10. You and the second user went online and logged in or registered you users using the login and password used when you were offline or one of you used different login and password. Finally you both are logged in globally not necessary at the same time.
11. The user sends to the global server the key that is used by him and you on your local server (to a table with one or more keys attached to a given user_id)
12. Now we have to be careful. You just get the server user_id and you cannot loose it, the user_id based on the key which is enough, but later the ever more fancier version of the app probably have to ask for email, login, or both, it seems however that he/she can decline the request.

13. Having this we can focus on sending the data to the server but it is still tricky - the user may yet have not sent our well-known key to the server
-- let's rest a bit.

=================================================

Technical to do: 
i've panicked a little, but maybe it is not that difficult, i "panicked" again when you have one user on two or more devices both went offline for couple of days and are quite different in many aspects - YOU AS USER OF THE APP EXPECT ALL THE MESS WILL BE SORTED OUT SOMEHOW, RIGHT?:
To simplify you installed your app logged and you are a user with long history of f.e. contacts, groups, chats, but also tasks, etc - let's focus on less not to get confused:
1. You load your contacts/messages data from the server.
2. You went offline for whatever time hour, day, week, month, even three months - you have job online in a rainforest in central america with no access to the internet but you have your solar usb powerbank.
3. You do some offline changes.
For now: You cannot update anything FROM the server, first you have to send your changes to the server with timestamp you last was online and server must know it (statistically more reliable way later - time on the phone must be properly synchronized - this later). For now the date on the server is more important, and easier. PROBABLY THE LAST TIMESTAMP IS ABOUT LAST TIME DATA WAS FULLY SYNCHRONIZED - SO IF YOU SEND CHANGES FROM 1 WIDGET OR 10 IN CHUNKS ALL NEED HAVE THE SAME LAST TIMESTAMP DATA. ONLY AFTER YOU SENT/SYNCHRONIZED !!ALL!! YOU CAN UPDATE THE TIME STAMP THE APP MUST INFORM SYNCHRONIZATION FINISHED AND SERVER CHANGES THE TIMESTAMP TO A NEWER. IN THE MEANTIME YOU HAD A SLOW INTERNET CONNECTION AND MADE SOME CHANGES YOU CANNOT SEND THEM FOR NOW, NOW IS TIME TO UPDATE DATA FROM THE  
Older explanation, overal Better solution:
I HAVE NOW AN IDEA YOU UPDATE YOUR LAST ONLINE TIMESTAMP FROM THE SERVER, AND ALL NEW MESSAGES, CONTACTS IN THE TIME OFFLINE GET THE OLD TIMESTAMP. !!! THIS TIME SERVER KNOWS, FOR THIS YOU MUST
USE UNIQUE ID OF THE APP SOME RANDOM UGLY NUMBER - IT MAYBE QUITE SIMPLE TO DO !!! I THINK THE EASIEST WAY TO DO IT WHEN YOU GO OFFLINE IS F.E. ALL MESSAGES, NEW CONTACTS, WIDGET MOVEMENTS GET LASTSEEN/LASTCONTACTTOTHESERVER TIMESTAMP COMING FROM THE SERVER. SO WIDGET CAN BE UPDATED ON THE SERVER IN THIS WAY I HAVE THE TIMESTAMP FROM ONE HOUR AGO - ALL MY NEW WIDGETS GET THIS DATE, BUT IF SOMETHING WAS REMOVED, MOVED HALF AN HOUR ON THE SERVER BY THE OTHER INSTANCE OF THE APP, BY THE SAME USER (NOT ONLY IN CONTACT GROUPS) THE SECOND APP GET PRIORITY, AND AS I WRITE IT LATER IT CAN BE MOVED TO THE ARCHIVE IN THE APP NOT ON THE SERVER PROBABLY AND OR MARKED AS REMOVED IN THE APP IN THE PLACE IT WAS ORIGINALLY - MAYBE not because TOO CONFUSING
4. Now you get the uptodate tree of ids of models/widgets from the server but ids with the timestamps i think, and the tree is the main thing now with which the rest is to be compared with, it is final i think. And you could build a new tree of models based on that tree of ids from the server and you have to decide which widget from the server is up-to-date - you need to compare a widget last update on the server timestamp (the same maing group update timestamp from the previous point) with the timestamp assigned to the mentioned id. If the timestamp received from the server is newer - another instance of the app with the same user, o possibly another user from the contact group changed the widget after you and it must be updated. By the way if it is a browser the tree of ids from the server should go to localStorage. After reload you get the up-to-date data from the server anyway. It can be a little more difficult, but it seems to be close to be solved.
5. The 4. point is more important, you analyse how it relates to it. If element was removed (not the same as moved) in the meantime on the server by another instance of the same user on other device you mark it as removed in the app but you don't remove it from the app you inform it's been removed and alow for sending to archive/trash in the app (i know it is the same user), additionaly you alow to do it massively all such items. You do overall warning - data no longer available it may be lost.
6. The 4. point is more important, you analyse how it relates to it. If element was moved not removed by the second instance of the app you seek
First you always update your changes on the server g

Each coding start repeating this (if i am correct). Both methods then and catchError of [Future] object .object.then produces another and brand new (second) future object. When you in then pass the callback and the callback return some value, the second future is finished with that value, you have then(() {return firstvalue}).then((firstvalue) {whatever}) - alright for now? The point: So based on the aforementioned i assume that then(() {return firstvalue}).catchError().catchError().then((firstvalue) {whatever}) - it works this way if NO error occured and knowing that each method produces a new [Future] first then copletes the second Future it produced, next catchError internally/invisibly completes the third Future with the mentioned "return firstvalue", next catchError the fourth Future also with the same "return firstvalue", and our second then() is completed with the firstvalue .then((firstvalue) {whatever}). So catchError must be constructed that it conveys the firstvalue of the first then passing finally to the sedon then. Again it is only done by completing Futures they created one by one. So in total we have probably 5 Futures but 4 Futures completed in total until we invoke our part "(firstvalue) {whatever}". I think it cannot work any other way.

Condition is (going to be) a messenger with audio and video (+ conference), a task manager, a fittness app, an some feateres more.

Replace Hive or shared_preferences with your own simple (simple !) key-value solution based on files and localstorage for web - strings only, not maps, integers - right? - ConditionModel models are to do the rest with types and even sofisticated pseudo types.

This for now is going to be optimised for a max middle size number of user in one backend server.
It could be like 10000 users without video and like 200 users for video one conference on the server.
To achieve greater numbers, being rather designed for a standalone powerful server with 2 to 5 Gbits bandwdth gigabits you could achieve up to 1000 video users in pretty good video quality or 2000 in a worse but about 10000 in barely enough quality

This app is done with all platforms in mind, even old handsets, on all desktops, android, ios, BUT finally also on dart commandline (+ nodejs after dartjs), when one dart <command> invokation gives you sending a message, contact list etc. For this you need f.e. Hive plugin not shared_preferences. On web using url should enable you getting a widget, put some data send message if you are logged, etc. Also url should enable you reading data from a frame, f.e a message, that appeared after changing url in the frame. So all-flexible solution.


[To do]
Now i think the app/frontend data architecture would be like this on all platforms to make one code for all but from web perspective and you implement the equivalent for all:
1. You load all data (tree of widgets) from json which is in a div. THIS WILL BE IN MEMORY SO ONLY LIMITED NUMBER OF WIDGETS WILL BE IN THE DIV AND THERE WILL BE A MANAGER FOR THAT - LATER ON THE REST OF THE WIDTETS. If possible a page should be reloaded from cache. Also you could save the page offline and open it in a browser and see it's working - i know it can be done if data is in div. At this point LocalStorage isn't used.

2. LocalStorage (important: much is described also for [ConditionModelId] class description). After loading the app changes are made offline adding to the stack of changes in LocalStorage. How? At the beginning you have the standard tree of models and another tree which fully mirrors the original one in a way that it contains empty widget models and also containing changed normal widget models. So if you have [ConditionModelMessage] model, if it wasn't updated, in the second tree it will have just widget id, so in case of widgets were sorted you have in LocalStorage only simple updated json encoded widget numbers. But if in such an id you stumble upon [ConditionModelMessage] json fully serialized widget it means a widget was added or changed. 
So what do you have to do - you have LocalStorage updated shortened/simplified but full actual/updated tree of just ids models [ConditionModelId] or typical models class like [ConditionModelMessage]. you traverse the tree looking a widget (id) in the original full tree of models and link the actual model with the model found there. Now we have the updated full tree of models which we can render. Being offline If a widget is updated or added we immediatelly update the second tree in the LocalStorage, then try synchronising it also on the server. The server will send full json of the first main tree on full reload to the div from point "1.". But only after full synchronization a full reload can clean up the LocalStorage from changes. This doesn't take into account conflicts caused by different instances of the app (newest update is more important).
3. Let say we are offline all the time after the first app loading. We refresh the page. We get widget tree (model tree) from that div in point "1." . Then we restore all the changes sequently one by one from the localStorage ad they were done, adding new models or updating the existing models. In the model Tree. (much is described also for [ConditionModelId] class description)
4. We get online. We update synchroinize the data on the server in one request in a way that no update/add operation on the server can fail - which seems that to be easier for now to send all the changed models of the changed widgets, and add new widgets. After ALL is fully synchronized, we cannot remove anything from LocalStorage only after all the page is sent from the server with full json in the div from point "1.". So for now it seems that a page should be reloaded automatically in a moment of inactivity (but when LocalStorage gets close to be full) i a way that a possibly edited current widget is saved in the current state. A user should be informed that in order for application to work properly we need to reload but the edited widget itself should be yet stored. Such thing shouldn't happen when you don't store images in LocalStorage - only teksts and textual configuration.

At the BEGINNING all platform work the same but:
For web you FINALLY need to take data from div when the page is loaded and try to cashe webpages with this div placed in html. When a app/page is loaded from cashe it will use the data as a starting point instead of using LocalStorage, and then the empty LocalStorage could be used only for new data that possibly cannot be synchronizded because of lack of internet access, the data from localStorage would be restored after another load from cache - because we imagine scenario of loading page from cashe a couple of times until there is internet access. But for desktop, android you can store everything normally and don't care much for now.

The architecture is data Models (they are Maps at the same time (based on MapDelegate class)) handled in a tree can be json encoded. Each model has it's own coresponding widget in a property of the model, having all the tree model you can crete and render widgets going down the model tree one by one. So after login you first simply recreate all models tree then one by one create widgets reflecting the model tree. SO USER SHOULD BE AT THE TOP OF THE TREE AND OBVIOUSLY IT WOULDN'T HAVE ANY WIDGET ATTACHED TO ITSELF LIKE IN CASE OF THOSE WIDGET MODELS

Knowing this /// The important part of the tree starts with a Stateful widget [ConditionUser], this widget along with each relevant widget of the architecture has its model and basically represends part of a layout. Then you have (not done yet) about 10 tabs and coresponding classes which are layout by [ConditionUser], however i suppose they don't neccessaryli need any models attached to them they can be managed via [ConditionUser], then you have in each of the 10 tabs [ConditionDragTargetContainerWidget] widgets each coresponding tab f.e. any messenger message [ConditionMessage] widget (extending [ConditionDragTargetContainerWidget]) with a correponsing data model [ConditionModelMessage], the widget will be rendered in one of the 10 tabs in a tab it is meant to be. For this it is probably enough to have a [ConditionModelUser] model which is a [Map] easily converted to json, a map with additional features and a mentioned widget instance attached to the [ConditionModelUser] map. Simplifying then you have in the [ConditionModelUser] a list where each element of the list corresponds to a tab, and an example tab will have f.e [ConditionMessageModel] elements in the right order. Any [ConditionMessageModel] widget can have f.e. answers to a message so can have one or more [ConditionMessageModel] widgets in itself. If you got it so far, the benefit of such an architecture is. Because ol Model are map you can very easily serialise [toString] or [jsonEncode] first [ConditionModelUser] and it will give you full deep tree of the models with [ConditionMessageModel] messages and its submessages. So the top [ConditionUser] widget will take care of traversing through the tree of all the models and their corresponding widgets, will render them assigning to the corresponding tabs. This architecture seems to be the fastest. It would be easier to implement if each widget was kind of intependent from it's parent in terms of data and confituration. And as you guess you can have more than [ConditionUser] at the same time and copy or link our example [ConditionModelMessage] message not only withing the same tab or other tabs of the same user but even between currently logged users in the application. So when you update a property of the model f.e. model.title = 'title' a setter will do model['title']=
Knowing this /// The important part of the tree starts with a Stateful widget [ConditionUser], this widget along with each relevant widget of the architecture has its model and basically represends part of a layout. Then you have (not done yet) about 10 tabs and coresponding classes which are layout by [ConditionUser], however i suppose they don't neccessaryli need any models attached to them they can be managed via [ConditionUser], then you have in each of the 10 tabs [ConditionDragTargetContainerWidget] widgets each coresponding tab f.e. any messenger message [ConditionMessage] widget (extending [ConditionDragTargetContainerWidget]) with a correponsing data model [ConditionModelMessage], the widget will be rendered in one of the 10 tabs in a tab it is meant to be. For this it is probably enough to have a [ConditionModelUser] model which is a [Map] easily converted to json, a map with additional features and a mentioned widget instance attached to the [ConditionModelUser] map. Simplifying then you have in the [ConditionModelUser] a list where each element of the list corresponds to a tab, and an example tab will have f.e [ConditionMessageModel] elements in the right order. Any [ConditionMessageModel] widget can have f.e. answers to a message so can have one or more [ConditionMessageModel] widgets in itself. If you got it so far, the benefit of such an architecture is. Because ol Model are map you can very easily serialise [toString] or [jsonEncode] first [ConditionModelUser] and it will give you full deep tree of the models with [ConditionMessageModel] messages and its submessages. So the top [ConditionUser] widget will take care of traversing through the tree of all the models and their corresponding widgets, will render them assigning to the corresponding tabs. This architecture seems to be the fastest. It would be easier to implement if each widget was kind of intependent from it's parent in terms of data and confituration. And as you guess you can have more than [ConditionUser] at the same time and copy or link our example [ConditionModelMessage] message not only withing the same tab or other tabs of the same user but even between currently logged users in the application. So when you update a property of the model f.e. model.title = 'title' a setter will do model\['title'\]= title (from the param of the setter), but the models widget will be updated (setState()) with the new title and it's subwidgets down the tree will be traversed which according to what i know, they probably will not change because of the mere title change of their ancestor widget, so it won't be resources consuming.


For the web bigger overhead size is better than limitation in the amount of data that can be stored. So improving data compression methods or some custom encoding is ok.

To developers. During development have in mind of doing in javascript, not dart some improvements for web, especially Local storate data compression due to browser limitation of 5 MB stored data. As far as i remember someone said that changing encoding from 2 bytes to 1 byte would give you even 10 MB data - i don't know how because 5 MB is 5 MB. It looks like it should mean that 2 bytes encoding would give you 2,5 MB of test if you are not using one byte encoding.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
