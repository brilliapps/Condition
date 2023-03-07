var users_counter = "4";
var currently_logged = "1,2";
var currently_active = 1;

/// Initially the class is to feed the app with data as if it has worked for a month for example and already has some registered users - at leas one, come contacts, messages, tasks, etc.
/// All variables show things from the perspective of one app instance
/// Debug data doesn"t have to be as memory efficient and quick as things in div and localstorage. Below debug variables should as closely as possible reflect what is going to be in the DIV or LocalStorage - ofcourse widgets should be in completely separate variables each, but the model tree structure can be always passed as is as it contains relatively little data even in worse case scenario
/// "core" in the variable means - the app has this at the start, but when app is offline "changes" in the name of the variable means changes that hasn"t been synchronized with the server. Especially in the web and elsewhere when the app is reloaded it gets complete data in the core variable and there is no changes in the localstorage. To clean localstorage you have to synchronize then reload the page with the app - it gets full data to special div - more in readme file
/// where possible for simplification some id can repeat - i just copied-pasted
/// first is user id in the tree ids in the app dont have to be in the right order because some users might have been removed.
/// !!! User id, first element is 'contacts' with it's tree structure
/// !!! then after "contacts" key is key being number (f.e. it was "3" at the moment of writing this description) - it is contact id, and to it is assigned json map/object
/// !!! then next element is "2" - it stands for Messages (for now numbers and corresponding types should be defined in ConditionModelApp), '3' - video or something, '4' - tasks, etc. Why not "1" in there one is for the mentioned "contacts" and for better readability i didn't choose to use a corresponding number. Apart from contacts themselves each widget belongs to a contact id
/// contacts are the way they are but messages, tasks, publications whatever: first number in the array means contact id and the rest works like contacts
/// "s" means settings with "c" - id_counter if c:50 then a new widget is to have id = 51
/// If you ever have two or more apps you can use the same data for each in debug mode - data of an app is stored with unique prefix
class ConditionDebugDataForDevelopmentAndTesting {
  /// See description for the property"s class + this variable contains easily traversable [Map]s of id"s with only "s" property containing settings with f.e. "c" - id_counter if c:50 then a new widget is to have id = 51. First keys in the variable tree  are user ids
  static const String widget_tree_ids = """
{ 
    "4": {
          "contacts":{
            "s": {
              "c": 50,
              "d": "SEE THIS DESCRIPTION, AFTER \\"contacts\\" THERE IS key with number f.e \\"3\\" - which means contact id and f.e. you know that \\"messages\\" belongs to this contact id"
              },
            "3": {},
            "5":{
              "4":{"20":{},"25":{},"17":{}}
            },
            "2":{
              "6":{}
            }
          }, 
          "3": {
                  "2":{
                    "s": {"c": 50},
                    "3":{},
                    "5":{
                      "4":{"20":{},"25":{},"17":{}}

                    },
                    "2":{
                      "6":{}
                    }
                  },
                  "3":{
                    "s": {"c": 50},
                    "3":{},
                    "5":{
                      "4":{"20":{},"25":{},"17":{}}
                    },
                    "2":{
                      "6":{}
                    }
                },
                "4":{
                    "3":{},
                    "5":{
                      "4":{"20":{},"25":{},"17":{}}

                    },
                    "2":{
                      "6":{}
                    }
                },
                "5":{
                    "s": {"c": 50},
                    "3":{},
                    "5":{
                      "4":{"20":{},"25":{},"17":{}}
                    },
                    "2":{
                      "6":{}
                    }
                },
                "6":{
                    "s": {"c": 50},
                    "3":{},
                    "5":{
                      "4":{"20":{},"25":{},"17":{}}
                    },
                    "2":{
                      "6":{}
                    }
                },
                "7":{
                    "s": {"c": 50},
                    "3":{},
                    "5":{
                      "4":{"20":{},"25":{},"17":{}}
                    },
                    "2":{
                      "6":{}
                    }
                }
        },
    "2": {
          "contacts":{
            "s": {"c": 50},
            "3":{},
            "5":{
              "4":{"20":{},"25":{},"17":{}}
            },
            "2":{
              "6":{}
            }
          },
          "3": {
                  "2":{
                    "s": {"c": 50},
                    "3":{},
                    "5":{
                      "4":{"20":{},"25":{},"17":{}}
                    },
                    "2":{
                      "6":{}
                    }
                  }
          }          


    }


  }

}
""";

