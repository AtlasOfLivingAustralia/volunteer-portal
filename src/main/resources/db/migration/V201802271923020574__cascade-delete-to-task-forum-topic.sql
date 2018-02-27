ALTER TABLE public.forum_topic DROP CONSTRAINT IF EXISTS fkee14a091cbab13a;
ALTER TABLE public.forum_topic
  ADD CONSTRAINT fkee14a091cbab13a
FOREIGN KEY (task_id) REFERENCES task (id) ON DELETE CASCADE;

ALTER TABLE public.forum_topic_notification_message DROP CONSTRAINT IF EXISTS fk1e5043a1ed2a7059;
ALTER TABLE public.forum_topic_notification_message
  ADD CONSTRAINT fk1e5043a1ed2a7059
FOREIGN KEY (topic_id) REFERENCES forum_topic (id) ON DELETE CASCADE;

ALTER TABLE public.forum_topic_notification_message DROP CONSTRAINT IF EXISTS fk1e5043a15f96c37a;
ALTER TABLE public.forum_topic_notification_message
  ADD CONSTRAINT fk1e5043a15f96c37a
FOREIGN KEY (user_id) REFERENCES vp_user (id) ON DELETE CASCADE;

ALTER TABLE public.forum_topic_notification_message DROP CONSTRAINT IF EXISTS fk1e5043a1961b1d99;
ALTER TABLE public.forum_topic_notification_message
  ADD CONSTRAINT fk1e5043a1961b1d99
FOREIGN KEY (message_id) REFERENCES forum_message (id) ON DELETE CASCADE;

ALTER TABLE public.forum_message DROP CONSTRAINT IF EXISTS fk384182e9ed2a7059;
ALTER TABLE public.forum_message
  ADD CONSTRAINT fk384182e9ed2a7059
FOREIGN KEY (topic_id) REFERENCES forum_topic (id) ON DELETE CASCADE;

ALTER TABLE public.user_forum_watch_list_forum_topic DROP CONSTRAINT IF EXISTS fk60309cb2d8a449b7;
ALTER TABLE public.user_forum_watch_list_forum_topic
  ADD CONSTRAINT fk60309cb2d8a449b7
FOREIGN KEY (forum_topic_id) REFERENCES forum_topic (id) ON DELETE CASCADE;