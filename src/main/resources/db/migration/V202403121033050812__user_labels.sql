/*
    Label and user changes
    By: Chris Dunstall
*/

create table if not exists label_category (
    id bigint not null,
    version bigint not null,
    name text not null,
    label_colour varchar default null,
    is_default boolean not null default false,
    updated_date timestamp not null default current_timestamp,
    created_by bigint not null default 0,
    primary key (id)
);
comment on column label_category.id is 'Unique ID (primary key) for label category';
comment on column label_category.version is 'Record version';
comment on column label_category.name is 'Name of the label category';
comment on column label_category.label_colour is 'Selected colour for the label category';
comment on column label_category.is_default is 'True if a system default category, false if not';
comment on column label_category.updated_date is 'Date record was last updated';
comment on column label_category.created_by is 'User who created record';

-- This record will be deleted after migration.
INSERT INTO label_category VALUES (0, 1, 'placeholder');

alter table label
    drop constraint label_value_category_key,
    drop constraint unique_category;

alter table label
    add column if not exists category_id bigint not null default 0
        constraint label_category_id_fk references label_category (id),
    add column if not exists is_default boolean not null default false,
    add column if not exists updated_date timestamp not null default current_timestamp,
    add column if not exists created_by bigint not null default 0
    ;
comment on column label.category_id is 'Foreign key to label_category';
comment on column label.is_default is 'True if label is system default label, false if not';
comment on column label.updated_date is 'Date record was last updated';
comment on column label.created_by is 'User who created record';

create table if not exists vp_user_labels (
  user_id bigint not null,
  label_id bigint not null,
  primary key (user_id, label_id),
  foreign key (user_id) references vp_user (id),
  foreign key (label_id) references label (id)
);
comment on column vp_user_labels.user_id is 'User for user label';
comment on column vp_user_labels.label_id is 'Label for user label';


/* Migrate old categories to new table */
DROP TABLE IF EXISTS category_temp;
CREATE TABLE category_temp (
    category TEXT
);

INSERT INTO category_temp (category)
    SELECT DISTINCT category FROM label;

INSERT INTO label_category (id, VERSION, name, created_by)
    SELECT NEXTVAL('hibernate_sequence'), 0, category, 0 FROM category_temp
    ON CONFLICT DO NOTHING;

DROP TABLE category_temp;

UPDATE label SET category_id = label_category.id
  FROM label_category
 WHERE label_category.name = label.category;

ALTER TABLE label ALTER COLUMN category DROP NOT NULL;

DELETE from label_category WHERE name = 'placeholder';