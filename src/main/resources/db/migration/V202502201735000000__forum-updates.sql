/*
    Forum updates
    - Adding topic_type (Question, announcement, discussion) and is_answered to forum topic
    - Adding is_answer to forum message
    By: Chris Dunstall
*/

alter table forum_topic
    add column if not exists topic_type integer null,
    add column if not exists is_answered boolean null
;

comment on column forum_topic.topic_type is 'Enum denoting the topic type (Question, Discussion or Announcement)';
comment on column forum_topic.is_answered is 'Boolean to mark whether the topic question has been answered (only for Question types)';

create index if not exists forum_topic_topic_type_idx on forum_topic (topic_type);
create index if not exists forum_topic_is_answered_idx on forum_topic (is_answered);

alter table forum_message
    add column if not exists is_answer boolean null
;

comment on column forum_message.is_answer is 'Boolean to mark whether this message is the topic answer';

-- Fill in new columns to migrate topics to new types
-- Task topics are set to Questions (topic type 0)
update forum_topic set topic_type = 0, is_answered = false
where forum_topic.class = 'au.org.ala.volunteer.TaskForumTopic'
and forum_topic.topic_type is null
;

-- Update question topics to answered if they have any replies (assumption)
update forum_topic set is_answered = true
from (
    select forum_topic.id, count(forum_message.id) as replies
    from forum_topic
    join forum_message on (forum_topic.id = forum_message.topic_id and forum_message.reply_to_id is not null)
    where class = 'au.org.ala.volunteer.TaskForumTopic'
    group by forum_topic.id
     ) as sq
where forum_topic.id = sq.id
;

-- Project topics are set to Announcements (topic type 2)
update forum_topic set topic_type = 2, is_answered = false
where forum_topic.class = 'au.org.ala.volunteer.ProjectForumTopic'
  and forum_topic.topic_type is null
;

-- Site/General topics are set to Discussion (topic type 1)
update forum_topic set topic_type = 1, is_answered = false
where forum_topic.class = 'au.org.ala.volunteer.SiteForumTopic'
  and forum_topic.topic_type is null
;

-- Change site topics to announcement if they had a high priority
UPDATE forum_topic SET topic_type = 2
FROM (
    SELECT forum_topic.id
    FROM forum_topic
    WHERE topic_type = 1
    AND priority > 0
) AS sq
WHERE forum_topic.id = sq.id
;