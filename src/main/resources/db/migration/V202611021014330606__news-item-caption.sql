alter table news_item
    add column if not exists image_caption varchar(255);

comment on column news_item.image_caption is 'Caption for the image associated with the news item';