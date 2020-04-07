DROP INDEX IF EXISTS task_fully_transcribed_by_idx;
CREATE INDEX task_fully_transcribed_by_idx ON task(fully_transcribed_by);
DROP INDEX IF EXISTS task_fully_validated_by_idx;
CREATE INDEX task_fully_validated_by_idx ON task(fully_validated_by);

DROP INDEX IF EXISTS transcription_fully_transcribed_by_idx;
CREATE INDEX transcription_fully_transcribed_by_idx ON transcription(fully_transcribed_by);
DROP INDEX IF EXISTS transcription_fully_validated_by_idx;
CREATE INDEX transcription_fully_validated_by_idx ON transcription(fully_validated_by);