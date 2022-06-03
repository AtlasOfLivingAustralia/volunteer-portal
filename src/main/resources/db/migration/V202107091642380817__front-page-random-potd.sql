-- Random Project of the day
alter table front_page add column if not exists random_project_otd boolean NOT NULL default FALSE;
alter table front_page add column if not exists random_project_date_updated timestamp without time zone NULL;
alter table project add column if not exists potd_last_selected timestamp without time zone NULL;