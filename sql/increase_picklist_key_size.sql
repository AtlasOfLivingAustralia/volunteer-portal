UPDATE pg_attribute SET atttypmod = 1024+4
WHERE attrelid = 'picklist_item'::regclass
AND attname = 'key';

INSERT INTO field (id, name, record_idx, superceded, task_id, transcribed_by_user_id, value, created, updated)
  SELECT nextval('hibernate_sequence'), 'sequenceNumber', 0, false, id, 'system', nextval('addseqno')::text, now(), now() FROM task WHERE project_id = 7156530 order by id asc;