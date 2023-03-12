-- Adminer 4.8.1 SQLite 3 3.15.1 dump

DROP TABLE IF EXISTS "ConditionModelApp";
CREATE TABLE "ConditionModelApp" (
  "id" integer NOT NULL,
  "server_key" text NULL,
  "users_counter" integer NULL,
  "currently_active_user_id" integer NULL,
  "users_ids" text NULL,
  "currently_logged_users_ids" text NULL,
  PRIMARY KEY ("id")
);


DROP TABLE IF EXISTS "ConditionModelApps";
CREATE TABLE "ConditionModelApps" (
  "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  "key" text NOT NULL,
  "creation_date_timestamp" integer NOT NULL
, "one_time_insertion_key" integer NULL);

CREATE INDEX "ConditionModelApps_one_time_insertion_key" ON "ConditionModelApps" ("one_time_insertion_key");

CREATE INDEX "ConditionModelApps_key" ON "ConditionModelApps" ("key");


DROP TABLE IF EXISTS "ConditionModelClasses";
CREATE TABLE "ConditionModelClasses" (
  "id" integer NOT NULL,
  "name" text NOT NULL
);

INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (1,	'ConditionModelContact');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (2,	'ConditionModelMessage');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (3,	'ConditionModelVideoConference');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (4,	'ConditionModelTask');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (5,	'ConditionTripAndFitness');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (6,	'ConditionModelURLTicker');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (7,	'ConditionModelReadingRoom');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (8,	'ConditionModelWebPage');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (9,	'ConditionModelShop');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (10,	'ConditionModelProgramming');
INSERT INTO "ConditionModelClasses" ("id", "name") VALUES (11,	'ConditionModelPodcasting');

DROP TABLE IF EXISTS "ConditionModelUser";
CREATE TABLE "ConditionModelUser" (
  "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  "app_id" integer NULL,
  "local_id" integer NOT NULL,
  "to_be_synchronized" integer NOT NULL,
  "e_mail" text NULL,
  "phone_number" integer NULL,
  "server_id" integer NULL,
  "password" text NOT NULL,
  "local_server_login" text NULL,
  "local_server_key" integer NULL,
  "one_time_insertion_key" text NULL,
  "server_one_time_insertion_key" text NULL,
  "url_alias" text NULL,
  "creation_date_timestamp" integer NOT NULL,
  "server_creation_date_timestamp" integer NULL,
  "update_date_timestamp" integer NULL,
  "server_update_date_timestamp" integer NULL,
  "parent_id" integer NULL,
  "user_id" integer NOT NULL
);

CREATE INDEX "ConditionModelUser_local_id" ON "ConditionModelUser" ("local_id");

CREATE INDEX "ConditionModelUser_app_id" ON "ConditionModelUser" ("app_id");

CREATE INDEX "ConditionModelUser_to_be_synchronized" ON "ConditionModelUser" ("to_be_synchronized");

CREATE INDEX "ConditionModelUser_one_time_insertion_key" ON "ConditionModelUser" ("one_time_insertion_key");


DROP TABLE IF EXISTS "ConditionModelWidget";
CREATE TABLE "ConditionModelWidget" (
  "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  "app_id" integer NULL,
  "local_id" integer NULL,
  "to_be_synchronized" integer NOT NULL,
  "user_id" integer NOT NULL,
  "model_type_id" integer NOT NULL,
  "server_id" integer NULL,
  "parent_id" integer NULL,
  "server_parent_id" integer NULL,
  "url_alias" text NULL,
  "owner_contact_id" integer NULL,
  "server_owner_contact_id" integer NULL,
  "contact_user_id" integer NULL,
  "server_contact_user_id" integer NULL,
  "contact_accepted_invitation" integer NULL,
  "contact_e_mail" text NULL,
  "contact_phone_number" text NULL,
  "contact_local_server_login" text NULL,
  "contact_local_server_key" text NULL,
  "creation_date_timestamp" integer NOT NULL,
  "server_creation_date_timestamp" integer NULL,
  "update_date_timestamp" integer NULL,
  "server_update_date_timestamp" integer NULL,
  "link_type_id" integer NULL,
  "link_id" integer NULL,
  "server_link_id" integer NULL,
  "title" text NULL,
  "description" integer NULL,
  "configuration" text NULL,
  "one_time_insertion_key" text NULL,
  "server_one_time_insertion_key" text NULL
);

CREATE INDEX "ConditionModelWidget_local_id" ON "ConditionModelWidget" ("local_id");

CREATE INDEX "ConditionModelWidget_app_id" ON "ConditionModelWidget" ("app_id");

CREATE INDEX "ConditionModelWidget_to_be_synchronized" ON "ConditionModelWidget" ("to_be_synchronized");

CREATE INDEX "ConditionModelWidget_one_time_insertion_key" ON "ConditionModelWidget" ("one_time_insertion_key");


-- 