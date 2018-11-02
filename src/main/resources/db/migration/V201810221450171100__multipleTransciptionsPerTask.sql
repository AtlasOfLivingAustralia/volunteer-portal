
CREATE TABLE transcription (
     id bigint NOT NULL,
     version bigint NOT NULL,
     date_created timestamp without time zone,
     date_last_updated timestamp without time zone,
     task_id bigint NOT NULL,
     fully_transcribed_by character varying(255),
     fully_validated_by character varying(255),
     project_id bigint NOT NULL,
 /*    viewed integer, */
     is_valid boolean,
     date_fully_transcribed timestamp without time zone,
     date_fully_validated timestamp without time zone,
      /* last_viewed bigint,
     last_viewed_by character varying(255), */
     fully_transcribed_ip_address character varying(255),
     transcribeduuid uuid,
     validateduuid uuid,
     time_to_transcribe bigint,
     time_to_validate bigint
);

ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_pkey PRIMARY KEY (id);

ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_task_id FOREIGN KEY (task_id) REFERENCES task(id);

ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_project_id FOREIGN KEY (project_id) REFERENCES project(id);    

INSERT INTO transcription (id, version, task_id, project_id, date_created, date_last_updated, 
                           fully_transcribed_by, date_fully_transcribed, fully_validated_by, date_fully_validated, 
                           fully_transcribed_ip_address, transcribeduuid, time_to_transcribe, time_to_validate)
SELECT id, 1, id, project_id, now(), date_last_updated, 
       fully_transcribed_by, date_fully_transcribed, fully_validated_by, date_fully_validated,
       fully_transcribed_ip_address, transcribeduuid, time_to_transcribe, time_to_validate 
FROM task
WHERE fully_transcribed_by is not null;