  /// Remember that construction of a debug variable if not written wrong it might has been be done in a educational for a reader way - don"t necessary remove some error data like a self describing wrong key "server_contact_id____cannot_be_used_for_contacts_or_groupd_becuse_message_or_tasks_belong_to_a_contact", this contains all widget model reflection with each widget configuration that are in widget_tree_ids variable. Notice however there are only variables needed for a model. F.e. there is no need to add user_id, id or parent_id property because you can detect them from widget_tree_ids variable or a similar way, and in the LocalStorage also you will have variables like someting like "appprefixu2c5t1w4" - you have user 2, contact id (each widget first belongs to a contact id), type 1 (contact list), widget id 4. To make development easier all development initil data is improved as necessary - it may be just copied-pasted and slightly modified as necessary
  /// Variables described prefixu4t1c5w3 - notice that t1 doesn't need contact id f.e. "c4" after that because t1 - contacts doesn't belong to a contct id like messages, tasks, etc.
  static const Map<String, String> widgets_configs = {
    'u4t1w3': """{
            "parent_id": null,
          "server_id":27,
          "server_contact_id____cannot_be_used_for_contacts_or_groupd_becuse_message_or_tasks_belong_to_a_contact" : null,
          "server_parent_id" : 12,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}
        }""",
    'u4t1w5': """{
            "parent_id": null,
          "server_id":null,
          "server_contact_id____cannot_be_used_for_contacts_or_groupd_becuse_message_or_tasks_belong_to_a_contact" : null,
          "server_parent_id" : null,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 5 title",
          "description":"widget id 5 description",
          "configuration": {}
        }""",
    'u4t1w4': """{
            "parent_id": null,
          "server_id":12,
          "server_contact_id____cannot_be_used_for_contacts_or_groupd_becuse_message_or_tasks_belong_to_a_contact" : null,
          "server_parent_id" : 65,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 4 title",
          "description":"widget id 4 description",
          "configuration": {}
        }""",
    'u4t1w20': """{
            "parent_id": null,
          "server_id":3,
          "server_contact_id____cannot_be_used_for_contacts_or_groupd_becuse_message_or_tasks_belong_to_a_contact" : null,
          "server_parent_id" : 11,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}
        }""",
    'u4t1w25': """{
            "parent_id": null,
          "server_id":23,
          "server_contact_id____cannot_be_used_for_contacts_or_groupd_becuse_message_or_tasks_belong_to_a_contact" : null,
          "server_parent_id" : 22,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}
        }""",
    'u4t1w17': """{
            "parent_id": null,
          "server_id":null,
          "server_contact_id____cannot_be_used_for_contacts_or_groupd_becuse_message_or_tasks_belong_to_a_contact" : null,
          "server_parent_id" : null,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}
        }""",
    'u4t2c3w3': """{
            "parent_id": null,
          "server_id":27,
          "server_contact_id" : 22,
          "server_parent_id" : 12,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}
        }""",
    'u4t2c3w5': """{
            "parent_id": null,
          "server_id":null,
          "server_contact_id" : null,
          "server_parent_id" : null,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 5 title",
          "description":"widget id 5 description",
          "configuration": {}
        }""",
    'u4t2c3w20': """{
            "parent_id": null,
          "server_id":3,
          "server_contact_id" : 55,
          "server_parent_id" : 11,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}
        }""",
    'u4t2c3w25': """{
            "parent_id": null,
          "server_id":23,
          "server_contact_id" : 11,
          "server_parent_id" : 22,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}

        }""",
    'u4t2c3w17': """{
            "parent_id": null,
          "server_id":null,
          "server_contact_id" : null,
          "server_parent_id" : null,
            "creation_date_timestamp":123123,
            "server_creation_date_timestamp":123123,
            "update_date_timestamp":null,
            "server_update_date_timestamp":null,
            "link_type_id":null,
            "link_id":null,
            "server_link_id":null,
          "title":"widget id 3 title",
          "description":"widget id 3 description",
          "configuration": {}
        }""",
  };
}
