/*
    Author: Chris Dunstall

    Task Descriptor Error
        - This table is used to record errors associated with Task Descriptors. Each record will include the error
          message and stack trace, along with a reference to the associated Task Descriptor.
        - The date_updated column is added to the task_descriptor table to track when a Task Descriptor was last updated,
          which can be useful for monitoring and debugging purposes.
        - ID not having a default is intentional. There is no domain for this table, and only one place records can be
          created.
*/

CREATE TABLE IF NOT EXISTS task_descriptor_error (
    id bigint PRIMARY KEY,
    date_created TIMESTAMP NOT NULL default current_timestamp,
    task_descriptor_id bigint NOT NULL,
    error_message text NOT NULL,
    stack_trace text,
    constraint task_descriptor_error_task_descriptor_id_fk foreign key (task_descriptor_id) references task_descriptor (id)
);

COMMENT ON TABLE task_descriptor_error IS 'Record table for errors associated with Task Descriptors';
COMMENT ON COLUMN task_descriptor_error.id IS 'Unique ID (primary key) for task_descriptor_error';
COMMENT ON COLUMN task_descriptor_error.date_created IS 'Datetime record was created';
COMMENT ON COLUMN task_descriptor_error.task_descriptor_id IS 'ID of the associated Task Descriptor';
COMMENT ON COLUMN task_descriptor_error.error_message IS 'The error message associated with the Task Descriptor error';
COMMENT ON COLUMN task_descriptor_error.stack_trace IS 'The stack trace associated with the Task Descriptor error';

alter table task_descriptor
    add column if not exists date_updated TIMESTAMP null default current_timestamp;


update task_descriptor
    set date_updated = time_created;

comment on column task_descriptor.date_updated is 'Datetime record was last updated';
