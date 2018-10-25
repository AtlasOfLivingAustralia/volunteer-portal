CREATE TABLE transcription (
     id bigint NOT NULL,
     version bigint NOT NULL,
     date_created timestamp without time zone,
     last_updated timestamp without time zone,
     task_id bigint NOT NULL,
     fully_transcribed_by character varying(255),
     fully_validated_by character varying(255),
     project_id bigint NOT NULL,
     viewed integer,
     is_valid boolean,
     date_fully_transcribed timestamp without time zone,
     date_fully_validated timestamp without time zone,
     date_last_updated timestamp without time zone,
    /* last_viewed bigint,
     last_viewed_by character varying(255), */
     fully_transcribed_ip_address character varying(255),
     transcribeduuid uuid,
     validateduuid uuid
);

ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_pkey PRIMARY KEY (id);

ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_task_id FOREIGN KEY (task_id) REFERENCES task(id);

INSERT INTO transcription (id, version, task_id, project_id, date_created, last_updated, fully_transcribed_by, fully_transcribed_ip_address, transcribeduuid)
SELECT id, 1, id, project_id, now(), now(), fully_transcribed_by, fully_transcribed_ip_address, transcribeduuid FROM task;
