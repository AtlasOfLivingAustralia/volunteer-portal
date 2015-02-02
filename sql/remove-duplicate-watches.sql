-- Removes duplicate entries from the user forum watch list forum topic table.
BEGIN;

CREATE TEMPORARY TABLE t_user_forum_watch_list_forum_topic ON COMMIT DROP AS -- drop temp table at commit
--CREATE TEMPORARY TABLE t_tmp AS  -- retain temp table after commit
SELECT DISTINCT * FROM user_forum_watch_list_forum_topic;  -- DISTINCT folds duplicates

TRUNCATE user_forum_watch_list_forum_topic;

INSERT INTO user_forum_watch_list_forum_topic
SELECT * FROM t_user_forum_watch_list_forum_topic;
-- ORDER BY id; -- optionally "cluster" your data while being at it.

-- SELECT
-- forum_topic_id, user_forum_watch_list_topics_id,
-- ROW_NUMBER() OVER (PARTITION BY forum_topic_id, user_forum_watch_list_topics_id ORDER BY user_forum_watch_list_topics_id) AS intRow
-- FROM user_forum_watch_list_forum_topic t;

COMMIT;