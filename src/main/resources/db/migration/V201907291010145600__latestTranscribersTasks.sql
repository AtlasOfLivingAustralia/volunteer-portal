
CREATE OR REPLACE VIEW public.latest_transcribers_task AS
 SELECT transcription.id,
    task.id AS task_id,
    task.created,
    task.external_identifier,
    task.external_url,
    task.project_id,
    task.viewed,
    task.is_valid,
    transcription.date_fully_transcribed,
    task.date_fully_validated,
    task.date_last_updated,
    task.last_viewed,
    task.last_viewed_by,
    transcription.fully_transcribed_ip_address,
    transcription.transcribeduuid,
    task.validateduuid,
    transcription.time_to_transcribe,
    task.time_to_validate,
    volunteers.max_date,
    volunteers.fully_transcribed_by
   FROM task,
    transcription,
    ( SELECT latest_transcribers.project_id,
            latest_transcribers.fully_transcribed_by,
            latest_transcribers.max_date
           FROM latest_transcribers) volunteers
  WHERE transcription.fully_transcribed_by = volunteers.fully_transcribed_by AND task.project_id = volunteers.project_id AND task.id = transcription.task_id
  ORDER BY volunteers.max_date DESC;
