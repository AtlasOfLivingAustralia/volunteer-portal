/*
Add as-idempotent-as-possible DDL statements here
See: http://www.jeremyjarrell.com/using-flyway-db-with-distributed-version-control/
*/

alter table template add column if NOT exists is_global boolean default false not null;
alter table template add column if NOT exists is_hidden boolean default false not null;
