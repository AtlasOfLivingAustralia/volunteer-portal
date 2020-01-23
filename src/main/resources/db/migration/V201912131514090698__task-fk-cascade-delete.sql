ALTER TABLE field
    DROP CONSTRAINT IF EXISTS "field_transcription_id",
    DROP CONSTRAINT IF EXISTS "fk5cea0facbab13a";

ALTER TABLE field
    ADD CONSTRAINT "field_transcription_id"
        FOREIGN KEY (transcription_id)
            REFERENCES transcription(id)
            ON DELETE CASCADE,
    ADD CONSTRAINT "fk5cea0facbab13a"
        FOREIGN KEY (task_id)
            REFERENCES task(id)
            ON DELETE CASCADE;


ALTER TABLE task_comment
    DROP CONSTRAINT IF EXISTS "fk61f475a5cbab13a";

ALTER TABLE task_comment
    ADD CONSTRAINT "fk61f475a5cbab13a"
        FOREIGN KEY (task_id)
            REFERENCES task(id)
            ON DELETE CASCADE;
