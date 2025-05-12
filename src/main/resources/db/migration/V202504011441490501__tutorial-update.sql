/*
    Author: Chris Dunstall

    - New table for Tutorials
*/

CREATE TABLE IF NOT EXISTS tutorial (
    id bigint PRIMARY KEY,
    version bigint NOT NULL,
    date_created TIMESTAMP,
    last_updated TIMESTAMP,
    filename varchar(255) NOT NULL,
    tutorial_name varchar(130) NOT NULL,
    description varchar(255),
    is_active boolean NOT NULL,
    institution_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    constraint tutorial_institution_id_fk foreign key (institution_id) references institution (id)
);

COMMENT ON TABLE tutorial IS 'Record table for DigiVol Tutorials';
COMMENT ON COLUMN tutorial.id IS 'Unique ID (primary key) for report_queue';
COMMENT ON COLUMN tutorial.version IS 'Record version';
COMMENT ON COLUMN tutorial.date_created IS 'Datetime record was created';
COMMENT ON COLUMN tutorial.last_updated IS 'Datetime record was last updated';
COMMENT ON COLUMN tutorial.filename IS 'The filename of the tutorial';
COMMENT ON COLUMN tutorial.tutorial_name IS 'The name of the tutorial';
COMMENT ON COLUMN tutorial.description IS 'A short description for the tutorial';
COMMENT ON COLUMN tutorial.is_active IS 'Boolean flag to indicate whether the tutorial is active (true) or inactive (false)';
COMMENT ON COLUMN tutorial.institution_id IS 'Owner institution of the tutorial';
COMMENT ON COLUMN tutorial.created_by_id IS 'ID of the user who created the tutorial record';
COMMENT ON COLUMN tutorial.updated_by_id IS 'ID of the user who last updated the tutorial record';

create index if not exists tutorial_institution_id_idx on tutorial (institution_id);
create index if not exists tutorial_institution_id_is_active_idx on tutorial (institution_id, is_active, tutorial_name);

CREATE TABLE IF NOT EXISTS tutorial_projects (
    tutorial_id bigint NOT NULL,
    project_id bigint NOT NULL,
    primary key (tutorial_id, project_id),
    constraint tutorial_project_tutorial_id_fk foreign key (tutorial_id) references tutorial (id),
    constraint tutorial_project_project_id_fk foreign key (project_id) references project (id)
);

COMMENT ON TABLE tutorial_projects IS 'Relationship table between tutorial and project';
COMMENT ON COLUMN tutorial_projects.tutorial_id IS 'ID of the tutorial';
COMMENT ON COLUMN tutorial_projects.project_id IS 'ID of the project';