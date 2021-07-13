
ALTER TABLE institution ADD COLUMN if NOT exists is_inactive boolean NOT NULL default FALSE;