-- drop existing column index, creating a unique constraint will create a unique index for the column anyway
DROP INDEX IF EXISTS landing_page_short_url_idx;
ALTER TABLE landing_page
    ALTER COLUMN short_url SET NOT NULL,
    ADD CONSTRAINT langing_page_short_url_unique UNIQUE (short_url);