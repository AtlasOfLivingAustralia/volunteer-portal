ALTER TABLE task
    ALTER COLUMN viewed SET DEFAULT -1,
    ALTER COLUMN created SET DEFAULT current_timestamp,
    ALTER COLUMN date_last_updated SET DEFAULT current_timestamp;

ALTER TABLE field
    ALTER COLUMN created SET DEFAULT current_timestamp,
    ALTER COLUMN updated SET DEFAULT current_timestamp;

ALTER TABLE multimedia
    ALTER COLUMN created SET DEFAULT current_timestamp;