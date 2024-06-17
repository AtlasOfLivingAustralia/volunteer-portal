/*
    Report generation request table
    By: Chris Dunstall
*/

CREATE TABLE if not exists report_request (
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    date_created TIMESTAMP NOT NULL default current_timestamp,
    request_user_id BIGINT NOT NULL,
    report_name TEXT NOT NULL,
    date_completed TIMESTAMP NULL,
    date_archived TIMESTAMP NULL,
    report_params JSONB NULL,
    primary key (id),
    constraint report_queue_id_fk foreign key (request_user_id) references vp_user (id)
);

COMMENT on TABLE  report_request is 'Request queue for report generation';
COMMENT ON COLUMN report_request.id IS 'Unique ID (primary key) for report_queue';
COMMENT ON COLUMN report_request.version IS 'Record version';
COMMENT ON COLUMN report_request.date_created IS 'Datetime record was created';
COMMENT ON COLUMN report_request.request_user_id IS 'User creating report queue record';
COMMENT ON COLUMN report_request.report_name IS 'Name of the report requested';
COMMENT ON COLUMN report_request.date_completed IS 'Datetime report request was completed';
COMMENT ON COLUMN report_request.date_archived IS 'Datetime report request was archived';
COMMENT ON COLUMN report_request.report_params IS 'Parameters for the requested report';

create index if not exists report_request_user_report_name_idx on report_request (request_user_id, report_name);
create index if not exists report_request_queue_idx on report_request using btree (date_created asc, date_completed);

