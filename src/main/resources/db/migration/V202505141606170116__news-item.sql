/*
    Author: Chris Dunstall

    News Item
*/

CREATE TABLE IF NOT EXISTS news_item (
    id bigint PRIMARY KEY,
    version bigint NOT NULL,
    date_created TIMESTAMP NOT NULL,
    last_updated TIMESTAMP,
    title varchar(60) NOT NULL,
    content text NOT NULL,
    created_by_id bigint NOT NULL,
    updated_by_id bigint,
    is_active boolean NOT NULL,
    date_expires TIMESTAMP NOT NULL,
    topic_id bigint,
    constraint news_item_forum_topic_id_fk foreign key (topic_id) references forum_topic (id)
);

COMMENT ON TABLE news_item IS 'Record table for DigiVol News Items';
COMMENT ON COLUMN news_item.id IS 'Unique ID (primary key) for news_item';
COMMENT ON COLUMN news_item.version IS 'Record version';
COMMENT ON COLUMN news_item.date_created IS 'Datetime record was created';
COMMENT ON COLUMN news_item.last_updated IS 'Datetime record was last updated';
COMMENT ON COLUMN news_item.title IS 'The title of the news item';
COMMENT ON COLUMN news_item.content IS 'The content of the news item';
COMMENT ON COLUMN news_item.created_by_id IS 'ID of the user who created the news item record';
COMMENT ON COLUMN news_item.updated_by_id IS 'ID of the user who last updated the news item record';
COMMENT ON COLUMN news_item.is_active IS 'Boolean flag to indicate whether the news item is active (true) or inactive (false)';
COMMENT ON COLUMN news_item.date_expires IS 'Datetime when the news item expires';
COMMENT ON COLUMN news_item.topic_id IS 'ID of the forum topic associated with the news item';

create index if not exists news_item_idx on news_item using btree (is_active, date_expires, date_created desc);