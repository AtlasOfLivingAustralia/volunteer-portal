begin;
alter table project add column date_created timestamp;
alter table project add column last_updated timestamp;

update project set date_created = COALESCE(created, CURRENT_TIMESTAMP);
update project set last_updated = date_created;

alter table project alter column date_created set not null;
alter table project alter column last_updated set not null;
commit;