/*
Add as-idempotent-as-possible DDL statements here
See: http://www.jeremyjarrell.com/using-flyway-db-with-distributed-version-control/
*/

ALTER TABLE user_role ADD COLUMN if NOT exists created_by_id bigint NULL;
ALTER TABLE user_role ADD COLUMN if NOT exists date_created timestamp without time zone NULL;
