/*
Add as-idempotent-as-possible DDL statements here
See: http://www.jeremyjarrell.com/using-flyway-db-with-distributed-version-control/
*/

ALTER TABLE project ALTER COLUMN harvestable_by_ala SET DEFAULT false;