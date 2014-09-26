UPDATE vp_user SET user_id = 'robyn.lawrence@environment.gov.au' WHERE user_id = 'robyn.lawrence@csiro.au';

CREATE FUNCTION update_emails(old varchar, new varchar) RETURNS void AS $$
--DECLARE
BEGIN
  UPDATE task SET last_viewed_by = new WHERE last_viewed_by = old;
  UPDATE task SET fully_transcribed_by = new WHERE fully_transcribed_by = old;
  UPDATE task SET fully_validated_by = new WHERE fully_validated_by = old;
  UPDATE news_item SET created_by = new WHERE created_by = old;
  UPDATE field SET transcribed_by_user_id = new WHERE transcribed_by_user_id = old;
  UPDATE viewed_task SET user_id = new WHERE user_id = old;
  UPDATE template set author = new where author = old;
END
$$ LANGUAGE plpgsql;

SELECT update_emails('robyn.lawrence@csiro.au', 'robyn.lawrence@environment.gov.au'); -- robyn.lawrence@environment.gov.au
SELECT update_emails('Donald.Hobern@csiro.au', 'dhobern@gmail.com'); --  dhobern@gmail.com dhobern@gbif.org

UPDATE vp_user SET transcribed_count = (SELECT COUNT(fully_transcribed_by) FROM task WHERE fully_transcribed_by in ('dhobern@gmail.com', 'Donald.Hobern@csiro.au')) WHERE user_id = 'dhobern@gmail.com';

-- One news item by Paul.Flemons instead of paul.flemons
UPDATE news_item SET created_by = 'paul.flemons@austmus.gov.au' WHERE created_by = 'Paul.Flemons@austmus.gov.au';

-- Template table
UPDATE template SET author = 'Nick.dosRemedios@csiro.au' WHERE author = 'nick.dosremedios@csiro.au';
UPDATE template SET author = 'Nick.dosRemedios@csiro.au' WHERE author = 'webmaster@ala.org.au';

DELETE FROM vp_user WHERE user_id = 'twentyjazzfunkgreats@hotmail.com'; -- Unknown user with no activity
DELETE FROM vp_user WHERE user_id = 'Donald.Hobern@csiro.au'; -- Remove old record because this email no longer exists in ALA

ALTER TABLE vp_user
  ADD COLUMN email CHARACTER VARYING (200) NOT NULL DEFAULT '-1';

UPDATE vp_user set email = user_id;

ALTER TABLE vp_user
    ALTER COLUMN email DROP DEFAULT;

UPDATE vp_user SET email = 'support@ala.org.au' WHERE user_id = 'system';

DROP FUNCTION update_emails(old VARCHAR, new VARCHAR);