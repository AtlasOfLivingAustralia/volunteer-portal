-- Institution application/approval
alter table institution add column if not exists is_approved boolean NOT NULL default FALSE;
alter table institution add column if not exists created_by_id bigint NULL;
alter table institution add column if not exists display_contact boolean NOT NULL default TRUE;	