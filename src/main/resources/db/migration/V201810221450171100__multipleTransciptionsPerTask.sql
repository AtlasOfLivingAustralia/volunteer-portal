
CREATE TABLE IF NOT EXISTS transcription (
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

ALTER TABLE ONLY transcription DROP CONSTRAINT IF EXISTS transcription_pkey;
ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_pkey PRIMARY KEY (id);

ALTER TABLE ONLY transcription DROP CONSTRAINT IF EXISTS transcription_task_id;
ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_task_id FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE CASCADE;

ALTER TABLE ONLY transcription DROP CONSTRAINT IF EXISTS transcription_project_id;
ALTER TABLE ONLY transcription
    ADD CONSTRAINT transcription_project_id FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE;

INSERT INTO transcription (id, version, task_id, project_id, date_created, date_last_updated,
                           fully_transcribed_by, date_fully_transcribed, fully_validated_by, date_fully_validated,
                           fully_transcribed_ip_address, transcribeduuid, time_to_transcribe, time_to_validate)
  (SELECT id, 1, id, project_id, now(), date_last_updated,
       fully_transcribed_by, date_fully_transcribed, fully_validated_by, date_fully_validated,
       fully_transcribed_ip_address, transcribeduuid, time_to_transcribe, time_to_validate
    FROM task
    WHERE fully_transcribed_by is not null)
ON CONFLICT ON CONSTRAINT transcription_pkey
DO NOTHING;


ALTER TABLE ONLY task
  ADD COLUMN IF NOT EXISTS transcription_count integer NOT NULL default 0;

ALTER TABLE ONLY field
  ADD COLUMN IF NOT EXISTS transcription_id bigint;

UPDATE field SET transcription_id = transcription.id
FROM transcription
WHERE transcription.task_id = field.task_id
AND transcription_id IS NULL;

ALTER TABLE ONLY field ALTER COLUMN transcription_id SET NOT NULL;

ALTER TABLE ONLY field DROP CONSTRAINT IF EXISTS field_transcription_id;
ALTER TABLE ONLY field
  ADD CONSTRAINT field_transcription_id FOREIGN KEY (transcription_id) REFERENCES transcription(id);


CREATE INDEX IF NOT EXISTS forum_message_topic ON FORUM_MESSAGE (topic_id);
CREATE INDEX IF NOT EXISTS forum_message_date ON FORUM_MESSAGE (date DESC);


CREATE INDEX IF NOT EXISTS forum_topic_project ON FORUM_TOPIC (project_id);
CREATE INDEX IF NOT EXISTS forum_topic_task ON FORUM_TOPIC (task_id);
CREATE INDEX IF NOT EXISTS forum_topic_project_task ON FORUM_TOPIC (project_id, task_id);


CREATE INDEX IF NOT EXISTS task_project ON task (project_id);

CREATE INDEX IF NOT EXISTS project_proj_type ON project (project_type_id);
CREATE INDEX IF NOT EXISTS project_institution ON project (institution_id);


CREATE INDEX IF NOT EXISTS transcription_project ON transcription (project_id);
CREATE INDEX IF NOT EXISTS transcription_task ON transcription (task_id);
CREATE INDEX IF NOT EXISTS transcription_task_project ON transcription (project_id, task_id);
CREATE INDEX IF NOT EXISTS transcription_project_transcribers_date ON transcription (project_id, fully_transcribed_by, date_fully_transcribed DESC);


CREATE OR REPLACE VIEW public.latest_transcribers AS 
 SELECT transcription.project_id,
    transcription.fully_transcribed_by,
    max(transcription.date_fully_transcribed) AS max_date
   FROM transcription,
    project
  WHERE transcription.project_id = project.id AND project.inactive = false
  GROUP BY transcription.project_id, transcription.fully_transcribed_by
  ORDER BY (max(transcription.date_fully_transcribed)) DESC;


CREATE OR REPLACE VIEW public.latest_transcribers_task AS 
 SELECT transcription.id,
    task.id AS task_id,
    task.created,
    task.external_identifier,
    task.external_url,
    task.project_id,
    task.viewed,
    task.is_valid,
    task.date_fully_transcribed,
    task.date_fully_validated,
    task.date_last_updated,
    task.last_viewed,
    task.last_viewed_by,
    task.fully_transcribed_ip_address,
    task.transcribeduuid,
    task.validateduuid,
    task.time_to_transcribe,
    task.time_to_validate,
    volunteers.max_date,
    volunteers.fully_transcribed_by
   FROM task,
    transcription,
    ( SELECT latest_transcribers.project_id,
            latest_transcribers.fully_transcribed_by,
            latest_transcribers.max_date
           FROM latest_transcribers
         LIMIT 10) volunteers
  WHERE transcription.fully_transcribed_by::text = volunteers.fully_transcribed_by::text AND task.project_id = volunteers.project_id AND task.id = transcription.task_id
  ORDER BY volunteers.max_date DESC;

  CREATE OR REPLACE VIEW public.latest_transcribers_task_multimedia AS 
 SELECT multimedia.id,
    multimedia.created,
    multimedia.creator,
    multimedia.file_path,
    multimedia.file_path_to_thumbnail,
    multimedia.licence,
    multimedia.mime_type,
    multimedia.task_id,
    latest_transcribers_task.id AS latest_transcribers_task_id
   FROM multimedia,
    latest_transcribers_task
  WHERE multimedia.task_id = latest_transcribers_task.task_id;